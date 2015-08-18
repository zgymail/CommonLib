//
//  NetService.h
//  ky
//
//  Created by MacBook on 13-10-11.
//  Copyright (c) 2013年 pipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "AFDownloadStorage.h"
typedef NS_ENUM(NSUInteger, NetServiceNetworkSwitchStatus) {
    NetServiceNetworkSwitchStatusNone,
    NetServiceNetworkSwitchStatusNo,
    NetServiceNetworkSwitchStatusYes,
};

typedef NS_ENUM(NSUInteger, NetServiceResponseStatus) {
    NetServiceResponseStatusSuccess,
    NetServiceResponseStatusFail,
    NetServiceResponseStatusParseFail,
};

@interface NetServiceResponseInfo : NSObject
@property(nonatomic,assign)BOOL cache;
@property(nonatomic,strong)NSURL* url;
@end

#if NS_BLOCKS_AVAILABLE
typedef void (^NetServiceLoadImageCompleteBlock)(UIImage *image);
typedef void (^NetServiceNetworkCheckBlock)(NetServiceNetworkSwitchStatus switchState,NetworkStatus status);
typedef void (^NetServiceSendDataCompleteBlock)(id data,NetServiceResponseStatus responseStatus,NetServiceResponseInfo* responseInfo);
#endif
@class NetServiceDamain;
@class NetRequest;
@protocol NetServiceReceiveDataDelegate;
@protocol NetServiceParseDelegate;

@interface NetService : NSObject
@property(nonatomic,strong)id<NetServiceParseDelegate> defaultParse;
+(NetService*) shareInstance;
-(void)setRootUrl:(NSString *) url;
-(void)setResourceRootUrl:(NSString *) rootUrl;
-(void)setServiceUrl:(NSString *) serviceUrl;
-(void)setNetworkCheck:(NetServiceNetworkCheckBlock)block;
-(void)addNetworkCheck:(id<NetServiceReceiveDataDelegate>)checkDelegate;

-(void) sendData:(NSString*)serviceName  delegate:(id<NetServiceReceiveDataDelegate>)delegate parse:(id<NetServiceParseDelegate>)parse;
-(void) sendData:(NSString*)serviceName  delegate:(id<NetServiceReceiveDataDelegate>)delegate data:(id)data parse:(id<NetServiceParseDelegate>)parse;
-(void) sendData:(NSString*)serviceName delegate:(id<NetServiceReceiveDataDelegate>)delegate data:(id)data uploadFileDatas:(NSArray*)uploadFileDatas parse:(id<NetServiceParseDelegate>)parse;

-(void) sendData:(NSString*)serviceName completionBlock:(NetServiceSendDataCompleteBlock)completionBlock parse:(id<NetServiceParseDelegate>)parse;
-(void) sendData:(NSString*)serviceName data:(id)data completionBlock:(NetServiceSendDataCompleteBlock)completionBlock parse:(id<NetServiceParseDelegate>)parse;
-(void) sendData:(NSString*)serviceName data:(id)data  uploadFileDatas:(NSArray*)uploadFileDatas completionBlock:(NetServiceSendDataCompleteBlock)completionBlock parse:(id<NetServiceParseDelegate>)parse;

-(void)cacelDomainLoading:(NSString*)domainid;
-(NetServiceDamain*)createDomain:(NSString*)domainid;
-(void)removeDomain:(NSString*)domainid;
-(NetServiceDamain*)getDomain:(NSString*)domainid;
- (void) loadImage:(NSString*)imageURL complete:(NetServiceLoadImageCompleteBlock)completeBlock;
- (void) loadImage:(NSString*)imageURL complete:(NetServiceLoadImageCompleteBlock)completeBlock domainid:(NSString*)domainid;
- (void) loadData:(NSString*)relaviteUrl complete:(NetServiceSendDataCompleteBlock)completeBlock parse:(id<NetServiceParseDelegate>)parse;
- (void) loadData:(NSString*)relaviteUrl complete:(NetServiceSendDataCompleteBlock)completeBlock parse:(id<NetServiceParseDelegate>)parse domainid:(NSString *)domainid;
@end

@protocol NetServiceReceiveDataDelegate <NSObject>
@optional
-(void)receiveData:(NSString*)urlkey data:(NSDictionary*)data responseStatus:(NetServiceResponseStatus)responseStatus;
- (void) reachabilityChanged:(NetServiceNetworkSwitchStatus)switchStatus networkStatus:(NetworkStatus) networkStatus;
@end
@protocol NetServiceParseDelegate <NSObject>
-(id)decode:(NSData*)data error:(NSError**)error;
-(NSData*)encode:(id)data error:(NSError**)error;
@end
@interface NetServiceDamain :NSOperationQueue
@property(nonatomic,strong)AFDownloadStorage* storage;
-(void)setStoragePath:(NSString *)storagePath;
-(void)clearStoragePath;
@end
@interface NetServiceJsonParse : NSObject<NetServiceParseDelegate>
@end
@interface NetServiceBaseParse : NSObject<NetServiceParseDelegate>

@end
@interface NetServiceDesJsonParse : NSObject<NetServiceParseDelegate>
@property(nonatomic,assign)NSJSONReadingOptions readingOptions;
@end
@interface NetServiceDataCache : NSURLCache
+ (instancetype)standardDataCache;
@end
