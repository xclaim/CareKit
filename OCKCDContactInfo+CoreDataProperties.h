//
//  OCKCDContactInfo+CoreDataProperties.h
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDContactInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OCKCDContactInfo (CoreDataProperties)

+ (NSFetchRequest<OCKCDContactInfo *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *actionURL;
@property (nullable, nonatomic, copy) NSString *displayString;
@property (nullable, nonatomic, retain) NSObject *icon;
@property (nullable, nonatomic, copy) NSString *label;
@property (nullable, nonatomic, copy) NSNumber *type;

@end

NS_ASSUME_NONNULL_END
