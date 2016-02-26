//
//  WAResponseDescriptor.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAResponseDescriptor.h"
#import "WANetworkRoutingMacros.h"

#import "WAObjectRequest.h"
#import "WANetworkRoutePattern.h"

#import <WAMapping/WAEntityMapping.h>

@implementation WAResponseDescriptor

- (instancetype)initWithMapping:(WAEntityMapping *)mapping method:(WAObjectRequestMethod)method pathPattern:(NSString *)pathPattern keyPath:(NSString *)keyPath {
    self = [super init];
    
    WANRClassParameterAssert(mapping, WAEntityMapping);
    WANRClassParameterAssert(pathPattern, NSString);
    
    if (self) {
        self->_mapping     = mapping;
        self->_method      = method;
        self->_pathPattern = pathPattern;
        self->_keyPath     = keyPath;
    }
    
    return self;
}

+ (instancetype)responseDescriptorWithMapping:(WAEntityMapping *)mapping method:(WAObjectRequestMethod)method pathPattern:(NSString *)pathPattern keyPath:(NSString *)keyPath {
    return [[self alloc] initWithMapping:mapping method:method pathPattern:pathPattern keyPath:keyPath];
}

#pragma mark - Matching

- (BOOL)matchesObjectRequest:(WAObjectRequest *)objectRequest {
    BOOL methodMatching = objectRequest.method & self.method;
    
    WANetworkRoutePattern* pattern = [[WANetworkRoutePattern alloc] initWithPattern:self.pathPattern];
    NSString *pathWithoutParameters = nil;
    NSRange paramStartRange = [objectRequest.path rangeOfString:@"?"];
    if (paramStartRange.location == NSNotFound) {
        pathWithoutParameters = objectRequest.path;
    }
    else {
        pathWithoutParameters = [objectRequest.path substringToIndex:paramStartRange.location];
    }
    
    BOOL pathMatching = [pattern matchesRoute:pathWithoutParameters];
    
    return methodMatching && pathMatching;
}

#pragma mark - Debug and equality

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - mapping=%@ methods=%@ path pattern=%@ keypath=%@", [super description], self.mapping, WAStringFromObjectRequestMethod(self.method), self.pathPattern, self.keyPath];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[WAResponseDescriptor class]]) {
        return NO;
    }
    
    return [self isEqualToResponseDescriptor:object];
}

- (BOOL)isEqualToResponseDescriptor:(WAResponseDescriptor *)responseDescriptor {
    if (self == responseDescriptor) {
        return YES;
    }
    
    if ([self.mapping isEqual:responseDescriptor.mapping]
        &&
        [self.pathPattern isEqualToString:responseDescriptor.pathPattern]
        &&
        [self.keyPath isEqualToString:responseDescriptor.keyPath]
        &&
        self.method == responseDescriptor.method
        ) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [self.pathPattern hash] ^ [self.keyPath hash] ^ [self.mapping hash] ^ self.method;
}

@end
