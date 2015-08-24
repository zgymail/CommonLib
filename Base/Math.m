//
//  Math.m
//  Pods
//
//  Created by gavin on 15/8/20.
//
//

#import "Math.h"

@implementation Math
+(NSInteger)randomInt:(NSInteger)value{
    return roundf(((double)arc4random()/(double)0x100000000) * value);
}
+(float)randomFloat:(float)value{
    return ((double)arc4random()/(double)0x100000000) * value;
}
+(double)randomDouble:(double)value{
    return ((double)arc4random()/(double)0x100000000) * value;
}
+(int)sign:(double)value{
    if (value>0) {
        return 1;
    }else if(value<0){
        return -1;
    }else{
        return 0;
    }
}
@end
