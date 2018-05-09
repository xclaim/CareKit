/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 Copyright (c) 2017, Troy Tsubota. All rights reserved.
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
#import "NSDateComponents+CarePlanInternal.h"
#import "OCKCareCardTableViewCell.h"
#import "OCKSymptomTrackerTableViewCell.h"
#import "OCKReadOnlyTableViewCell.h"
#import "OCKLabel.h"
#import "OCKCarePlanStore_Internal.h"
#import "OCKHelpers.h"
#import "OCKDefines_Private.h"
#import "OCKGlyph_Internal.h"


#define RedColor() OCKColorFromRGB(0xEF445B);


@interface OCKShareActivitiesViewController() < OCKCarePlanStoreDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSDateComponents *selectedDate;

@end


@implementation OCKShareActivitiesViewController {
    NSCalendar *_calendar;
    NSMutableArray *_constraints;
    NSMutableArray *_sectionTitles;
    NSArray <OCKCarePlanActivity *> *_activities;
    NSMutableArray<NSMutableArray <NSMutableArray <OCKCarePlanEvent *> *> *> *_tableViewData;
    NSString *_otherString;
    NSString *_optionalString;
    BOOL _isGrouped;
    BOOL _isSorted;
    OCKLabel *_noActivitiesLabel;
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithCarePlanStore:(OCKCarePlanStore *)store {
    self = [super init];
    if (self) {
        _store = store;
        _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        _glyphTintColor = nil;
        _isGrouped = YES;
        _isSorted = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _otherString = OCKLocalizedString(@"ACTIVITY_TYPE_OTHER_SECTION_HEADER", nil);
    _optionalString = OCKLocalizedString(@"ACTIVITY_TYPE_OPTIONAL_SECTION_HEADER", nil);
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.store.careCardUIDelegate = self;
    
    [self setGlyphTintColor: _glyphTintColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:OCKLocalizedString(@"SAVE", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(save:)];
    self.navigationItem.rightBarButtonItem.tintColor = self.glyphTintColor;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];


    [_store activitiesWithCompletion:^(BOOL success, NSArray<OCKCarePlanActivity *> * _Nonnull activities, NSError * _Nullable error) {
        _activities = activities;

        for (OCKCarePlanActivity *activity in activities) {
            NSLog(@"activity %@",activity);
        }
    }];
    
    [self prepareView];

    _tableView.estimatedRowHeight = 90.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.tableFooterView = [UIView new];
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    _noActivitiesLabel = [OCKLabel new];
    _noActivitiesLabel.hidden = YES;
    _noActivitiesLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _noActivitiesLabel.textStyle = UIFontTextStyleTitle2;
    _noActivitiesLabel.textColor = [UIColor lightGrayColor];
    _noActivitiesLabel.text = self.noActivitiesText;
    _noActivitiesLabel.textAlignment = NSTextAlignmentCenter;
    _noActivitiesLabel.numberOfLines = 0;
    _tableView.backgroundView = _noActivitiesLabel;
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:245.0/255.0 green:244.0/255.0 blue:246.0/255.0 alpha:1.0]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSAssert(self.navigationController, @"OCKCareCardViewController must be embedded in a navigation controller.");
    
}

- (void)save:(id)sender {
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

- (void)setGlyphTintColor:(UIColor *)glyphTintColor {
    _glyphTintColor = glyphTintColor;
    if (!_glyphTintColor) {
        _glyphTintColor = [OCKGlyph defaultColorForGlyph:self.glyphType];
    }
    self.navigationItem.rightBarButtonItem.tintColor = _glyphTintColor;
}

- (void)setNoActivitiesText:(NSString *)noActivitiesText {
    _noActivitiesText = noActivitiesText;
    _noActivitiesLabel.text = noActivitiesText;
}

#pragma mark - Helpers

- (OCKCarePlanActivity *)activityForIndexPath:(NSIndexPath *)indexPath {
    return _tableViewData[indexPath.section][indexPath.row].firstObject.activity;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = _sectionTitles[section];

    if ([sectionTitle isEqualToString:_otherString] && (_sectionTitles.count == 1 || (_sectionTitles.count == 2 && [_sectionTitles containsObject:_optionalString]))) {
        sectionTitle = @"";
    }
    return sectionTitle;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; //_tableViewData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activities.count;

    //_tableViewData[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    OCKCarePlanActivity *activity = _activities[indexPath.row];
    OCKCarePlanActivityType type = activity.type;

    NSLog(@"type %d", type);

    if (type == OCKCarePlanActivityTypeIntervention) {

        static NSString *CellIdentifier = @"SymptomTrackerCell";
        OCKSymptomTrackerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[OCKSymptomTrackerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:CellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = activity.identifier;
        return cell;
    }
    else if (type == OCKCarePlanActivityTypeAssessment) {

        static NSString *CellIdentifier = @"SymptomTrackerCell";
        OCKSymptomTrackerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[OCKSymptomTrackerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = activity.title;

        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else if (type == OCKCarePlanActivityTypeReadOnly) {

        static NSString *CellIdentifier = @"ReadOnlyCell";
        OCKSymptomTrackerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[OCKSymptomTrackerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = activity.identifier;
        cell.accessoryType = UITableViewCellAccessoryNone;
       return cell;
    } else {
        NSLog(@" unhandled type");
    }
    

    return nil;
}
@end
