//
//  SyncService.h
//  SSAdventure
//
//  Created by MacBook on 6/1/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "NetService.h"
#if NS_BLOCKS_AVAILABLE
typedef NSDictionary*(^SyncRequestParameterCallback)();
typedef bool(^SyncCheckItemCompleteCallback)(NSDictionary* data);
typedef void (^SyncCheckCompleteCallback)(bool success);
typedef void (^SyncRequestCompleteCallback)(NSDictionary* data);

typedef void (^SyncSaveCompleteCallback)(bool success);
#endif
@class SyncRequest;
@class SyncCheckItem;
@interface SyncService : NSObject
SYNTHESIZE_SINGLETON_FOR_INTERFACE(SyncService);
-(void)removeRegisterWithGroupid:(NSString*)groupid;
-(void)registerResourceUpdateCheck:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback checkItemCompleteCallback:(SyncCheckItemCompleteCallback)checkItemCompleteCallback groupid:(NSString*)groupid;

-(void)registerCurrentResourceUpdateCheck:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback checkItemCompleteCallback:(SyncCheckItemCompleteCallback)checkItemCompleteCallback;

-(bool)checkResourceUpdate:(SyncCheckCompleteCallback)complete;
-(bool)checkResourceUpdate:(SyncCheckCompleteCallback)complete syncDataRequests:(NSMutableArray*)syncDataRequests;
-(bool)checkResourceUpdateWithGroupids:(NSArray*)groupids complete:(SyncCheckCompleteCallback)complete;
-(void)continueCheckNext;
-(void)networkRequestResourceWithCheck:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback requestCompleteCallback:(void (^)(NSDictionary* data,bool write))requestCompleteCallback;
-(void)networkRequestResource:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback requestCompleteCallback:(SyncRequestCompleteCallback)requestCompleteCallback parse:(id<NetServiceParseDelegate>)parse;

-(void)fileSystemRequestResource:(NSString*)urlkey requestCompleteCallback:(SyncRequestCompleteCallback)requestCompleteCallback;
-(void)fileSystemRequestUserData:(NSString*)urlkey requestCompleteCallback:(SyncRequestCompleteCallback)requestCompleteCallback;
-(void)fileSystemSaveUserData:(NSString*)urlkey data:(NSDictionary*)data saveCompleteCallback:(SyncSaveCompleteCallback)saveCompleteCallback;
-(bool)fileSystemExistUserData:(NSString*)urlkey;
@end
@interface SyncCheckItem : NSObject
@property(nonatomic,strong)NSString* groupid;
@property(nonatomic,strong)SyncRequest* request;
@property(nonatomic,strong)SyncCheckItemCompleteCallback itemCompleteCallback;
-(id)initWithUrlkey:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback;
@end

@interface SyncRequest : NSObject
@property(nonatomic,strong)NSString* urlkey;
@property(nonatomic,assign,readonly)bool load;
@property(nonatomic,strong)SyncRequestParameterCallback requestParameterCallback;
@property(nonatomic,strong,readonly)NSString* filekey;
-(id)initWithUrlkey:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback;
-(void)setSyncUrlkey:(NSString*)syncUrlkey;
@end