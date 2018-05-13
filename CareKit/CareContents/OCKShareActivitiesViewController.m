/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 Copyright (c) 2017, Erik Hornberger. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "OCKShareActivitiesViewController.h"
#import "OCKCareCardDetailViewController.h"
#import "NSDateComponents+CarePlanInternal.h"
#import "OCKLabel.h"
#import "OCKCareCardTableViewCell.h"
#import "OCKSymptomTrackerTableViewCell.h"
#import "OCKReadOnlyTableViewCell.h"
#import "OCKCarePlanStore_Internal.h"
#import "OCKHelpers.h"
#import "OCKDefines_Private.h"
#import "OCKGlyph_Internal.h"


#define RedColor() OCKColorFromRGB(0xEF445B);


@interface OCKShareActivitiesViewController() <OCKCarePlanStoreDelegate, OCKCareCardCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSDateComponents *selectedDate;

@end


@implementation OCKShareActivitiesViewController {
    UITableView *_tableView;
    UIRefreshControl *_refreshControl;
    OCKLabel *_noActivitiesLabel;
    NSMutableArray<NSMutableArray<OCKCarePlanEvent *> *> *_events;
    NSCalendar *_calendar;
    NSMutableArray *_constraints;
    NSMutableArray *_sectionTitles;
    NSMutableArray<NSMutableArray <NSMutableArray <OCKCarePlanEvent *> *> *> *_tableViewData;
    NSMutableDictionary *_allEvents;
    NSMutableArray <OCKCarePlanActivity *> *_selectedActivities;
    BOOL _hasInterventions;
    BOOL _hasAssessments;
    BOOL _hasReadOnlyItems;
    
    NSString *_otherString;
    NSString *_optionalString;
    NSString *_readOnlyString;
    BOOL _isGrouped;
    BOOL _isSorted;
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithCarePlanStore:(OCKCarePlanStore *)store sharing:(NSArray <OCKCarePlanActivity *> *)sharingActivities; {
    self = [super init];
    if (self) {
        _store = store;
        _selectedActivities =  [NSMutableArray arrayWithArray:sharingActivities];
        _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        _glyphTintColor = nil;
        _isGrouped = YES;
        _isSorted = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = OCKLocalizedString(@"SHARE_ACTIVITIES", nil);
    _otherString = OCKLocalizedString(@"ACTIVITY_TYPE_OTHER_SECTION_HEADER", nil);
    _optionalString = OCKLocalizedString(@"ACTIVITY_TYPE_OPTIONAL_SECTION_HEADER", nil);
    _readOnlyString = OCKLocalizedString(@"ACTIVITY_TYPE_READ_ONLY_SECTION_HEADER", nil);
    if (self.optionalSectionHeader && ![self.optionalSectionHeader  isEqual: @""]) {
        _optionalString = _optionalSectionHeader;
    }
    if (self.readOnlySectionHeader && ![self.readOnlySectionHeader  isEqual: @""]) {
        _readOnlyString = _readOnlySectionHeader;
    }
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.store.symptomTrackerUIDelegate = self;
    self.store.careCardUIDelegate = self;
    [self setGlyphTintColor: _glyphTintColor];
    NSDictionary *_initialDictionary = @{ @(OCKCarePlanActivityTypeAssessment): [NSMutableArray new],
                                         @(OCKCarePlanActivityTypeIntervention): [NSMutableArray new],
                                         @(OCKCarePlanActivityTypeReadOnly): [NSMutableArray new] };
    _allEvents = [_initialDictionary mutableCopy];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(share:)];
    self.navigationItem.rightBarButtonItem.tintColor = self.glyphTintColor;

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self prepareView];
    self.selectedDate = [NSDateComponents ock_componentsWithDate:[NSDate date] calendar:_calendar];
    _tableView.estimatedRowHeight = 90.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.tableFooterView = [UIView new];
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;

    _noActivitiesLabel = [OCKLabel new];
    _noActivitiesLabel.hidden = YES;
    _noActivitiesLabel.textStyle = UIFontTextStyleTitle2;
    _noActivitiesLabel.textColor = [UIColor lightGrayColor];
    _noActivitiesLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _noActivitiesLabel.text = self.noActivitiesText;
    _noActivitiesLabel.numberOfLines = 0;
    _noActivitiesLabel.textAlignment = NSTextAlignmentCenter;
    _tableView.backgroundView = _noActivitiesLabel;
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:245.0/255.0 green:244.0/255.0 blue:246.0/255.0 alpha:1.0]];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSAssert(self.navigationController, @"OCKCareViewController must be embedded in a navigation controller.");
}

- (void)share:(id)sender {
    NSLog(@"Callback");

    for (OCKCarePlanActivity *activity in _selectedActivities) {
        NSLog(@"%@ ",activity.identifier);
    }
    NSLog(@"\n");

    if (self.delegate && [self.delegate respondsToSelector:@selector(shareViewController:shareWith:)]) {
        [self.delegate shareViewController:self shareWith:_selectedActivities];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)prepareView {
    
    _tableView.showsVerticalScrollIndicator = NO;
    
    [self setUpConstraints];
}

- (void)setUpConstraints {
    [NSLayoutConstraint deactivateConstraints:_constraints];
    
    _constraints = [NSMutableArray new];
    
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;

    
    [_constraints addObjectsFromArray:@[
                                        [NSLayoutConstraint constraintWithItem:_tableView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_tableView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_tableView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_tableView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                          ]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)setSelectedDate:(NSDateComponents *)selectedDate {
    NSDateComponents *today = [self today];
    _selectedDate = [selectedDate isLaterThan:today] ? today : selectedDate;

    [self fetchEvents];
}

- (void)setGlyphTintColor:(UIColor *)glyphTintColor {
    _glyphTintColor = glyphTintColor;
    if (!_glyphTintColor) {
        _glyphTintColor = [OCKGlyph defaultColorForGlyph:self.glyphType];
    }
    self.navigationItem.rightBarButtonItem.tintColor = _glyphTintColor;
}

- (void)setDelegate:(id<OCKShareActivitiesViewControllerDelegate>)delegate
{
    _delegate = delegate;
    
}

- (void)setNoActivitiesText:(NSString *)noActivitiesText {
    _noActivitiesText = noActivitiesText;
    _noActivitiesLabel.text = noActivitiesText;
}

#pragma mark - Helpers

- (void)fetchEvents {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchEventsOfType:OCKCarePlanActivityTypeIntervention];
        [self fetchEventsOfType:OCKCarePlanActivityTypeAssessment];
        [self fetchEventsOfType:OCKCarePlanActivityTypeReadOnly];
    });
}

- (void)fetchEventsOfType:(OCKCarePlanActivityType)type {
    [self.store eventsOnDate:self.selectedDate
                        type:type
                  completion:^(NSArray<NSArray<OCKCarePlanEvent *> *> *eventsGroupedByActivity, NSError *error) {
                      NSAssert(!error, error.localizedDescription);
                      dispatch_async(dispatch_get_main_queue(), ^{
                          _events = [NSMutableArray new];
                          for (NSArray<OCKCarePlanEvent *> *events in eventsGroupedByActivity) {
                              [_events addObject:[events mutableCopy]];
                          }
                          [_allEvents setObject:_events forKey:@(type)];
                          /*
                          if (self.delegate &&
                              [self.delegate respondsToSelector:@selector(careContentsViewController:willDisplayEvents:dateComponents:)]) {
                              [self.delegate careContentsViewController:self willDisplayEvents:[_events copy] dateComponents:_selectedDate];
                          }*/
                          [self createGroupedEventDictionaryForEvents];
                          if (type == OCKCarePlanActivityTypeIntervention || type == OCKCarePlanActivityTypeAssessment) {
                          }
                          
                          switch (type) {
                              case OCKCarePlanActivityTypeIntervention:
                                  _hasInterventions = _events.count > 0;
                                  break;
                                  
                              case OCKCarePlanActivityTypeAssessment:
                                  _hasAssessments = _events.count > 0;
                                  break;
                                  
                              case OCKCarePlanActivityTypeReadOnly:
                                  _hasReadOnlyItems = _events.count > 0;
                                  break;
                                  
                              default:
                                  break;
                          }
                          _noActivitiesLabel.hidden = _hasAssessments || _hasInterventions || _hasReadOnlyItems;
                          [_tableView reloadData];
                      });
                  }];

}


- (UIImage *)createCustomImageName:(NSString*)customImageName {
    UIImage *customImageToReturn;
    if (customImageName != nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        customImageToReturn = [UIImage imageNamed: customImageName inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        OCKGlyphType defaultGlyph = OCKGlyphTypeHeart;
        customImageToReturn = [[OCKGlyph glyphImageForType:defaultGlyph] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return customImageToReturn;
}


- (NSDateComponents *)today {
    return [NSDateComponents ock_componentsWithDate:[NSDate date] calendar:_calendar];
}

- (void)createGroupedEventDictionaryForEvents {

    NSArray<OCKCarePlanEvent *> *interventions = _allEvents[@(OCKCarePlanActivityTypeIntervention)];
    NSArray<OCKCarePlanEvent *> *assessments = _allEvents[@(OCKCarePlanActivityTypeAssessment)];
    NSArray<OCKCarePlanEvent *> *readOnly = _allEvents[@(OCKCarePlanActivityTypeReadOnly)];
    
    NSMutableArray *interventionGroupIdentifiers = [[NSMutableArray alloc] init];
    NSMutableArray *assessmentGroupIdentifiers = [[NSMutableArray alloc] init];
    
    NSArray<NSArray<OCKCarePlanEvent *> *> *events = [NSArray arrayWithArray:[interventions arrayByAddingObjectsFromArray:[assessments arrayByAddingObjectsFromArray:readOnly]]];
    NSMutableDictionary *groupedEvents = [NSMutableDictionary new];
    NSMutableArray *groupArray = [NSMutableArray new];
    
    for (NSArray<OCKCarePlanEvent *> *activityEvents in events) {
        OCKCarePlanEvent *firstEvent = activityEvents.firstObject;
        
        if (firstEvent.activity.groupIdentifier && firstEvent.activity.type == OCKCarePlanActivityTypeIntervention) {
            if (![interventionGroupIdentifiers containsObject:firstEvent.activity.groupIdentifier]) {
                [interventionGroupIdentifiers addObject:firstEvent.activity.groupIdentifier];
            }
        }
        
        if (firstEvent.activity.groupIdentifier && firstEvent.activity.type == OCKCarePlanActivityTypeAssessment) {
            if (![assessmentGroupIdentifiers containsObject:firstEvent.activity.groupIdentifier]) {
                [assessmentGroupIdentifiers addObject:firstEvent.activity.groupIdentifier];
            }
        }
        
        NSString *groupIdentifier = firstEvent.activity.groupIdentifier ? firstEvent.activity.groupIdentifier : _otherString;
        
        if (firstEvent.activity.optional) {
            groupIdentifier = firstEvent.activity.type == OCKCarePlanActivityTypeReadOnly ? _readOnlyString : _optionalString;
        }
        
        if (!_isGrouped) {
            // Force only one grouping
            groupIdentifier = _otherString;
        }
        
        if (groupedEvents[groupIdentifier]) {
            NSMutableArray<NSArray *> *objects = [groupedEvents[groupIdentifier] mutableCopy];
            [objects addObject:activityEvents];
            groupedEvents[groupIdentifier] = objects;
        } else {
            NSMutableArray<NSArray *> *objects = [activityEvents mutableCopy];
            groupedEvents[groupIdentifier] = @[objects];
            [groupArray addObject:groupIdentifier];
        }
    }
    
    if (_isGrouped && _isSorted) {
        
        NSMutableArray *sortedKeys = [[groupedEvents.allKeys sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        
        for (NSString *groupIdentifier in interventionGroupIdentifiers) {
            if ([sortedKeys containsObject:groupIdentifier]) {
                [sortedKeys removeObject:groupIdentifier];
                [sortedKeys addObject:groupIdentifier];
            }
        }
        
        for (NSString *groupIdentifier in assessmentGroupIdentifiers) {
            if ([sortedKeys containsObject:groupIdentifier]) {
                [sortedKeys removeObject:groupIdentifier];
                [sortedKeys addObject:groupIdentifier];
            }
        }
        
        if ([sortedKeys containsObject:_otherString]) {
            [sortedKeys removeObject:_otherString];
            [sortedKeys addObject:_otherString];
        }
        
        if ([sortedKeys containsObject:_optionalString]) {
            [sortedKeys removeObject:_optionalString];
            [sortedKeys addObject:_optionalString];
        }
        
        if ([sortedKeys containsObject:_readOnlyString]) {
            [sortedKeys removeObject:_readOnlyString];
            [sortedKeys addObject:_readOnlyString];
        }
        
        _sectionTitles = [sortedKeys copy];
        
    } else {
        
        _sectionTitles = [groupArray mutableCopy];
        
    }
    
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *key in _sectionTitles) {
        NSMutableArray *groupArray = [NSMutableArray new];
        NSArray *groupedEventsArray = groupedEvents[key];
        
        if (_isSorted) {
            
            NSMutableDictionary *activitiesDictionary = [NSMutableDictionary new];
            for (NSArray<OCKCarePlanEvent *> *events in groupedEventsArray) {
                NSString *activityTitle = events.firstObject.activity.title;
                activitiesDictionary[activityTitle] = events;
            }
            
            NSArray *sortedActivitiesKeys = [activitiesDictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
            for (NSString *activityKey in sortedActivitiesKeys) {
                [groupArray addObject:activitiesDictionary[activityKey]];
            }
            [array addObject:groupArray];
            
        } else {
            
            [array addObject:[groupedEventsArray mutableCopy]];
            
        }
    }
    _tableViewData = [array mutableCopy];
}


#pragma mark - OCKCarePlanStoreDelegate

- (void)carePlanStore:(OCKCarePlanStore *)store didReceiveUpdateOfEvent:(OCKCarePlanEvent *)event {
    for (int i = 0; i < _tableViewData.count; i++) {
        NSMutableArray<NSMutableArray <OCKCarePlanEvent *> *> *groupedEvents = _tableViewData[i];
        
        for (int j = 0; j < groupedEvents.count; j++) {
            NSMutableArray<OCKCarePlanEvent *> *events = groupedEvents[j];
            
            if ([events.firstObject.activity.identifier isEqualToString:event.activity.identifier]) {
                if (events[event.occurrenceIndexOfDay].numberOfDaysSinceStart == event.numberOfDaysSinceStart) {
                    [events replaceObjectAtIndex:event.occurrenceIndexOfDay withObject:event];
                    _tableViewData[i][j] = events;

                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    OCKCarePlanActivityType type = _tableViewData[indexPath.section][indexPath.row].firstObject.activity.type;
                    if ( type == OCKCarePlanActivityTypeIntervention) {
                        OCKCareCardTableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
                        cell.interventionEvents = events;
                    } else if (type == OCKCarePlanActivityTypeAssessment) {
                        OCKSymptomTrackerTableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
                        cell.assessmentEvent = events.firstObject;
                    }
                }
                break;
            }
        }
    }

}

- (void)carePlanStoreActivityListDidChange:(OCKCarePlanStore *)store {
    [self fetchEvents];
}



#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = _sectionTitles[section];
    if ([sectionTitle isEqualToString:_otherString] && (_sectionTitles.count == 1 || (_sectionTitles.count == 2 && [_sectionTitles containsObject:_optionalString]))) {
        sectionTitle = @"";
    }
    return sectionTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OCKCarePlanEvent *selectedEvent = _tableViewData[indexPath.section][indexPath.row].firstObject;
    OCKCarePlanActivity *selectedActivity = selectedEvent.activity;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_selectedActivities containsObject:selectedActivity]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [_selectedActivities removeObject:selectedActivity];
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_selectedActivities addObject:selectedActivity];
        }
    });
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _tableViewData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableViewData[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray <OCKCarePlanEvent *> *events = _tableViewData[indexPath.section][indexPath.row];
    
    OCKCarePlanEvent *event = events.firstObject;
    OCKCarePlanActivity *activity = event.activity;
    OCKCarePlanActivityType type = activity.type;
    
    if (type == OCKCarePlanActivityTypeAssessment) {
        static NSString *CellIdentifier = @"SymptomTrackerCell";
        OCKSymptomTrackerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[OCKSymptomTrackerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:CellIdentifier];
        }
        cell.assessmentEvent = event;
        cell.accessoryType = UITableViewCellAccessoryNone;
        for (OCKCarePlanActivity *selectedActivity in _selectedActivities) {
            NSLog(@"%@ %@",selectedActivity.identifier,activity.identifier);
            if ([selectedActivity.identifier isEqualToString:activity.identifier]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        return cell;
    }
    else if (type == OCKCarePlanActivityTypeReadOnly) {
        
        static NSString *CellIdentifier = @"ReadOnlyCell";
        OCKReadOnlyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[OCKReadOnlyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:CellIdentifier];
        }
        
        cell.readOnlyEvent = event;
        cell.accessoryType = UITableViewCellAccessoryNone;
        for (OCKCarePlanActivity *selectedActivity in _selectedActivities) {
            NSLog(@"%@ %@",selectedActivity.identifier,activity.identifier);
            if ([selectedActivity.identifier isEqualToString:activity.identifier]) {
               cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"CareCardCell";
        OCKCareCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[OCKCareCardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:CellIdentifier];
        }
        //cell.readOnly = YES;
        cell.interventionEvents = events;
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSLog(@"\nTESTING");
        for (OCKCarePlanActivity *selectedActivity in _selectedActivities) {
            NSLog(@"%@ %@",selectedActivity.identifier,activity.identifier);
            if ([selectedActivity.identifier isEqualToString:activity.identifier]) {
                NSLog(@"MATCH");
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        NSLog(@"DONE\n");
        return cell;
    }
    
    return nil;
}

- (OCKCarePlanActivity *)activityForIndexPath:(NSIndexPath *)indexPath {
    return _tableViewData[indexPath.section][indexPath.row].firstObject.activity;
}

@end
