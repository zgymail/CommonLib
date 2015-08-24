//
//  Math.h
//  Pods
//
//  Created by gavin on 15/8/20.
//
//

#import <Foundation/Foundation.h>
@interface Math : NSObject
+(NSInteger)randomInt:(NSInteger)value;
+(float)randomFloat:(float)value;
+(double)randomDouble:(double)value;

+(int)sign:(double)value;
@end
