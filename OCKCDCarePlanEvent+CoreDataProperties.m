//
//  OCKCDCarePlanEvent+CoreDataProperties.m
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDCarePlanEvent+CoreDataProperties.h"

@implementation OCKCDCarePlanEvent (CoreDataProperties)

+ (NSFetchRequest<OCKCDCarePlanEvent *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"OCKCDCarePlanEvent"];
}

@dynamic numberOfDaysSinceStart;
@dynamic occurrenceIndexOfDay;
@dynamic state;
@dynamic activity;
@dynamic result;

@end
