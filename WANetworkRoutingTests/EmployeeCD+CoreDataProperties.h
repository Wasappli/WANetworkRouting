//
//  EmployeeCD+CoreDataProperties.h
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EmployeeCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmployeeCD (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *itemID;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) EnterpriseCD *enterprise;

@end

NS_ASSUME_NONNULL_END
