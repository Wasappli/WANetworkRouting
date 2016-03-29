//
//  WABatchSession.h
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAObjectRequest, WABatchObject;

/**
 *  A batch session is an object you create if you want to send multiple calls grouped in a single one.
 *  For example, you could have a `GET me`, a `GET meetings`, a `GET configuration` after a signin.
 */
@interface WABatchSession : NSObject

/**
 *  Add a request to the batch. Please note that the order does matter. See `WAObjectRequest` init method to create a request.
 *  The request will automatically be converted to a `WABatchObject`
 *
 *  @param objectRequest the request to enqueue in the session
 */
- (void)addRequest:(WAObjectRequest *)objectRequest;

/**
 *  Same as adding a request, but you add a batch object instead. You have no reason to use this method. It is internally used in `WABatchManager` implementation.
 *
 *  @param batchObject the batch objct to enqueue in the session
 */
- (void)addBatchObject:(WABatchObject *)batchObject;

/**
 *  An array of batch objects enqueued
 */
@property (nonatomic, readonly) NSArray<WABatchObject *> *batchObjects;

@end
