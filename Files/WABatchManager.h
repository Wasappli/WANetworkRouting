//
//  WABatchManager.h
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WABatchManagerProtocol.h"

@class WANetworkRoute;

/**
 A default implementation for `WABatchManagerProtocol`. See the README for the server specifications.
 */
@interface WABatchManager : NSObject <WABatchManagerProtocol>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Add a route describing the request which can be enqueued
 *
 *  @param route the route allowed to be automatically batched if offline
 */
- (void)addRouteToBatchIfOffline:(WANetworkRoute *)route;

@end
