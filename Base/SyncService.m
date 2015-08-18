//
//  SyncService.m
//  SSAdventure
//
//  Created by MacBook on 6/1/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import "SyncService.h"
#import "FileService.h"
#import "NetService.h"

@implementation SyncService{
    NSMutableArray* _syncDataRequests;
    NSMutableDictionary* _syncDataWaitSaveDictionary;
    SyncCheckCompleteCallback _checkCompleteBlock;
    NSMutableArray* _currentCheckList;
}
SYNTHESIZE_SINGLETON_FOR_IMPL(SyncService)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _syncDataRequests=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)removeRegisterWithGroupid:(NSString*)groupid{
    NSMutableArray* _syncDataRequestsRemove=[[NSMutableArray alloc] init];
    for(SyncCheckItem* item in _syncDataRequests){
        if([item.groupid isEqualToString:groupid]){
            [_syncDataRequestsRemove addObject:item];
        }
    }
    [_syncDataRequests removeObjectsInArray:_syncDataRequestsRemove];
}

-(void)registerResourceUpdateCheck:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback checkItemCompleteCallback:(SyncCheckItemCompleteCallback)checkItemCompleteCallback groupid:(NSString*)groupid{
    for(SyncCheckItem* item in _syncDataRequests){
        if([item.request.urlkey isEqualToString:urlkey]){
            return;
        }
    }
    SyncCheckItem* checkItem=[[SyncCheckItem alloc] initWithUrlkey:urlkey requestParameterCallback:requestParameterCallback];
    checkItem.itemCompleteCallback=checkItemCompleteCallback;
    checkItem.groupid=groupid;
    [_syncDataRequests addObject:checkItem];
}

-(void)registerCurrentResourceUpdateCheck:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback checkItemCompleteCallback:(SyncCheckItemCompleteCallback)checkItemCompleteCallback{
    if(_currentCheckList!=nil){
        for(SyncCheckItem* item in _currentCheckList){
            if([item.request.urlkey isEqualToString:urlkey]){
                return;
            }
        }
        SyncCheckItem* checkItem=[[SyncCheckItem alloc] initWithUrlkey:urlkey requestParameterCallback:requestParameterCallback];
        checkItem.itemCompleteCallback=checkItemCompleteCallback;
        checkItem.groupid=@"dynamic";
        [_currentCheckList addObject:checkItem];
    }
}

-(bool)checkResourceUpdate:(SyncCheckCompleteCallback)complete{
    
     return [self checkResourceUpdate:complete syncDataRequests:_syncDataRequests];
}

-(bool)checkResourceUpdate:(SyncCheckCompleteCallback)complete syncDataRequests:(NSMutableArray*)syncDataRequests{
    if(_checkCompleteBlock!=nil){
        return false;
    }
     NSLog(@"SyncService checkUpdate start");
    _checkCompleteBlock=complete;
    _currentCheckList=[[NSMutableArray alloc] initWithArray:syncDataRequests];
    _syncDataWaitSaveDictionary=[[NSMutableDictionary alloc] init];
    [self continueCheckNext];
    return true;
}

-(bool)checkResourceUpdateWithGroupids:(NSArray*)groupids complete:(SyncCheckCompleteCallback)complete{
     NSMutableArray* _currentSyncDataRequests=[[NSMutableArray alloc] init];
    for(SyncCheckItem* checkItem in _syncDataRequests){
        
        if([groupids containsObject:checkItem.groupid]){
            [_currentSyncDataRequests addObject:checkItem];
        }
    }
    return [self checkResourceUpdate:complete syncDataRequests:_currentSyncDataRequests];
}

-(void)continueCheckNext{
    if(_currentCheckList.count>0){
        SyncCheckItem* checkItem=_currentCheckList.firstObject;
        [_currentCheckList removeObjectAtIndex:0];
        SyncRequest* syncDataRequest=checkItem.request;
        [self networkRequestResourceWithCheck:syncDataRequest.urlkey requestParameterCallback:syncDataRequest.requestParameterCallback requestCompleteCallback:^(NSDictionary *data,bool write) {
            if(data==nil){
                [_syncDataWaitSaveDictionary removeAllObjects];
                [self checkResourceUpdateComplete:false];
            }else{
                if(write){
                    _syncDataWaitSaveDictionary[syncDataRequest.filekey]=data;
                }
                SyncCheckItemCompleteCallback itemCompleteCallback=checkItem.itemCompleteCallback;
                if(itemCompleteCallback!=nil){
                    if(checkItem.itemCompleteCallback(data)){
                        [self continueCheckNext];
                    }
                }else{
                    [self continueCheckNext];
                }
            }
        }];
    }else{
        [self checkResourceUpdateComplete:true];
    }
}

-(void)checkResourceUpdateComplete:(bool)success{
    if(_syncDataWaitSaveDictionary.count>0){
        NSMutableDictionary* _syncDataList=[[NSMutableDictionary alloc] init];
        NSEnumerator* keys=_syncDataWaitSaveDictionary.keyEnumerator;
        for(NSString* filekey in keys){
                NSDictionary* data=_syncDataWaitSaveDictionary[filekey];
                NSError* error;
                NSData* enData =[[NetService shareInstance].defaultParse encode:data error:&error];
                if(error){
                    [_syncDataList removeAllObjects];
                    success=false;
                    break;
                }else{
                    _syncDataList[filekey]=enData;
                }
        }
        if(_syncDataList.count>0){
            FileService* fileService=[FileService sharedInstance];
            [fileService dir:@"resource"];
            NSEnumerator* keys=_syncDataList.keyEnumerator;
            for(NSString* filekey in keys){
                NSData* data=_syncDataList[filekey];
                [fileService saveFile:filekey data:data];
            }
        }
    }
    if(!success){
         NSLog(@"SyncService checkUpdate fail");
    }
    _currentCheckList=nil;
    _checkCompleteBlock(success);
    _checkCompleteBlock=nil;
}

-(void)networkRequestResourceWithCheck:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback requestCompleteCallback:(void (^)(NSDictionary* data,bool write))requestCompleteCallback{
    SyncRequest* syncDataRequest=[[SyncRequest alloc] initWithUrlkey:urlkey requestParameterCallback:requestParameterCallback];
    if(syncDataRequest.load){
        [[NetService shareInstance] loadData:syncDataRequest.urlkey complete:^(id data,NetServiceResponseStatus responseState,NetServiceResponseInfo* connectInfo) {
            if(responseState==NetServiceResponseStatusSuccess){
                requestCompleteCallback(data,!connectInfo.cache);
            }else{
                requestCompleteCallback(nil,false);
            }
        } parse:nil];
    }else{
        NSDictionary* data=nil;
        if(syncDataRequest.requestParameterCallback!=nil){
            data=syncDataRequest.requestParameterCallback();
        }
        [[NetService shareInstance] sendData:urlkey data:data completionBlock:^(id data,NetServiceResponseStatus status,NetServiceResponseInfo* connectInfo) {
            if(status==NetServiceResponseStatusSuccess){
                NSNumber* s=data[@"success"];
                if(s.boolValue){
                    NSDictionary* syncdata=data[@"syncData"];
                    requestCompleteCallback(syncdata,!connectInfo.cache);
                }else{
                    requestCompleteCallback(nil,false);
                }
            }else{
                requestCompleteCallback(nil,false);
            }
        } parse:nil];
    }
}


-(void)networkRequestResource:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback requestCompleteCallback:(SyncRequestCompleteCallback)requestCompleteCallback parse:(id<NetServiceParseDelegate>)parse{
    SyncRequest* syncDataRequest=[[SyncRequest alloc] initWithUrlkey:urlkey requestParameterCallback:requestParameterCallback];
    if(syncDataRequest.load){
        [[NetService shareInstance] loadData:syncDataRequest.urlkey complete:^(id data,NetServiceResponseStatus responseState,NetServiceResponseInfo* connectInfo) {
            if(responseState==NetServiceResponseStatusSuccess){
                if(!connectInfo.cache){
                    NSError* error;
                    NSData* enData =[[NetService shareInstance].defaultParse encode:data error:&error];
                    if(error){
                       NSLog(@"SyncService networkRequestData write file parse fail,urlkey:%@",urlkey);
                    }else{
                        FileService* fileService=[FileService sharedInstance];
                        [fileService dir:@"resource"];
                        [fileService saveFile:syncDataRequest.filekey data:enData];
                    }
                }
                requestCompleteCallback(data);
            }else{
                requestCompleteCallback(nil);
            }
        } parse:parse];
    }else{
        NSDictionary* data=nil;
        if(syncDataRequest.requestParameterCallback!=nil){
            data=syncDataRequest.requestParameterCallback();
        }
        [[NetService shareInstance] sendData:urlkey data:data completionBlock:^(id data,NetServiceResponseStatus status,NetServiceResponseInfo* connectInfo) {
            if(status==NetServiceResponseStatusSuccess){
                NSNumber* s=data[@"success"];
                if(s.boolValue){
                    if(data[@"syncUrlkey"]!=nil){
                        [syncDataRequest setSyncUrlkey:data[@"syncUrlkey"]];
                    }
                    NSInteger type=((NSNumber*)data[@"type"]).integerValue;
                    NSDictionary* syncdata=data[@"syncData"];
                    if(type==1||type==2||type==3){//拉取，添加，修改
                        NSError* error;
                        NSData* enData =[[NetService shareInstance].defaultParse encode:syncdata error:&error];
                        if(error){
                            NSLog(@"SyncService networkRequestData write file parse fail,urlkey:%@",urlkey);
                        }else{
                            FileService* fileService=[FileService sharedInstance];
                            [fileService dir:@"resource"];
                            [fileService saveFile:syncDataRequest.filekey data:enData];
                        }
                        requestCompleteCallback(syncdata);
                    }else if(type==4){//删除
                        FileService* fileService=[FileService sharedInstance];
                        [fileService dir:@"resource"];
                        [fileService deleteFile:syncDataRequest.filekey];
                        requestCompleteCallback(syncdata);
                    }
                    
                }else{
                    requestCompleteCallback(nil);
                }
            }else{
                requestCompleteCallback(nil);
            }
        } parse:parse];
    }
}


-(void)fileSystemRequestResource:(NSString*)urlkey requestCompleteCallback:(SyncRequestCompleteCallback)requestCompleteCallback{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        SyncRequest* syncDataRequest=[[SyncRequest alloc] initWithUrlkey:urlkey requestParameterCallback:nil];
        FileService* fileService=[FileService sharedInstance];
        [fileService dir:@"resource"];
        
        NSString* furlkey=syncDataRequest.filekey;
        NSData* byteData= [fileService getFile:furlkey];
        NSError *error;
        NSDictionary* jsonData =[[NetService shareInstance].defaultParse decode:byteData error:&error];
        if(error!=nil){
            NSLog(@"SyncService fileSystemRequestResource json format error filepath:%@ error:%@",furlkey,[error localizedDescription]);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            requestCompleteCallback(jsonData);
        });
    });

}

-(void)fileSystemRequestUserData:(NSString*)urlkey requestCompleteCallback:(SyncRequestCompleteCallback)requestCompleteCallback{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        SyncRequest* syncDataRequest=[[SyncRequest alloc] initWithUrlkey:urlkey requestParameterCallback:nil];
        
        FileService* fileService=[FileService sharedInstance];
        [fileService dir:@"userData"];
        NSString* furlkey=syncDataRequest.filekey;
        NSData* byteData= [fileService getFile:furlkey];
        NSError *error;
        NSDictionary* jsonData =[[NetService shareInstance].defaultParse decode:byteData error:&error];
        if(error!=nil){
            NSLog(@"SyncService fileSystemRequestUserData json format error filepath:%@ error:%@",furlkey,[error localizedDescription]);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
             requestCompleteCallback(jsonData);
        });
    });
 }

-(void)fileSystemSaveUserData:(NSString*)urlkey data:(NSDictionary*)data saveCompleteCallback:(SyncSaveCompleteCallback)saveCompleteCallback{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
            SyncRequest* syncDataRequest=[[SyncRequest alloc] initWithUrlkey:urlkey requestParameterCallback:nil];
             NSString* furlkey=syncDataRequest.filekey;
            
            NSError *error;
            NSData* byteData =[[NetService shareInstance].defaultParse encode:data error:&error];
            bool success=true;
            if(error!=nil){
                NSLog(@"SyncService fileSystemSaveUserData json format error filepath:%@ error:%@",furlkey,[error localizedDescription]);
                success=false;
            }else{
                FileService* fileService=[FileService sharedInstance];
                [fileService dir:@"userData"];
                [fileService saveFile:furlkey data:byteData];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                saveCompleteCallback(success);
            });
    });
}

-(bool)fileSystemExistUserData:(NSString*)urlkey{
    SyncRequest* syncDataRequest=[[SyncRequest alloc] initWithUrlkey:urlkey requestParameterCallback:nil];
    NSString* furlkey=syncDataRequest.filekey;
    FileService* fileService=[FileService sharedInstance];
    [fileService dir:@"userData"];
    return [fileService existFile:furlkey];
}


@end
@implementation SyncCheckItem{
   
}

-(id)initWithUrlkey:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback{
    self = [super init];
    if (self) {
        _request=[[SyncRequest alloc] initWithUrlkey:urlkey requestParameterCallback:requestParameterCallback];

    }
    return self;
}
@end
@implementation SyncRequest{
     NSString* _syncUrlkey;
}
-(id)initWithUrlkey:(NSString*)urlkey requestParameterCallback:(SyncRequestParameterCallback)requestParameterCallback{
    self = [super init];
    if (self) {
        _urlkey=urlkey;
        _requestParameterCallback=requestParameterCallback;
        _syncUrlkey=urlkey;
    }
    return self;
}

-(void)setSyncUrlkey:(NSString*)syncUrlkey{
    _syncUrlkey=syncUrlkey;
}

-(NSString*)filekey{
    NSRange range=[_syncUrlkey rangeOfString:@"/"];
    if(range.location==0&&range.length==1){
        NSString* filekey= [_syncUrlkey substringFromIndex:1];
        filekey=[filekey stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        return filekey;
    }else{
        NSString* filekey=[_syncUrlkey stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        filekey=[NSString stringWithFormat:@"%@.dat",filekey];
        return filekey;
    }
}

-(bool)load{
    NSRange range=[_urlkey rangeOfString:@"/"];
    return range.location==0&&range.length==1;
}

@end
