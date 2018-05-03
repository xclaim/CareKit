//
//  OCKCDCarePlanActivity+CoreDataProperties.m
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDCarePlanActivity+CoreDataProperties.h"

@implementation OCKCDCarePlanActivity (CoreDataProperties)

+ (NSFetchRequest<OCKCDCarePlanActivity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"OCKCDCarePlanActivity"];
}

@dynamic color;
@dynamic groupIdentifier;
@dynamic identifier;
@dynamic imageURL;
@dynamic instructions;
@dynamic optional;
@dynamic resultResettable;
@dynamic schedule;
@dynamic text;
@dynamic thresholds;
@dynamic title;
@dynamic type;
@dynamic userInfo;
@dynamic events;
@dynamic contacts;

@end
