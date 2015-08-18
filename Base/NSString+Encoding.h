//
//  NSString+URLEncode.h
//  ky
//
//  Created by MacBook on 13-10-10.
//  Copyright (c) 2013年 pipi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encoding)
-(NSString*)urlEncode;
-(NSString*)urlDecode;

- (NSString *)base64Encode;
- (NSString *)base64Decode;
@end
