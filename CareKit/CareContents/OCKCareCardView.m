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


#import "OCKCareCardView.h"
#import "OCKWeekView.h"
#import "OCKCareCardDetailViewController.h"
#import "OCKWeekViewController.h"
#import "NSDateComponents+CarePlanInternal.h"
#import "OCKHeaderView.h"
#import "OCKLabel.h"
#import "OCKWeekLabelsView.h"
#import "OCKCarePlanStore_Internal.h"
#import "OCKHelpers.h"
#import "OCKDefines_Private.h"
#import "OCKGlyph_Internal.h"


#define RedColor() OCKColorFromRGB(0xEF445B);


@interface OCKCareCardView() <OCKWeekViewDelegate, OCKCarePlanStoreDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic) NSDateComponents *selectedDate;

@end


@implementation OCKCareCardView {
    NSMutableArray<NSMutableArray<OCKCarePlanEvent *> *> *_events;
    NSMutableArray *_weekValues;
    OCKHeaderView *_headerView;
    UIPageViewController *_pageViewController;
    OCKWeekViewController *_weekViewController;
    NSCalendar *_calendar;
    NSMutableArray<NSMutableArray <NSMutableArray <OCKCarePlanEvent *> *> *> *_tableViewData;
    NSMutableArray *_constraints;
    NSMutableDictionary *_allEvents;
 }

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithCarePlanStore:(OCKCarePlanStore *)store frame:(CGRect)frame {

    self = [super initWithFrame:frame];

     if (self) {
        _store = store;
        _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        _glyphTintColor = nil;
         [self configure];
    }
    return self;
}
/*
#pragma mark - UIResponder Overrides

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    return [super resignFirstResponder]
}

- (BOOL)resignFirstResponder
{
    return [self canResignFirstResponder];
}
*/

- (void)configure {

    self.backgroundColor = [UIColor whiteColor];
    self.store.symptomTrackerUIDelegate = self;
    self.store.careCardUIDelegate = self;
    [self setGlyphTintColor: _glyphTintColor];
    NSDictionary *_initialDictionary = @{ @(OCKCarePlanActivityTypeAssessment): [NSMutableArray new],
                                         @(OCKCarePlanActivityTypeIntervention): [NSMutableArray new],
                                         @(OCKCarePlanActivityTypeReadOnly): [NSMutableArray new] };
    _allEvents = [_initialDictionary mutableCopy];

    [self prepareView];
    self.selectedDate = [NSDateComponents ock_componentsWithDate:[NSDate date] calendar:_calendar];
    _weekViewController.weekView.delegate = self;

}


- (void)showToday:(id)sender {
    self.selectedDate = [NSDateComponents ock_componentsWithDate:[NSDate date] calendar:_calendar];
 }

- (void)prepareView {
    if (!_headerView) {
        _headerView = [[OCKHeaderView alloc] initWithFrame:CGRectZero];
        [self addSubview:_headerView];
    }
    
    _headerView.tintColor = self.glyphTintColor;
    if (self.glyphType == OCKGlyphTypeCustom) {
        UIImage *glyphImage = [self createCustomImageName:self.customGlyphImageName];
        _headerView.glyphImage = glyphImage;
    }
    _headerView.isCareCard = YES;
    _headerView.glyphType = self.glyphType;
    
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            _pageViewController.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
            
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = _pageViewController.view.bounds;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_pageViewController.view insertSubview:blurEffectView atIndex:_pageViewController.view.subviews.count-1];
        }
        else {
            _pageViewController.view.backgroundColor = [UIColor whiteColor];
        }
        
        OCKWeekViewController *weekController = [OCKWeekViewController new];
        weekController.weekView.delegate = _weekViewController.weekView.delegate;
        weekController.weekView.ringTintColor = self.glyphTintColor;
        weekController.weekView.isCareCard = YES;
        weekController.weekView.glyphType = self.glyphType;
        _weekViewController = weekController;
        
        [_pageViewController setViewControllers:@[weekController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [self addSubview:_pageViewController.view];
    }

    [self setUpConstraints];
}

- (void)setUpConstraints {
    [NSLayoutConstraint deactivateConstraints:_constraints];
    
    _constraints = [NSMutableArray new];
    
    _pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [_constraints addObjectsFromArray:@[
/*
                                        [NSLayoutConstraint constraintWithItem:_pageViewController.view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0],*/
                                        [NSLayoutConstraint constraintWithItem:_pageViewController.view
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_headerView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:10.0],
                                        [NSLayoutConstraint constraintWithItem:_pageViewController.view
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_pageViewController.view
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_pageViewController.view
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:65.0],
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:140.0],
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:65.0],
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:0.0]
                                        ]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)setSelectedDate:(NSDateComponents *)selectedDate {
    NSDateComponents *today = [self today];
    _selectedDate = [selectedDate isLaterThan:today] ? today : selectedDate;
    
    _weekViewController.weekView.isToday = [[self today] isEqualToDate:selectedDate];
    _weekViewController.weekView.selectedIndex = self.selectedDate.weekday - 1;
    
    [self fetchEvents];
    [self.careContentsView fetchEvents:_selectedDate];
}

- (void)setGlyphTintColor:(UIColor *)glyphTintColor {
    _glyphTintColor = glyphTintColor;
    if (!_glyphTintColor) {
        _glyphTintColor = [OCKGlyph defaultColorForGlyph:self.glyphType];
    }
    _weekViewController.weekView.tintColor = _glyphTintColor;
    _headerView.tintColor = _glyphTintColor;
}

- (void)setDelegate:(id<OCKCareCardViewDelegate>)delegate
{
    _delegate = delegate;

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
                          
                          if (self.delegate &&
                              [self.delegate respondsToSelector:@selector(careContentsViewController:willDisplayEvents:dateComponents:)]) {
                              [self.delegate careCardView:self willDisplayEvents:[_events copy] dateComponents:_selectedDate];
                          }
                          if (type == OCKCarePlanActivityTypeIntervention || type == OCKCarePlanActivityTypeAssessment) {
                              [self updateHeaderView];
                              [self updateWeekView];
                          }
                        });
                  }];

}

- (void)updateHeaderView {
    _headerView.date = [NSDateFormatter localizedStringFromDate:[_calendar dateFromComponents:self.selectedDate]
                                                      dateStyle:NSDateFormatterLongStyle
                                                      timeStyle:NSDateFormatterNoStyle];
    NSMutableArray *values = [NSMutableArray new];
    __block NSUInteger completedEvents;
    __block NSUInteger totalEvents;
    
    __weak __typeof__(self) weakSelf = self;
    
    [self.store dailyCompletionStatusWithType:OCKCarePlanActivityTypeIntervention
                                    startDate:self.selectedDate
                                      endDate:self.selectedDate
                                      handler:^(NSDateComponents *date, NSUInteger completedInterventionEvents, NSUInteger totalInterventionEvents) {
                                          
                                          completedEvents = completedInterventionEvents;
                                          totalEvents = totalInterventionEvents;
                                          
                                      } completion:^(BOOL completed, NSError *error) {
                                          NSAssert(!error, error.localizedDescription);
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              __typeof__(self) strongSelf = weakSelf;
                                              [strongSelf.store dailyCompletionStatusWithType:OCKCarePlanActivityTypeAssessment
                                                                                    startDate:strongSelf.selectedDate
                                                                                      endDate:strongSelf.selectedDate
                                                                                      handler:^(NSDateComponents *date, NSUInteger completedAssessmentEvents, NSUInteger totalAssessmentEvents) {
                                                                                          completedEvents = completedEvents + completedAssessmentEvents;
                                                                                          totalEvents = totalEvents + totalAssessmentEvents;
                                                                                          if (totalEvents == 0) {
                                                                                              [values addObject:@(1)];
                                                                                          } else {
                                                                                              [values addObject:@((float)completedEvents/totalEvents)];
                                                                                          }
                                                                                          
                                                                                      } completion:^(BOOL completed, NSError *error) {
                                                                                          NSAssert(!error, error.localizedDescription);
                                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                                              NSInteger selectedIndex = _weekViewController.weekView.selectedIndex;
                                                                                              [_weekValues replaceObjectAtIndex:selectedIndex withObject:values.firstObject];
                                                                                              _weekViewController.weekView.values = _weekValues;
                                                                                              _headerView.value = [values.firstObject doubleValue];
                                                                                          });
                                                                                      }];
                                          });
                                      }];
}

- (void)updateWeekView {
    NSDate *selectedDate = [_calendar dateFromComponents:self.selectedDate];
    NSDate *startOfWeek;
    NSTimeInterval interval;
    [_calendar rangeOfUnit:NSCalendarUnitWeekOfMonth
                 startDate:&startOfWeek
                  interval:&interval
                   forDate:selectedDate];
    NSDate *endOfWeek = [startOfWeek dateByAddingTimeInterval:interval-1];
    
    NSMutableArray *values = [NSMutableArray new];
    NSMutableArray *interventionCompleted = [NSMutableArray new];
    NSMutableArray *interventionTotal = [NSMutableArray new];
    NSMutableArray *assessmentCompleted = [NSMutableArray new];
    NSMutableArray *assessmentTotal = [NSMutableArray new];
    __weak __typeof__(self) weakSelf = self;
    [self.store dailyCompletionStatusWithType:OCKCarePlanActivityTypeIntervention
                                    startDate:[NSDateComponents ock_componentsWithDate:startOfWeek calendar:_calendar]
                                      endDate:[NSDateComponents ock_componentsWithDate:endOfWeek calendar:_calendar]
                                      handler:^(NSDateComponents *date, NSUInteger completedEvents, NSUInteger totalEvents) {
                                          [interventionCompleted addObject:@((float)completedEvents)];
                                          [interventionTotal addObject:@((float)totalEvents)];
                                      } completion:^(BOOL completed, NSError *error) {
                                          NSAssert(!error, error.localizedDescription);
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              __typeof__(self) strongSelf = weakSelf;
                                              [strongSelf.store dailyCompletionStatusWithType:OCKCarePlanActivityTypeAssessment
                                                                                    startDate:[NSDateComponents ock_componentsWithDate:startOfWeek calendar:_calendar]
                                                                                      endDate:[NSDateComponents ock_componentsWithDate:endOfWeek calendar:_calendar]
                                                                                      handler:^(NSDateComponents *date, NSUInteger completedEvents, NSUInteger totalEvents) {
                                                                                          [assessmentCompleted addObject:@((float)completedEvents)];
                                                                                          [assessmentTotal addObject:@((float)totalEvents)];
                                                                                      } completion:^(BOOL completed, NSError *error) {
                                                                                          NSAssert(!error, error.localizedDescription);
                                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                                              for (int i = 0; i<7; i++) {
                                                                                                  if (([interventionTotal[i] floatValue] + [assessmentTotal[i] floatValue]) == 0) {
                                                                                                      [values addObject:@(1)];
                                                                                                  } else {
                                                                                                      float completed = [interventionCompleted[i] floatValue] + [assessmentCompleted[i] floatValue];
                                                                                                      float total = [interventionTotal[i] floatValue] + [assessmentTotal[i] floatValue];
                                                                                                      [values addObject:@(completed/total)];
                                                                                                  }
                                                                                              }
                                                                                              _weekViewController.weekView.values = values;
                                                                                              _weekValues = [values mutableCopy];
                                                                                          });
                                                                                      }];
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

- (NSDateComponents *)dateFromSelectedIndex:(NSInteger)index {
    NSDateComponents *newComponents = [NSDateComponents new];
    newComponents.year = self.selectedDate.year;
    newComponents.month = self.selectedDate.month;
    newComponents.weekOfMonth = self.selectedDate.weekOfMonth;
    newComponents.weekday = index + 1;
    
    NSDate *newDate = [_calendar dateFromComponents:newComponents];
    return [NSDateComponents ock_componentsWithDate:newDate calendar:_calendar];
}

- (NSDateComponents *)today {
    return [NSDateComponents ock_componentsWithDate:[NSDate date] calendar:_calendar];
}


#pragma mark - OCKWeekViewDelegate

- (void)weekViewSelectionDidChange:(UIView *)weekView {
    OCKWeekView *currentWeekView = (OCKWeekView *)weekView;
    NSDateComponents *selectedDate = [self dateFromSelectedIndex:currentWeekView.selectedIndex];
    self.selectedDate = selectedDate;
}

- (BOOL)weekViewCanSelectDayAtIndex:(NSUInteger)index {
    NSDateComponents *today = [self today];
    NSDateComponents *selectedDate = [self dateFromSelectedIndex:index];
    return ![selectedDate isLaterThan:today];
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
                    [self updateHeaderView];
                }
                break;
            }
        }
    }
    
    if ([event.date isInSameWeekAsDate: self.selectedDate]) {
        [self updateWeekView];
    }
}

- (void)carePlanStoreActivityListDidChange:(OCKCarePlanStore *)store {
    [self fetchEvents];
    [self.careContentsView fetchEvents:self.selectedDate];
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        OCKWeekViewController *controller = (OCKWeekViewController *)pageViewController.viewControllers.firstObject;
        controller.weekView.delegate = _weekViewController.weekView.delegate;
        
        NSDateComponents *components = [NSDateComponents new];
        components.day = (controller.weekIndex > _weekViewController.weekIndex) ? 7 : -7;
        NSDate *newDate = [_calendar dateByAddingComponents:components toDate:[_calendar dateFromComponents:self.selectedDate] options:0];
        
        _weekViewController = controller;
        self.selectedDate = [NSDateComponents ock_componentsWithDate:newDate calendar:_calendar];
    }
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    OCKWeekViewController *controller = [OCKWeekViewController new];
    controller.weekIndex = ((OCKWeekViewController *)viewController).weekIndex - 1;
    controller.weekView.tintColor = self.glyphTintColor;
    controller.weekView.isCareCard = YES;
    controller.weekView.glyphType = self.glyphType;
    return controller;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    OCKWeekViewController *controller = [OCKWeekViewController new];
    controller.weekIndex = ((OCKWeekViewController *)viewController).weekIndex + 1;
    controller.weekView.tintColor = self.glyphTintColor;
    controller.weekView.isCareCard = YES;
    controller.weekView.glyphType = self.glyphType;
    return (![self.selectedDate isInSameWeekAsDate:[self today]]) ? controller : nil;
}

- (UIViewController *)detailViewControllerForActivity:(OCKCarePlanActivity *)activity {
    OCKCareCardDetailViewController *detailViewController = [[OCKCareCardDetailViewController alloc] initWithIntervention:activity store:_store];
    return detailViewController;
}


- (BOOL)delegateCustomizesRowSelection {
    return self.delegate && [self.delegate respondsToSelector:@selector(careCardView:didSelectRowWithInterventionActivity:)];
}

- (BOOL)delegateCustomizesRowReadOnlySelection {
    return self.delegate && [self.delegate respondsToSelector:@selector(careCardView:didSelectRowWithReadOnlyActivity:)];
}


@end
