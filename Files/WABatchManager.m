//
//  WABatchManager.m
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WABatchManager.h"

#import "WABatchCache.h"
#import "WABatchObject.h"
#import "WABatchSession.h"
#import "WAObjectRequest.h"
#import "WAObjectResponse.h"
#import "WAURLResponse.h"
#import "WABatchResponse.h"
#import "WANRErrorProtocol.h"

#import "WANetworkRoute.h"
#import "WANetworkRoutePattern.h"

#import "WANetworkRoutingMacros.h"

@interface WABatchManager ()

@property (nonatomic, strong) WABatchCache *cache;
@property (nonatomic, strong) NSMutableSet<WANetworkRoute *> *offlineRoutes;
@property (nonatomic, strong) NSString *batchPath;
@property (nonatomic, assign) NSUInteger batchLimit;

@property (nonatomic, assign, getter=isFlushing) BOOL flushing;

@end

@implementation WABatchManager
@synthesize delegate = _delegate;
@synthesize offlineFlushFailureBlock = _offlineFlushFailureBlock;
@synthesize offlineFlushSuccessBlock = _offlineFlushSuccessBlock;

- (instancetype)initWithBatchPath:(NSString *)batchPath limit:(NSUInteger)limit {
    WANRClassParameterAssert(batchPath, NSString);
    WANRParameterAssert(limit > 0);
    
    self = [super init];
    
    if (self) {
        self->_cache         = [[WABatchCache alloc] init];
        self->_offlineRoutes = [NSMutableSet set];
        self->_batchPath     = batchPath;
        self->_batchLimit    = limit;
    }
    
    return self;
}

+ (instancetype)batchManagerWithBatchPath:(NSString *)batchPath limit:(NSUInteger)limit {
    return [[self alloc] initWithBatchPath:batchPath limit:limit];
}

#pragma mark - WABatchManagerProtocol

#pragma mark Offline

- (BOOL)needsFlushing {
    return
    (([[self.cache batchObjects] count] == 0) ? NO : YES)
    &&
    !self.isFlushing;
}

- (void)flushDataWithCompletion:(void (^)(BOOL success))completion {
    
    if (![self needsFlushing]) {
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    NSArray <WABatchObject *> *batchObjects = [self.cache batchObjects];
    if ([batchObjects count] > self.batchLimit) {
        batchObjects = [batchObjects subarrayWithRange:NSMakeRange(0, self.batchLimit)];
    }
    
    WABatchSession *batchSession = [WABatchSession new];
    for (WABatchObject *batchObject in batchObjects) {
        [batchSession addBatchObject:batchObject];
    }
    
    self.flushing = YES;
    
    wanrWeakify(self);
    [self sendBatchSession:batchSession
              successBlock:^(id <WABatchManagerProtocol> batchManager, NSArray<WABatchResponse *> *batchResponses) {
                  wanrStrongify(self);
                  self.flushing = NO;
                  
                  // Remove the batch objects
                  [self.cache removeBatchObjects:batchObjects];
                  
                  // Tell something that we sent a batch session
                  if (self.offlineFlushSuccessBlock) {
                      self.offlineFlushSuccessBlock(batchManager, batchResponses);
                  }
                  
                  // If we still needs flushing, continue
                  if ([self needsFlushing]) {
                      [self flushDataWithCompletion:completion];
                  }
                  else {
                      // We, the flush is a success!
                      if (completion) {
                          completion(YES);
                      }
                  }
              } failureBlock:^(id <WABatchManagerProtocol> batchManager, WAObjectRequest *request, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                  wanrStrongify(self);
                  self.flushing = NO;
                  
                  if (self.offlineFlushFailureBlock) {
                      self.offlineFlushFailureBlock(batchManager, request, response, error);
                  }
                  
                  if (completion) {
                      completion(NO);
                  }
              }];
}

- (BOOL)canEnqueueOfflineRequest:(WAObjectRequest *)request withResponse:(WAObjectResponse *)response error:(id<WANRErrorProtocol>)error {
    __block BOOL matchesRoute = NO;
    
    [self.offlineRoutes enumerateObjectsUsingBlock:^(WANetworkRoute *obj, BOOL * _Nonnull stop) {
        BOOL correctMethod = obj.method & request.method;
        if (correctMethod) {
            BOOL samePath = [obj.pathPattern isEqualToString:request.path];
            if (!samePath && [obj.pathPattern rangeOfString:WANetworkRoutePatternObjectPrefix].location != NSNotFound) {
                WANetworkRoutePattern *pattern = [[WANetworkRoutePattern alloc] initWithPattern:obj.pathPattern];
                samePath = [pattern matchesRoute:request.path];
            }
            
            if (samePath) {
                matchesRoute = YES;
                *stop   = YES;
            }
        }
    }];
    
    BOOL matchesError = NO;
    
    if (!error && !response) {
        matchesError = YES;
    } else {
        // If the server is not responding or in maintenance mode, then enqueue
        if (response.urlResponse.statusCode == 500 || response.urlResponse.statusCode == 503) {
            matchesError = YES;
        }
        
        if ([[[error originalError] domain] isEqualToString:NSURLErrorDomain]) {
            NSInteger code = [[error originalError] code];
            if (code == NSURLErrorNotConnectedToInternet || code == NSURLErrorTimedOut) {
                matchesError = YES;
            }
        }
    }
    
    return matchesRoute && matchesError;
}

- (void)enqueueOfflineRequest:(WAObjectRequest *)request {
    NSAssert([self canEnqueueOfflineRequest:request withResponse:nil error:nil], @"Cannot enqueue %@ for offline batch, define a route to match the pattern", request.path);
    
    [self.cache addBatchObject:[self batchObjectFromRequest:request]];
}

- (void)reset {
    [self.cache dropDatabase];
}

#pragma mark Batch session

- (void)sendBatchSession:(WABatchSession *)session successBlock:(WABatchManagerSuccess)successBlock failureBlock:(WABatchManagerFailure)failureBlock {
    NSAssert(self.delegate, @"Delegate should no be nil, batch request needs to be handled");
    
    // Build the parameters from the session
    NSMutableArray *requestsAsDics = [NSMutableArray array];
    
    for (WABatchObject *batchObject in session.batchObjects) {
        NSMutableDictionary *requestAsDic = [NSMutableDictionary dictionary];
        requestAsDic[@"method"]           = batchObject.method;
        requestAsDic[@"uri"]              = [batchObject.uri hasPrefix:@"/"] ? batchObject.uri : [@"/" stringByAppendingString:batchObject.uri];
        
        if (batchObject.parameters) {
            // Encode it as string
            NSData *dJSON = [NSJSONSerialization dataWithJSONObject:batchObject.parameters
                                                            options:0
                                                              error:nil];
            NSString *json = [[NSString alloc] initWithData:dJSON encoding:NSUTF8StringEncoding];
            requestAsDic[@"body"] = json;
        }
        
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:batchObject.headers];
        headers[@"Content-Type"] = @"application/json";
        requestAsDic[@"headers"] = headers;
        
        [requestsAsDics addObject:requestAsDic];
    }
    
    WAObjectRequest *objectRequest = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodPOST
                                                                       path:self.batchPath
                                                                 parameters:@{@"batch": requestsAsDics}
                                                            optionalHeaders:nil];
    
    wanrWeakify(self);
    [objectRequest setCompletionBlocksWithSuccess:
     ^(WAObjectRequest *objectRequest, WAObjectResponse *fromBatchResponse, NSArray *mappedObjects) {
         wanrStrongify(self);
         
         NSArray *responses = (NSArray *)fromBatchResponse.responseObject;
         NSMutableArray *batchResponses = [NSMutableArray array];
         
         // Go through all responses
         NSUInteger index = 0;
         
         for (NSDictionary *dic in responses) {
             WAObjectResponse *response = [WAObjectResponse new];
             
             NSString *body = dic[@"body"];
             if ([body isEqual:[NSNull null]]) {
                 body = nil;
             }
             
             if (body) {
                 response.responseObject = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding]
                                                                           options:0
                                                                             error:nil];
             }
             
             WAURLResponse *urlResponse   = [WAURLResponse new];
             urlResponse.statusCode       = [dic[@"code"] integerValue];
             urlResponse.httpHeaderFields = dic[@"headers"];
             response.urlResponse         = urlResponse;
             
             WABatchObject *batchObject = session.batchObjects[index];
             WAObjectRequest *request   = [self objectRequestFromBatchObject:batchObject];
             
             WABatchResponse *batchResponse = [WABatchResponse new];
             batchResponse.response         = response;
             batchResponse.request          = request;
             
             [batchResponses addObject:batchResponse];
             index++;
         }
         
         [self.delegate batchManager:self haveBatchResponsesToProcess:[batchResponses copy]];
         
         if (successBlock) {
             successBlock(self, [batchResponses copy]);
         }
     }
                                          failure:
     ^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
         if (failureBlock) {
             failureBlock(self, objectRequest, response, error);
         }
     }];
    
    [self.delegate batchManager:self haveBatchRequestToEnqueue:objectRequest];
}
#pragma mark - Helpers

- (WABatchObject *)batchObjectFromRequest:(WAObjectRequest *)request {
    WABatchObject *batchObject = [WABatchObject new];
    batchObject.parameters     = request.parameters;
    batchObject.headers        = request.headers;
    batchObject.uri            = request.path;
    batchObject.method         = WAStringFromObjectRequestMethod(request.method);
    
    return batchObject;
}

- (WAObjectRequest *)objectRequestFromBatchObject:(WABatchObject *)batchObject {
    WAObjectRequest *request = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodFromString(batchObject.method)
                                                                 path:batchObject.uri
                                                           parameters:batchObject.parameters
                                                      optionalHeaders:batchObject.parameters];
    return request;
}

#pragma mark - Public methods

- (void)addRouteToBatchIfOffline:(WANetworkRoute *)route {
    WANRClassParameterAssert(route, WANetworkRoute);
    
    NSAssert(![self.offlineRoutes containsObject:route], @"You cannot add twice the same route");
    
    [self.offlineRoutes addObject:route];
}

@end
