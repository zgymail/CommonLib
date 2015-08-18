//
//  UIImage+Extensions.h
//  SSAdventure
//
//  Created by MacBook on 7/5/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import <UIKit/UIKit.h>
NSUInteger bitmapByteOffset(NSUInteger x, NSUInteger y, NSUInteger w,NSUInteger offset);
@interface UIImage (Extensions)
- (UIImage *)imageWithRotate:(CGFloat)rotation;
+ (NSDictionary*)spritesWithContentsOfFile:(NSString*)filename;
-(unsigned char*)getBitmapBytes;
- (UIImage *)subImage:(CGRect)rect;
@end
