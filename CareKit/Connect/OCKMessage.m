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


#import "OCKMessage.h"
#import "OCKMessage_Internal.h"
#import "OCKHelpers.h"

@implementation OCKMessage

+ (instancetype)new {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithPayload:(NSString *)payload
                         identifier:(NSString *)identifier
                            sig:(nullable NSString *)sig
                          topic:(nullable NSString *)topic
             recipientPublicKey:(nullable NSString *)recipientPublicKey
                      timestamp:(NSUInteger)timestamp
                        padding:(nullable NSString *)padding
                            ttl:(NSUInteger)ttl
                            pow:(double)pow
    {

	self = [super init];
	if (self) {
		_payload = [payload copy];
        _identifier = [identifier copy];
        _sig = [sig copy];
        _topic = [topic copy];
        _recipientPublicKey = [recipientPublicKey copy];
        _recipientPublicKey = [recipientPublicKey copy];
        _timestamp = timestamp;
        _padding = [padding copy];
        _ttl = ttl;
        _pow = pow;
 	}
	return self;
}

- (instancetype)initWithCoreDataObject:(OCKCDMessage *)cdObject {

    NSParameterAssert(cdObject);

    self = [self initWithPayload:cdObject.payload
                          identifier:cdObject.identifier
                             sig:cdObject.sig
                           topic:cdObject.topic
              recipientPublicKey:cdObject.recipientPublicKey
                       timestamp:cdObject.timestamp.unsignedIntegerValue
                         padding:cdObject.padding
                             ttl:cdObject.ttl.unsignedIntegerValue
                             pow:cdObject.pow.floatValue];

    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.payload == castObject.payload) &&
            OCKEqualObjects(self.identifier, castObject.identifier) &&
            OCKEqualObjects(self.sig, castObject.sig) &&
            OCKEqualObjects(self.topic, castObject.topic) &&
            OCKEqualObjects(self.recipientPublicKey, castObject.recipientPublicKey) &&
            OCKEqualObjects(self.padding, castObject.padding) &&
            self.pow == castObject.pow &&
            self.ttl == castObject.ttl &&
            self.timestamp == castObject.timestamp);
}


#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        OCK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, padding, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, payload, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, recipientPublicKey, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, sig, NSString);
        OCK_DECODE_OBJ_CLASS(aDecoder, topic, NSString);
        OCK_DECODE_INTEGER(aDecoder, ttl);
        OCK_DECODE_INTEGER(aDecoder, timestamp);
        OCK_DECODE_DOUBLE(aDecoder, pow);
     }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    OCK_ENCODE_OBJ(aCoder, identifier);
    OCK_ENCODE_OBJ(aCoder, padding);
    OCK_ENCODE_OBJ(aCoder, payload);
    OCK_ENCODE_OBJ(aCoder, recipientPublicKey);
    OCK_ENCODE_OBJ(aCoder, sig);
    OCK_ENCODE_OBJ(aCoder, topic);
    OCK_ENCODE_INTEGER(aCoder, ttl);
    OCK_ENCODE_INTEGER(aCoder, timestamp);
    OCK_ENCODE_DOUBLE(aCoder, pow);

}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    OCKMessage *message = [[[self class] allocWithZone:zone] init];

    message->_payload = [self.payload copy];
    message->_identifier = [self.identifier copy];
    message->_sig = [self.sig copy];
    message->_topic = [self.topic copy];
    message->_recipientPublicKey = [self.recipientPublicKey copy];
    message->_padding = [self.padding copy];
    message->_timestamp = self.timestamp;
    message->_ttl = self.ttl;
    message->_pow = self.pow;
    return message;
}


@end

@implementation OCKCDMessage

- (instancetype)initWithEntity:(NSEntityDescription *)entity
insertIntoManagedObjectContext:(NSManagedObjectContext *)context
                          item:(OCKMessage *)item {

    NSParameterAssert(item);
    self = [self initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        self.ttl = @(item.ttl);
        self.timestamp = @(item.timestamp);
        self.pow = @(item.pow);
        self.payload = item.payload;
        self.identifier = item.identifier;
        self.sig = item.sig;
        self.topic = item.topic;
        self.recipientPublicKey = item.recipientPublicKey;
        self.padding = item.padding;
      }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"OCKCDMessage"];
}

@dynamic topic;
@dynamic recipientPublicKey;
@dynamic identifier;
@dynamic payload;
@dynamic sig;
@dynamic padding;
@dynamic ttl;
@dynamic pow;
@dynamic timestamp;

@end

