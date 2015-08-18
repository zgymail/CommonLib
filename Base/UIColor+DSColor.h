//
//  UIColor+DSColor.h
//  DressStyle
//
//  Created by MacBook on 12/31/13.
//  Copyright (c) 2013 yn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DSColor)
+ (UIColor *)colorWithHexRGB:(NSString *)inColorString;
-(NSString*) toHexRGB;
@end
