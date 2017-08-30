//
//  WANetworkRoutePattern.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@interface WANetworkRoutePattern : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 *  Init with a pattern like 'list/:itemID/extra'
 *
 *  @param pattern The pattern
 *
 *  @return Return a fresh pattern matcher
 */
- (instancetype _Nonnull)initWithPattern:(NSString *_Nonnull)pattern NS_DESIGNATED_INITIALIZER;

/**
 *  Tests if a route matches the pattern
 *
 *  @param route The route (url as string)
 *
 *  @return YES if matches, NO if not
 */
- (BOOL)matchesRoute:(NSString *_Nonnull)route;

/**
 *  Get the string path with values replaced from object properties
 *
 *  @param object The object you want to map against the pattern
 *
 *  @return A string from path pattern with values replaced
 */
- (NSString *_Nullable)stringFromObject:(_Nonnull id)object;

@end

FOUNDATION_EXTERN NSString * _Nonnull const WANetworkRoutePatternObjectPrefix;
