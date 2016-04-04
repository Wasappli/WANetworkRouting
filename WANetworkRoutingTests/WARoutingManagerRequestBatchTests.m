//
//  WARoutingManagerRequestBatchTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 30/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//
#import <Kiwi/Kiwi.h>

#import "WANetworkRoutingManager.h"
#import "WAAFNetworkingRequestManager.h"
#import "WABatchManager.h"
#import "WABatchCache.h"

#import "WANetworkRoute.h"
#import "WAObjectRequest.h"
#import "WAObjectResponse.h"
#import "WANRBasicError.h"
#import "WAURLResponse.h"

SPEC_BEGIN(RoutingManagerRequestBatchTests)

static NSString *kBaseURL = @"http://www.someURL.com";

describe(@"RoutingManagerRequestBatchTests", ^{
    
    __block WANetworkRoutingManager *routingManager = nil;
    
    beforeEach(^{
        // ———————————————————————————————————————————
        // Create the batch manager
        // ———————————————————————————————————————————
        WABatchManager *batchManager = [[WABatchManager alloc] initWithBatchPath:@"/batch" limit:1];
        [batchManager reset];
        
        WANetworkRoute *postEnterprise = [WANetworkRoute routeWithObjectClass:nil
                                                                  pathPattern:@"enterprises"
                                                                       method:WAObjectRequestMethodPOST];
        
        WANetworkRoute *putPatchEnterprise = [WANetworkRoute routeWithObjectClass:nil
                                                                      pathPattern:@"enterprises/:itemID"
                                                                           method:WAObjectRequestMethodPUT|WAObjectRequestMethodPATCH];
        
        [batchManager addRouteToBatchIfOffline:postEnterprise];
        [batchManager addRouteToBatchIfOffline:putPatchEnterprise];
        
        // ———————————————————————————————————————————
        // Create the routing manager
        // ———————————————————————————————————————————
        WAAFNetworkingRequestManager *requestManager = [WAAFNetworkingRequestManager new];
        
        routingManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:kBaseURL]
                                                      requestManager:requestManager
                                                      mappingManager:nil
                                               authenticationManager:nil
                                                        batchManager:batchManager];
        
        // Stub reachability
        [requestManager stub:@selector(isReachable) andReturn:theValue(NO)];
    });
    
    it(@"should batch requests allowed to be batch", ^{
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];
        
        [routingManager postObject:nil
                              path:@"enterprises"
                        parameters:nil
                           success:nil
                           failure:nil];
        
        [routingManager putObject:nil
                             path:@"enterprises/1"
                       parameters:nil
                          success:nil
                          failure:nil];
        
        [routingManager patchObject:nil
                               path:@"enterprises/1"
                         parameters:nil
                            success:nil
                            failure:nil];
        
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@YES];
        [[[[[WABatchCache alloc] init] batchObjects] should] haveCountOf:3];
    });
    
    it(@"should not batch requests not allowed to be batch", ^{
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];
        
        [routingManager postObject:nil
                              path:@"employees"
                        parameters:nil
                           success:nil
                           failure:nil];
        
        [routingManager putObject:nil
                             path:@"employees/1"
                       parameters:nil
                          success:nil
                          failure:nil];
        
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];
        [[[[[WABatchCache alloc] init] batchObjects] should] haveCountOf:0];
    });
    
    it(@"should return an error when the request is batched", ^{
        __block id<WANRErrorProtocol> apiError = nil;
        
        [routingManager postObject:nil
                              path:@"enterprises"
                        parameters:nil
                           success:nil
                           failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                               apiError = error;
                           }];
        
        [[expectFutureValue([apiError originalError].domain) shouldEventually] equal:WANetworkRoutingManagerErrorDomain];
        [[expectFutureValue(theValue([apiError originalError].code)) shouldEventually] equal:theValue(WANetworkRoutingManagerErrorRequestBatched)];
    });
    
    it(@"should not batch requests allowed to be batch if online", ^{
        // Stub reachability
        [(WAAFNetworkingRequestManager *)routingManager.requestManager stub:@selector(isReachable) andReturn:theValue(YES)];
        
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];
        
        [routingManager postObject:nil
                              path:@"enterprises"
                        parameters:nil
                           success:nil
                           failure:nil];
        
        [routingManager putObject:nil
                             path:@"enterprises/1"
                       parameters:nil
                          success:nil
                          failure:nil];
        
        [routingManager patchObject:nil
                               path:@"enterprises/1"
                         parameters:nil
                            success:nil
                            failure:nil];
        
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];
        [[[[[WABatchCache alloc] init] batchObjects] should] haveCountOf:0];
    });
});

SPEC_END
