//
//  WARouteEqualityTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "WANetworkRoutingManager.h"
#import "WAAFNetworkingRequestManager.h"
#import "WANetworkRoute.h"
#import "WANetworkRouter.h"
#import "Enterprise.h"

SPEC_BEGIN(WARouteEquality)

describe(@"Create two routes with the same parameters", ^{
        
    WANetworkRoutingManager *objectManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:@"http://www.someURL.com"] requestManager:[[WAAFNetworkingRequestManager alloc] init] mappingManager:nil authenticationManager:nil batchManager:nil];
    
    WANetworkRoute *route1 = [WANetworkRoute routeWithObjectClass:[Enterprise class]
                                                      pathPattern:@"enterprises"
                                                           method:WAObjectRequestMethodGET];
    
    WANetworkRoute *routeEqualTo1 = [WANetworkRoute routeWithObjectClass:[Enterprise class]
                                                             pathPattern:@"enterprises"
                                                                  method:WAObjectRequestMethodGET];
    
    WANetworkRoute *routeNotEqualTo1 = [WANetworkRoute routeWithObjectClass:[Enterprise class]
                                                                pathPattern:@"enterprise"
                                                                     method:WAObjectRequestMethodGET];
    
    [objectManager.router addRoute:route1];
    
    it(@"1 and 1 should be equals", ^{
        [[route1 should] equal:route1];
    });
    
    it(@"1 and equalTo1 should be equals", ^{
        [[route1 should] equal:routeEqualTo1];
    });
    
    it(@"1 and notEqualTo1 should not be equals", ^{
        [[route1 shouldNot] equal:routeNotEqualTo1];
    });
    
    it(@"You cannot add twice the same route", ^{
        [[theBlock(^{
            [objectManager.router addRoute:route1];
        }) should] raise];
    });
    
    it(@"You cannot add the same route if there are equals", ^{
        [[theBlock(^{
            [objectManager.router addRoute:routeEqualTo1];
        }) should] raise];
    });
    
    WANetworkRoute *singleObjectGetRoute = [WANetworkRoute routeWithObjectClass:[Enterprise class]
                                                                    pathPattern:@"enterprise/:itemID"
                                                                         method:WAObjectRequestMethodGET];
    
    it(@"You can add two routes with the same method and class", ^{
        [[theBlock(^{
            [objectManager.router addRoute:singleObjectGetRoute];
        }) shouldNot] raise];
    });
});

describe(@"Create two routes with the same parameters but no class", ^{
    
    WANetworkRoute *route1 = [WANetworkRoute routeWithObjectClass:nil
                                                      pathPattern:@"enterprises"
                                                           method:WAObjectRequestMethodGET];
    
    WANetworkRoute *routeEqualTo1 = [WANetworkRoute routeWithObjectClass:nil
                                                             pathPattern:@"enterprises"
                                                                  method:WAObjectRequestMethodGET];
    
    WANetworkRoute *routeNotEqualTo1 = [WANetworkRoute routeWithObjectClass:nil
                                                                pathPattern:@"enterprise"
                                                                     method:WAObjectRequestMethodGET];
    
    it(@"1 and 1 should be equals", ^{
        [[route1 should] equal:route1];
    });
    
    it(@"1 and equalTo1 should be equals", ^{
        [[route1 should] equal:routeEqualTo1];
    });
    
    it(@"1 and notEqualTo1 should not be equals", ^{
        [[route1 shouldNot] equal:routeNotEqualTo1];
    });
});


SPEC_END
