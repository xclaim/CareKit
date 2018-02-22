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


#import "OCKConnectMessageItem.h"
#import "OCKHelpers.h"


@implementation OCKConnectMessageItem

- (instancetype)ock_init {
    return [super init];
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithMessageType:(OCKConnectMessageType)type
                               sender:(OCKContact *)sender
                             message:(NSString *)message
                            icon:(UIImage *_Nullable)icon
                         dateString:(NSString *)dateString
                           userData:(NSObject *_Nullable)userData{
    self = [super init];
    if (self) {
        _type = type;
        _sender = [sender copy];
        _message = [message copy];
        _icon = [icon copy];
        _dateString = [dateString copy];
        _userData = [userData copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (self.type == castObject.type &&
            OCKEqualObjects(self.sender, castObject.sender) &&
            OCKEqualObjects(self.message, castObject.message) &&
            OCKEqualObjects(self.icon, castObject.icon) &&
            OCKEqualObjects(self.userData, castObject.userData) &&
            OCKEqualObjects(self.dateString, castObject.dateString));
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        OCK_DECODE_ENUM(aDecoder, type);
        OCK_DECODE_OBJ_CLASS(aDecoder, sender, OCKContact);
        OCK_DECODE_OBJ_CLASS(aDecoder, message, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, icon, UIImage);
        OCK_DECODE_OBJ_CLASS(aDecoder, userData, NSObject);
        OCK_DECODE_OBJ_CLASS(aDecoder, dateString, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    OCK_ENCODE_ENUM(aCoder, type);
    OCK_ENCODE_OBJ(aCoder, sender);
    OCK_ENCODE_OBJ(aCoder, message);
    OCK_ENCODE_OBJ(aCoder, icon);
    OCK_ENCODE_OBJ(aCoder, userData);
    OCK_ENCODE_OBJ(aCoder, dateString);
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    OCKConnectMessageItem *item = [[[self class] allocWithZone:zone] ock_init];
    item->_type = _type;
    item->_sender = [_sender copy];
    item->_message = [_message copy];
    item->_icon = [_icon copy];
    item->_userData = [_userData copy];
    item->_dateString = [_dateString copy];
    return item;
}

@end
