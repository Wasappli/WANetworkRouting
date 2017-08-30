//
//  WAMappingManagerProtocol.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WANetworkRoutingUtilities.h"

@class WAObjectRequest, WAObjectResponse;

typedef void (^WAMappingManagerMappingCompletion)(NSArray *_Nullable mappedObjects, NSError *_Nullable error);
typedef _Nullable id (^WAMappingManagerMappingBlock)(id _Nonnull value);

@protocol WAMappingManagerProtocol <NSObject>

/**
 *  Return the status of ability to map a request response
 *
 *  @param request the request
 *
 *  @return YES if there is at least one response descriptor
 */
- (BOOL)canMapRequestResponse:(WAObjectRequest *_Nonnull)request;

/**
 *  Map the response to managed objects using responses descriptors registered (there can be many)
 *
 *  @param response   the response from server with raw data
 *  @param request    the original request
 *  @param completion a block with an array of all mapped objects no matter the hierarchy
 */
- (void)mapResponse:(WAObjectResponse *_Nonnull)response fromRequest:(WAObjectRequest *_Nonnull)request withCompletion:(_Nonnull WAMappingManagerMappingCompletion)completion;

/**
 *  Map an object to dictionary for the request
 *
 *  @param object the object to map
 *  @param path   the path (used to retrieve the request descriptor)
 *  @param method the method (also used to retrieve the request descriptor)
 *
 *  @return a dictionary mapped with object properties from original mapping
 */
- (NSDictionary *_Nullable)mapObject:(_Nullable id)object forPath:(NSString *_Nullable)path method:(WAObjectRequestMethod)method;

/**
 *  Delete an object from store. This usually comes from a DELETE operation
 *
 *  @param object the object to delete
 */
- (void)deleteObjectFromStore:(_Nonnull id)object fromRequest:(WAObjectRequest *_Nonnull)request;

/**
 *  Add a default mapping block for a class. For example, you could have an API returning dates all with the same format. You can register the transformation once here.
 *
 *  @param mappingBlock     the mapping block called to transform the value
 *  @param destinationClass the destination class
 */
- (void)addDefaultMappingBlock:(_Nonnull WAMappingManagerMappingBlock)mappingBlock forDestinationClass:(_Nonnull Class)destinationClass;

/**
 *  Add a reverse default mapping block for a class. For example, you could have an API returning dates all with the same format. You can register the transformation once here.
 *
 *  @param reverseMappingBlock the reverse mapping block called to transform the value
 *  @param destinationClass    the destination class
 */
- (void)addReverseDefaultMappingBlock:(_Nonnull WAMappingManagerMappingBlock)reverseMappingBlock forDestinationClass:(_Nonnull Class)destinationClass;

@end
