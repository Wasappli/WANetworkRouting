//
//  WANetworkRouter.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WANetworkRouter.h"
#import "WANetworkRoutingMacros.h"

#import "WANetworkRoute.h"
#import "WANetworkRoutePattern.h"

@interface WANetworkRouter ()

@property (nonatomic, strong) NSMutableSet *routes;

@end

@implementation WANetworkRouter

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    WANRClassParameterAssert(baseURL, NSURL);
    self = [super init];
    
    if (self) {
        self->_baseURL = baseURL;
        self->_routes  = [NSMutableSet set];
    }
    return self;
}

- (void)addRoute:(WANetworkRoute *)route {
    WANRClassParameterAssert(route, WANetworkRoute);
    
    NSAssert(![self.routes containsObject:route], @"You cannot add twice the same route");
    
    [self.routes addObject:route];
}

- (WANetworkRoute *)routeForObject:(id)object method:(WAObjectRequestMethod)method {
    WANRParameterAssert(object);
    
    NSSet *filteredSet = [self.routes filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(WANetworkRoute  *_Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ([evaluatedObject.objectClass isEqual:[object class]]
                &&
                evaluatedObject.method & method
                &&
                [evaluatedObject.pathPattern rangeOfString:WANetworkRoutePatternObjectPrefix].location != NSNotFound);
    }]];
    
    NSAssert([filteredSet count] <= 1, @"You should not have more than one route which match these conditions. Please review the routes we found for you:\n%@", filteredSet);
    return [[filteredSet allObjects] firstObject];
}

- (NSArray *)routesForClass:(Class)objectClass {
    NSMutableArray *routes = [NSMutableArray array];
    for (WANetworkRoute *route in self.routes) {
        if ([route.objectClass isEqual:objectClass]) {
            [routes addObject:route];
        }
    }
    return [routes copy];
}

- (NSURL *)urlForObject:(id)object method:(WAObjectRequestMethod)method {
    WANRParameterAssert(object);
    
    // First, get the route
    WANetworkRoute *route = [self routeForObject:object method:method];
    
    if (route) {
        WANetworkRoutePattern* pattern = [[WANetworkRoutePattern alloc] initWithPattern:route.pathPattern];
        id pathReplaced = [pattern stringFromObject:object];
        NSAssert(pathReplaced, @"Cannot get path on %@ from %@", object, route);
        
        return [NSURL URLWithString:pathReplaced relativeToURL:self.baseURL];
    }

    return nil;
}

@end
