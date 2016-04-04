//
//  WABatchManagerTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "WABatchCache.h"
#import "WABatchObject.h"
#import "WAObjectRequest.h"
#import "WANetworkRoute.h"

#import "WABatchManager.h"

SPEC_BEGIN(WABatchManagerTests)

describe(@"Needs flushing", ^{
    WABatchCache *cache = [[WABatchCache alloc] init];
    [cache dropDatabase];
    
    WABatchObject *batchObject = [[WABatchObject alloc] init];
    batchObject.uri            = @"/authentication";
    batchObject.method         = @"POST";
    batchObject.headers        = @{@"header1": @"Test"};
    batchObject.parameters     = @{@"param1": @1};
    
    [cache addBatchObject:batchObject];
    
    specify(^{
        WABatchManager *batchManager = [[WABatchManager alloc] initWithBatchPath:@"/batch" limit:1];
        [[theValue([batchManager needsFlushing]) should] equal:@YES];
    });
    
    specify(^{
        [cache dropDatabase];
        WABatchManager *batchManager = [[WABatchManager alloc] initWithBatchPath:@"/batch" limit:1];
        [[theValue([batchManager needsFlushing]) should] equal:@NO];
    });
});

describe(@"Can enqueue offline", ^{
    WABatchManager *batchManager = [[WABatchManager alloc] initWithBatchPath:@"/batch" limit:1];
    WAObjectRequest *notEnqueuableRequest = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodGET
                                                                              path:@"/authentication"
                                                                        parameters:nil
                                                                   optionalHeaders:nil];
    
    WAObjectRequest *notEnqueuableRequest2 = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodGET
                                                                               path:@"/books"
                                                                         parameters:nil
                                                                    optionalHeaders:nil];
    
    WAObjectRequest *notEnqueuableRequest3 = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodPUT
                                                                               path:@"/authors/1"
                                                                         parameters:nil
                                                                    optionalHeaders:nil];
    
    WAObjectRequest *enqueuableRequest1 = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodPOST
                                                                            path:@"/books"
                                                                      parameters:nil
                                                                 optionalHeaders:nil];
    
    WAObjectRequest *enqueuableRequest2 = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodPUT
                                                                            path:@"/books/1"
                                                                      parameters:nil
                                                                 optionalHeaders:nil];
    
    WANetworkRoute *postRoute = [WANetworkRoute routeWithObjectClass:nil
                                                         pathPattern:@"/books"
                                                              method:WAObjectRequestMethodPOST];
    
    WANetworkRoute *putRoute = [WANetworkRoute routeWithObjectClass:nil
                                                        pathPattern:@"/books/1"
                                                             method:WAObjectRequestMethodPUT];
    
    [batchManager addRouteToBatchIfOffline:postRoute];
    [batchManager addRouteToBatchIfOffline:putRoute];
    
    specify(^{
        [[theValue([batchManager canEnqueueOfflineRequest:notEnqueuableRequest]) should] equal:@NO];
    });
    
    specify(^{
        [[theValue([batchManager canEnqueueOfflineRequest:enqueuableRequest1]) should] equal:@YES];
        [[theValue([batchManager canEnqueueOfflineRequest:enqueuableRequest2]) should] equal:@YES];
        [[theValue([batchManager canEnqueueOfflineRequest:notEnqueuableRequest2]) should] equal:@NO];
        [[theValue([batchManager canEnqueueOfflineRequest:notEnqueuableRequest3]) should] equal:@NO];
    });
});

SPEC_END
