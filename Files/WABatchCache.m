//
//  WABatchCache.m
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WABatchCache.h"
#import "WABatchObject.h"

#import "WANetworkRoutingMacros.h"

@interface WABatchCache ()

@property (nonatomic, strong) NSMutableArray *mBatchObjects;
@property (nonatomic, assign) NSInteger      maxObjectID;

@end

@implementation WABatchCache

static NSString *kBatchObjectsKey  = @"kBatchObjectsKey";
static NSString *kBatchMaxObjectID = @"kBatchMaxObjectID";

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadData];
    }
    
    return self;
}

- (void)addBatchObject:(WABatchObject *)batchObject {
    WANRClassParameterAssert(batchObject, WABatchObject);
    
    self.maxObjectID += 1;
    batchObject.batchID = @(self.maxObjectID);
    
    [self.mBatchObjects addObject:batchObject];
    
    [self save];
}

- (void)removeBatchObjects:(NSArray<WABatchObject *> *)batchObjects {
    [self.mBatchObjects removeObjectsInArray:batchObjects];
    
    [self save];
}

- (void)dropDatabase {
    [self.mBatchObjects removeAllObjects];
    self.maxObjectID = 0;
    [[NSFileManager defaultManager] removeItemAtPath:[[self class] archiveFilePath] error:nil];
}

- (NSArray *)batchObjects {
    return [self.mBatchObjects copy];
}

#pragma mark - File management

+ (NSString *)libraryDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)archiveFilePath {
    return [[self libraryDocumentsDirectory] stringByAppendingPathComponent:@"WABatchManager/batchData.archive"];
}

- (void)save {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeObject:self.batchObjects forKey:kBatchObjectsKey];
    [coder encodeObject:@(self.maxObjectID) forKey:kBatchMaxObjectID];
    [coder finishEncoding];
    
    NSString *path = [[self class] archiveFilePath];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];

    BOOL saved = [data writeToFile:path atomically:YES];
    WANRParameterAssert(saved);
}

- (void)loadData {
    NSData *archiveData        = [NSData dataWithContentsOfFile:[[self class] archiveFilePath]];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:archiveData];
    
    self.mBatchObjects = [[decoder decodeObjectForKey:kBatchObjectsKey] mutableCopy];
    self.maxObjectID   = [[decoder decodeObjectForKey:kBatchMaxObjectID] integerValue];
    
    if (!self.mBatchObjects) {
        self.mBatchObjects = [NSMutableArray array];
    }
}

@end
