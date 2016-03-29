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

@property (nonatomic, strong) NSMutableDictionary *defaultMappingBlocks;
@property (nonatomic, strong) NSMutableDictionary *defaultReverseMappingBlocks;

@property (nonatomic, strong) id <WAStoreProtocol> store;

@property (nonatomic, strong) NSMutableArray *mappers;

@end

@implementation WAMappingManager

- (instancetype)initWithStore:(id<WAStoreProtocol>)store {
    self = [super init];
    
    if (self) {
        WANRProtocolParameterAssert(store, WAStoreProtocol);
        self->_mappers = [NSMutableArray array];
        self->_store   = store;
    }
    
    return self;
}

+ (instancetype)mappingManagerWithStore:(id<WAStoreProtocol>)store {
    return [[self alloc] initWithStore:store];
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

- (NSArray *)representationArrayFromResponse:(WAObjectResponse *)response usingResponseDescriptor:(WAResponseDescriptor *)responseDescriptor {
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
    
    return array;
}

- (void)mapResponse:(WAObjectResponse *)response fromRequest:(WAObjectRequest *)request withCompletion:(WAMappingManagerMappingCompletion)completion {
    NSArray *responseDescriptors = [self responseDescriptorsForRequest:request];
    
    if ([responseDescriptors count] > 0) {
        NSMutableArray *allObjectsMapped = [NSMutableArray array];
        __block NSError *finalError      = nil;
        
        __block int currentIndex = 0;
        __unsafe_unretained __block void (^mapResponseBlock)(WAResponseDescriptor *);
        
        NSInteger numberOfMappings = 0;
        for (WAResponseDescriptor *responseDescriptor in responseDescriptors) {
            NSArray *array = [self representationArrayFromResponse:response
                                           usingResponseDescriptor:responseDescriptor];
            if ([array count]) {
                numberOfMappings++;
            }
        }
        
        NSProgress *mappingProgress = [NSProgress progressWithTotalUnitCount:numberOfMappings];
        [mappingProgress addObserver:self
                          forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                             options:NSKeyValueObservingOptionNew
                             context:(__bridge void * _Nullable)(request)];
        
        wanrWeakify(self);
        void (^endMappingBlock)(void) = ^{
            wanrStrongify(self);
            currentIndex ++;
            if ([responseDescriptors count] > currentIndex) {
                mapResponseBlock(responseDescriptors[currentIndex]);
            }
            else {
                [mappingProgress removeObserver:self
                                     forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
                
                completion([allObjectsMapped copy], finalError);
            }
        };
        
        mapResponseBlock = ^(WAResponseDescriptor *responseDescriptor) {
            NSArray *array = [self representationArrayFromResponse:response usingResponseDescriptor:responseDescriptor];
            if ([array count]) {
                [mappingProgress becomeCurrentWithPendingUnitCount:1];
                
                WAMapper *mapper = [WAMapper newMapperWithStore:self.store];
                // Transfer default mappings blocks
                [self.defaultMappingBlocks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [mapper addDefaultMappingBlock:obj forDestinationClass:NSClassFromString(key)];
                }];
                
                [self.mappers addObject:mapper];
                wanrWeakify(self);
                [mapper mapFromRepresentation:array
                                      mapping:responseDescriptor.mapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       wanrStrongify(self);
                                       if ([mappedObjects count] != 0) {
                                           [allObjectsMapped addObjectsFromArray:mappedObjects];
                                       }
                                       
                                       if (error) {
                                           finalError = error;
                                       }
                                       
                                       [mappingProgress resignCurrent];
                                       
                                       endMappingBlock();
                                       
                                       [self.mappers removeObject:mapper];
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
        completion(@[], nil);
    }
}

- (NSDictionary *)mapObject:(id)object forPath:(NSString *)path method:(WAObjectRequestMethod)method {
    
    if (!object || method & WAObjectRequestMethodDELETE) {
        return nil;
    }
    
    WANRClassParameterAssert(path, NSString);
    
    NSArray *requestDescriptors = [self requestDescriptorsForPath:path method:method];
    
    if ([requestDescriptors count] != 0) {
        NSAssert([requestDescriptors count] == 1, @"For now, we only want one request descriptor per request. If this is an issue then update me");
        WARequestDescriptor *requestDescriptor = [requestDescriptors firstObject];
        WAReverseMapper *reverseMapper = [WAReverseMapper new];
        // Transfer default mappings blocks
        [self.defaultReverseMappingBlocks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [reverseMapper addReverseDefaultMappingBlock:obj forDestinationClass:NSClassFromString(key)];
        }];

        NSArray *mappedObjects = [reverseMapper reverseMapObjects:@[object]
                                                      fromMapping:requestDescriptor.mapping
                                            shouldMapRelationship:^BOOL(NSString *sourceRelationShip) {
                                                return requestDescriptor.shouldMapBlock ? requestDescriptor.shouldMapBlock(requestDescriptor.mapping.entityName, sourceRelationShip) : YES;
                                            }
                                                            error:nil];
        
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
        if (request.method & WAObjectRequestMethodDELETE) {
            // Try to grab it from path
            NSArray *responseDescriptors = [self responseDescriptorsForRequest:request];
            WANRParameterAssert([responseDescriptors count] <= 1);
            WAResponseDescriptor *responseDescriptor = [responseDescriptors firstObject];
            if (responseDescriptor) {
                id objectID = [request.path lastPathComponent];
                // Test if the 
                if ([objectID isEqualToString:[NSString stringWithFormat:@"%ld", [objectID integerValue]]]) {
                    objectID = @([objectID integerValue]);
                }
                
                if (objectID) {
                    NSArray *objects = [self.store objectsWithAttributes:@[objectID] forMapping:responseDescriptor.mapping];
                    object = [objects firstObject];
                }
            }
        }
        
        if (!object) {
            return;
        }
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
        [self.store beginTransaction];
        [self.store deleteObject:object];
        [self.store commitTransaction];
    }
}

- (void)addDefaultMappingBlock:(WAMappingBlock)mappingBlock forDestinationClass:(Class)destinationClass {
    WANRParameterAssert(destinationClass);
    WANRParameterAssert(mappingBlock);
    
    if (!self.defaultMappingBlocks) {
        self.defaultMappingBlocks = [NSMutableDictionary dictionary];
    }
    
    self.defaultMappingBlocks[NSStringFromClass(destinationClass)] = mappingBlock;
}


- (void)addReverseDefaultMappingBlock:(WAMappingBlock)mappingBlock forDestinationClass:(Class)destinationClass {
    WANRParameterAssert(destinationClass);
    WANRParameterAssert(mappingBlock);
    
    if (!self.defaultReverseMappingBlocks) {
        self.defaultReverseMappingBlocks = [NSMutableDictionary dictionary];
    }
    
    self.defaultReverseMappingBlocks[NSStringFromClass(destinationClass)] = mappingBlock;
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSProgress class]]) {
        WAObjectRequest *request = (__bridge WAObjectRequest *)context;
        if (request.progressBlock) {
            request.progressBlock(request, nil, nil, (NSProgress *)object);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
