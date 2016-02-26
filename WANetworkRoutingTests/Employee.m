//
//  Employee.m
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "Employee.h"

@implementation Employee

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Employee class]]) {
        return NO;
    }
    
    return [self isEqualToEmployee:object];
}

- (BOOL)isEqualToEmployee:(Employee *)employee {
    if (self == employee) {
        return YES;
    }
    
    if ([self.itemID isEqual:employee.itemID]) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [self.itemID hash];
}

@end
