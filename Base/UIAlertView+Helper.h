//
//  UIAlertView+Dismiss.h
//  DressStyle
//
//  Created by MacBook on 2/11/14.
//  Copyright (c) 2014 yn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Helper)
-(void)show:(NSTimeInterval)timer;

+(UIAlertView*)alertViewWithTitle:(NSString*)title timer:(NSTimeInterval)timer;
@end
