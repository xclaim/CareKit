//
//  OCKCDCarePlanEvent+CoreDataClass.h
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OCKCDCarePlanActivity, OCKCDCarePlanEventResult;

NS_ASSUME_NONNULL_BEGIN

@interface OCKCDCarePlanEvent : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "OCKCDCarePlanEvent+CoreDataProperties.h"
