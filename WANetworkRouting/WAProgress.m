//
//  WAProgress.m
//  WANetworkRouting
//
//  Created by Marian Paul on 16-03-21.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAProgress.h"

@interface WAProgress ()

@property (nonatomic, strong) NSMutableArray <NSProgress *>*childs;

@end

@implementation WAProgress

- (void)addChildOnce:(NSProgress *)child withPendingUnitCount:(int64_t)inUnitCount {
    // Unfortunately, we don't have access to `_parent` property of NSProgress
    if (child && ![self.childs containsObject:child]) {
        [self addChild:child withPendingUnitCount:inUnitCount];
        [self.childs addObject:child];
    }
}

- (NSMutableArray<NSProgress *> *)childs {
    if (!_childs) {
        _childs = [NSMutableArray array];
    }
    
    return _childs;
}

@end
