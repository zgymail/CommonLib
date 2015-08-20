//
//  NetService.m
//  ky
//
//  Created by MacBook on 13-10-11.
//  Copyright (c) 2013年 pipi. All rights reserved.
//
#import "NetService.h"
#import "NSString+Encoding.h"
#import "NSData+Des.h"
#import "NSData+Base64.h"
#import "Reachability.h"
#import <AFNetworking/AFNetworking.h>
#import "AFDownloadRequestOperation.h"
#define DEFAULT_QUEUEID (@"defualt_queue_id")
@implementation NetServiceResponseInfo
@end
@implementation NetService{
    NSString* _rootUrl;
    NSString* _serviceUrl;
    NSString* _resourceRootUrl;
    
    Reachability* _hostReachability;
    NetServiceNetworkCheckBlock _networkCheck;
    NetworkStatus _currentState;
    
    NSHashTable* _networkCheckDelegates;
    NSMutableDictionary* _domains;
    
}

-(void)setRootUrl:(NSString *) rootUrl{
    _rootUrl=rootUrl;
    if(_resourceRootUrl==nil){
        _resourceRootUrl=rootUrl;
    }
}

-(void)setResourceRootUrl:(NSString *) rootUrl{
    _resourceRootUrl=rootUrl;
}


-(void)setServiceUrl:(NSString *) serviceUrl{
    _serviceUrl=serviceUrl;
}

+(NetService*)shareInstance{
    static NetService *instance=nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[self alloc] init];
//    });
    @synchronized(self) {
        if (instance == nil) {
            NSLog(@"share instance");
            instance=[[self alloc] init];
        }
    }
    return instance;
}
-(id)init {
    if (self = [super init]) {
        NSLog(@"NetService init");
        //init property
        _rootUrl=nil;
        _serviceUrl=nil;
        _defaultParse=[[NetServiceBaseParse alloc] init];
        _currentState=100;
        _networkCheckDelegates=[NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _domains=[NSMutableDictionary dictionary];
        [self createDomain:DEFAULT_QUEUEID];
    }
    return self;
}

- (void)dealloc{
    _rootUrl=nil;
    _serviceUrl=nil;
}

-(void)setNetworkCheck:(NetServiceNetworkCheckBlock)networkCheck{
     _networkCheck=networkCheck;
    if(_hostReachability==nil){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        _hostReachability = [Reachability reachabilityWithHostname:_rootUrl];
        [_hostReachability startNotifier];
    }
}
-(void)addNetworkCheck:(id<NetServiceReceiveDataDelegate>)checkDelegate{
    [_networkCheckDelegates addObject:checkDelegate];
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NetworkStatus _newState=[reachability currentReachabilityStatus];
    NetServiceNetworkSwitchStatus switchState=NetServiceNetworkSwitchStatusNone;
    if(_currentState==NotReachable&& _newState!=NotReachable){
        switchState=NetServiceNetworkSwitchStatusYes;
    }else if(_currentState!=NotReachable&& _newState==NotReachable){
        switchState=NetServiceNetworkSwitchStatusNo;
    }
    _networkCheck(switchState,_newState);
    for(id<NetServiceReceiveDataDelegate> delegate in _networkCheckDelegates){
        if([delegate respondsToSelector:@selector(reachabilityChanged:networkStatus:)]){
            [delegate reachabilityChanged:switchState networkStatus:_newState];
        }
    }
    _currentState=_newState;
    /*
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });*/
}



-(void) sendData:(NSString*)serviceName delegate:(id<NetServiceReceiveDataDelegate>)delegate data:(id)data parse:(id<NetServiceParseDelegate>)parse {
    if(data==nil){
        [self sendData:serviceName delegate:delegate parse:parse];
        return;
    }
    //    NSLog(@"---------------------");
    //    NSLog(@"%@%@%@",_rootUrl,_serviceUrl,serviceName);
    //    NSLog(@"---------------------");
    if(parse==nil){
        parse=_defaultParse;
    }
    NSError *error;
    NSData *byteData = [parse encode:data error:&error];
    if(error!=nil){
        NSLog(@"sendData parse error:%@", [error localizedDescription]);
        return;
    }
    NSString *dataStr=[byteData base64EncodedString];
    NSString *furl=[[NSString alloc] initWithFormat:@"%@%@%@",_rootUrl,_serviceUrl,serviceName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"data": dataStr};
    [manager POST:furl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSData* responseData=operation.responseData;
        id data = [parse decode:responseData error:&error];
        if([delegate respondsToSelector:@selector(receiveData:data:responseStatus:)]){
            if(error){
                [delegate receiveData:serviceName data:data responseStatus:NetServiceResponseStatusParseFail];
            }else{
                [delegate receiveData:serviceName data:data responseStatus:NetServiceResponseStatusSuccess];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request receive data fail %@",error);
        if([delegate respondsToSelector:@selector(receiveData:data:responseStatus:)]){
            [delegate receiveData:serviceName data:nil responseStatus:NetServiceResponseStatusFail];
        }
    }];
}
-(void) sendData:(NSString*)serviceName delegate:(id<NetServiceReceiveDataDelegate>)delegate parse:(id<NetServiceParseDelegate>)parse{
    if(parse==nil){
        parse=_defaultParse;
    }
    NSString *furl=[[NSString alloc] initWithFormat:@"%@%@%@",_rootUrl,_serviceUrl,serviceName];
//    NSLog(@"---------------------");
//    NSLog(@"%@%@%@",_rootUrl,_serviceUrl,serviceName);
//    NSLog(@"---------------------");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:furl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSData* responseData=operation.responseData;
        id data = [parse decode:responseData error:&error];
        if([delegate respondsToSelector:@selector(receiveData:data:responseStatus:)]){
            if(error){
                [delegate receiveData:serviceName data:data responseStatus:NetServiceResponseStatusParseFail];
            }else{
                [delegate receiveData:serviceName data:data responseStatus:NetServiceResponseStatusSuccess];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request receive data fail %@",error);
        if([delegate respondsToSelector:@selector(receiveData:data:responseStatus:)]){
            [delegate receiveData:serviceName data:nil responseStatus:NetServiceResponseStatusFail];
        }
    }];
}


-(void) sendData:(NSString*)serviceName delegate:(id<NetServiceReceiveDataDelegate>)delegate data:(id)data uploadFileDatas:(NSArray*)uploadFileDatas parse:(id<NetServiceParseDelegate>)parse{
    NSString *furl=[[NSString alloc] initWithFormat:@"%@%@%@",_rootUrl,_serviceUrl,serviceName];
//    NSLog(@"---------------------");
//    NSLog(@"%@%@%@",_rootUrl,_serviceUrl,serviceName);
//    NSLog(@"---------------------");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters=nil;
    if(data!=nil){
        NSError *error;
        NSData *byteData =[parse encode:data error:&error];
        if(error!=nil){
            NSLog(@"parse error:%@", [error localizedDescription]);
            return;
        }
        NSString *dataStr=[byteData base64EncodedString];
        parameters = @{@"data": dataStr};
    }
    [manager POST:furl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for(NSInteger i=0;i<uploadFileDatas.count;i++){
            NSDictionary *rowData=uploadFileDatas[i];
            NSString* refUrl=rowData[UIImagePickerControllerReferenceURL];
            refUrl=[[NSString alloc] initWithFormat:@"%@",refUrl];
            NSArray* refUrlCompoment=[refUrl componentsSeparatedByString:@"ext="];
            NSString* type=@"png";
            if(refUrlCompoment.count==2){
                type=[refUrlCompoment[1] lowercaseString];
            }
            NSString* name=[NSString stringWithFormat:@"file%li",(long)i];
            NSString* filename=[NSString stringWithFormat:@"%@.%@",name,type];
            NSString* contentType=[NSString stringWithFormat:@"%@%@",@"image/",type];
            UIImage* image=rowData[UIImagePickerControllerOriginalImage];
            NSData* imageData;
            if([type isEqualToString:@"jpg"]){
                imageData = UIImageJPEGRepresentation(image, 1.0);
            }else{
                imageData = UIImagePNGRepresentation(image);
            }
            [formData appendPartWithFileData:imageData name:name fileName:filename mimeType:contentType];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSData* responseData=operation.responseData;
        id data = [parse decode:responseData error:&error];
        if([delegate respondsToSelector:@selector(receiveData:data:responseStatus:)]){
            if(error){
                [delegate receiveData:serviceName data:data responseStatus:NetServiceResponseStatusParseFail];
            }else{
                [delegate receiveData:serviceName data:data responseStatus:NetServiceResponseStatusSuccess];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request receive data fail %@",error);
        if([delegate respondsToSelector:@selector(receiveData:data:responseStatus:)]){
            [delegate receiveData:serviceName data:nil responseStatus:NetServiceResponseStatusFail];
        }
    }];
}

-(void) sendData:(NSString*)serviceName completionBlock:(NetServiceSendDataCompleteBlock)completionBlock parse:(id<NetServiceParseDelegate>)parse
{
    if(parse==nil){
        parse=_defaultParse;
    }
    NSString *furl=[[NSString alloc] initWithFormat:@"%@%@%@",_rootUrl,_serviceUrl,serviceName];
//    NSLog(@"---------------------");
//    NSLog(@"%@%@%@",_rootUrl,_serviceUrl,serviceName);
//    NSLog(@"---------------------");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:furl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSData* responseData=operation.responseData;
        id data =[parse decode:responseData error:&error];
        NetServiceResponseInfo* responseInfo=[[NetServiceResponseInfo alloc] init];
        if(error){
            completionBlock(data,NetServiceResponseStatusParseFail,responseInfo);
        }else{
            completionBlock(data,NetServiceResponseStatusSuccess,responseInfo);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request receive data fail %@",error);
        completionBlock(nil,NetServiceResponseStatusFail,nil);
    }];
}

-(void) sendData:(NSString*)serviceName data:(id)data completionBlock:(NetServiceSendDataCompleteBlock)completionBlock parse:(id<NetServiceParseDelegate>)parse{
    if(data==nil){
        [self sendData:serviceName completionBlock:completionBlock parse:parse];
        return;
    }
    //    NSLog(@"---------------------");
    //    NSLog(@"%@%@%@",_rootUrl,_serviceUrl,serviceName);
    //    NSLog(@"---------------------");
    if(parse==nil){
        parse=_defaultParse;
    }
    NSError *error;
    NSData *byteData =[parse encode:data error:&error];
    if(error!=nil){
        NSLog(@"parse format error:%@", [error localizedDescription]);
        return;
    }
    NSString *dataStr=[byteData base64EncodedString];
    NSString *furl=[[NSString alloc] initWithFormat:@"%@%@%@",_rootUrl,_serviceUrl,serviceName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"data": dataStr};
    [manager POST:furl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSData* responseData=operation.responseData;
        id data =[parse decode:responseData error:&error];
        NetServiceResponseInfo* responseInfo=[[NetServiceResponseInfo alloc] init];
        if(error){
            completionBlock(data,NetServiceResponseStatusParseFail,responseInfo);
        }else{
            completionBlock(data,NetServiceResponseStatusSuccess,responseInfo);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request receive data fail %@",error);
        completionBlock(nil,NetServiceResponseStatusFail,nil);
    }];
}

-(void) sendData:(NSString*)serviceName data:(id)data  uploadFileDatas:(NSArray*)uploadFileDatas completionBlock:(NetServiceSendDataCompleteBlock)completionBlock parse:(id<NetServiceParseDelegate>)parse{
    if(parse==nil){
        parse=_defaultParse;
    }
    NSString *furl=[[NSString alloc] initWithFormat:@"%@%@%@",_rootUrl,_serviceUrl,serviceName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters=nil;
    if(data!=nil){
        NSError *error;
        NSData *byteData =[parse encode:data error:&error];
        if(error!=nil){
            NSLog(@"parse error:%@", [error localizedDescription]);
            return;
        }
        NSString *dataStr=[byteData base64EncodedString];
        parameters = @{@"data": dataStr};
    }
    [manager POST:furl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for(NSInteger i=0;i<uploadFileDatas.count;i++){
            NSDictionary *rowData=uploadFileDatas[i];
            NSString* refUrl=rowData[UIImagePickerControllerReferenceURL];
            refUrl=[[NSString alloc] initWithFormat:@"%@",refUrl];
            NSArray* refUrlCompoment=[refUrl componentsSeparatedByString:@"ext="];
            NSString* type=@"png";
            if(refUrlCompoment.count==2){
                type=[refUrlCompoment[1] lowercaseString];
            }
            NSString* name=[NSString stringWithFormat:@"file%li",(long)i];
            NSString* filename=[NSString stringWithFormat:@"%@.%@",name,type];
            NSString* contentType=[NSString stringWithFormat:@"%@%@",@"image/",type];
            UIImage* image=rowData[UIImagePickerControllerOriginalImage];
            NSData* imageData;
            if([type isEqualToString:@"jpg"]){
                imageData = UIImageJPEGRepresentation(image, 1.0);
            }else{
                imageData = UIImagePNGRepresentation(image);
            }
            [formData appendPartWithFileData:imageData name:name fileName:filename mimeType:contentType];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSData* responseData=operation.responseData;
        id data = [parse decode:responseData error:&error];
        NetServiceResponseInfo* responseInfo=[[NetServiceResponseInfo alloc] init];
        if(error){
            completionBlock(data,NetServiceResponseStatusParseFail,responseInfo);
        }else{
            completionBlock(data,NetServiceResponseStatusSuccess,responseInfo);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request receive data fail %@",error);
        completionBlock(nil,NetServiceResponseStatusFail,nil);
    }];
}


-(NetServiceDamain*)createDomain:(NSString*)domainid{
    NetServiceDamain* _domain;
    if(_domains[domainid]){
        _domain=_domains[domainid];
        [_domain cancelAllOperations];
    }
    _domain=[[NetServiceDamain alloc] init];
    [_domain setMaxConcurrentOperationCount:1];
    [_domain setStoragePath:@"download"];
    _domains[domainid]=_domain;
    return _domain;
}

-(void)removeDomain:(NSString*)domainid{
    if(domainid==nil){
        domainid=DEFAULT_QUEUEID;
    }
    if(_domains[domainid]){
        NetServiceDamain* _networkQueue=_domains[domainid];
        [_networkQueue cancelAllOperations];
        if(![domainid isEqualToString:DEFAULT_QUEUEID]){
            [_domains removeObjectForKey:domainid];
        }
    }
}
-(NetServiceDamain*)getDomain:(NSString*)domainid{
    if(domainid==nil){
        domainid=DEFAULT_QUEUEID;
    }
    return _domains[domainid];
}

-(void)cacelDomainLoading:(NSString*)domainid{
    if(domainid==nil){
        domainid=DEFAULT_QUEUEID;
    }
    if(_domains[domainid]){
        NetServiceDamain* _networkQueue=_domains[domainid];
        [_networkQueue cancelAllOperations];
    }
}


-(void)networkQueueCompleteAction:(id)sender{

}

-(void)requestDidStartAction:(id)sender{
  //  ASIHTTPRequest* _request=sender;
    //NSLog(@"requestDidStartAction:%@",_request.url);
}

-(void)requestDidFinishAction:(id)sender{
   // ASIHTTPRequest* _request=sender;
    //NSLog(@"requestDidFinishAction:%@",_request.url);
}

-(void)requestDidFailAction:(id)sender{
  //  ASIHTTPRequest* _request=sender;
    //NSLog(@"requestDidFailAction:%@",_request.url);
}


- (void) loadImage:(NSString*)relaviteUrl complete:(NetServiceLoadImageCompleteBlock)completeBlock{
    [self loadImage:relaviteUrl complete:completeBlock domainid:DEFAULT_QUEUEID];
}
- (void) loadImage:(NSString*)relaviteUrl complete:(NetServiceLoadImageCompleteBlock)completeBlock domainid:(NSString *)domainid{
    NSString* imageURL;
    if([[relaviteUrl substringToIndex:1] isEqualToString:@"/"] ||[[relaviteUrl substringToIndex:6] isEqualToString:@"upload"]){
        imageURL=[[NSString alloc] initWithFormat:@"%@%@",_resourceRootUrl,relaviteUrl];
    }else{
        imageURL=relaviteUrl;
    }
//    NSLog(@"---------------------");
//    NSLog(@"loadImage%@",imageURL);
//    NSLog(@"---------------------");
    NetServiceDamain* domain=_domains[domainid];
    if(domain==nil){
        domain=_domains[DEFAULT_QUEUEID];
    }
    NSURL *URL = [NSURL URLWithString:imageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFImageResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage* image=responseObject;
        @try {
            completeBlock(image);
        }
        @catch (NSException *exception) {
            NSLog(@"*****************load image fail,message:%@",exception.name);
        }
        @finally {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"************************async image download failed");
    }];
    [domain addOperation:op];
}


//data
- (void) loadData:(NSString*)relaviteUrl complete:(NetServiceSendDataCompleteBlock)completeBlock parse:(id<NetServiceParseDelegate>)parse{
    [self loadData:relaviteUrl complete:completeBlock parse:parse domainid:DEFAULT_QUEUEID];
}
- (void) loadData:(NSString*)relaviteUrl complete:(NetServiceSendDataCompleteBlock)completeBlock  parse:(id<NetServiceParseDelegate>)parse domainid:(NSString *)domainid{
    NSString* url;
    if([[relaviteUrl substringToIndex:1] isEqualToString:@"/"] ||[[relaviteUrl substringToIndex:6] isEqualToString:@"upload"]){
        url=[[NSString alloc] initWithFormat:@"%@%@",_resourceRootUrl,relaviteUrl];
    }else{
        url=relaviteUrl;
    }
    if(parse==nil){
        parse=_defaultParse;
    }
    NetServiceDamain* domain=_domains[domainid];
    if(domain==nil){
        domain=_domains[DEFAULT_QUEUEID];
    }
    NSURL *URL = [NSURL URLWithString:url];
    /*
    NSData* storageData=[domain.storage getStorageData:URL];
    if(storageData){
        NSError* error;
        id idata=[parse decode:storageData error:&error];
        NetServiceResponseInfo* responseInfo=[[NetServiceResponseInfo alloc] init];
        responseInfo.url=URL;
        responseInfo.cache=true;
        if(error){
            completeBlock(nil,NetServiceResponseStatusParseFail,responseInfo);
        }else{
            completeBlock(idata,NetServiceResponseStatusSuccess,responseInfo);
        }
    }else{
     */
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        AFHTTPRequestOperation* op=[[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFHTTPResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
            NSData* data=responseObject;
            NSError* error;
            id idata=[parse decode:data error:&error];
            NetServiceResponseInfo* responseInfo=[[NetServiceResponseInfo alloc] init];
            responseInfo.cache=false;
            responseInfo.url=operation.request.URL;
            if(error){
                completeBlock(nil,NetServiceResponseStatusParseFail,responseInfo);
            }else{
                //[domain.storage saveStorageData:storageData url:URL];
                completeBlock(idata,NetServiceResponseStatusSuccess,responseInfo);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"************************async image download failed%@",error.description);
            completeBlock(nil,NetServiceResponseStatusFail,nil);
        }];
        [domain addOperation:op];
   // }
}

@end
@implementation NetServiceDamain
- (instancetype)init
{
    self = [super init];
    if (self) {
    
        
    }
    return self;
}
-(void)setStoragePath:(NSString *)storagePath{
    _storage=[[AFDownloadStorage alloc] initWithStoragePath:storagePath];
}


-(void)clearStoragePath{
    [_storage clear];
}

@end

@implementation NetServiceJsonParse

-(id)decode:(NSData*)data error:(NSError**)error{
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    return jsonObject;
}
-(NSData*)encode:(id)data error:(NSError**)error{
     NSData *byteData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:error];
    return byteData;
}

@end
@implementation NetServiceBaseParse
-(id)decode:(NSData*)data error:(NSError**)error{
    return data;
}
-(NSData*)encode:(id)data error:(NSError**)error{
    return data;
}
@end
@implementation NetServiceDesJsonParse
- (instancetype)init
{
    self = [super init];
    if (self) {
        _readingOptions=NSJSONReadingAllowFragments;
    }
    return self;
}
-(id)decode:(NSData*)data error:(NSError**)error{
    data=[data desDecoded];
    if(data==nil){
        NSString *description = @"des data after is nil";
        NSString *recoverySuggestion = @"please check data exception";
        NSInteger errorCode = -1;
        NSArray *keys = [NSArray arrayWithObjects: NSLocalizedDescriptionKey, NSLocalizedRecoverySuggestionErrorKey, nil];
        NSArray *values = [NSArray arrayWithObjects:description, recoverySuggestion, nil];
        NSDictionary *userDict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        if(error){
            *error=[[NSError alloc] initWithDomain:@"data domain" code:errorCode userInfo:userDict];
        }
        return nil;
    }
     NSError* err;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:_readingOptions error:&err];
    if(err){
        *error=err;
        return nil;
    }
    return jsonObject;
}

-(NSData*)encode:(id)data error:(NSError**)error{
    NSError* err;
    NSData *byteData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&err];
    if(err){
        *error=err;
        return nil;
    }
    byteData=[byteData desEncoded];
    
    return byteData;
}

@end
