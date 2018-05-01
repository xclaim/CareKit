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

#import <UIKit/UIKit.h>
#import <CareKit/OCKDefines.h>

@class OCKContact;

NS_ASSUME_NONNULL_BEGIN

/**
 An enumeration of the types of immunizations available.
 */
OCK_ENUM_AVAILABLE
typedef NS_ENUM(NSInteger, OCKImmunizationType) {
    OCKImmunizationTypeFlu = 0,
    OCKImmunizationTypePolio,
    OCKImmunizationTypeTBE, /* Tick Borne Encefalitits */
    OCKImmunizationTypeYellowFever,
   };


/**
 The `OCKImmunization` class is an object that represents an immuinzation for the `OCKConnectDetailViewController`.
 */
OCK_CLASS_AVAILABLE
@interface OCKImmunization : NSObject <NSSecureCoding, NSCopying>

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized immunization using the specified values.
 
 @param type                The immunization record type.
 @param title               The immunization record title.
 @param tintColor           The immunization record tint color.
 @param photo               The immunization record photo.
 @param monogram            The immunization record monogram.
 @param image               The immunization record image.
 
 @return An initialized immunization record object.
 */
- (instancetype)initWithImmunizationType:(OCKImmunizationType)type
                            identifier:(NSString *)identifier
                            title:(NSString *)title
                            synopsis:(nullable NSString *)synopsis
                            issuer: (nullable OCKContact *)issuer
                            webURL: (nullable NSURL *)webURL
                            tintColor:(nullable UIColor *)tintColor
                            monogram:(NSString *)monogram
                            image:(nullable UIImage *)image
                            userInfo:(nullable NSDictionary<NSString *, id<NSCoding>> *)userInfo NS_DESIGNATED_INITIALIZER;

/**
 The record type.
 This might also determine the grouping of the immunization in the table view.
 
 See the `OCKImmunizationType` enum.
 */
@property (nonatomic, readonly) OCKImmunizationType type;

/**
 A string identifying an immunization.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 A string indicating the title for an immunization.
 */
@property (nonatomic, readonly) NSString *title;

/**
A short synopsis
*/
@property (nonatomic, readonly) NSString *synopsis;

/**
 Who administered the immunization
 */
@property (nonatomic, readonly, nullable) OCKContact *issuer;


/**
 A string indicating a reference URL for an immunization.
 
 */
@property (nonatomic, readonly, nullable) NSURL *webURL;

/**
 The tint color for an immunization.
 
 If the value is not specified, the app's tint color is used.
 */
@property (nonatomic, readonly, nullable) UIColor *tintColor;

/**
 A photo for an immunization.
*/
@property (nonatomic, nullable) UIImage *photo;

/**
 A string indicating the monogram for an immunization record.
 
 If a monogram is not provided, the image will be used for the record.
 */
@property (nonatomic, readonly) NSString *monogram;

/**
 An image for an immunization record.
 
 If an image is not provided, a monogram will be used for the record.
 An image can be set after a journal record object has been created. If an image
 is available, it will be displayed instead of the monogram.
 */
@property (nonatomic, nullable) UIImage *image;

/**
 Save any additional objects that comply with the NSCoding protocol.
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id<NSCoding>> *userInfo;


@end

NS_ASSUME_NONNULL_END
