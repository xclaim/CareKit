/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 
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


#import "OCKInsightWidgetsView.h"
#import "OCKInsightsTableViewHeaderView.h"
#import "OCKHelpers.h"
#import "OCKDefines_Private.h"

@interface OCKInsightsView()

@end

@implementation OCKInsightWidgetsView {
    OCKInsightsTableViewHeaderView *_headerView;
    NSMutableArray *_constraints;
    NSMutableArray *_triggeredThresholds;
    NSMutableArray *_triggeredThresholdActivities;
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithInsightItems:(NSArray<OCKInsightItem *> *)items
                      patientWidgets:(NSArray<OCKPatientWidget *> *)widgets
                          thresholds:(NSArray<NSString *> *)thresholds
                               store:(OCKCarePlanStore *)store
                               frame:(CGRect)frame {
    NSAssert(widgets.count < 4, @"A maximum of 3 patient widgets is allowed.");
    if (thresholds.count > 0) {
        NSAssert(store, @"A care plan store is required for thresholds.");
    }

    self = [super initWithFrame:frame];

    self = [super init];
    if (self) {
        _items = OCKArrayCopyObjects(items);
        _widgets = OCKArrayCopyObjects(widgets);
        _thresholds = OCKArrayCopyObjects(thresholds);
        _store = store;
    }
    return self;
}

- (instancetype)initWithInsightItems:(NSArray<OCKInsightItem *> *)items frame:(CGRect)frame {
    return [[OCKInsightWidgetsView alloc]  initWithInsightItems:items
                                           patientWidgets:nil
                                               thresholds:nil
                                                    store:nil
                                                    frame:frame];
}

- (void)configure {

    self.backgroundColor = [UIColor whiteColor];

    //self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (!_headerView) {
        _headerView = [[OCKInsightsTableViewHeaderView alloc] initWithWidgets:self.widgets
                                                                        store:self.store];
        [self addSubview:_headerView];
    }
    [self setUpConstraints];
    viewWillAppear:YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [_headerView updateWidgets];
}

- (void)setItems:(NSArray<OCKInsightItem *> *)items {
    _items = OCKArrayCopyObjects(items);
}

- (void)setUpConstraints {
    [NSLayoutConstraint deactivateConstraints:_constraints];
    
    _constraints = [NSMutableArray new];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat headerViewHeight = (self.widgets.count > 0) ? 100 : 0;
    
    [_constraints addObjectsFromArray:@[
                                        [NSLayoutConstraint constraintWithItem: _headerView
                                                                     attribute: NSLayoutAttributeTop
                                                                     relatedBy: NSLayoutRelationEqual
                                                                        toItem: self
                                                                     attribute: NSLayoutAttributeTop
                                                                    multiplier: 1.0
                                                                      constant: 0.0],
                                        [NSLayoutConstraint constraintWithItem: _headerView
                                                                     attribute: NSLayoutAttributeLeading
                                                                     relatedBy: NSLayoutRelationEqual
                                                                        toItem: self
                                                                     attribute: NSLayoutAttributeLeading
                                                                    multiplier: 1.0
                                                                      constant: 0.0],
                                        [NSLayoutConstraint constraintWithItem: _headerView
                                                                     attribute: NSLayoutAttributeTrailing
                                                                     relatedBy: NSLayoutRelationEqual
                                                                        toItem: self
                                                                     attribute: NSLayoutAttributeTrailing
                                                                    multiplier: 1.0
                                                                      constant: 0.0],
                                        [NSLayoutConstraint constraintWithItem: _headerView
                                                                     attribute: NSLayoutAttributeHeight
                                                                     relatedBy: NSLayoutRelationEqual
                                                                        toItem: nil
                                                                     attribute: NSLayoutAttributeNotAnAttribute
                                                                    multiplier: 1.0
                                                                      constant: headerViewHeight],
                                        ]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
    
    
}

@end
