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

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

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
- (instancetype)initWithMapping:(WAEntityMapping *)mapping
                         method:(WAObjectRequestMethod)method
                    pathPattern:(NSString *)pathPattern
                        keyPath:(NSString *)keyPath NS_DESIGNATED_INITIALIZER;

// @see `initWithMapping: method: pathPattern: keyPath:`
+ (instancetype)responseDescriptorWithMapping:(WAEntityMapping *)mapping
                                       method:(WAObjectRequestMethod)method
                                  pathPattern:(NSString *)pathPattern
                                      keyPath:(NSString *)keyPath;

/**
 *  Test if the response descriptor would match a request
 *
 *  @param objectRequest the request to match against
 *
 *  @return YES if the descriptor can be used on the provided request, NO otherwise
 */
- (BOOL)matchesObjectRequest:(WAObjectRequest *)objectRequest;

@property (nonatomic, strong, readonly) WAEntityMapping       *mapping;
@property (nonatomic, assign, readonly) WAObjectRequestMethod method;
@property (nonatomic, strong, readonly) NSString              *pathPattern;
@property (nonatomic, strong, readonly) NSString              *keyPath;

@end
