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

@class OCKCarePlanStore;



/**
 The `OCKShareActivitiesViewController` class is a view controller that displays the activities and events
 from an `OCKCarePlanStore` that are of intervention type (see `OCKCarePlanActivityTypeIntervention`).
 
 It includes a master view and a detail view. Therefore, it must be embedded inside a `UINavigationController`.
 */
OCK_CLASS_AVAILABLE
@interface OCKShareActivitiesViewController : UIViewController

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized care card view controller using the specified store.
 
 @param store        A care plan store.
 
 @return An initialized care card view controller.
 */
- (instancetype)initWithCarePlanStore:(OCKCarePlanStore *)store;

/**
 The care plan store that provides the content for the care card.
 
 The care card displays activites and events that are of intervention type (see `OCKCarePlanActivityTypeIntervention`).
 */
@property (nonatomic, readonly) OCKCarePlanStore *store;

/** 
 A reference to the `UITableView` contained in the view controller
 */
@property (nonatomic, readonly, nonnull) UITableView *tableView;

/**
 The image that will be used to mask the fill shape in the week view.
 
 In order to provide a custom maskImage, you must have a regular size and small size.
 For example, in the assets catalog, there are "heart" and a "heart-small" assets.
 Both assets must be provided in order to properly render the interface.

 The tint color that will be used to fill the shape.
 
 If tint color is not specified, a default red color will be used.
 */
@property (nonatomic, null_resettable) UIColor *glyphTintColor;

/**
 The string that will be used as the Care Card header title.
 
 If the value is not specified, CareKit's default string ("Care Completion") is used.
 */
@property (nonatomic, null_resettable) NSString *headerTitle;

/**
 The glyph type for the header view (see OCKGlyphType).
 */
@property (nonatomic) OCKGlyphType glyphType;

/**
 Image name string if using a custom image. Cannot access image name once image has been created
 and we need a way to access that to send the custom image name string to the watch
 */
@property (nonatomic, copy) NSString *customGlyphImageName;

/** 
 A message that will be displayed in the table view's background view if there are
 no intervention activities to display.
 
 If the value is not specified, nothing will be shown when the table is empty.
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

@end

NS_ASSUME_NONNULL_END
