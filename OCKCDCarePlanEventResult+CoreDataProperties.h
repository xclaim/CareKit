//
//  OCKCDCarePlanEventResult+CoreDataProperties.h
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDCarePlanEventResult+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OCKCDCarePlanEventResult (CoreDataProperties)

+ (NSFetchRequest<OCKCDCarePlanEventResult *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *categoryValueStringKeys;
@property (nullable, nonatomic, copy) NSDate *creationDate;
@property (nullable, nonatomic, retain) NSObject *displayUnit;
@property (nullable, nonatomic, retain) NSObject *quantityStringFormatter;
@property (nullable, nonatomic, retain) NSObject *sampleType;
@property (nullable, nonatomic, retain) NSObject *sampleUUID;
@property (nullable, nonatomic, copy) NSString *unitString;
@property (nullable, nonatomic, retain) NSObject *unitStringKeys;
@property (nullable, nonatomic, retain) NSObject *userInfo;
@property (nullable, nonatomic, retain) NSObject *values;
@property (nullable, nonatomic, copy) NSString *valueString;
@property (nullable, nonatomic, retain) OCKCDCarePlanEvent *event;

@end

NS_ASSUME_NONNULL_END
