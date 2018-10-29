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


#import "OCKCareContentsView.h"
#import "OCKCareCardDetailViewController.h"
#import "NSDateComponents+CarePlanInternal.h"
#import "OCKLabel.h"
#import "OCKCareCardTableViewCell.h"
#import "OCKSymptomTrackerTableViewCell.h"
#import "OCKReadOnlyTableViewCell.h"
#import "OCKCarePlanStore_Internal.h"
#import "OCKHelpers.h"
#import "OCKDefines_Private.h"


#define RedColor() OCKColorFromRGB(0xEF445B);


@interface OCKCareContentsView() <OCKCarePlanStoreDelegate, OCKCareCardCellDelegate, UITableViewDelegate, UITableViewDataSource>

@end


@implementation OCKCareContentsView {
    OCKLabel *_noActivitiesLabel;
    NSMutableArray<NSMutableArray<OCKCarePlanEvent *> *> *_events;
    NSMutableArray *_constraints;
    NSMutableArray *_sectionTitles;
    NSMutableArray<NSMutableArray <NSMutableArray <OCKCarePlanEvent *> *> *> *_tableViewData;
    NSMutableDictionary *_allEvents;
    NSCalendar *_calendar;
    
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

- (instancetype)initWithCarePlanStore:(OCKCarePlanStore *)store frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _store = store;
        _isGrouped = YES;
        _isSorted = YES;
        _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];

        self.backgroundColor = [UIColor blueColor];
        [self configure];
    }
    return self;
}

- (void)configure {
    _otherString = OCKLocalizedString(@"ACTIVITY_TYPE_OTHER_SECTION_HEADER", nil);
    _optionalString = OCKLocalizedString(@"ACTIVITY_TYPE_OPTIONAL_SECTION_HEADER", nil);
    _readOnlyString = OCKLocalizedString(@"ACTIVITY_TYPE_READ_ONLY_SECTION_HEADER", nil);
    if (self.optionalSectionHeader && ![self.optionalSectionHeader  isEqual: @""]) {
        _optionalString = _optionalSectionHeader;
    }
    if (self.readOnlySectionHeader && ![self.readOnlySectionHeader  isEqual: @""]) {
        _readOnlyString = _readOnlySectionHeader;
    }
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.store.symptomTrackerUIDelegate = self;
    self.store.careCardUIDelegate = self;
    NSDictionary *_initialDictionary = @{ @(OCKCarePlanActivityTypeAssessment): [NSMutableArray new],
                                         @(OCKCarePlanActivityTypeIntervention): [NSMutableArray new],
                                         @(OCKCarePlanActivityTypeReadOnly): [NSMutableArray new] };
    _allEvents = [_initialDictionary mutableCopy];
    
    self.dataSource = self;
    self.delegate = self;

    self.estimatedRowHeight = 90.0;
    self.rowHeight = UITableViewAutomaticDimension;
    self.tableFooterView = [UIView new];
    self.estimatedSectionHeaderHeight = 60;
    self.estimatedSectionFooterHeight = 0;
    self.showsVerticalScrollIndicator = NO;

    _noActivitiesLabel = [OCKLabel new];
    _noActivitiesLabel.hidden = YES;
    _noActivitiesLabel.textStyle = UIFontTextStyleTitle2;
    _noActivitiesLabel.textColor = [UIColor lightGrayColor];
    _noActivitiesLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _noActivitiesLabel.text = self.noActivitiesText;
    _noActivitiesLabel.numberOfLines = 0;
    _noActivitiesLabel.textAlignment = NSTextAlignmentCenter;
    self.backgroundView = _noActivitiesLabel;
    [self fetchEvents:[NSDateComponents ock_componentsWithDate:[NSDate date] calendar:_calendar]];
    //[self reloadData];
}

- (void)setNoActivitiesText:(NSString *)noActivitiesText {
    _noActivitiesText = noActivitiesText;
    _noActivitiesLabel.text = noActivitiesText;
}

#pragma mark - Helpers

- (void)connectCareCardView:(OCKCareCardView *)careCardView {
    self.careCardView = careCardView;
}

- (void)fetchEvents:(NSDateComponents *)selectedDate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchEventsOfType:OCKCarePlanActivityTypeIntervention selectedDate: selectedDate];
        [self fetchEventsOfType:OCKCarePlanActivityTypeAssessment selectedDate: selectedDate];
        [self fetchEventsOfType:OCKCarePlanActivityTypeReadOnly selectedDate: selectedDate];
    });
}

- (void)fetchEventsOfType:(OCKCarePlanActivityType)type selectedDate: (NSDateComponents *)selectedDate {
    [self.store eventsOnDate:selectedDate
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
                              [self.delegate respondsToSelector:@selector(careContentsView:willDisplayEvents:dateComponents:)]) {
                              [self.delegate careContentsView:self willDisplayEvents:[_events copy] dateComponents:_selectedDate];
                          }*/
                          [self createGroupedEventDictionaryForEvents];

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
                          [self reloadData];
                      });
                  }];
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

-(void)addActivity:(UIButton *)button {
    
    int section = (int)button.tag;
    if (_contentsViewDelegate &&
        [_contentsViewDelegate respondsToSelector:@selector(careContentsView:didSelectAddActivityGroupType:)]) {
        [_contentsViewDelegate careContentsView:self didSelectAddActivityGroupType:_sectionTitles[section]];
    }
}

-(void)update {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *today = [NSDateComponents ock_componentsWithDate:[NSDate date] calendar:calendar];
    [self fetchEvents:today];

    if (self.careCardView!=nil) {
        [self.careCardView fetchEvents];
    }
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    NSString *sectionTitle = _sectionTitles[section];
    if ([sectionTitle isEqualToString:_otherString] && (_sectionTitles.count == 1 || (_sectionTitles.count == 2 && [_sectionTitles containsObject:_optionalString]))) {
        sectionTitle = @"";
    }
    CGRect frame = CGRectMake(0.0, 0.0,tableView.frame.size.width , 60.0);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    OCKLabel *label = [OCKLabel new];
    label.text = [sectionTitle uppercaseString];
    label.frame = CGRectMake(10.0, 30.0, tableView.frame.size.width*0.5 , 30.0);
    label.textStyle = UIFontTextStyleCaption1;
    label.textColor = [UIColor darkTextColor];
    [headerView addSubview:label];
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.tag = section;
    button.frame = CGRectMake(tableView.frame.size.width - 58.0, 19.0, 22.0, 22.0);
    [button addTarget:self action:@selector(addActivity:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = _sectionTitles[section];
    if ([sectionTitle isEqualToString:_otherString] && (_sectionTitles.count == 1 || (_sectionTitles.count == 2 && [_sectionTitles containsObject:_optionalString]))) {
        sectionTitle = @"";
    }
    return sectionTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"didSelectRowAtIndexPath %@", indexPath);

    OCKCarePlanEvent *selectedEvent = _tableViewData[indexPath.section][indexPath.row].firstObject;
    _lastSelectedEvent = selectedEvent;
    _lastSelectedActivity = selectedEvent.activity;
    OCKCarePlanActivityType type = selectedEvent.activity.type;

    if (type == OCKCarePlanActivityTypeAssessment) {
        if (_contentsViewDelegate &&
            [_contentsViewDelegate respondsToSelector:@selector(careContentsView:didSelectRowWithAssessmentEvent:)]) {
            [_contentsViewDelegate careContentsView:self didSelectRowWithAssessmentEvent:selectedEvent];
        }
    }
    else if (type == OCKCarePlanActivityTypeReadOnly) {
        if ([self delegateCustomizesRowReadOnlySelection]) {
            [_contentsViewDelegate careContentsView:self didSelectRowWithReadOnlyActivity:selectedEvent.activity];
        } else {
            /* FIXME
            [self.navigationController pushViewController:[self detailViewControllerForActivity:selectedEvent.activity] animated:YES];*/
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_tableViewData[indexPath.section][indexPath.row].firstObject.activity.type == OCKCarePlanActivityTypeIntervention) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _tableViewData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableViewData[section].count;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSArray <OCKCarePlanEvent *> *events = _tableViewData[indexPath.section][indexPath.row];

    OCKCarePlanEvent *event = events.firstObject;
    OCKCarePlanActivity *activity = event.activity;
    OCKCarePlanActivityType type = activity.type;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[self detailViewControllerForActivity:activity]];

    [self.launchDelegate presentViewController:nav animated:YES completion:nil];

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

        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"CareCardCell";
        OCKCareCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[OCKCareCardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:CellIdentifier];
        }
        
        cell.interventionEvents = events;
        cell.delegate = self;
        
        return cell;
    }
    
    return nil;
}

- (UIViewController *)detailViewControllerForActivity:(OCKCarePlanActivity *)activity {
    OCKCareCardDetailViewController *detailViewController = [[OCKCareCardDetailViewController alloc] initWithIntervention:activity store:_store];
    return detailViewController;
}

- (OCKCarePlanActivity *)activityForIndexPath:(NSIndexPath *)indexPath {
    return _tableViewData[indexPath.section][indexPath.row].firstObject.activity;
}

- (BOOL)delegateCustomizesRowSelection {
    return self.contentsViewDelegate && [self.contentsViewDelegate respondsToSelector:@selector(careContentsView:didSelectRowWithInterventionActivity:)];
}

- (BOOL)delegateCustomizesRowReadOnlySelection {
    return self.contentsViewDelegate && [self.contentsViewDelegate respondsToSelector:@selector(careContentsView:didSelectRowWithReadOnlyActivity:)];
}


#pragma mark - OCKCareCardCellDelegate

- (void)careCardTableViewCell:(OCKCareCardTableViewCell *)cell didUpdateFrequencyofInterventionEvent:(OCKCarePlanEvent *)event {
    _lastSelectedEvent = event;
    _lastSelectedActivity = event.activity;

    if (self.delegate &&
        [self.contentsViewDelegate respondsToSelector:@selector(careContentsView:didSelectButtonWithInterventionEvent:)]) {
        [self.contentsViewDelegate careContentsView:self didSelectButtonWithInterventionEvent:event];
    }

    BOOL shouldHandleEventCompletion = YES;

    if (self.delegate &&
        [self.contentsViewDelegate respondsToSelector:@selector(careContentsView:shouldHandleEventCompletionForInterventionActivity:)]) {
        shouldHandleEventCompletion = [self.contentsViewDelegate careContentsView:self shouldHandleEventCompletionForInterventionActivity:event.activity];
    }

    if (shouldHandleEventCompletion) {
        OCKCarePlanEventState state = (event.state == OCKCarePlanEventStateCompleted) ? OCKCarePlanEventStateNotCompleted : OCKCarePlanEventStateCompleted;
        
        [self.store updateEvent:event
                     withResult:nil
                          state:state
                     completion:^(BOOL success, OCKCarePlanEvent * _Nonnull event, NSError * _Nonnull error) {
                         NSAssert(success, error.localizedDescription);
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSMutableArray *events = [cell.interventionEvents mutableCopy];
                             [events replaceObjectAtIndex:event.occurrenceIndexOfDay withObject:event];
                             cell.interventionEvents = events;
                             if (self.careCardView!=nil) {
                                 [self.careCardView fetchEvents];
                             }
                         });
                     }];
    }
}

- (void)careCardTableViewCell:(OCKCareCardTableViewCell *)cell didSelectInterventionActivity:(OCKCarePlanActivity *)activity {
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    OCKCarePlanActivity *selectedActivity = [self activityForIndexPath:indexPath];
    
    _lastSelectedEvent = nil;
    _lastSelectedActivity = selectedActivity;

    if ([self delegateCustomizesRowSelection]) {
        [self.contentsViewDelegate careContentsView:self didSelectRowWithInterventionActivity:activity];
    } else {
        NSLog(@"detailViewControllerForActivity");
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[self detailViewControllerForActivity:selectedActivity]];
        [self.launchDelegate presentViewController:nav animated:YES completion:nil];
    }
}


@end
