//
//  UIColor+DSColor.m
//  DressStyle
//
//  Created by MacBook on 12/31/13.
//  Copyright (c) 2013 yn. All rights reserved.
//

#import "UIColor+DSColor.h"
#define DEFAULT_VOID_COLOR [UIColor whiteColor]
@implementation UIColor (DSColor)
+ (UIColor *)colorWithHexRGB:(NSString *)inColorString{
    if (inColorString==nil)
    {
        return DEFAULT_VOID_COLOR;
    }
    if([[inColorString substringToIndex:1] isEqualToString:@"#"]){
        inColorString=[inColorString substringFromIndex:1];
    }
    if(inColorString.length!=8&&inColorString.length!=6){
        return DEFAULT_VOID_COLOR;
    }
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *color0 = [inColorString substringWithRange:range];
    range.location = 2;
    NSString *color1 = [inColorString substringWithRange:range];
    range.location = 4;
    NSString *color2 = [inColorString substringWithRange:range];
    unsigned int r, g, b,a;
    if(inColorString.length==8){
        range.location = 6;
        NSString *color3 = [inColorString substringWithRange:range];
        [[NSScanner scannerWithString:color0] scanHexInt:&a];
        [[NSScanner scannerWithString:color1] scanHexInt:&r];
        [[NSScanner scannerWithString:color2] scanHexInt:&g];
        [[NSScanner scannerWithString:color3] scanHexInt:&b];
    }else{
        a=255.0f;
        [[NSScanner scannerWithString:color0] scanHexInt:&r];
        [[NSScanner scannerWithString:color1] scanHexInt:&g];
        [[NSScanner scannerWithString:color2] scanHexInt:&b];
    }
    UIColor * result = [UIColor colorWithRed:((float) r / 255.0f)
                                       green:((float) g / 255.0f)
                                        blue:((float) b / 255.0f)
                                       alpha:((float) a / 255.0f)];
    return result;
}

//颜色转字符串
-(NSString*) toHexRGB{
    const CGFloat *cs=CGColorGetComponents(self.CGColor);
    const CGFloat a=CGColorGetAlpha(self.CGColor);
    NSString *astr = [NSString stringWithFormat:@"%@",[self  toHex:a*255]];
    NSString *r = [NSString stringWithFormat:@"%@",[self  toHex:cs[0]*255]];
    NSString *g = [NSString stringWithFormat:@"%@",[self  toHex:cs[1]*255]];
    NSString *b = [NSString stringWithFormat:@"%@",[self  toHex:cs[2]*255]];
    return [NSString stringWithFormat:@"#%@%@%@%@",astr,r,g,b];
}


//十进制转十六进制
-(NSString *)toHex:(int)tmpid
{
    NSString *endtmp=@"";
    NSString *nLetterValue;
    NSString *nStrat;
    int ttmpig=tmpid%16;
    int tmp=tmpid/16;
    switch (ttmpig)
    {
        case 10:
            nLetterValue =@"A";break;
        case 11:
            nLetterValue =@"B";break;
        case 12:
            nLetterValue =@"C";break;
        case 13:
            nLetterValue =@"D";break;
        case 14:
            nLetterValue =@"E";break;
        case 15:
            nLetterValue =@"F";break;
        default:nLetterValue=[[NSString alloc]initWithFormat:@"%i",ttmpig];
            
    }
    switch (tmp)
    {
        case 10:
            nStrat =@"A";break;
        case 11:
            nStrat =@"B";break;
        case 12:
            nStrat =@"C";break;
        case 13:
            nStrat =@"D";break;
        case 14:
            nStrat =@"E";break;
        case 15:
            nStrat =@"F";break;
        default:nStrat=[[NSString alloc]initWithFormat:@"%i",tmp];
            
    }
    endtmp=[[NSString alloc]initWithFormat:@"%@%@",nStrat,nLetterValue];
    return endtmp;
}

@end
