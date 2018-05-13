/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
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


#import "OCKShareWithContactsViewController.h"
#import "OCKCareCardDetailViewController.h"
#import "OCKCareCardDetailHeaderView.h"
#import "OCKCareCardInstructionsTableViewCell.h"
#import "OCKCareCardAdditionalInfoTableViewCell.h"
#import "OCKCareCardSharingTableViewCell.h"
#import "OCKConnectTableViewCell.h"
#import "OCKConnectSharingTableViewCell.h"
#import "OCKDefines_Private.h"


static const CGFloat HeaderViewHeight = 100.0;


@interface OCKCareCardDetailViewController() <OCKShareWithContactsViewControllerDelegate>

@end

@implementation OCKCareCardDetailViewController {
    OCKCarePlanStore *_store;
    OCKCareCardDetailHeaderView *_headerView;
    NSMutableArray<NSString *> *_sectionTitles;
    NSString *_instructionsSectionTitle;
    NSString *_additionalInfoSectionTitle;
    NSString *_resultsSectionTitle;
    NSString *_sharingSectionTitle;
    UITableView *_tableView;
    NSMutableArray *_constraints;
    NSMutableArray<OCKContact *> *_sharingContacts;
    NSArray<OCKCarePlanEvent *> *_events;
}

- (instancetype)initWithIntervention:(OCKCarePlanActivity *)intervention store:(OCKCarePlanStore *)store {
    self = [super init];
    if (self) {
        _intervention = intervention;
        _store = store;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareView];
    //[_tableView setEditing: YES animated: YES];
}

- (void)prepareView {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:OCKLocalizedString(@"EDIT_SHARING", nil)
        style:UIBarButtonItemStylePlain target:self action:@selector(share:)];

    if (!_headerView) {
        _headerView = [[OCKCareCardDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HeaderViewHeight)];
        [self.view addSubview:_headerView];
    }
    _headerView.intervention = _intervention;
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    _tableView.estimatedRowHeight = 44.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [_store activityForIdentifier:_intervention.identifier completion:^(BOOL success, OCKCarePlanActivity * _Nullable activity,  NSError * _Nullable error) {

        _sharingContacts = [NSMutableArray arrayWithArray:activity.contacts];

        NSLog(@" INITIAL");
        for (OCKContact *contact in _sharingContacts) {
            NSLog(@"_sharingContacts %@", contact.name);
        }

        NSDateComponents *dateComponents = [[NSDateComponents alloc] initWithDate:[NSDate date]
                                                                         calendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
        [_store eventsForActivity:_intervention date:dateComponents completion:^(NSArray<OCKCarePlanEvent *> * _Nonnull events, NSError * _Nullable error) {
            _events = events;
            for (OCKCarePlanEvent *event in _events) {
                for (NSNumber *value in event.result.values) {
                    NSLog(@"%@ %@", event.result.creationDate, value);
                }
            }
            [self createTableViewDataArray];
        }];
   }];

    [self setUpConstraints];
}


- (void)share:(id)sender {
/*    NSArray* dataToShare = @[_intervention];

    UIActivityViewController *activityViewController =  [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = nil;
    [self presentViewController:activityViewController animated:YES completion:nil];
*/

    [_store contactsWithCompletion:^(BOOL success, NSArray<OCKContact *> * _Nonnull contacts, NSError * _Nullable error) {
        NSMutableArray *allContacts = [NSMutableArray arrayWithArray:contacts];
        OCKShareWithContactsViewController *shareViewController = [[OCKShareWithContactsViewController alloc] initWithContacts:allContacts sharingWith:_sharingContacts];

        shareViewController.delegate = self;

       UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shareViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }];

}
    
- (void)setUpConstraints {
    [NSLayoutConstraint deactivateConstraints:_constraints];
    
    _constraints = [NSMutableArray new];
    
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_constraints addObjectsFromArray:@[
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.topLayoutGuide
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:0.0],
                                        [NSLayoutConstraint constraintWithItem:_headerView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_tableView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:-1.0],
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
                                        [NSLayoutConstraint constraintWithItem:_tableView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0.0]
                                        ]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}


#pragma mark - Helpers

- (void)createTableViewDataArray {
    _sectionTitles = [NSMutableArray new];
    
    if (_intervention.instructions) {
        _instructionsSectionTitle = OCKLocalizedString(@"CARE_CARD_INSTRUCTIONS_SECTION_TITLE", nil);
        [_sectionTitles addObject:_instructionsSectionTitle];
    }
    
    if (_intervention.imageURL) {
        _additionalInfoSectionTitle = OCKLocalizedString(@"CARE_CARD_ADDITIONAL_INFO_SECTION_TITLE", nil);
        [_sectionTitles addObject:_additionalInfoSectionTitle];
    }

    if (_events && _events.count>0) {
        _resultsSectionTitle = OCKLocalizedString(@"CARE_CARD_RESULTS_SECTION_TITLE", nil);
        [_sectionTitles addObject:_resultsSectionTitle];
    }

    if (_sharingContacts && _sharingContacts.count>0) {
        _sharingSectionTitle = OCKLocalizedString(@"CARE_CARD_SHARING_SECTION_TITLE", nil);
        [_sectionTitles addObject:_sharingSectionTitle];
    }

}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = _sectionTitles[section];
    if ([sectionTitle isEqualToString: _resultsSectionTitle]) {
        return _events.count;
    } else if ([sectionTitle isEqualToString: _sharingSectionTitle]) {
        return _sharingContacts.count;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _sectionTitles[section];
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"willBeginEditingRowAtIndexPath");
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didEndEditingRowAtIndexPath");

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform the real delete action here. Note: you may need to check editing style
    //   if you do not perform delete only.
    NSLog(@"Deleted row.");

    [_sharingContacts removeObject:_sharingContacts[indexPath.row]];

    //__unsafe_unretained typeof(self) weakSelf = self;
    [_store setContacts:_sharingContacts  forActivity:_intervention completion:^(BOOL success, OCKCarePlanActivity * _Nullable activity, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            // Your UI update code here
        });
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = _sectionTitles[indexPath.section];
    if ([sectionTitle isEqualToString: _sharingSectionTitle]) {
        return YES;
    } else {
        return NO;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = _sectionTitles[indexPath.section];
    
    if ([sectionTitle isEqualToString:_instructionsSectionTitle]) {
        static NSString *InstructionsCellIdentifier = @"InstructionsCell";
        OCKCareCardInstructionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InstructionsCellIdentifier];
        if (!cell) {
            cell = [[OCKCareCardInstructionsTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:InstructionsCellIdentifier];
        }
        cell.intervention = _intervention;
        cell.layer.masksToBounds = YES;
        return cell;
    } else if ([sectionTitle isEqualToString:_additionalInfoSectionTitle]) {
        static NSString *AdditionalInfoCellIdentifier = @"AdditionalInfoCell";
        OCKCareCardAdditionalInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AdditionalInfoCellIdentifier];
        if (!cell) {
            cell = [[OCKCareCardAdditionalInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:AdditionalInfoCellIdentifier];
        }
        cell.intervention = _intervention;
        cell.layer.masksToBounds = YES;
        return cell;
    } else if ([sectionTitle isEqualToString: _resultsSectionTitle]) {
        static NSString *ResultsCellIdentifier = @"ResultsCell";
        OCKCareCardAdditionalInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ResultsCellIdentifier];
        if (!cell) {
            cell = [[OCKCareCardAdditionalInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:ResultsCellIdentifier];
        }
        cell.intervention = _intervention;
        cell.layer.masksToBounds = YES;
        return cell;
    } else if ([sectionTitle isEqualToString: _sharingSectionTitle]) {
        static NSString *SharingCellIdentifier = @"SharingCell";
        OCKConnectSharingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SharingCellIdentifier];
        if (!cell) {
            cell = [[OCKConnectSharingTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:SharingCellIdentifier];
        }
        cell.contact = _sharingContacts[indexPath.row];
        cell.intervention = _intervention;
        cell.store = _store;
        cell.layer.masksToBounds = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
   return nil;
}

- (void)shareViewController:(nonnull OCKShareWithContactsViewController *)shareViewController shareWith:(nonnull NSArray<OCKContact *> *)contacts {
    _sharingContacts = [[NSMutableArray alloc] initWithArray:contacts];

    for (OCKContact *contact in _sharingContacts) {
        NSLog(@"Share with %@", contact.name);
    }

    [_store setContacts:_sharingContacts forActivity:_intervention completion:^(BOOL success, OCKCarePlanActivity * _Nullable activity, NSError * _Nullable error) {
        NSLog(@"Update CD");

        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            // Your UI update code here
        });

    }];




}


@end
