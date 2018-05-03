//
//  OCKCDContact+CoreDataProperties.m
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDContact+CoreDataProperties.h"

@implementation OCKCDContact (CoreDataProperties)

+ (NSFetchRequest<OCKCDContact *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"OCKCDContact"];
}

@dynamic contactInfoItems;
@dynamic identifier;
@dynamic image;
@dynamic monogram;
@dynamic name;
@dynamic relation;
@dynamic tintColor;
@dynamic type;
@dynamic activity;

@end
