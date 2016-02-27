//
//  WAMappingManager.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAMappingManager.h"
#import "WANetworkRoutingMacros.h"

#import "WAResponseDescriptor.h"
#import "WARequestDescriptor.h"
#import "WAObjectResponse.h"
#import "WAObjectRequest.h"

#import <WAMapping/WAEntityMapping.h>
#import <WAMapping/WAMapper.h>
#import <WAMapping/WAReverseMapper.h>
#import <WAMapping/WAStoreProtocol.h>

@interface WAMappingManager ()

@property (nonatomic, strong) NSMutableArray *mutableResponseDescriptors;
@property (nonatomic, strong) NSMutableArray *mutableRequestDescriptors;

@property (nonatomic, strong) WAMapper        *mapper;
@property (nonatomic, strong) WAReverseMapper *reverseMapper;

@end

@implementation WAMappingManager

- (instancetype)initWithMapper:(WAMapper *)mapper reverseMapper:(WAReverseMapper *)reverseMapper {
    self = [super init];
    
    if (self) {
        WANRClassParameterAssert(mapper, WAMapper);
        WANRClassParameterAssert(reverseMapper, WAReverseMapper);
        
        self->_mapper        = mapper;
        self->_reverseMapper = reverseMapper;
    }
    
    return self;
}

+ (instancetype)mappingManagerWithMapper:(WAMapper *)mapper reverseMapper:(WAReverseMapper *)reverseMapper {
    return [[self alloc] initWithMapper:mapper reverseMapper:reverseMapper];
}

- (void)addResponseDescriptor:(WAResponseDescriptor *)responseDescriptor {
    WANRClassParameterAssert(responseDescriptor, WAResponseDescriptor);
    [self.mutableResponseDescriptors addObject:responseDescriptor];
}

- (void)addRequestDescriptor:(WARequestDescriptor *)requestDescriptor {
    WANRClassParameterAssert(requestDescriptor, WARequestDescriptor);
    [self.mutableRequestDescriptors addObject:requestDescriptor];
}

#pragma mark - Protocols methods

- (BOOL)canMapRequestResponse:(WAObjectRequest *)request {
    return [[self responseDescriptorsForRequest:request] count] != 0;
}

- (void)mapResponse:(WAObjectResponse *)response fromRequest:(WAObjectRequest *)request withCompletion:(WAMappingManagerMappingCompletion)completion {
    NSArray *responseDescriptors = [self responseDescriptorsForRequest:request];
    
    if ([responseDescriptors count] > 0) {
        NSMutableArray *allObjectsMapped = [NSMutableArray array];
        __block int currentIndex = 0;
        __unsafe_unretained __block void (^mapResponseBlock)(WAResponseDescriptor *);
        
        void (^endMappingBlock)(void) = ^{
            currentIndex ++;
            if ([responseDescriptors count] > currentIndex) {
                mapResponseBlock(responseDescriptors[currentIndex]);
            }
            else {
                completion([allObjectsMapped copy]);
            }
        };
        
        mapResponseBlock = ^(WAResponseDescriptor *responseDescriptor) {
            NSString *key = responseDescriptor.keyPath;
            NSArray *array = nil;
            if (key) {
                array = response.responseObject[key];
            }
            else {
                if (response.responseObject) {
                    array = [response.responseObject isKindOfClass:[NSArray class]] ? (NSArray *)response.responseObject : @[response.responseObject];
                }
            }
            
            if (array) {
                [self.mapper mapFromRepresentation:array
                                           mapping:responseDescriptor.mapping
                                        completion:^(NSArray *mappedObjects) {
                                            if ([mappedObjects count] != 0) {
                                                [allObjectsMapped addObjectsFromArray:mappedObjects];
                                            }
                                            endMappingBlock();
                                        }];
            }
            else {
                endMappingBlock();
            }
        };
        
        WAResponseDescriptor *responseDescriptor = responseDescriptors[currentIndex];
        mapResponseBlock(responseDescriptor);
    }
    else {
        completion(@[]);
    }
}

- (NSDictionary *)mapObject:(id)object forPath:(NSString *)path method:(WAObjectRequestMethod)method {
    
    if (!object) {
        return nil;
    }
    
    WANRClassParameterAssert(path, NSString);
    
    NSArray *requestDescriptors = [self requestDescriptorsForPath:path method:method];
    
    if ([requestDescriptors count] != 0) {
        NSAssert([requestDescriptors count] == 1, @"For now, we only want one request descriptor per request. If this is an issue then update me");
        WARequestDescriptor *requestDescriptor = [requestDescriptors firstObject];
        NSArray *mappedObjects = [self.reverseMapper reverseMapObjects:@[object]
                                                           fromMapping:requestDescriptor.mapping
                                                 shouldMapRelationship:^BOOL(NSString *sourceRelationShip) {
                                                     return requestDescriptor.shouldMapBlock(requestDescriptor.mapping.entityName, sourceRelationShip);
                                                 }];
        
        NSDictionary *finalDictionary = nil;
        
        if (requestDescriptor.requestKeyPath) {
            finalDictionary = [NSDictionary dictionaryWithObject:[mappedObjects firstObject] forKey:requestDescriptor.requestKeyPath];
        }
        else {
            finalDictionary = [mappedObjects firstObject];
        }
        
        return finalDictionary;
    }
    
    return nil;
}

- (void)deleteObjectFromStore:(id)object fromRequest:(WAObjectRequest *)request {
    if (!object) {
        return;
    }
    
    BOOL shouldDelete = NO;
    if (request.method & WAObjectRequestMethodDELETE) {
        shouldDelete = YES;
    } else if (request.method & WAObjectRequestMethodPOST) {
        // Let's see if the target object has a value for identification attribute
        NSArray *requestDescriptors = [self requestDescriptorsForPath:request.path method:request.method];
        NSAssert([requestDescriptors count] <= 1, @"For now, we only want one request descriptor per request. If this is an issue then update me");
        WARequestDescriptor *requestDescriptor = [requestDescriptors firstObject];
        WAEntityMapping *mapping = requestDescriptor.mapping;
        
        id identificationAttribute = [object valueForKey:mapping.identificationAttribute];
        // If the object has no identification attribute, then this object can be delete.
        // It means that we created an object to POST on server, which is sent back with an id. But these two objects are not the same.
        if (!identificationAttribute || [identificationAttribute isEqual:[NSNull null]]) {
            shouldDelete = YES;
        }
    }
    
    if (shouldDelete) {
        [self.mapper.store beginTransaction];
        [self.mapper.store deleteObject:object];
        [self.mapper.store commitTransaction];
    }
}

#pragma mark - Private methods

- (NSArray *)responseDescriptorsForRequest:(WAObjectRequest *)request {
    NSMutableArray *requestDescriptors = [NSMutableArray array];
    for (WAResponseDescriptor *descriptor in self.mutableResponseDescriptors) {
        if ([descriptor matchesObjectRequest:request]) {
            [requestDescriptors addObject:descriptor];
        }
    }
    return [NSArray arrayWithArray:requestDescriptors];
}

- (NSArray *)requestDescriptorsForPath:(NSString *)path method:(WAObjectRequestMethod)method {
    NSMutableArray *requestDescriptors = [NSMutableArray array];
    for (WARequestDescriptor *descriptor in self.mutableRequestDescriptors) {
        if ([descriptor matchesPath:path method:method]) {
            [requestDescriptors addObject:descriptor];
        }
    }
    return [NSArray arrayWithArray:requestDescriptors];
}

#pragma mark - Getters

- (NSArray *)responseDescriptors {
    return [NSArray arrayWithArray:self.mutableResponseDescriptors];
}

- (NSMutableArray *)mutableResponseDescriptors {
    if (!_mutableResponseDescriptors) {
        _mutableResponseDescriptors = [NSMutableArray array];
    }
    return _mutableResponseDescriptors;
}

- (NSArray *)requestDescriptors {
    return [NSArray arrayWithArray:self.mutableRequestDescriptors];
}

- (NSMutableArray *)mutableRequestDescriptors {
    if (!_mutableRequestDescriptors) {
        _mutableRequestDescriptors = [NSMutableArray array];
    }
    return _mutableRequestDescriptors;
}

@end
