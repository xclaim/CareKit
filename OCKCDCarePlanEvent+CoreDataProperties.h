//
//  OCKCDCarePlanEvent+CoreDataProperties.h
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDCarePlanEvent+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OCKCDCarePlanEvent (CoreDataProperties)

+ (NSFetchRequest<OCKCDCarePlanEvent *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *numberOfDaysSinceStart;
@property (nullable, nonatomic, copy) NSNumber *occurrenceIndexOfDay;
@property (nullable, nonatomic, copy) NSNumber *state;
@property (nullable, nonatomic, retain) OCKCDCarePlanActivity *activity;
@property (nullable, nonatomic, retain) OCKCDCarePlanEventResult *result;

@end

NS_ASSUME_NONNULL_END
