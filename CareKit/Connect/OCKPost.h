/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 Copyright (c) 2016, WWT Asynchrony Labs. All rights reserved.
 
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
#import <CareKit/OCKCarePlanActivity.h>
#import <ContactsUI/ContactsUI.h>


NS_ASSUME_NONNULL_BEGIN

/**
 An enumeration of the types of posts available.
 */
OCK_ENUM_AVAILABLE
typedef NS_ENUM(NSInteger, OCKPostType) {
    OCKPostTypeStatus = 0,
    OCKPostTypeDiagnosis,
    OCKPostTypeIntervention,
    OCKPostTypeLab,
    OCKPostTypePrescription
};


/**
 The `OCKPost` class is an object that represents a post for the `OCKConnectViewController`.
 */
OCK_CLASS_AVAILABLE
@interface OCKPost : NSObject <NSSecureCoding, NSCopying>

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized post using the specified values.
 
 @param type                The post type.
 @param identifier          The post identifier.
 @param image               The post image.
 
 @return An initialized post object.
 */
- (instancetype)initWithPostType:(OCKPostType)type
                        identifier:(NSString *)identifier
                               created:(NSDate *)created
						   text:(nullable NSString *)text
                        imageURL:(nullable NSURL *)imageURL
                        linkURL:(nullable NSURL *)linkURL
                   numberOfLikes:(NSUInteger)numberOfLikes
                numberOfComments:(NSUInteger)numberOfComments;

/**
 The post type.

 See the `OCKPostType` enum.
 */
@property (nonatomic, readonly) OCKPostType type;

/**
 A string indicating the uuid for a post.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 The date of this event, in the Gregorian calendar, represented by era, year, month, and day.
 */
@property (nonatomic, readonly) NSDate *created;

/**
 A string with the text for a post.
 */
@property (nonatomic, readonly) NSString *text;

/**
 Image for the post.
 */
@property (nonatomic, readonly, nullable) NSURL *imageURL;

/**
 Link for the post.
 */
@property (nonatomic, readonly, nullable) NSURL *linkURL;


/**
 The number of likes
 */
@property (nonatomic, readonly) NSUInteger numberOfLikes;

/**
 The number of comments
 */
@property (nonatomic, readonly) NSUInteger numberOfComments;

/**
 An image for a post.
*/
@property (nonatomic, nullable) UIImage *image;


@end

NS_ASSUME_NONNULL_END
