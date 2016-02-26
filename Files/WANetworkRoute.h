//
//  WANetworkRoute.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WANetworkRoutingUtilities.h"

@interface WANetworkRoute : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Create a new route description to use on router
 *
 *  @param objectClass the class of the object concerned by the route
 *  @param pathPattern a path pattern (ex: shelves/:itemId)
 *  @param method      the method(s) for which the route applies
 *
 *  @return a new route
 */
- (instancetype)initWithObjectClass:(Class)objectClass pathPattern:(NSString *)pathPattern method:(WAObjectRequestMethod)method NS_DESIGNATED_INITIALIZER;

// @see `initWithObjectClass: pathPattern: method:`
+ (instancetype)routeWithObjectClass:(Class)objectClass pathPattern:(NSString *)pathPattern method:(WAObjectRequestMethod)method;

@property (nonatomic, strong, readonly) Class                 objectClass;
@property (nonatomic, assign, readonly) WAObjectRequestMethod method;
@property (nonatomic, strong, readonly) NSString              *pathPattern;

@end
