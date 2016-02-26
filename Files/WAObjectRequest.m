//
//  WAObjectRequest.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAObjectRequest.h"
#import "WANetworkRoutingMacros.h"

@interface WAObjectRequest ()

@property (nonatomic, assign) WAObjectRequestMethod                 method;
@property (nonatomic, strong) NSString                              *path;
@property (nonatomic, strong) NSDictionary                          *parameters;
@property (nonatomic, strong) NSDictionary                          *headers;
@property (nonatomic, copy  ) WAObjectRequestSuccessCompletionBlock successBlock;
@property (nonatomic, copy  ) WAObjectRequestFailureCompletionBlock failureBlock;


@end

@implementation WAObjectRequest

+ (instancetype)requestWithHTTPMethod:(WAObjectRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters optionalHeaders:(NSDictionary *)headers {
    WANRClassParameterAssert(path, NSString);
    WANRClassParameterAssertIfExists(parameters, NSDictionary);
    WANRClassParameterAssertIfExists(headers, NSDictionary);
    
    WAObjectRequest *request = [[self class] new];
    request.method           = method;
    request.path             = path;
    request.parameters       = parameters;
    request.headers          = headers;
    
    return request;
}

- (void)setCompletionBlocksWithSuccess:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - method=(%@) path=%@ parameters=%@ headers=%@", [super description], WAStringFromObjectRequestMethod(self.method), self.path, self.parameters, self.headers];
}

@end
