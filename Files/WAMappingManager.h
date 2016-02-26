//
//  WAMappingManager.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WAMappingManagerProtocol.h"

@class WAResponseDescriptor, WARequestDescriptor;
@class WAMapper, WAReverseMapper;

@interface WAMappingManager : NSObject <WAMappingManagerProtocol>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithMapper:(WAMapper *)mapper reverseMapper:(WAReverseMapper *)reverseMapper NS_DESIGNATED_INITIALIZER;
+ (instancetype)mappingManagerWithMapper:(WAMapper *)mapper reverseMapper:(WAReverseMapper *)reverseMapper;

/**
 *  Add a new response descriptor
 *
 *  @param responseDescriptor a response descriptor
 */
- (void)addResponseDescriptor:(WAResponseDescriptor *)responseDescriptor;

/**
 *  Add a new request descriptor
 *
 *  @param requestDescriptor a request descriptor
 */
- (void)addRequestDescriptor:(WARequestDescriptor *)requestDescriptor;

@property (nonatomic, strong, readonly) NSArray<WAResponseDescriptor *> *responseDescriptors;
@property (nonatomic, strong, readonly) NSArray<WARequestDescriptor*> *requestDescriptors;

@end
