//
//  WANetworkRoutePattern.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@interface WANetworkRoutePattern : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Init with a pattern like 'list/:itemID/extra'
 *
 *  @param pattern The pattern
 *
 *  @return Return a fresh pattern matcher
 */
- (instancetype)initWithPattern:(NSString *)pattern NS_DESIGNATED_INITIALIZER;

/**
 *  Tests if a route matches the pattern
 *
 *  @param route The route (url as string)
 *
 *  @return YES if matches, NO if not
 */
- (BOOL)matchesRoute:(NSString *)route;

/**
 *  Get the string path with values replaced from object properties
 *
 *  @param object The object you want to map against the pattern
 *
 *  @return A string from path pattern with values replaced
 */
- (NSString *)stringFromObject:(id)object;

@end

FOUNDATION_EXTERN NSString * const WANetworkRoutePatternObjectPrefix;