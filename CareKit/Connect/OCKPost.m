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


#import "OCKPost.h"
#import "OCKPost_Internal.h"
#import "OCKHelpers.h"

@implementation OCKPost

+ (instancetype)new {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithPostType:(OCKPostType)type
                      identifier:(NSString *)identifier
                         created:(NSDate *)created
                            text:(nullable NSString *)text
                        imageURL:(nullable NSURL *)imageURL
                         linkURL:(nullable NSURL *)linkURL
                   numberOfLikes:(NSUInteger)numberOfLikes
                numberOfComments:(NSUInteger)numberOfComments {

	self = [super init];
	if (self) {
		_type = type;
        _identifier = [identifier copy];
        _created = created;
        _text = [text copy];
        _imageURL = imageURL;
        _linkURL = linkURL;
        _numberOfLikes = numberOfLikes;
        _numberOfComments = numberOfComments;
	}
	return self;
}

- (instancetype)initWithCoreDataObject:(OCKCDPost *)cdObject {

    NSParameterAssert(cdObject);

    self = [self initWithPostType:cdObject.type.integerValue
                       identifier:cdObject.identifier
                       created:cdObject.created
                             text:cdObject.text
                         imageURL:OCKURLFromBookmarkData(cdObject.imageURL)
                          linkURL:OCKURLFromBookmarkData(cdObject.linkURL)
                  numberOfLikes:cdObject.numberOfLikes.unsignedIntegerValue
                 numberOfComments:cdObject.numberOfComments.unsignedIntegerValue
            ];


    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.type == castObject.type) &&
            OCKEqualObjects(self.identifier, castObject.identifier) &&
            OCKEqualObjects(self.created, castObject.created) &&
            OCKEqualObjects(self.text, castObject.text) &&
            OCKEqualObjects(self.imageURL, castObject.imageURL) &&
            OCKEqualObjects(self.linkURL, castObject.linkURL) &&
            self.numberOfLikes == castObject.numberOfLikes &&
            self.numberOfComments == castObject.numberOfComments);
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        OCK_DECODE_ENUM(aDecoder, type);
        OCK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        OCK_DECODE_URL_BOOKMARK(aDecoder, imageURL);
        OCK_DECODE_URL_BOOKMARK(aDecoder, linkURL);
        OCK_DECODE_INTEGER(aDecoder, numberOfLikes);
        OCK_DECODE_INTEGER(aDecoder, numberOfComments);
     }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    OCK_ENCODE_ENUM(aCoder, type);
    OCK_ENCODE_OBJ(aCoder, identifier);
    OCK_ENCODE_OBJ(aCoder, created);
    OCK_ENCODE_OBJ(aCoder, text);
    OCK_ENCODE_URL_BOOKMARK(aCoder, imageURL);
    OCK_ENCODE_URL_BOOKMARK(aCoder, linkURL);
    OCK_ENCODE_INTEGER(aCoder, numberOfLikes);
    OCK_ENCODE_INTEGER(aCoder, numberOfComments);
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    OCKPost *post = [[[self class] allocWithZone:zone] init];
    post->_type = self.type;
    post->_identifier = [self.identifier copy];
    post->_text = [self.text copy];
    post->_created = self.created;
    post->_imageURL = self.imageURL;
    post->_linkURL = self.linkURL;
    post->_numberOfLikes = self.numberOfLikes;
    post->_numberOfComments = self.numberOfComments;
    return post;
}

#pragma mark - Monogram

- (NSString *)clippedMonogramForString:(NSString *)string {
    NSRange stringRange = {0, MIN([string length], 2)};
    stringRange = [string rangeOfComposedCharacterSequencesForRange:stringRange];
    return [string substringWithRange:stringRange];
}

@end

@implementation OCKCDPost

- (instancetype)initWithEntity:(NSEntityDescription *)entity
insertIntoManagedObjectContext:(NSManagedObjectContext *)context
                          item:(OCKPost *)item {

    NSParameterAssert(item);
    self = [self initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        self.type = @(item.type);
        self.identifier = item.identifier;
        self.text = item.text;
        self.created = item.created;
        self.imageURL = OCKBookmarkDataFromURL(item.imageURL);
        self.linkURL  = OCKBookmarkDataFromURL(item.linkURL);
        self.numberOfLikes = @(item.numberOfLikes);
        self.numberOfComments = @(item.numberOfComments);
     }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"OCKCDPost"];
}

@dynamic identifier;
@dynamic text;
@dynamic created;
@dynamic type;
@dynamic imageURL;
@dynamic linkURL;
@dynamic numberOfLikes;
@dynamic numberOfComments;

@end

