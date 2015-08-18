//
//  NSData+Base64.h
//  SSAdventure
//
//  Created by MacBook on 6/3/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import <Foundation/Foundation.h>
void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength);

char *NewBase64Encode(
                      const void *inputBuffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength);

@interface NSData (Base64)

+ (NSData *)dataFromBase64String:(NSString *)aString;
+ (NSData *)dataFromBase64String1:(NSString *)aString;
- (NSString *)base64EncodedString;

// added by Hiroshi Hashiguchi
- (NSString *)base64EncodedStringWithSeparateLines:(BOOL)separateLines;

@end
