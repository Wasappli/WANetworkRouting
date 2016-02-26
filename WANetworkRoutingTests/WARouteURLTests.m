//
//  WARouteURLTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "WANetworkRoutingManager.h"
#import "WANetworkRoute.h"
#import "WANetworkRouter.h"

@interface RouteObjectTest : NSObject
@property (nonatomic, strong) NSNumber *itemID;
@end

@implementation RouteObjectTest

@end

SPEC_BEGIN(WARouteURL)

static NSString *kBaseURL = @"http://www.someURL.com";

describe(@"Get url paths from path pattern and object", ^{
    
    WANetworkRoutingManager *objectManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:kBaseURL] requestManager:nil mappingManager:nil authenticationManager:nil];
    
    WANetworkRoute *routeClassic = [WANetworkRoute routeWithObjectClass:[RouteObjectTest class]
                                                            pathPattern:@"categories/:itemID"
                                                                 method:WAObjectRequestMethodPOST];
    
    WANetworkRoute *routeJSON = [WANetworkRoute routeWithObjectClass:[RouteObjectTest class]
                                                         pathPattern:@"categories/:itemID\\.json"
                                                              method:WAObjectRequestMethodGET];
    
    WANetworkRoute *routeKeyPath = [WANetworkRoute routeWithObjectClass:[RouteObjectTest class]
                                                            pathPattern:@"categories/:itemID/update"
                                                                 method:WAObjectRequestMethodPUT];
    
    [objectManager.router addRoute:routeClassic];
    [objectManager.router addRoute:routeJSON];
    [objectManager.router addRoute:routeKeyPath];
    
    RouteObjectTest *category = [RouteObjectTest new];
    category.itemID = @(1234);
    
    it(@"Classic route should work", ^{
        NSURL *expectedURL = [NSURL URLWithString:@"categories/1234" relativeToURL:[NSURL URLWithString:kBaseURL]];
        NSURL *createdURL = [objectManager.router urlForObject:category method:WAObjectRequestMethodPOST];
        
        [[expectedURL should] equal:createdURL];
    });
    
    it(@"JSON route should work", ^{
        NSURL *expectedURL = [NSURL URLWithString:@"categories/1234.json" relativeToURL:[NSURL URLWithString:kBaseURL]];
        NSURL *createdURL = [objectManager.router urlForObject:category method:WAObjectRequestMethodGET];
        
        [[expectedURL should] equal:createdURL];
    });
    
    it(@"Key path route should work", ^{
        NSURL *expectedURL = [NSURL URLWithString:@"categories/1234/update" relativeToURL:[NSURL URLWithString:kBaseURL]];
        NSURL *createdURL = [objectManager.router urlForObject:category method:WAObjectRequestMethodPUT];
        
        [[expectedURL should] equal:createdURL];
    });
    
});

SPEC_END
