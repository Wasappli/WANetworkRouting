//
//  WARequestDescriptor.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WANetworkRoutingUtilities.h"

@class WAEntityMapping;

typedef BOOL (^WARequestDescriptorShouldMapBlock)(NSString *_Nonnull entityName, NSString *_Nonnull relationShip);

@interface WARequestDescriptor : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 *  Create a request descriptor to map the objects to dictionary on request
 *
 *  @param method         the method(s) for which the descriptor apply
 *  @param pathPattern    the path pattern for which the descriptor apply (ex: shelves/:itemId)
 *  @param mapping        the mapping of the object
 *  @param shouldMapBlock a block for mapping hierarchy more precisely. Pass nil if you want to map everything
 *  @param requestKeyPath the final key path under which the created dictionary should be set
 *
 *  @return a request descriptor to use on mapping manager
 */
- (instancetype _Nonnull)initWithMethod:(WAObjectRequestMethod)method
                            pathPattern:(NSString *_Nonnull)pathPattern
                                mapping:(WAEntityMapping *_Nonnull)mapping
                         shouldMapBlock:(_Nullable WARequestDescriptorShouldMapBlock)shouldMapBlock
                         requestKeyPath:(NSString *_Nullable)requestKeyPath;

// @see `initWithMethod: pathPattern: mapping: shouldMapBlock: requestKeyPath:`
+ (instancetype _Nonnull)requestDescriptorWithMethod:(WAObjectRequestMethod)method
                                         pathPattern:(NSString *_Nonnull)pathPattern
                                             mapping:(WAEntityMapping *_Nonnull)mapping
                                      shouldMapBlock:(_Nullable WARequestDescriptorShouldMapBlock)shouldMapBlock
                                      requestKeyPath:(NSString *_Nullable)requestKeyPath;

/**
 *  Test if the descriptor match a path and a method
 *
 *  @param path   the path (ex: shelves/1234)
 *  @param method the method(s)
 *
 *  @return YES if the descriptor can be used, NO otherwise
 */
- (BOOL)matchesPath:(NSString *_Nonnull)path method:(WAObjectRequestMethod)method;

@property (nonatomic, assign, readonly) WAObjectRequestMethod             method;
@property (nonatomic, strong, readonly) NSString                          *_Nonnull pathPattern;
@property (nonatomic, strong, readonly) WAEntityMapping                   *_Nonnull mapping;
@property (nonatomic, copy, readonly  ) WARequestDescriptorShouldMapBlock _Nullable shouldMapBlock;
@property (nonatomic, strong, readonly) NSString                          *_Nullable requestKeyPath;

@end
