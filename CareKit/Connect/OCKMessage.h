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
 The `OCKMessage` class is an object that represents a message for the `OCKSlackViewController`.
 */
OCK_CLASS_AVAILABLE
@interface OCKMessage : NSObject <NSSecureCoding, NSCopying>

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized message using the specified values.
 
 @param topic               The message topic.
 @param payload             The message payload.
 
 @return An initialized post object.
 */
- (instancetype)initWithPayload:(NSString *)payload
                            identifier:(NSString *)identifier
                            sig:(nullable NSString *)sig
                          topic:(nullable NSString *)topic
             recipientPublicKey:(nullable NSString *)recipientPublicKey
                        timestamp:(NSUInteger)timestamp
						   padding:(nullable NSString *)padding
                        ttl:(NSUInteger)ttl
                            pow:(double)pow;


/**
 The message topic.

 */
@property (nonatomic, readonly, nullable) NSString *topic;

/**
 A string indicating the uuid for a message.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 The  timestamp of this message.
 */
@property (nonatomic, readonly) NSUInteger timestamp;

/**
 The  time to live for this message.
 */
@property (nonatomic, readonly) NSUInteger ttl;

/**
 A string with the text for a message.
 */
@property (nonatomic, readonly) NSString *payload;

/**
 A optional padding string for a message.
 */
@property (nonatomic, readonly, nullable) NSString *padding;

/**
 A string with the signature for a message.
 */
@property (nonatomic, readonly) NSString *sig;


/**
 The Proof-of-Work
 */
@property (nonatomic, readonly) double pow;

/**
 The recipients public key
 */
@property (nonatomic, readonly, nullable) NSString *recipientPublicKey;


@end

NS_ASSUME_NONNULL_END
