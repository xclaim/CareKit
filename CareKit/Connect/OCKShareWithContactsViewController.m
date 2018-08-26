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


#import "OCKShareWithContactsViewController.h"
#import "OCKConnectSharingTableViewCell.h"
#import "OCKContact.h"
#import "OCKHelpers.h"
#import "OCKDefines_Private.h"
#import "OCKLabel.h"


@interface OCKShareWithContactsViewController() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation OCKShareWithContactsViewController {
    UITableView *_tableView;
    NSMutableArray *_constraints;
    NSMutableArray<NSArray<OCKContact *>*> *_sectionedContacts;
    NSMutableArray <OCKContact *> *_selectedContacts;
    NSMutableArray<NSString *> *_sectionTitles;
    OCKLabel *_noContactsLabel;
}

+ (instancetype)new {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithContacts:(NSArray<OCKContact *> *)contacts sharingWith:(nullable NSArray<OCKContact *> *)sharingContacts {
    self = [super init];
    if (self) {
        _contacts = OCKArrayCopyObjects(contacts);
        _sharingContacts = OCKArrayCopyObjects(sharingContacts);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OCKLocalizedString(@"SHARE_WITH", nil);

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];

    _tableView.estimatedRowHeight = 44.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(share:)];

    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:245.0/255.0 green:244.0/255.0 blue:246.0/255.0 alpha:1.0]];
    
    [self createSectionedContacts];
    [self prepareHeaderView];
}

- (void)prepareHeaderView {
    if (self.contacts.count == 0) {
        if (!_noContactsLabel) {
            _noContactsLabel = [OCKLabel new];
            _noContactsLabel.textStyle = UIFontTextStyleTitle2;
            _noContactsLabel.text = OCKLocalizedString(@"CONNECT_NO_CONTACTS_TITLE", nil);
            _noContactsLabel.textColor = [UIColor lightGrayColor];
        }
        [self.view addSubview:_noContactsLabel];
    } else {
        [_noContactsLabel removeFromSuperview];
    }
}

- (void)share:(id)sender {
    NSLog(@"Callback");

    for (OCKContact *contacts in _selectedContacts) {
        NSLog(@"%@ ",contacts.name);
    }
    NSLog(@"\n");

    if (self.delegate && [self.delegate respondsToSelector:@selector(shareViewController:shareWith:)]) {
        [self.delegate shareViewController:self shareWith:_selectedContacts];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSAssert(self.navigationController, @"OCKShareWithContactdViewController must be embedded in a navigation controller.");
}

- (void)setContacts:(NSArray<OCKContact *> *)contacts {
    _contacts = OCKArrayCopyObjects(contacts);
    [self createSectionedContacts];
    [_tableView reloadData];
}

- (void)setSharingContacts:(NSArray<OCKContact *> *)sharingContacts {
    _sharingContacts = OCKArrayCopyObjects(sharingContacts);
    [self createSectionedContacts];
    [_tableView reloadData];
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
    
    if (self.contacts.count == 0) {
        _noContactsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_constraints addObjectsFromArray:@[
                                            [NSLayoutConstraint constraintWithItem:_noContactsLabel
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0],
                                            [NSLayoutConstraint constraintWithItem:_noContactsLabel
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0]
                                            ]];
    }
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)createSectionedContacts {
    _sectionedContacts = [NSMutableArray new];
    _selectedContacts = [[NSMutableArray alloc] initWithArray:_sharingContacts];
    _sectionTitles = [NSMutableArray new];
        
    NSMutableArray *careTeamContacts = [NSMutableArray new];
    NSMutableArray *delegateContacts = [NSMutableArray new];
    NSMutableArray *patientContacts = [NSMutableArray new];
    NSMutableArray *personalContacts = [NSMutableArray new];
    NSMutableArray *groupContacts = [NSMutableArray new];
    NSMutableArray *deviceContacts = [NSMutableArray new];
    NSMutableArray *contactContacts = [NSMutableArray new];

    for (OCKContact *contact in self.contacts) {
        switch (contact.type) {
            case OCKContactTypeCareTeam:
                [careTeamContacts addObject:contact];
                break;
            case OCKContactTypePatient:
                [patientContacts addObject:contact];
                break;
            case OCKContactTypeContact:
                [contactContacts addObject:contact];
                break;
            case OCKContactTypePersonal:
                [personalContacts addObject:contact];
                break;
            case OCKContactTypeGroup:
                [groupContacts addObject:contact];
                break;
            case OCKContactTypeDevice:
                [deviceContacts addObject:contact];
                break;
        }
        switch (contact.role) {
            case OCKContactRoleRecoveryDelegate:
                [delegateContacts addObject:contact];
                break;
        }
    }
    
    if (careTeamContacts.count > 0) {
        [_sectionedContacts addObject:[careTeamContacts copy]];
        [_sectionTitles addObject:OCKLocalizedString(@"CARE_TEAM_SECTION_TITLE", nil)];
    }

    if (delegateContacts.count > 0) {
        [_sectionedContacts addObject:[delegateContacts copy]];
        [_sectionTitles addObject:OCKLocalizedString(@"DELEGATES_SECTION_TITLE", nil)];
    }

    if (patientContacts.count > 0) {
        [_sectionedContacts addObject:[patientContacts copy]];
        [_sectionTitles addObject:OCKLocalizedString(@"PATIENT_SECTION_TITLE", nil)];
    }

    if (contactContacts.count > 0) {
        [_sectionedContacts addObject:[contactContacts copy]];
        [_sectionTitles addObject:OCKLocalizedString(@"CONTACT_SECTION_TITLE", nil)];
    }

    if (personalContacts.count > 0) {
        [_sectionedContacts addObject:[personalContacts copy]];
        [_sectionTitles addObject:OCKLocalizedString(@"PERSONAL_SECTION_TITLE", nil)];
    }

    if (groupContacts.count > 0) {
        [_sectionedContacts addObject:[groupContacts copy]];
        [_sectionTitles addObject:OCKLocalizedString(@"GROUP_SECTION_TITLE", nil)];
    }

    if (deviceContacts.count > 0) {
        [_sectionedContacts addObject:[deviceContacts copy]];
        [_sectionTitles addObject:OCKLocalizedString(@"DEVICE_SECTION_TITLE", nil)];
    }

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setUpConstraints];
}


#pragma mark - Helpers

- (OCKContact *)contactForIndexPath:(NSIndexPath *)indexPath {
    return _sectionedContacts[indexPath.section][indexPath.row];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    OCKContact *contact = [self contactForIndexPath:indexPath];

    if ([_selectedContacts containsObject:contact]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_selectedContacts removeObject:contact];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_selectedContacts addObject:contact];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionedContacts.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _sectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sectionedContacts[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"ConnectCell";
    OCKConnectSharingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[OCKConnectSharingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:CellIdentifier];
    }
    
    NSArray <OCKContact *> *contacts = [[NSMutableArray alloc] initWithObjects:_sectionedContacts[indexPath.section][indexPath.row], nil];
    cell.contact = contacts[0];
    
    OCKContact *x = _sectionedContacts[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;

    for (OCKContact *contact in _selectedContacts) {
        NSLog(@"%@ %@ ",contact.name, x.name  );

        if ([contact.identifier isEqualToString:x.identifier]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

@end
