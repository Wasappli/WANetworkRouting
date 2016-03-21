//
//  WAProgress.h
//  WANetworkRouting
//
//  Created by Marian Paul on 16-03-21.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WAProgress : NSProgress

- (void)addChildOnce:(NSProgress *)child withPendingUnitCount:(int64_t)inUnitCount;

@end
