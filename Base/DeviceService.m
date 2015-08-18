//
//  DeviceService.m
//  DressStyle
//
//  Created by MacBook on 3/10/14.
//  Copyright (c) 2014 yn. All rights reserved.
//

#import "DeviceService.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>
@implementation DeviceService
+(NSString*)getDeviceType{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return @"iphone";
    } else {
        return @"ipad";
    }
}
+(NSString*)getDeviceID{
   KeychainItemWrapper *keychain=[[KeychainItemWrapper alloc] initWithIdentifier:@"DeviceID" accessGroup:@"QTY8YA2JKS.com.chaobo.WeidaSuite"];
    NSString* deviceid=[keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    if(deviceid==nil||deviceid.length==0){
        deviceid=[DeviceService getUUID];
        [keychain setObject:deviceid forKey:(__bridge id)(kSecAttrAccount)];
    }
    return deviceid;
}

+(NSString*) getUUID {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result =(__bridge_transfer NSString*)uuidString;
    CFRelease(puuid);
    return result;
}


@end
