//
//  WAResponseDescriptor.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WANetworkRoutingUtilities.h"

@class WAEntityMapping, WAObjectRequest;

@interface WAResponseDescriptor : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 *  Create a response descriptor to map a dictionary (on the response) to objects
 *
 *  @param mapping     the mapping to use
 *  @param method      the method(s) for which the descriptor applies
 *  @param pathPattern the path pattern of the method (ex: shelves/:itemId)
 *  @param keyPath     the key path on the response (ex: shelf for shelf:{someProperties})
 *
 *  @return A response descriptor to give to mapping manager
 */
- (instancetype _Nonnull)initWithMapping:(WAEntityMapping *_Nonnull)mapping
                                  method:(WAObjectRequestMethod)method
                             pathPattern:(NSString *_Nonnull)pathPattern
                                 keyPath:(NSString *_Nullable)keyPath NS_DESIGNATED_INITIALIZER;

// @see `initWithMapping: method: pathPattern: keyPath:`
+ (instancetype _Nonnull)responseDescriptorWithMapping:(WAEntityMapping *_Nonnull)mapping
                                                method:(WAObjectRequestMethod)method
                                           pathPattern:(NSString *_Nonnull)pathPattern
                                               keyPath:(NSString *_Nullable)keyPath;

/**
 *  Test if the response descriptor would match a request
 *
 *  @param objectRequest the request to match against
 *
 *  @return YES if the descriptor can be used on the provided request, NO otherwise
 */
- (BOOL)matchesObjectRequest:(WAObjectRequest *_Nonnull)objectRequest;

@property (nonatomic, strong, readonly) WAEntityMapping       *_Nonnull mapping;
@property (nonatomic, assign, readonly) WAObjectRequestMethod method;
@property (nonatomic, strong, readonly) NSString              *_Nonnull pathPattern;
@property (nonatomic, strong, readonly) NSString              *_Nullable keyPath;

@end
