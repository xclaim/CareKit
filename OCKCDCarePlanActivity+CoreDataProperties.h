//
//  OCKCDCarePlanActivity+CoreDataProperties.h
//  CareKit
//
//  Created by Johan Sellström on 2018-05-01.
//  Copyright © 2018 carekit.org. All rights reserved.
//
//

#import "OCKCDCarePlanActivity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OCKCDCarePlanActivity (CoreDataProperties)

+ (NSFetchRequest<OCKCDCarePlanActivity *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *color;
@property (nullable, nonatomic, copy) NSString *groupIdentifier;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, retain) NSObject *imageURL;
@property (nullable, nonatomic, copy) NSString *instructions;
@property (nullable, nonatomic, copy) NSNumber *optional;
@property (nullable, nonatomic, copy) NSNumber *resultResettable;
@property (nullable, nonatomic, retain) NSObject *schedule;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, retain) NSObject *thresholds;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSNumber *type;
@property (nullable, nonatomic, retain) NSObject *userInfo;
@property (nullable, nonatomic, retain) NSSet<OCKCDCarePlanEvent *> *events;
@property (nullable, nonatomic, retain) NSSet<OCKCDContact *> *contacts;

@end

@interface OCKCDCarePlanActivity (CoreDataGeneratedAccessors)

- (void)addEventsObject:(OCKCDCarePlanEvent *)value;
- (void)removeEventsObject:(OCKCDCarePlanEvent *)value;
- (void)addEvents:(NSSet<OCKCDCarePlanEvent *> *)values;
- (void)removeEvents:(NSSet<OCKCDCarePlanEvent *> *)values;

- (void)addContactsObject:(OCKCDContact *)value;
- (void)removeContactsObject:(OCKCDContact *)value;
- (void)addContacts:(NSSet<OCKCDContact *> *)values;
- (void)removeContacts:(NSSet<OCKCDContact *> *)values;

@end

NS_ASSUME_NONNULL_END
