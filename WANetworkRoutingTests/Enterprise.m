//
//  Enterprise.m
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "Enterprise.h"

@implementation Enterprise

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", [super description], self.itemID];
}

@end
