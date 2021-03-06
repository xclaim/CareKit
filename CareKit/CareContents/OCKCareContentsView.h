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


#import <CareKit/CareKit.h>


NS_ASSUME_NONNULL_BEGIN

@class OCKCarePlanStore, OCKCareContentsView, OCKCareCardView;


/**
 An object that adopts the `OCKCareContentsViewDelegate` protocol can use it to modify or update the events before they are displayed.
 */
@protocol OCKCareContentsViewDelegate <NSObject>

@required

/**
 Tells the delegate when the user selected an assessment event.

 @param view                The view providing the callback.
 @param assessmentEvent     The assessment event that the user selected.
 */
- (void)careContentsView:(OCKCareContentsView *)view didSelectRowWithAssessmentEvent:(OCKCarePlanEvent *)assessmentEvent;


/**
 Tells the delegate when the user selected to add an activity of a certain group type

 @param view                The view providing the callback.
 @param groupIdentifier     The groupIdentifier.
 */
- (void)careContentsView:(OCKCareContentsView *)view didSelectAddActivityGroupType:(NSString *)groupIdentifier;

@optional

/**
 Tells the delegate when the user tapped an intervention event.

 If the user must perform some activity in order to complete the intervention event,
 then this method can be implemented to show a custom view controller.

 If the completion status of the event is dependent on the presented activity, the developer can implement
 the `careCardView:shouldHandleEventCompletionForActivity` to control the completion status of the event.

 @param view                        The view providing the callback.
 @param interventionEvent           The intervention event that the user selected.
 */
- (void)careContentsView:(OCKCareContentsView *)view didSelectButtonWithInterventionEvent:(OCKCarePlanEvent *)interventionEvent;

/**
 Tells the delegate when the user selected an intervention activity.

 This can be implemented to show a custom detail view controller.
 If not implemented, a default detail view controller will be presented.

 @param view                The view providing the callback.
 @param interventionActivity        The intervention activity that the user selected.
 */
- (void)careContentsView:(OCKCareContentsView *)view didSelectRowWithInterventionActivity:(OCKCarePlanActivity *)interventionActivity;

/**
 Tells the delegate when the user selected a readonly activity.

 This can be implemented to show a custom detail view controller.
 If not implemented, a default detail view controller will be presented.

 @param view                        The view providing the callback.
 @param readOnlyActivity            The readonly activity that the user selected.
 */
- (void)careContentsView:(OCKCareContentsView *)view didSelectRowWithReadOnlyActivity:(OCKCarePlanActivity *)readOnlyActivity;

/**
 Asks the delegate if care view should automatically mark the state of an intervention activity when
 the user selects and deselects the intervention circle button. If this method is not implemented, care view
 handles all event completion by default.

 If returned NO, the `careCardView:didSelectButtonWithInterventionEvent` method can be implemeted to provide
 custom logic for completion.

 @param view              The view controller providing the callback.
 @param interventionActivity        The intervention activity that the user selected.
 */
- (BOOL)careContentsView:(OCKCareContentsView *)view shouldHandleEventCompletionForInterventionActivity:(OCKCarePlanActivity *)interventionActivity;

/**
 Tells the delegate when a new set of events is fetched from the care plan store.

 This is invoked when the date changes or when the care plan store's `carePlanStoreActivityListDidChange` delegate method is called.
 This provides a good opportunity to update the store such as fetching data from HealthKit.

 @param view                    The view providing the callback.
 @param events                  An array containing the fetched set of intervention events grouped by activity.
 @param dateComponents          The date components for which the events will be displayed.
 */
- (void)careContentsView:(OCKCareContentsView *)view willDisplayEvents:(NSArray<NSArray<OCKCarePlanEvent*>*>*)events dateComponents:(NSDateComponents *)dateComponents;

@end


/**
 The `OCKCareContentsView` class is a view that displays the activities and events from an `OCKCarePlanStore` that are of
 intervention type (see `OCKCarePlanActivityTypeIntervention`), assessment type (see `OCKCarePlanActivityTypeAssessment`), and read only 
 intervention and assessment types (see `OCKCarePlanActivityTypeReadOnly`).
 
 Activities can include a detail view. Therefore, it must be embedded inside a `UINavigationController`.
 */
OCK_CLASS_AVAILABLE
@interface OCKCareContentsView : UITableView

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized care view controller using the specified store.
 
 @param store        A care plan store.
 
 @return An initialized care contents view controller.
 */
- (instancetype)initWithCarePlanStore:(OCKCarePlanStore *)store frame:(CGRect)frame;;


- (void)connectCareCardView:(OCKCareCardView *)careCardView;


/**
 Updates the view for the selected date

 @param selectedDate        The date from the OCKWeekViewController.

 */

- (void)fetchEvents:(NSDateComponents *)selectedDate;

/**
 The care plan store that provides the content for the care card.
 
 The care view displays activites and events of type intervention, assessment, intervention read-only, 
 and assessment read-only (see `OCKCarePlanActivityType`).
 */
@property (nonatomic, readonly) OCKCarePlanStore *store;


/**
 The last activity selected by the user.
 
 This value is nil if no activity has been selected yet.
 */
@property (nonatomic, readonly, nullable) OCKCarePlanActivity *lastSelectedActivity;


/**
 The last event selected by the user.
 
 This value is nil if no event has been selected yet.
 */
@property (nonatomic, readonly, nullable) OCKCarePlanEvent *lastSelectedEvent;


/**
 The delegate can be used to modify or update the internvention events before they are displayed.
 
 See the `OCKCareContentsViewDelegate` protocol.
 */
@property (nonatomic, weak, nullable) id<OCKCareContentsViewDelegate> contentsViewDelegate;

/**
 The section header title for all the Optional activities. Default is `Optional` if nil.
 */
@property (nonatomic, nullable) NSString *optionalSectionHeader;

/**
 The section header title for all the ReadOnly activities. Default is `Read Only` if nil.
 */
@property (nonatomic, nullable) NSString *readOnlySectionHeader;

/**
 Optional: A message that will be displayed in the table view's background view
 if there are no interventions, assessments, or ReadOnly activities to display.
 */
@property (nonatomic, nullable) NSString *noActivitiesText;

/**
 The property that allows activities to be grouped.
 
 If true, the activities will be grouped by groupIdentifier into sections,
 otherwise the activities will all be in one section and groupIdentifier is ignored.
  
 The default is true.
 */
@property (nonatomic) BOOL isGrouped;

/**
 The property that allows activities to be sorted.
 
 If true, the activities will be sorted alphabetically by title and by groupIdentifier if isGrouped is true,
 otherwise the activities will be sorted in the order they are added in the care plan store.
 
 The default is true.
 */

@property (nonatomic) BOOL isSorted;


/**
 The OCKCareCardView
 */


@property (nonatomic, nullable) OCKCareCardView *careCardView;

@property (nonatomic, nullable) UIViewController *launchDelegate;

-(void)update;

@end

NS_ASSUME_NONNULL_END
