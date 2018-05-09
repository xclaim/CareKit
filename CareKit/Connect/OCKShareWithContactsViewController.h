/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 Copyright (c) 2017, WWT Asynchrony Labs. All rights reserved.
 Copyright (c) 2017, Erik Hornberger. All rights reserved. 
 Copyright (c) 2017, Troy Tsubota. All rights reserved.

 
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
#import "OCKMessageItem.h"
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN

@class OCKContact, OCKShareWithContactsViewController;


/**
 An object that adopts the `OCKConnectViewControllerDelegate` protocol is responsible for providing the
 data required to populate the sharing section in the table view of an `OCKConnectViewController` object.
 */
@protocol OCKShareWithContactsViewControllerDelegate <NSObject>

@required

/**
 Tells the delegate which contacts were selected for sharing.

 @param shareViewController       The view controller providing the callback.
 */
- (void)shareViewController:(OCKShareWithContactsViewController *)shareViewController shareWith:(NSArray <OCKContact *> *) contacts;


@end


/**
 The `OCKConnectViewController` class is a view controller that displays an array of `OCKContact` objects.
 It includes a master view and a detail view. Therefore, it must be embedded inside a `UINavigationController`.
 */
OCK_CLASS_AVAILABLE
@interface OCKShareWithContactsViewController : UIViewController

/**
 Returns an initialized connect view controller using the specified contacts.
 
 @param contacts        An array of `OCKContact` objects.
 
 @return An initialized connect view controller.
 */
- (instancetype)initWithContacts:(nullable NSArray<OCKContact *> *)contacts sharingWith:(nullable NSArray<OCKContact *> *)sharingContacts;

/**
 An array of contacts.
 */
@property (nonatomic, copy, nullable) NSArray<OCKContact *> *contacts;

/**
 An array of contacts I am sharing with.
 */
@property (nonatomic, copy, nullable) NSArray<OCKContact *> *sharingContacts;

/**
 A reference to the `UITableView` contained in the view controller
 */
@property (nonatomic, readonly, nonnull) UITableView *tableView;

/**
 A boolean to show the edge indicators.
 
 The default value is NO.
 */
@property (nonatomic) BOOL showEdgeIndicators;

/**
 The delegate is used for the sharing section in the contact detail view.

 See the `OCKShareWithContactsViewControllerDelegate` protocol.
 */
@property (nonatomic, weak, nullable) id<OCKShareWithContactsViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
