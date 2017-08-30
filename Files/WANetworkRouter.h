//
//  WANetworkRouter.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WANetworkRoutingUtilities.h"

@class WANetworkRoute;

/**
 This class stores all the routes and allows you to retrieve from a path or create the URL
 */
@interface WANetworkRouter : NSObject

- (instancetype _Nonnull )init NS_UNAVAILABLE;
+ (instancetype _Nonnull )new NS_UNAVAILABLE;

/**
 *  Init the router with a base URL which will be used to create the URLs
 *
 *  @param baseURL the base URL
 *
 *  @return a WANetworkRouter object freshly instanciated
 */
- (instancetype _Nonnull)initWithBaseURL:(NSURL *_Nonnull)baseURL NS_DESIGNATED_INITIALIZER;

/**
 *  Register a new route
 *
 *  @param route the route to register
 */
- (void)addRoute:(WANetworkRoute *_Nonnull)route;

/**
 *  Get the existing route from an object and method
 *
 *  @param object The object you want to find a route for
 *  @param method The method(s) for which the route applies
 *
 *  @return A route
 */
- (WANetworkRoute *_Nullable)routeForObject:(_Nonnull id)object method:(WAObjectRequestMethod)method;

/**
 *  Returns an array of registered route for a class
 *
 *  @param objectClass The class of the routes object
 *
 *  @return An array of all routes for a class
 */
- (NSArray<WANetworkRoute *> *_Nullable)routesForClass:(_Nonnull Class)objectClass;

/**
 *  Get the url for a path pattern. For example, from categories/:itemID, you'd get [baseURL]/categories/1234
 *
 *  @param object the object to hit
 *  @param method the method
 *
 *  @return an URL with the baseURL+path with values replaced
 */
- (NSURL *_Nullable)urlForObject:(_Nonnull id)object method:(WAObjectRequestMethod)method;


@property (nonatomic, strong, readwrite) NSURL        *_Nonnull baseURL;
@property (nonatomic, strong, readonly ) NSMutableSet *_Nonnull routes;

@end
