//
//  WABatchCache.h
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WABatchObject;

/**
 *  A persistent cache used to store the offline batch objects enqueued and waiting to be synced to the server
 *  Disclaimer: you have absolutely no reason to use it
 */
@interface WABatchCache : NSObject

/**
 *  Add a batch object to the cache. Will automatically increment the id
 *
 *  @param batchObject a batch object to enqueue
 */
- (void)addBatchObject:(WABatchObject *_Nonnull)batchObject;

/**
 *  Remove objects from cache store
 *
 *  @param batchObjects the objects to remove
 */
- (void)removeBatchObjects:(NSArray <WABatchObject *>*_Nonnull)batchObjects;

/**
 *  Completely drop the database. Also resets the auto increment id
 */
- (void)dropDatabase;

/**
 *  The batch objects on cache
 */
@property (nonatomic, readonly) NSArray *_Nonnull batchObjects;

@end
