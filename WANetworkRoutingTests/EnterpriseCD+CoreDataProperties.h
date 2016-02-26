//
//  EnterpriseCD+CoreDataProperties.h
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EnterpriseCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface EnterpriseCD (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *streetNumber;
@property (nullable, nonatomic, retain) NSDate *creationDate;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *itemID;
@property (nullable, nonatomic, retain) NSSet<EmployeeCD *> *employees;
@property (nullable, nonatomic, retain) NSOrderedSet<EmployeeCD *> *orderedEmployees;
@property (nullable, nonatomic, retain) NSOrderedSet<EmployeeCD *> *chiefs;

@end

@interface EnterpriseCD (CoreDataGeneratedAccessors)

- (void)addEmployeesObject:(EmployeeCD *)value;
- (void)removeEmployeesObject:(EmployeeCD *)value;
- (void)addEmployees:(NSSet<EmployeeCD *> *)values;
- (void)removeEmployees:(NSSet<EmployeeCD *> *)values;

- (void)insertObject:(EmployeeCD *)value inOrderedEmployeesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromOrderedEmployeesAtIndex:(NSUInteger)idx;
- (void)insertOrderedEmployees:(NSArray<EmployeeCD *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeOrderedEmployeesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInOrderedEmployeesAtIndex:(NSUInteger)idx withObject:(EmployeeCD *)value;
- (void)replaceOrderedEmployeesAtIndexes:(NSIndexSet *)indexes withOrderedEmployees:(NSArray<EmployeeCD *> *)values;
- (void)addOrderedEmployeesObject:(EmployeeCD *)value;
- (void)removeOrderedEmployeesObject:(EmployeeCD *)value;
- (void)addOrderedEmployees:(NSOrderedSet<EmployeeCD *> *)values;
- (void)removeOrderedEmployees:(NSOrderedSet<EmployeeCD *> *)values;

- (void)insertObject:(EmployeeCD *)value inChiefsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChiefsAtIndex:(NSUInteger)idx;
- (void)insertChiefs:(NSArray<EmployeeCD *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChiefsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChiefsAtIndex:(NSUInteger)idx withObject:(EmployeeCD *)value;
- (void)replaceChiefsAtIndexes:(NSIndexSet *)indexes withChiefs:(NSArray<EmployeeCD *> *)values;
- (void)addChiefsObject:(EmployeeCD *)value;
- (void)removeChiefsObject:(EmployeeCD *)value;
- (void)addChiefs:(NSOrderedSet<EmployeeCD *> *)values;
- (void)removeChiefs:(NSOrderedSet<EmployeeCD *> *)values;

@end

NS_ASSUME_NONNULL_END
