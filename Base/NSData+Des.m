//
//  NSData+Des.m
//  SSAdventure
//
//  Created by MacBook on 6/3/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import "NSData+Des.h"
#import <CommonCrypto/CommonCryptor.h>
const NSString *key = @"20140401";
const NSString *iv = @"12345678";
@implementation NSData (Des)
- (NSData*)desEncoded{
    NSData* ivData = [iv dataUsingEncoding: NSUTF8StringEncoding];
    Byte *ivBytes = (Byte *)[ivData bytes];
    
    NSUInteger dataLength = [self length];
    NSUInteger bufferLength=dataLength+kCCBlockSizeAES128;
    unsigned char buffer[bufferLength];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          ivBytes,
                                          [self bytes], dataLength,
                                          buffer, bufferLength,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        return data;
    }
    return nil;
}
- (NSData*)desDecoded{
    NSData* ivData = [iv dataUsingEncoding: NSUTF8StringEncoding];
    Byte *ivBytes = (Byte *)[ivData bytes];
    NSUInteger dataLength=[self length];
    NSUInteger bufferLength=dataLength+kCCBlockSizeAES128;
    unsigned char buffer[bufferLength];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          ivBytes,
                                          [self bytes], dataLength,
                                          buffer, bufferLength,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        return plaindata;
    }
    return nil;
}
@end
