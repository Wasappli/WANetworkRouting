//
//  WAObjectRequestTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "WANetworkRoutingManager.h"
#import "WANetworkRoute.h"
#import "WANetworkRouter.h"
#import "Enterprise.h"
#import "WAObjectRequest.h"


@interface WANetworkRoutingManager (exposeCreateRequest)
- (WAObjectRequest *)objectRequestForObject:(id)object method:(WAObjectRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters progress:(WAObjectRequestProgressBlock)progress success:(WAObjectRequestSuccessCompletionBlock)success failure:(WAObjectRequestFailureCompletionBlock)failure;
@end

@interface ObjectRequestTest : NSObject
@property (nonatomic, strong) NSNumber *itemID;
@end

@implementation ObjectRequestTest

@end

SPEC_BEGIN(ObjectRequest)

static NSString *kBaseURLSimple = @"http://www.someURL.com";
static NSString *kBaseURLWithPaths = @"http://www.someURL.com/api/v2";

describe(@"Create request with simple URL", ^{
    WANetworkRoutingManager *objectManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:kBaseURLSimple] requestManager:nil mappingManager:nil authenticationManager:nil batchManager:nil];
    
    WANetworkRoute *routeClassic = [WANetworkRoute routeWithObjectClass:[ObjectRequestTest class]
                                                            pathPattern:@"categories/:itemID"
                                                                 method:WAObjectRequestMethodGET];
    
    
    [objectManager.router addRoute:routeClassic];
    
    ObjectRequestTest *object = [ObjectRequestTest new];
    object.itemID = @(1234);
    
    NSString *path = @"categories/1234";
    
    it(@"GET shoud comply with object", ^{
        WAObjectRequest *request = [objectManager objectRequestForObject:object
                                                                  method:WAObjectRequestMethodGET
                                                                    path:nil
                                                              parameters:nil
                                                                progress:nil
                                                                 success:nil
                                                                 failure:nil];
        
        [[request.path should] equal:path];
        [[theValue(request.method) should] equal:theValue(WAObjectRequestMethodGET)];
    });
    
    it(@"GET shoud comply with object", ^{
        WAObjectRequest *request = [objectManager objectRequestForObject:nil
                                                                  method:WAObjectRequestMethodGET
                                                                    path:path
                                                              parameters:nil
                                                                progress:nil
                                                                 success:nil
                                                                 failure:nil];
        
        [[request.path should] equal:path];
        [[theValue(request.method) should] equal:theValue(WAObjectRequestMethodGET)];
    });
});

describe(@"Create request with URL subpaths", ^{
    
    WANetworkRoutingManager *objectManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:kBaseURLWithPaths] requestManager:nil mappingManager:nil authenticationManager:nil batchManager:nil];
    
    WANetworkRoute *routeClassic = [WANetworkRoute routeWithObjectClass:[ObjectRequestTest class]
                                                            pathPattern:@"categories/:itemID"
                                                                 method:WAObjectRequestMethodGET];
    
    
    [objectManager.router addRoute:routeClassic];
    
    ObjectRequestTest *object = [ObjectRequestTest new];
    object.itemID = @(1234);
    
    NSString *path = @"categories/1234";
    
    it(@"GET shoud comply with object", ^{
        WAObjectRequest *request = [objectManager objectRequestForObject:object
                                                                  method:WAObjectRequestMethodGET
                                                                    path:nil
                                                              parameters:nil
                                                                progress:nil
                                                                 success:nil
                                                                 failure:nil];
        
        [[request.path should] equal:path];
        [[theValue(request.method) should] equal:theValue(WAObjectRequestMethodGET)];
    });
    
    it(@"GET shoud comply with object", ^{
        WAObjectRequest *request = [objectManager objectRequestForObject:nil
                                                                  method:WAObjectRequestMethodGET
                                                                    path:path
                                                              parameters:nil
                                                                progress:nil
                                                                 success:nil
                                                                 failure:nil];
        
        [[request.path should] equal:path];
        [[theValue(request.method) should] equal:theValue(WAObjectRequestMethodGET)];
    });
});

SPEC_END
