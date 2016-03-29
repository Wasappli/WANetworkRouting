//
//  WABatchSession.m
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WABatchSession.h"
#import "WANetworkRoutingMacros.h"

#import "WAObjectRequest.h"
#import "WABatchObject.h"

@interface WABatchSession ()

@property (nonatomic, strong) NSMutableArray<WABatchObject *> *mBatchObjects;

@end

@implementation WABatchSession

- (instancetype)init {
    self = [super init];
    if (self) {
        self->_mBatchObjects = [NSMutableArray array];
    }
    
    return self;
}

- (void)addRequest:(WAObjectRequest *)objectRequest {
    WANRClassParameterAssert(objectRequest, WAObjectRequest);
    
    WABatchObject *batchObject = [WABatchObject new];
    batchObject.parameters     = objectRequest.parameters;
    batchObject.headers        = objectRequest.headers;
    batchObject.uri            = objectRequest.path;
    batchObject.method         = WAStringFromObjectRequestMethod(objectRequest.method);
    
    [self addBatchObject:batchObject];
}

- (void)addBatchObject:(WABatchObject *)batchObject {
    WANRClassParameterAssert(batchObject, WABatchObject);
 
    [self.mBatchObjects addObject:batchObject];
}

- (NSArray<WABatchObject *> *)batchObjects {
    return [self.mBatchObjects copy];
}

@end
