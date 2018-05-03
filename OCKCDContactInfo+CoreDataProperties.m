//
//  OCKCDContactInfo+CoreDataProperties.m
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDContactInfo+CoreDataProperties.h"

@implementation OCKCDContactInfo (CoreDataProperties)

+ (NSFetchRequest<OCKCDContactInfo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"OCKCDContactInfo"];
}

@dynamic actionURL;
@dynamic displayString;
@dynamic icon;
@dynamic label;
@dynamic type;

@end
