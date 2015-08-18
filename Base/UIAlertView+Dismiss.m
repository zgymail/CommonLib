//
//  UIAlertView+Dismiss.m
//  DressStyle
//
//  Created by MacBook on 2/11/14.
//  Copyright (c) 2014 yn. All rights reserved.
//

#import "UIAlertView+Dismiss.h"

@implementation UIAlertView (Dismiss)
-(void)show:(NSTimeInterval)timer{
    [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
    [self show];
}
-(void) performDismiss:(NSTimer *)timer
{
    [timer invalidate];
    [self dismissWithClickedButtonIndex:0 animated:YES];
   
}

@end
