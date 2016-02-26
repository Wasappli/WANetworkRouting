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

typedef BOOL (^WARequestDescriptorShouldMapBlock)(NSString *entityName, NSString *relationShip);

@interface WARequestDescriptor : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

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
- (instancetype)initWithMethod:(WAObjectRequestMethod)method
                   pathPattern:(NSString *)pathPattern
                       mapping:(WAEntityMapping *)mapping
                shouldMapBlock:(WARequestDescriptorShouldMapBlock)shouldMapBlock
                requestKeyPath:(NSString *)requestKeyPath;

// @see `initWithMethod: pathPattern: mapping: shouldMapBlock: requestKeyPath:`
+ (instancetype)requestDescriptorWithMethod:(WAObjectRequestMethod)method
                                pathPattern:(NSString *)pathPattern
                                    mapping:(WAEntityMapping *)mapping
                             shouldMapBlock:(WARequestDescriptorShouldMapBlock)shouldMapBlock
                             requestKeyPath:(NSString *)requestKeyPath;

/**
 *  Test if the descriptor match a path and a method
 *
 *  @param path   the path (ex: shelves/1234)
 *  @param method the method(s)
 *
 *  @return YES if the descriptor can be used, NO otherwise
 */
- (BOOL)matchesPath:(NSString *)path method:(WAObjectRequestMethod)method;

@property (nonatomic, assign, readonly) WAObjectRequestMethod             method;
@property (nonatomic, strong, readonly) NSString                          *pathPattern;
@property (nonatomic, strong, readonly) WAEntityMapping                   *mapping;
@property (nonatomic, copy, readonly  ) WARequestDescriptorShouldMapBlock shouldMapBlock;
@property (nonatomic, strong, readonly) NSString                          *requestKeyPath;

@end
