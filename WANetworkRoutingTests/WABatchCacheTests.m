//
//  WABatchCacheTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "WABatchCache.h"
#import "WABatchObject.h"

SPEC_BEGIN(WABatchCacheTests)

describe(@"Register objects", ^{
    WABatchCache *cache = [[WABatchCache alloc] init];
    [cache dropDatabase];
    
    WABatchObject *batchObject1 = [[WABatchObject alloc] init];
    batchObject1.uri            = @"/authentication";
    batchObject1.method         = @"POST";
    batchObject1.headers        = @{@"header1": @"Test"};
    batchObject1.parameters     = @{@"param1": @1};

    WABatchObject *batchObject2 = [[WABatchObject alloc] init];
    batchObject2.uri            = @"/book";
    batchObject2.method         = @"POST";
    batchObject2.parameters     = @{@"param1": @1};
    
    [cache addBatchObject:batchObject1];
    [cache addBatchObject:batchObject2];
    
    specify(^{
        [[batchObject1.batchID should] equal:@1];
        [[batchObject2.batchID should] equal:@2];
        
        [[[cache batchObjects] should] haveCountOf:2];
    });
    
    specify(^{
        [cache removeBatchObjects:@[batchObject1, batchObject2]];
        [[[cache batchObjects] should] haveCountOf:0];
        
        WABatchObject *batchObject3 = [[WABatchObject alloc] init];
        batchObject3.uri            = @"/book";
        batchObject3.method         = @"POST";
        batchObject3.headers        = @{@"header1": @"Test"};
        batchObject3.parameters     = @{@"param1": @1};
        
        [cache addBatchObject:batchObject3];
        [[batchObject3.batchID should] equal:@3];

        [[[cache batchObjects] should] haveCountOf:1];
    });
    
    specify(^{
        [cache dropDatabase];
        [[[cache batchObjects] should] haveCountOf:0];
        
        WABatchObject *batchObject4 = [[WABatchObject alloc] init];
        batchObject4.uri            = @"/book";
        batchObject4.method         = @"POST";
        batchObject4.headers        = @{@"header1": @"Test"};
        batchObject4.parameters     = @{@"param1": @1};
        
        [cache addBatchObject:batchObject4];
        [[batchObject4.batchID should] equal:@1];
        
        [[[cache batchObjects] should] haveCountOf:1];
    });
    
    specify(^{
        [[[[[WABatchCache alloc] init] batchObjects] should] haveCountOf:1];
    });
});

SPEC_END