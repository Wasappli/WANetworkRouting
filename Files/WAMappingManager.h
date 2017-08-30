//
//  WAMappingManager.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WAMappingManagerProtocol.h"
#import <WAMapping/WAStoreProtocol.h>

@class WAResponseDescriptor, WARequestDescriptor;

@interface WAMappingManager : NSObject <WAMappingManagerProtocol>

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 *  Init the mapping manager with a store
 *
 *  @param store the store to use: memory, CoreData, NSCoding, ...
 *
 *  @return a fresh mapping manager
 */
- (instancetype _Nonnull)initWithStore:(_Nonnull id <WAStoreProtocol>)store NS_DESIGNATED_INITIALIZER;

/**
 *  Create mapping manager with a store
 *
 *  @param store the store to use: memory, CoreData, NSCoding, ...
 *
 *  @return a fresh mapping manager
 */
+ (instancetype _Nonnull)mappingManagerWithStore:(_Nonnull id <WAStoreProtocol>)store;

/**
 *  Add a new response descriptor
 *
 *  @param responseDescriptor a response descriptor
 */
- (void)addResponseDescriptor:(WAResponseDescriptor *_Nonnull)responseDescriptor;

/**
 *  Add a new request descriptor
 *
 *  @param requestDescriptor a request descriptor
 */
- (void)addRequestDescriptor:(WARequestDescriptor *_Nonnull)requestDescriptor;

@property (nonatomic, strong, readonly) NSArray<WAResponseDescriptor *> *_Nonnull responseDescriptors;
@property (nonatomic, strong, readonly) NSArray<WARequestDescriptor*> *_Nonnull requestDescriptors;

@end
