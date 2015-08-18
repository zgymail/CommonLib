//
//  DeviceService.h
//  DressStyle
//
//  Created by MacBook on 3/10/14.
//  Copyright (c) 2014 yn. All rights reserved.
//

#import <Foundation/Foundation.h>
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
@interface DeviceService : NSObject
+(NSString*)getDeviceType;
+(NSString*)getDeviceID;
+(NSString*) getUUID;

@end
