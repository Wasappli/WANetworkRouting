//
//  EnterpriseCD.m
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "EnterpriseCD.h"
#import "EmployeeCD.h"

@implementation EnterpriseCD

// Insert code here to add functionality to your managed object subclass
+ (NSString *)MR_entityName {
    NSString *className = NSStringFromClass(self);
    return [className substringToIndex:[className length] - 2];
}

@end
