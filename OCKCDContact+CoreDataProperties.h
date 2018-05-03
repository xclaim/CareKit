//
//  OCKCDContact+CoreDataProperties.h
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDContact+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OCKCDContact (CoreDataProperties)

+ (NSFetchRequest<OCKCDContact *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *contactInfoItems;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, retain) NSObject *image;
@property (nullable, nonatomic, copy) NSString *monogram;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *relation;
@property (nullable, nonatomic, retain) NSObject *tintColor;
@property (nullable, nonatomic, copy) NSNumber *type;
@property (nullable, nonatomic, retain) NSSet<OCKCDCarePlanActivity *> *activity;

@end

@interface OCKCDContact (CoreDataGeneratedAccessors)

- (void)addActivityObject:(OCKCDCarePlanActivity *)value;
- (void)removeActivityObject:(OCKCDCarePlanActivity *)value;
- (void)addActivity:(NSSet<OCKCDCarePlanActivity *> *)values;
- (void)removeActivity:(NSSet<OCKCDCarePlanActivity *> *)values;

@end

NS_ASSUME_NONNULL_END
