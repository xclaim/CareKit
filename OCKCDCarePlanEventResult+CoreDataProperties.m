//
//  OCKCDCarePlanEventResult+CoreDataProperties.m
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDCarePlanEventResult+CoreDataProperties.h"

@implementation OCKCDCarePlanEventResult (CoreDataProperties)

+ (NSFetchRequest<OCKCDCarePlanEventResult *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"OCKCDCarePlanEventResult"];
}

@dynamic categoryValueStringKeys;
@dynamic creationDate;
@dynamic displayUnit;
@dynamic quantityStringFormatter;
@dynamic sampleType;
@dynamic sampleUUID;
@dynamic unitString;
@dynamic unitStringKeys;
@dynamic userInfo;
@dynamic values;
@dynamic valueString;
@dynamic event;

@end
