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


#import "OCKImmunization.h"
#import "OCKContact.h"
#import "OCKImmunization_Internal.h"
#import "OCKHelpers.h"


@implementation OCKImmunization

+ (instancetype)new {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithImmunizationType:(OCKImmunizationType)type
                            identifier:(NSString *)identifier
                            title:(NSString *)title
                         synopsis:(NSString *)synopsis
                         issuer: (OCKContact *)issuer
                           webURL: (NSURL *)webURL
                          tintColor:(UIColor *)tintColor
                           monogram:(NSString *)monogram
                              image:(UIImage *)image
                            userInfo:(NSDictionary *)userInfo {
    NSAssert((monogram || image), @"An OCKImmunization must have either a monogram or an image.");
    
    self = [super init];
    if (self) {
        _type = type;
        _identifier = [identifier copy];
        _title = [title copy];
        _synopsis = [synopsis copy];
        _issuer = issuer;
        _webURL = [webURL copy];
        _tintColor = tintColor;
        _monogram = [monogram copy];
        _image = image;
        _userInfo = [userInfo copy];
        
    }
    return self;
}

- (instancetype)initWithCoreDataObject:(OCKCDImmunization *)cdObject {
    
    NSParameterAssert(cdObject);
    
    self = [self initWithImmunizationType:cdObject.type.integerValue
            identifier:cdObject.identifier
            title:cdObject.title
            synopsis:cdObject.synopsis
            issuer: cdObject.issuer
            webURL: OCKURLFromBookmarkData(cdObject.webURL)
            tintColor:cdObject.tintColor
            monogram:cdObject.monogram
            image:[UIImage imageWithData:cdObject.image scale:[[UIScreen mainScreen] scale]]
            userInfo:cdObject.userInfo ];

    return self;
}


- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    BOOL isClassMatch = ([self class] == [object class]);
    
    __typeof(self) castObject = object;
    return (isClassMatch && isParentSame &&
            (self.type == castObject.type) &&
            OCKEqualObjects(self.identifier, castObject.identifier) &&
            OCKEqualObjects(self.title, castObject.title) &&
            OCKEqualObjects(self.synopsis, castObject.synopsis) &&
            OCKEqualObjects(self.issuer, castObject.issuer) &&
            OCKEqualObjects(self.webURL, castObject.webURL) &&
            OCKEqualObjects(self.tintColor, castObject.tintColor) &&
            OCKEqualObjects(self.monogram, castObject.monogram) &&
            OCKEqualObjects(self.userInfo, castObject.userInfo) &&
            OCKEqualObjects(self.image, castObject.image));
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
        OCK_DECODE_OBJ_CLASS(aDecoder, title, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, synopsis, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, issuer, OCKContact);
        OCK_DECODE_URL_BOOKMARK(aDecoder, webURL);
        OCK_DECODE_OBJ_CLASS(aDecoder, tintColor, UIColor);
        OCK_DECODE_OBJ_CLASS(aDecoder, monogram, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, userInfo, NSDictionary);
        OCK_DECODE_IMAGE(aDecoder, image);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    OCK_ENCODE_ENUM(aCoder, type);
    OCK_ENCODE_OBJ(aCoder, identifier);
    OCK_ENCODE_OBJ(aCoder, title);
    OCK_ENCODE_OBJ(aCoder, synopsis);
    OCK_ENCODE_OBJ(aCoder, issuer);
    OCK_ENCODE_URL_BOOKMARK(aCoder, webURL);
    OCK_ENCODE_OBJ(aCoder, tintColor);
    OCK_ENCODE_OBJ(aCoder, monogram);
    OCK_ENCODE_IMAGE(aCoder, image);
    OCK_ENCODE_OBJ(aCoder, userInfo);

}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    OCKImmunization *immunization = [[[self class] allocWithZone:zone] init];
    immunization->_type = self.type;
    immunization->_identifier = [self.identifier copy];
    immunization->_title = [self.title copy];
    immunization->_synopsis = [self.synopsis copy];
    immunization->_issuer = self.issuer;
    immunization->_webURL = [self.webURL copy];
    immunization->_tintColor = self.tintColor;
    immunization->_monogram = [self.monogram copy];
    immunization->_image = self.image;
    immunization->_userInfo = self.userInfo;

    return immunization;
}

@end


@implementation OCKCDImmunization

- (instancetype)initWithEntity:(NSEntityDescription *)entity
insertIntoManagedObjectContext:(NSManagedObjectContext *)context
                          item:(OCKImmunization *)item {
    
    NSParameterAssert(item);
    self = [self initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {        
        self.identifier = item.identifier;
        self.issuer = item.issuer;
        self.title = item.title;
        self.synopsis = item.synopsis;
        self.monogram = item.monogram;
        self.webURL = OCKBookmarkDataFromURL(item.webURL);
        self.tintColor = item.tintColor;
        self.image = UIImageJPEGRepresentation(item.image,1.0);
        self.type = @(item.type);
        self.userInfo = item.userInfo;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"OCKCDImmunization"];
}

@dynamic tintColor;
@dynamic identifier;
@dynamic issuer;
@dynamic synopsis;
@dynamic title;
@dynamic type;
@dynamic webURL;
@dynamic monogram;
@dynamic image;
@dynamic userInfo;

@end

