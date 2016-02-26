//
//  Employee.h
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Enterprise;

@interface Employee : NSObject

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) Enterprise *enterprise;

@end
