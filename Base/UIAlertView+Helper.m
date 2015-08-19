//
//  UIAlertView+Dismiss.m
//  DressStyle
//
//  Created by MacBook on 2/11/14.
//  Copyright (c) 2014 yn. All rights reserved.
//

#import "UIAlertView+Helper.h"

@implementation UIAlertView (Helper)

-(void)show:(NSTimeInterval)timer
{
    [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
    [self show];
}

-(void) performDismiss:(NSTimer *)timer
{
    [self dismissWithClickedButtonIndex:0 animated:YES];
}

+(UIAlertView*)alertViewWithTitle:(NSString*)title timer:(NSTimeInterval)timer{
   UIAlertView* aview= [[UIAlertView alloc] initWithTitle:title message:title delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    if (timer>0) {
        [aview show:timer];
    }else{
         [aview show];
    }
    return aview;
}

@end
