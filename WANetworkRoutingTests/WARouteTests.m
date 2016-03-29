//
//  WARouteTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Enterprise.h"

#import "WANetworkRoutingManager.h"
#import "WANetworkRoute.h"
#import "WANetworkRouter.h"

SPEC_BEGIN(WARouteTest)

describe(@"Register a simple route", ^{
    WANetworkRoutingManager *objectManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:@"http://www.someURL.com"] requestManager:nil mappingManager:nil authenticationManager:nil batchManager:nil];
    WANetworkRoute *routeGetAllEnterprises = [WANetworkRoute routeWithObjectClass:[Enterprise class]
                                                                      pathPattern:@"enterprises"
                                                                           method:WAObjectRequestMethodGET];
    [objectManager.router addRoute:routeGetAllEnterprises];
    
    WANetworkRoute *routeGetPutEnterprise = [WANetworkRoute routeWithObjectClass:[Enterprise class]
                                                                     pathPattern:@"enterprises/:itemID"
                                                                          method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT];
    [objectManager.router addRoute:routeGetPutEnterprise];
    
    it(@"should have been added", ^{
        [[theValue([objectManager.router.routes containsObject:routeGetAllEnterprises]) should] equal:theValue(YES)];
    });
    
    it(@"shoud find it by class and method", ^{
        [[[objectManager.router routeForObject:[Enterprise new] method:WAObjectRequestMethodGET] should] equal:routeGetPutEnterprise];
    });
    
    it(@"shoud find them all by class", ^{
        NSArray *allRoutes = [objectManager.router routesForClass:[Enterprise class]];
        [[theValue([allRoutes count]) should] equal:theValue(2)];
        [[theValue([allRoutes containsObject:routeGetAllEnterprises]) should] equal:theValue(YES)];
        [[theValue([allRoutes containsObject:routeGetPutEnterprise]) should] equal:theValue(YES)];
    });
});

SPEC_END
