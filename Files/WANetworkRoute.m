//
//  WANetworkRoute.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WANetworkRoute.h"

#import "WANetworkRoutingMacros.h"

NSString *WAStringFromObjectRequestMethod(WAObjectRequestMethod method) {
    NSMutableArray *methodsAsString = [NSMutableArray array];
    if (method & WAObjectRequestMethodGET) [methodsAsString addObject:@"GET"];
    if (method & WAObjectRequestMethodPUT) [methodsAsString addObject:@"PUT"];
    if (method & WAObjectRequestMethodPOST) [methodsAsString addObject:@"POST"];
    if (method & WAObjectRequestMethodDELETE) [methodsAsString addObject:@"DELETE"];
    if (method & WAObjectRequestMethodHEAD) [methodsAsString addObject:@"HEAD"];
    if (method & WAObjectRequestMethodPATCH) [methodsAsString addObject:@"PATCH"];
    
    return [NSString stringWithFormat:@"%@", [methodsAsString componentsJoinedByString:@"|"]];
}

WAObjectRequestMethod WAObjectRequestMethodFromString(NSString *method) {
    if ([method isEqualToString:@"GET"]) {
        return WAObjectRequestMethodGET;
    } else if ([method isEqualToString:@"PUT"]) {
        return WAObjectRequestMethodPUT;
    } else if ([method isEqualToString:@"POST"]) {
        return WAObjectRequestMethodPOST;
    } else if ([method isEqualToString:@"HEAD"]) {
        return WAObjectRequestMethodHEAD;
    } else if ([method isEqualToString:@"PATCH"]) {
        return WAObjectRequestMethodPATCH;
    } else if ([method isEqualToString:@"DELETE"]) {
        return WAObjectRequestMethodDELETE;
    }
    return -1;
}

@interface WANetworkRoute ()

@property (nonatomic, strong) Class                 objectClass;
@property (nonatomic, assign) WAObjectRequestMethod method;
@property (nonatomic, strong) NSString              *pathPattern;

@end

@implementation WANetworkRoute

- (instancetype)initWithObjectClass:(Class)objectClass pathPattern:(NSString *)pathPattern method:(WAObjectRequestMethod)method {
    WANRClassParameterAssert(pathPattern, NSString);
    
    self = [super init];
    if (self) {
        self->_objectClass = objectClass;
        self->_pathPattern = pathPattern;
        self->_method = method;
    }

    return self;
}

+ (instancetype)routeWithObjectClass:(Class)objectClass pathPattern:(NSString *)pathPattern method:(WAObjectRequestMethod)method {
    return [[self alloc] initWithObjectClass:objectClass pathPattern:pathPattern method:method];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - object class=%@ path=%@ methods=%@", [super description], NSStringFromClass(self.objectClass), self.pathPattern, WAStringFromObjectRequestMethod(self.method)];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[WANetworkRoute class]]) {
        return NO;
    }
    
    return [self isEqualToRoute:object];
}

- (BOOL)isEqualToRoute:(WANetworkRoute *)route {
    if (self == route) {
        return YES;
    }
    
    if (((!self.objectClass && !route.objectClass) || [self.objectClass isEqual:route.objectClass])
        &&
        [self.pathPattern isEqualToString:route.pathPattern]
        &&
        self.method == route.method
        ) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [self.pathPattern hash] ^ self.method;
}
@end
