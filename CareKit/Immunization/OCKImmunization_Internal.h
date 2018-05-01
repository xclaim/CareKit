//
//  OCKImmunization_Internal.h
//  CareKit
//
//  Created by Johan Sellström on 06/08/16.
//  Copyright © 2016 carekit.org. All rights reserved.
//

#import "OCKContact.h"
#import "OCKImmunization.h"
#import <CoreData/CoreData.h>
#import "OCKCarePlanActivity_Internal.h"


NS_ASSUME_NONNULL_BEGIN


@interface OCKContact () <OCKCoreDataObjectMirroring, NSCopying>

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


@class OCKCDImmunizationItemType;

@interface OCKCDImmunization : NSManagedObject

- (instancetype)initWithEntity:(NSEntityDescription *)entity
insertIntoManagedObjectContext:(nullable NSManagedObjectContext *)context
                          item:(OCKImmunization *)item;

@property (nullable, nonatomic, retain) id tintColor;
@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) OCKContact *issuer;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *synopsis;
@property (nullable, nonatomic, retain) NSString *monogram;
@property (nullable, nonatomic, retain) NSData *webURL;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSDictionary *userInfo;

@end

NS_ASSUME_NONNULL_END
