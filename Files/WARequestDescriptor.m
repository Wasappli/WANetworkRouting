//
//  WARequestDescriptor.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WARequestDescriptor.h"
#import "WANetworkRoutingMacros.h"
#import "WANetworkRoutePattern.h"

#import <WAMapping/WAEntityMapping.h>

@implementation WARequestDescriptor

- (instancetype)initWithMethod:(WAObjectRequestMethod)method pathPattern:(NSString *)pathPattern mapping:(WAEntityMapping *)mapping shouldMapBlock:(WARequestDescriptorShouldMapBlock)shouldMapBlock requestKeyPath:(NSString *)requestKeyPath{
    WANRClassParameterAssert(pathPattern, NSString);
    WANRClassParameterAssert(mapping, WAEntityMapping);
    
    self = [super init];
    if (self) {
        self->_method         = method;
        self->_pathPattern    = pathPattern;
        self->_mapping        = mapping;
        self->_shouldMapBlock = shouldMapBlock;
        self->_requestKeyPath = requestKeyPath;
    }
    
    return self;
}

+ (instancetype)requestDescriptorWithMethod:(WAObjectRequestMethod)method pathPattern:(NSString *)pathPattern mapping:(WAEntityMapping *)mapping shouldMapBlock:(WARequestDescriptorShouldMapBlock)shouldMapBlock requestKeyPath:(NSString *)requestKeyPath {
    return [[self alloc] initWithMethod:method
                            pathPattern:pathPattern
                                mapping:mapping
                         shouldMapBlock:shouldMapBlock
                         requestKeyPath:requestKeyPath];
}

- (BOOL)matchesPath:(NSString *)path method:(WAObjectRequestMethod)method {
    BOOL methodMatching = method & self.method;
    
    WANetworkRoutePattern* pattern = [[WANetworkRoutePattern alloc] initWithPattern:self.pathPattern];
    BOOL pathMatching = [pattern matchesRoute:path];
    
    return methodMatching && pathMatching;
}

#pragma mark - Debug and equality

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - methods=%@ path pattern=%@ keypath=%@ mapping=%@", [super description], WAStringFromObjectRequestMethod(self.method), self.pathPattern, self.requestKeyPath, self.mapping];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[WARequestDescriptor class]]) {
        return NO;
    }
    
    return [self isEqualToRequestDescriptor:object];
}

- (BOOL)isEqualToRequestDescriptor:(WARequestDescriptor *)requestDescriptor {
    if (self == requestDescriptor) {
        return YES;
    }
    
    if ([self.mapping isEqual:self.mapping]
        &&
        [self.pathPattern isEqualToString:requestDescriptor.pathPattern]
        &&
        [self.requestKeyPath isEqualToString:requestDescriptor.requestKeyPath]
        &&
        self.method == requestDescriptor.method
        ) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [self.pathPattern hash] ^ [self.requestKeyPath hash] ^ [self.mapping hash] ^ self.method;
}


@end
