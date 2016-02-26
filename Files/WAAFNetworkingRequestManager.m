//
//  WAAFNetworkingRequestManager.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAAFNetworkingRequestManager.h"
#import "WAObjectRequest.h"
#import "WAObjectResponse.h"
#import "WAURLResponse.h"

#import "WANRErrorProtocol.h"
#import "WANRBasicError.h"

#import "WANetworkRoutingMacros.h"
#import "WANetworkRoutingUtilities.h"

#import <AFNetworking/AFNetworking.h>

@interface WAAFNetworkingRequestManager ()

@property (nonatomic, strong) AFURLSessionManager *httpManager;

@end

@implementation WAAFNetworkingRequestManager
@synthesize baseURL = _baseURL, errorClass = _errorClass;

- (instancetype)init {
    self = [super init];
    if (self) {
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.responseSerializer   = [AFJSONResponseSerializer serializer];
        self->_httpManager           = manager;
        
        // Set a default error class
        [self setErrorClass:[WANRBasicError class]];
    }
    
    return self;
}

#pragma mark - WARequestManagerProtocol implementation

- (void)setErrorClass:(Class)errorClass {
    WANRProtocolClassAssert(errorClass, WANRErrorProtocol);
    _errorClass = errorClass;
}

- (void)enqueueRequest:(WAObjectRequest *)objectRequest authenticateRequestBlock:(WARequestManagerAuthenticateRequest)authenticateRequestBlock successBlock:(WARequestManagerSuccess)successBlock failureBlock:(WARequestManagerFailure)failureBlock {
    NSError *requestError = nil;
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:WAStringFromObjectRequestMethod(objectRequest.method)
                                                                                 URLString:[[NSURL URLWithString:objectRequest.path relativeToURL:self.baseURL] absoluteString]
                                                                                parameters:objectRequest.parameters
                                                                                     error:&requestError];
    
    if (requestError) {
        id apiError = [[self.errorClass alloc] initWithOriginalError:requestError
                                                            response:nil];
        
        failureBlock(objectRequest, nil, apiError);
        return;
    }
    
    [self addAPIHeadersToRequest:request extraHeaders:objectRequest.headers];
    if (authenticateRequestBlock) {
        request = authenticateRequestBlock(request);
    }
    
    wanrWeakify(self);
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.httpManager dataTaskWithRequest:request
                                   completionHandler:
                ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    wanrStrongify(self);
                    
                    WAURLResponse *urlResponse = [WAURLResponse new];
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        urlResponse.statusCode = [(NSHTTPURLResponse *)response statusCode];
                        urlResponse.httpHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
                    }
                    
                    WAObjectResponse *objectResponse = [WAObjectResponse new];
                    objectResponse.responseObject    = responseObject;
                    objectResponse.urlResponse       = urlResponse;
                    
                    if (error) {
                        id apiError = [[self.errorClass alloc] initWithOriginalError:error
                                                                            response:objectResponse];
                        
                        failureBlock(objectRequest, objectResponse, apiError);
                    } else {
                        successBlock(objectRequest, objectResponse);
                    }
                }];
    
    [dataTask resume];
}

- (void)addAPIHeadersToRequest:(NSMutableURLRequest *)request extraHeaders:(NSDictionary *)extraHeaders {
    NSDictionary *fields = request.allHTTPHeaderFields;
    NSString *contentType = fields[@"Content-Type"];
    
    if ((!contentType) || ([contentType rangeOfString:@"application/json"].location == NSNotFound)) {
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    NSArray *locales = [NSLocale preferredLanguages];
    NSString *tempLang = [locales componentsJoinedByString:@", "];
    [request addValue:tempLang forHTTPHeaderField:@"Accept-Language"];
    
    for (NSString *field in extraHeaders) {
        NSString *value = extraHeaders[field];
        if ([value isKindOfClass:[NSString class]]) {
            [request addValue:value forHTTPHeaderField:field];
        }
    }
}

@end
