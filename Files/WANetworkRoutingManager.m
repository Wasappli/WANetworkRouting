//
//  WANetworkRoutingManager.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WANetworkRoutingManager.h"
#import "WANetworkRoutingMacros.h"

#import "WANetworkRouter.h"
#import "WAObjectRequest.h"

@implementation WANetworkRoutingManager

- (instancetype)initWithBaseURL:(NSURL *)baseURL requestManager:(id<WARequestManagerProtocol>)requestManager mappingManager:(id<WAMappingManagerProtocol>)mappingManager authenticationManager:(id<WARequestAuthenticationManagerProtocol>)authenticationManager {
    self = [super init];
    
    if (self) {
        WANRClassParameterAssert(baseURL, NSURL);
        WANRProtocolParameterAssertIfExists(requestManager, WARequestManagerProtocol);
        WANRProtocolParameterAssertIfExists(mappingManager, WAMappingManagerProtocol);
        WANRProtocolParameterAssertIfExists(authenticationManager, WARequestAuthenticationManagerProtocol);
        
        self->_requestManager        = requestManager;
        self->_authenticationManager = authenticationManager;
        self->_mappingManager        = mappingManager;
        self->_router                = [[WANetworkRouter alloc] initWithBaseURL:baseURL];
        self.baseURL                 = baseURL;
    }
    
    return self;
}

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL requestManager:(id<WARequestManagerProtocol>)requestManager mappingManager:(id<WAMappingManagerProtocol>)mappingManager authenticationManager:(id<WARequestAuthenticationManagerProtocol>)authenticationManager {
    return [[self alloc] initWithBaseURL:baseURL requestManager:requestManager mappingManager:mappingManager authenticationManager:authenticationManager];
}

#pragma mark - Public method

- (void)getObjectsAtPath:(NSString *)path parameters:(NSDictionary *)parameters success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    WANRParameterAssert(path);
    WAObjectRequest *request = [self objectRequestForObject:nil
                                                     method:WAObjectRequestMethodGET
                                                       path:path
                                                 parameters:parameters
                                                    success:success
                                                    failure:failure];
    [self enqueueRequest:request];
}

- (void)getObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    NSAssert(object || path, @"Cannot make a request without an object or a path.");
    WAObjectRequest *request = [self objectRequestForObject:object
                                                     method:WAObjectRequestMethodGET
                                                       path:path
                                                 parameters:parameters
                                                    success:success
                                                    failure:failure];
    [self enqueueRequest:request];
}

- (void)postObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    NSAssert(object || path, @"Cannot make a request without an object or a path.");
    WAObjectRequest *request = [self objectRequestForObject:object
                                                     method:WAObjectRequestMethodPOST
                                                       path:path
                                                 parameters:parameters
                                                    success:success
                                                    failure:failure];
    [self enqueueRequest:request];
}

- (void)putObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    NSAssert(object || path, @"Cannot make a request without an object or a path.");
    WAObjectRequest *request = [self objectRequestForObject:object
                                                     method:WAObjectRequestMethodPUT
                                                       path:path
                                                 parameters:parameters
                                                    success:success
                                                    failure:failure];
    [self enqueueRequest:request];
}

- (void)deleteObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    NSAssert(object || path, @"Cannot make a request without an object or a path.");
    WAObjectRequest *request = [self objectRequestForObject:object
                                                     method:WAObjectRequestMethodDELETE
                                                       path:path
                                                 parameters:parameters
                                                    success:success
                                                    failure:failure];
    [self enqueueRequest:request];
}

- (void)headObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    NSAssert(object || path, @"Cannot make a request without an object or a path.");
    WAObjectRequest *request = [self objectRequestForObject:object
                                                     method:WAObjectRequestMethodHEAD
                                                       path:path
                                                 parameters:parameters
                                                    success:success
                                                    failure:failure];
    [self enqueueRequest:request];
}

- (void)patchObject:(id)object path:(NSString *)path parameters:(NSDictionary *)parameters success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    NSAssert(object || path, @"Cannot make a request without an object or a path.");
    WAObjectRequest *request = [self objectRequestForObject:object
                                                     method:WAObjectRequestMethodPATCH
                                                       path:path
                                                 parameters:parameters
                                                    success:success
                                                    failure:failure];
    [self enqueueRequest:request];
}

#pragma mark - Object request

- (WAObjectRequest *)objectRequestForObject:(id)object method:(WAObjectRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    
    if (!path) {
        NSURL *fullURL = [self.router urlForObject:object method:method];
        NSAssert(@"Cannot create a URL from %@ (%@)", object, WAStringFromObjectRequestMethod(method));
        if (!fullURL) {
            return nil;
        }
        path = [fullURL relativeString];
    }
    
    NSDictionary *objectAsParameters = [self.mappingManager mapObject:object
                                                              forPath:path
                                                               method:method];
    NSMutableDictionary *finalParameters = [NSMutableDictionary dictionary];
    
    if (objectAsParameters) {
        [finalParameters addEntriesFromDictionary:objectAsParameters];
    }
    
    if (parameters) {
        for (NSString *key in [parameters allKeys]) {
            NSArray *components = [key componentsSeparatedByString:@"."];
            if ([components count] > 1) {
                components = [components subarrayWithRange:NSMakeRange(0, [components count] - 1)];
                NSMutableDictionary *currentDic = finalParameters;
                for (NSString *component in components) {
                    if (!currentDic[component]) {
                        currentDic[component] = [NSMutableDictionary dictionary];
                    }
                    currentDic = currentDic[component];
                }
            }
            
            [finalParameters setValue:parameters[key] forKeyPath:key];
        }
    }
    
    WAObjectRequest *request = [WAObjectRequest requestWithHTTPMethod:method
                                                                 path:path
                                                           parameters:[finalParameters count] > 0 ? [NSDictionary dictionaryWithDictionary:finalParameters] : nil
                                                      optionalHeaders:self.optionalHeaders];

    [request setCompletionBlocksWithSuccess:success
                                    failure:failure];
    
    request.targetObject = object;
    
    return request;
}

- (void)enqueueRequest:(WAObjectRequest *)request {
    if (!request) {
        return;
    }
    
    wanrWeakify(self)
    [self.requestManager enqueueRequest:request
               authenticateRequestBlock:
     ^NSMutableURLRequest *(NSMutableURLRequest *request) {
         wanrStrongify(self);
         [self.authenticationManager authenticateURLRequest:request];
         return request;
     }
                           successBlock:
     ^(WAObjectRequest *request, WAObjectResponse *response) {
         wanrStrongify(self);
         
         if (self.mappingManager) {
             if ([self.mappingManager canMapRequestResponse:request]) {
                 [self.mappingManager mapResponse:response
                                      fromRequest:request
                                   withCompletion:^(NSArray *mappedObjects) {
                                       if (request.method & WAObjectRequestMethodPOST || request.method & WAObjectRequestMethodDELETE) {
                                           [self.mappingManager deleteObjectFromStore:request.targetObject fromRequest:request];
                                           request.targetObject = nil;
                                       }
                                       request.successBlock(request, response, mappedObjects);
                                   }];
             }
             else {
                 if (request.method & WAObjectRequestMethodDELETE) {
                     [self.mappingManager deleteObjectFromStore:request.targetObject fromRequest:request];
                     request.targetObject = nil;
                 }
                 request.successBlock(request, response, nil);
             }
         }
         else {
             request.successBlock(request, response, nil);
         }
     }
                           failureBlock:
     ^(WAObjectRequest *request, WAObjectResponse *response, id<WANRErrorProtocol> error) {
         wanrStrongify(self);
         
         if ([self.authenticationManager shouldReplayRequest:request response:response error:error]) {
             [self.authenticationManager authenticateAndReplayRequest:request fromNetworkRoutingManager:self];
         }
         else {
             request.failureBlock(request, response, error);
         }
     }];
}

#pragma mark - Setters

- (void)setBaseURL:(NSURL *)baseURL {
    _baseURL = baseURL;
    [self.requestManager setBaseURL:baseURL];
    [self.router setBaseURL:baseURL];
}

@end
