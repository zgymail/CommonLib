//
//  ResourceService.m
//  test2
//
//  Created by gavin on 15/6/30.
//  Copyright (c) 2015年 SC. All rights reserved.
//

#import "ResourceService.h"
#import "NetService.h"
#import "ResourceDataFile.pb.h"
#import "ResourceByte.pb.h"
#import "Config.pb.h"
#import "ConfigItem.pb.h"
#include <stdio.h>
#include "ZipArchive.h"
@implementation ResourceService{
    NSString* _resourceAniConfig;
    NSString* _localResourceDir;
    NSString* _appResourceDir;
    NSString* _remoteResourceURL;
    ResourceServiceLoadRemoteResourceCompleteBlock _callback;
    NSMutableDictionary* _resourceConfigItems;
    NSMutableDictionary* _resourceAnimations;
    NSMutableDictionary* _resourceAtlasc;
    
}
SYNTHESIZE_SINGLETON_FOR_IMPL(ResourceService)
- (instancetype)init
{
    self = [super init];
    if (self) {
        _resourceAnimations=[[NSMutableDictionary alloc] init];
        _resourceConfigItems=[[NSMutableDictionary alloc] init];
        _resourceAtlasc=[[NSMutableDictionary alloc] init];
        _resourceAniConfig=@"ResourceAniConfig.pro";
        _appResourceDir=[NSString stringWithFormat:@"%@/",[[NSBundle mainBundle] resourcePath]];
        _localResourceDir=[NSString stringWithFormat:@"%@/rs/",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    }
    return self;
}

-(void)setLocalResourceDir:(NSString*)dir{
     _localResourceDir=dir;
}
-(void)setRemoteResourceUrl:(NSString*)url{
     _remoteResourceURL=url;
}
-(void)loadRemoteResourceConfigItem:(ResourceServiceLoadRemoteResourceCompleteBlock)callback{
    _callback=callback;
    NSString* furl=[NSString stringWithFormat:@"%@%@",_remoteResourceURL,_resourceAniConfig];
    NSLog(@"load remote resource:%@",furl);
    [[NetService shareInstance] loadData:furl complete:^(id data, NetServiceResponseStatus responseStatus,NetServiceResponseInfo *responseInfo) {
        if (responseStatus==NetServiceResponseStatusSuccess) {
            [self parseResourceData:data];
        }else{
            _callback(false);
        }
    } parse:[[NetServiceBaseParse alloc] init]];
}
-(void)parseResourceData:(id)data{
    NSString* filePath=[NSString stringWithFormat:@"%@%@",_localResourceDir,_resourceAniConfig];
    NSMutableDictionary* currentResourceConfigItem;
    if (_resourceConfigItems.count>0) {
        currentResourceConfigItem=_resourceConfigItems;
        _resourceConfigItems=[[NSMutableDictionary alloc] init];
    }else{
        currentResourceConfigItem=[self getLocalResourceConfigItems];
    }
    NSError* error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_localResourceDir]){
        [fileManager createDirectoryAtPath:_localResourceDir
               withIntermediateDirectories:YES attributes:nil
                                     error:&error];
        if(error){
            NSLog(@"create resource config dir %@ error:%@",_localResourceDir,error.description);
            _callback(false);
            return;
        }
    }
    if ([fileManager fileExistsAtPath:filePath]){
        [fileManager removeItemAtPath:filePath error:nil];
    }
    [data writeToFile:filePath options:NSDataWritingWithoutOverwriting error:&error];
    if(error){
         NSLog(@"save file %@ error:%@",filePath,error.description);
        _callback(false);
        return;
    }
    [self loadLocalResourceConfigItem];
    [self updateRemoteToLocal:currentResourceConfigItem];
    [self cleanResourceConfigItems:currentResourceConfigItem];
}

-(void)updateRemoteToLocal:(NSMutableDictionary*)oldResourceConfigItems{
    __block NSInteger loadCount=0;
    void(^loadComplete)(id data, NetServiceResponseStatus responseStatus,  NetServiceResponseInfo* responseInfo)=^(id data, NetServiceResponseStatus responseStatus, NetServiceResponseInfo* responseInfo) {
        loadCount--;
        NSString* path = responseInfo.url.relativeString;
        path=[path substringWithRange:NSMakeRange(_remoteResourceURL.length,path.length-_remoteResourceURL.length)];
        path=[path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        NSString* filePath=[NSString stringWithFormat:@"%@%@",_localResourceDir,path];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]){
            [fileManager removeItemAtPath:filePath error:nil];
        }
        NSError* error;
        [data writeToFile:filePath options:NSDataWritingWithoutOverwriting error:&error];
        if(error){
            NSLog(@"updateRemoteToLocal save file %@ error:%@",filePath,error.description);
        }
        if(loadCount==0){
             _callback(true);
        }
    };
    void(^loadCompleteZip)(id data, NetServiceResponseStatus responseStatus,  NetServiceResponseInfo* responseInfo)=^(id data, NetServiceResponseStatus responseStatus, NetServiceResponseInfo* responseInfo) {
        loadCount--;
        NSString* url = responseInfo.url.relativeString;
        url=[url substringWithRange:NSMakeRange(_remoteResourceURL.length,url.length-_remoteResourceURL.length)];
        url=[url stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        NSString* filePath=[NSString stringWithFormat:@"%@%@",_localResourceDir,url];
       
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:filePath]){
            [fileManager removeItemAtPath:filePath error:nil];
        }
       
        NSError* error;
        [data writeToFile:filePath options:NSDataWritingWithoutOverwriting error:&error];
        if(error){
            NSLog(@"updateRemoteToLocal save file %@ error:%@",filePath,error.description);
        }else{
            NSString* filePathAtlasc=[[NSString stringWithFormat:@"%@%@",_localResourceDir,url] stringByDeletingPathExtension];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePathAtlasc]){
                [fileManager removeItemAtPath:filePathAtlasc error:nil];
            }
            [self openZip:filePath unzipto:filePathAtlasc];
            NSArray* contents=[fileManager contentsOfDirectoryAtPath:filePathAtlasc error:nil];
            NSString* file=[NSString stringWithFormat:@"%@/%@",filePathAtlasc,contents[0]];
            NSString* bak=[NSString stringWithFormat:@"%@.bak",filePathAtlasc];
            [fileManager moveItemAtPath:file toPath:bak error:nil];
            [fileManager removeItemAtPath:filePathAtlasc error:nil];
            [fileManager moveItemAtPath:bak toPath:filePathAtlasc error:nil];
            [fileManager removeItemAtPath:filePath error:nil];

            NSString* atlascName=[[url stringByDeletingPathExtension] stringByDeletingPathExtension];
            NSArray* fileNames=[fileManager contentsOfDirectoryAtPath:filePathAtlasc error:nil];
            for(NSString* fileName in fileNames){
               if ( [[fileName pathExtension ] isEqualToString:@"plist"]) {
                    NSString* file=[NSString stringWithFormat:@"%@/%@",filePathAtlasc,fileName];
                    NSRange range=[fileName rangeOfString:@"."];
                    NSString* nfileName=[fileName substringFromIndex:range.location];
                    nfileName=[NSString stringWithFormat:@"%@/%@%@",filePathAtlasc,atlascName,nfileName];
                    [fileManager moveItemAtPath:file toPath:nfileName error:nil];
                }
            }
             NSString* appFilePathAtlasc=[[NSString stringWithFormat:@"%@%@",_appResourceDir,url] stringByDeletingPathExtension];
            [fileManager copyItemAtPath:filePathAtlasc toPath:appFilePathAtlasc error:nil];
        }
        if(loadCount==0){
            _callback(true);
        }
    };
    
    
    
     NSArray* allValues=_resourceConfigItems.allValues;
     NetServiceBaseParse* parse=[[NetServiceBaseParse alloc] init];
      for(ConfigItem* configItem in allValues){
           NSString* key=configItem.id;
          ConfigItem* oldconfigItem=(ConfigItem*)oldResourceConfigItems[key];
          if(oldconfigItem){
              if (oldconfigItem.version==configItem.version) {
                  continue;
              }
          }
      
          NSString* itemUrl=configItem.url;
          NSString* baseUrl=[itemUrl substringWithRange:NSMakeRange(0,itemUrl.length-4)];
          [[NetService shareInstance] loadData:[NSString stringWithFormat:@"%@%@%@",_remoteResourceURL,baseUrl,@".ani"] complete:loadComplete parse:parse];
          [[NetService shareInstance] loadData:[NSString stringWithFormat:@"%@%@%@",_remoteResourceURL,baseUrl,@".atlasc.zip"] complete:loadCompleteZip parse:parse];
          NSLog(@"update resource file:%@%@",_localResourceDir,baseUrl);
          loadCount+=2;
    }
    if(loadCount==0){
        _callback(true);
    }
}

-(void)loadLocalResourceConfigItem{
    [self cleanResourceConfigItems:_resourceConfigItems];
    _resourceConfigItems=[self getLocalResourceConfigItems];
}

-(NSMutableDictionary*)getLocalResourceConfigItems{
    NSString* aniConfigPath=[NSString stringWithFormat:@"%@%@",_localResourceDir,_resourceAniConfig];
    NSData* data=[NSData dataWithContentsOfFile:aniConfigPath];
    Config* config=[Config parseFromData:data];
    NSArray* configItem=config.items;
    NSMutableDictionary* resourceConfigItems=[[NSMutableDictionary alloc] initWithCapacity:configItem.count];
    for (ConfigItem* item in config.items) {
        resourceConfigItems[item.id]=item;
    }
    return resourceConfigItems;
}

-(void)cleanResourceConfigItems:(NSMutableDictionary*)resourceConfigItems{
    [resourceConfigItems removeAllObjects];
}

-(void)cleanResourceAnimation:(NSMutableDictionary*)resourceAnimations{
    [resourceAnimations removeAllObjects];
}

- (void)openZip:(NSString*)zipPath  unzipto:(NSString*)_unzipto
{
    ZipArchive* zip = [[ZipArchive alloc] init];
    if( [zip UnzipOpenFile:zipPath] )
    {
        BOOL ret = [zip UnzipFileTo:_unzipto overWrite:YES];
        if( NO==ret )
        {
            NSLog(@"error");
        }
        [zip UnzipCloseFile];
    }
   // [zip release];
    
}

-(void)loadTextureAtlas:(NSString*)identity complete:(void(^)())complete{
    ConfigItem* configItem=_resourceConfigItems[identity];
    if(configItem){
        NSString* path=configItem.url;
        path=[path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        path=[path substringWithRange:NSMakeRange(0,path.length-4)];
        
        NSString* anipath=[NSString stringWithFormat:@"%@%@%@",_localResourceDir,path,@".ani"];
        NSData* anidata=[NSData dataWithContentsOfFile:anipath];
        ResourceDataFile* resourceDataFile=[ResourceDataFile parseFromData:anidata];
        if(resourceDataFile){
            NSString* atlascpath=[NSString stringWithFormat:@"%@%@",path,@".atlasc"];
            NSString* atlascfullpath=[NSString stringWithFormat:@"%@%@",_appResourceDir,atlascpath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:atlascfullpath]){
                 NSString* atlascSourceFilePath=[NSString stringWithFormat:@"%@%@",_localResourceDir,atlascpath];
                  [fileManager copyItemAtPath:atlascSourceFilePath toPath:atlascfullpath error:nil];
            }
            SKTextureAtlas* atlas=[SKTextureAtlas atlasNamed:atlascpath];
            _resourceAtlasc[identity]=atlas;
            if (complete) {
                [atlas preloadWithCompletionHandler:^{
                    complete();
                }];
            }
            NSArray* list=resourceDataFile.desc.list;
            NSMutableDictionary* map=[[NSMutableDictionary alloc] init];
            for (SwAnimation* animation in list) {
                map[animation.name]=animation;
            }
            _resourceAnimations[identity]=map;
        }else{
            NSLog(@"ResourceService::loadSpriteFrames protobuf parse resource fail");
        }
    }else{
        NSLog(@"ResourceService::loadSpriteFrames is null,identity is %@",identity);
    }
}
-(ResourceAnimationData*)getAnimationData:(NSString*)identity name:(NSString*)name{
    NSMutableDictionary* map=_resourceAnimations[identity];
    if (map==nil) {
        [self loadTextureAtlas:identity complete:nil];
        map=_resourceAnimations[identity];
        if (map==nil) {
            NSLog(@"ResourceService::getAnimationData is null,identity is %@,name is%@",identity,name);
            return nil;
        }
    }
    SwAnimation* animation=map[name];
    if (animation==nil) {
        NSLog(@"ResourceService::getAnimationData is null,identity is %@,name is%@",identity,name);
        return nil;
    }
    ResourceAnimationData* ret=[[ResourceAnimationData alloc] init];
    ret.identity=identity;
    ret.dimension=name;
    ret.width=animation.width;
    ret.height=animation.height;
    ret.scaleX=animation.scaleX/100.0;
    ret.scaleY=animation.scaleY/100.0;
    ret.height=animation.height;
    ret.timeCount=animation.timeCount/1000.0;
    ret.frameCount=animation.frameCount;
    CGFloat scaleHeight=ret.scaleHeight;
    NSArray* paras=animation.paras;
    NSMutableDictionary* paraList=[[NSMutableDictionary alloc] init];
    for (Para* para in paras) {
        paraList[para.name]=para.value;
    }
    ret.paras=paraList;
    
    NSArray* rects=animation.signRectangles;
    NSMutableDictionary* rectList=[[NSMutableDictionary alloc] init];
    for (SignRectangle* rect in rects) {
        rectList[rect.name]=[NSValue valueWithCGRect:CGRectMake(rect.x,scaleHeight-rect.y-rect.height, rect.width, rect.height)];
    }
    ret.rects=rectList;
    
    
    NSArray* compsiteAnimationDatas=animation.compsiteAnimations;
    NSMutableDictionary* compsiteAnimationList=[[NSMutableDictionary alloc] init];
    for (SwCompsiteAnimation* compsiteAnimation in compsiteAnimationDatas) {
        ResourceCompsiteAnimationData* compsitedata=[[ResourceCompsiteAnimationData alloc] init];
        compsitedata.name=compsiteAnimation.name;
        compsitedata.targetRid=compsiteAnimation.targetRid;
        compsitedata.targetDimension=compsiteAnimation.targetDimension;
        compsitedata.targetSignRectangleName=compsiteAnimation.targetSignRectangleName;
        compsitedata.targetScaleX=compsiteAnimation.targetScaleX;
        compsitedata.targetScaleY=compsiteAnimation.targetScaleY;
        compsitedata.sourceSignRectangleName=compsiteAnimation.sourceSignRectangleName;
        compsiteAnimationList[compsitedata.name]=compsitedata;
    }
    ret.compsiteAnimations=compsiteAnimationList;

    
    return ret;
}
-(SKAction*)getAnimationAction:(NSString*)identity name:(NSString*)name{
    NSMutableDictionary* map=_resourceAnimations[identity];
    if (map==nil) {
        [self loadTextureAtlas:identity complete:nil];
         map=_resourceAnimations[identity];
        if (map==nil) {
            NSLog(@"ResourceService::getAnimationAction is null,identity is %@,name is%@",identity,name);
            return nil;
        }
    }
    SwAnimation* animation=map[name];
    if (animation==nil) {
        NSLog(@"ResourceService::getAnimationAction is null,identity is %@,name is%@",identity,name);
        return nil;
    }
    NSArray* frames=animation.frames;
    int timeCount=animation.timeCount;
    int frameCount=animation.frameCount;
    float frameTime=timeCount/(float)frameCount/1000;
    SKTextureAtlas* atlas=_resourceAtlasc[identity];
     NSMutableArray* textures=[[NSMutableArray alloc] init];
    for (SwFrame* frame in frames) {
        NSString* tname=[NSString stringWithFormat:@"%@_%i.png",identity,(int)frame.v];
        SKTexture* texture=[atlas textureNamed:tname];
        [textures addObject:texture];
    }
    SKAction* action= [SKAction animateWithTextures:textures timePerFrame:frameTime];
    return action;
}

-(ResourceAnimation*)getResourceAnimation:(NSString*)identity name:(NSString*)name{
    ResourceAnimationData* animationData=[self getAnimationData:identity name:name];
    if (animationData==nil) {
        return nil;
    }
    ResourceAnimation* ret=[[ResourceAnimation alloc] init];
    ret.action=[self getAnimationAction:identity name:name];
    ret.animationData=animationData;
    return ret;
}

-(ResourceAnimation*)runResourceAnimation:(NSString*)identity name:(NSString*)name node:(SKSpriteNode*)node{
    ResourceAnimation* resourceAnimation=[self getResourceAnimation:identity name:name];
    if (resourceAnimation==nil) {
        return nil;
    }
    ResourceAnimationData* animationData=resourceAnimation.animationData;
     node.size=CGSizeMake(animationData.width, animationData.height);
    [node setXScale:animationData.scaleX];
    [node setYScale:animationData.scaleY];
   
    [node runAction:[SKAction repeatActionForever:resourceAnimation.action]];
    return resourceAnimation;
}

-(ResourceCompsiteAnimation*)runResourceCompsiteAnimation:(NSString*)identity name:(NSString*)name node:(SKNode*)node{
    return [self runResourceCompsiteAnimation:identity name:name node:node filter:nil include:true];
}

-(ResourceCompsiteAnimation*)runResourceCompsiteAnimation:(NSString*)identity name:(NSString*)name node:(SKNode*)node include:(NSArray*)include{
    return [self runResourceCompsiteAnimation:identity name:name node:node filter:include include:true];
}

-(ResourceCompsiteAnimation*)runResourceCompsiteAnimation:(NSString*)identity name:(NSString*)name node:(SKNode*)node exclude:(NSArray*)exclude{
    return [self runResourceCompsiteAnimation:identity name:name node:node filter:exclude include:false];
}

-(ResourceCompsiteAnimation*)runResourceCompsiteAnimation:(NSString*)identity name:(NSString*)name node:(SKNode*)node filter:(NSArray*)filter include:(bool)include{
    ResourceAnimation* resourceAnimation=[self getResourceAnimation:identity name:name];
    if (resourceAnimation==nil) {
        return nil;
    }
    ResourceAnimationData* animationData=resourceAnimation.animationData;
    NSString* mainAnimationName=[NSString stringWithFormat:@"%@.%@",identity,name];
    SKNode* mainAnimationSprite=[node childNodeWithName:mainAnimationName];
    if (mainAnimationSprite==nil) {
        mainAnimationSprite=[[SKSpriteNode alloc]  init];
        ((SKSpriteNode*)mainAnimationSprite).anchorPoint=CGPointMake(0, 0);
        mainAnimationSprite.name=mainAnimationName;
        [node addChild:mainAnimationSprite];
    }
    ((SKSpriteNode*)mainAnimationSprite).size=CGSizeMake(animationData.width, animationData.height);
    [mainAnimationSprite setXScale:animationData.scaleX];
    [mainAnimationSprite setYScale:animationData.scaleY];
    [mainAnimationSprite runAction:[SKAction repeatActionForever:resourceAnimation.action]];
    NSDictionary* rects=animationData.rects;
    NSArray* compsiteAnimationDatas= animationData.compsiteAnimations.allValues;
    CGFloat mainAnimationRealHeight=animationData.scaleHeight;
    NSMutableArray* compsiteAnimations=[[NSMutableArray alloc] init];
    for (ResourceCompsiteAnimationData* data in compsiteAnimationDatas) {
        if (filter) {
            if (include) {
                if (![filter containsObject:data.name]) {
                    continue;
                }
            }else{
                if ([filter containsObject:data.name]) {
                    continue;
                }
            }
        }
        ResourceAnimation* targetResourceAnimation=[self getResourceAnimation:data.targetRid name:data.targetDimension];
        if (targetResourceAnimation==nil) {
            NSLog(@"ResourceService::runResourceCompsiteAnimation compsite animation is null,target identity is %@,targetDimension is%@",data.targetRid,data.targetDimension);
            continue;
        }
        ResourceAnimationData* targetAnimationData=targetResourceAnimation.animationData;
        SKNode* compsiteAnimationSprite=[node childNodeWithName:data.name];
        if (compsiteAnimationSprite==nil) {
            compsiteAnimationSprite=[[SKSpriteNode alloc] init];
            ((SKSpriteNode*)compsiteAnimationSprite).anchorPoint=CGPointMake(0, 0);
            compsiteAnimationSprite.name=data.name;
            ((SKSpriteNode*)compsiteAnimationSprite).size=CGSizeMake(targetAnimationData.width, targetAnimationData.height);
            [node addChild:compsiteAnimationSprite];
        }
        CGFloat tscalex=data.targetScaleX/100.0;
        CGFloat tscaley=data.targetScaleY/100.0;
        
        NSDictionary* targetRects=targetAnimationData.rects;
        CGRect sourceSignRect;
        CGRect targetSignRect;
        if (![data.sourceSignRectangleName isEqualToString:@""]) {
            sourceSignRect=((NSValue*)rects[data.sourceSignRectangleName]).CGRectValue;
        }else{
            sourceSignRect=CGRectMake(0, mainAnimationRealHeight, 0, 0);
        }
        if (![data.targetSignRectangleName isEqualToString:@""]) {
            targetSignRect=((NSValue*)targetRects[data.targetSignRectangleName]).CGRectValue;
        }else{
            targetSignRect=CGRectMake(0, targetAnimationData.scaleHeight, 0, 0);
        }

        compsiteAnimationSprite.xScale=tscalex;
        compsiteAnimationSprite.yScale=tscaley;
        compsiteAnimationSprite.position=CGPointMake(sourceSignRect.origin.x-targetSignRect.origin.x*tscalex/targetAnimationData.scaleX,sourceSignRect.origin.y-targetSignRect.origin.y*tscaley/targetAnimationData.scaleY);
        
        [compsiteAnimationSprite runAction:[SKAction repeatActionForever:targetResourceAnimation.action]];
        [compsiteAnimations addObject:targetResourceAnimation];
    }
    
    ResourceCompsiteAnimation* ret=[[ResourceCompsiteAnimation alloc] init];
    ret.animationData=animationData;
    ret.action=resourceAnimation.action;
    ret.compsiteAnimations=compsiteAnimations;
    return ret;
}


-(SKTexture*)getTexture:(NSString*)identity name:(NSString*)name frameIndex:(NSInteger)frameIndex{
    NSMutableDictionary* map=_resourceAnimations[identity];
    if (map==nil) {
        [self loadTextureAtlas:identity complete:nil];
        map=_resourceAnimations[identity];
        if (map==nil) {
            NSLog(@"ResourceService::getTexture is null,identity is %@,name is%@",identity,name);
            return nil;
        }
    }
    SwAnimation* animation=map[name];
    if (animation==nil) {
        NSLog(@"ResourceService::getTexture is null,identity is %@,name is%@",identity,name);
        return nil;
    }

    NSArray* frames=animation.frames;
    SKTextureAtlas* atlas=_resourceAtlasc[identity];
    if (frameIndex<0 || frameIndex>=frames.count) {
        NSLog(@"ResourceService::getTexture is null,identity is %@,name is%@",identity,name);
        return nil;
    }
    SwFrame* frame=frames[frameIndex];
    NSString* tname=[NSString stringWithFormat:@"%@_%i.png",identity,(int)frame.v];
    SKTexture* texture=[atlas textureNamed:tname];
    return texture;
}
-(NSArray*)getTextures:(NSString*)identity name:(NSString*)name{
    NSMutableDictionary* map=_resourceAnimations[identity];
    if (map==nil) {
        [self loadTextureAtlas:identity complete:nil];
        map=_resourceAnimations[identity];
        if (map==nil) {
            NSLog(@"ResourceService::getTextures is null,identity is %@,name is%@",identity,name);
            return nil;
        }
    }
    SwAnimation* animation=map[name];
    if (animation==nil) {
        NSLog(@"ResourceService::getTextures is null,identity is %@,name is%@",identity,name);
        return nil;
    }
   
    NSArray* frames=animation.frames;
    SKTextureAtlas* atlas=_resourceAtlasc[identity];
    NSMutableArray* textures=[[NSMutableArray alloc] init];
    for (SwFrame* frame in frames) {
        NSString* tname=[NSString stringWithFormat:@"%@_%i.png",identity,(int)frame.v];
        SKTexture* texture=[atlas textureNamed:tname];
        [textures addObject:texture];
    }
    return textures;
}

-(ResourceTexture*)getResourceTexture:(NSString*)identity name:(NSString*)name frameIndex:(NSInteger)frameIndex{
    ResourceAnimationData* animationData=[self getAnimationData:identity name:name];
    if (animationData==nil) {
        return nil;
    }
    ResourceTexture* ret=[[ResourceTexture alloc] init];
    ret.texture=[self getTexture:identity name:name frameIndex:frameIndex];
    ret.animationData=animationData;
    return ret;
}
-(ResourceTextures*)getResourceTextures:(NSString*)identity name:(NSString*)name{
    ResourceAnimationData* animationData=[self getAnimationData:identity name:name];
    if (animationData==nil) {
        return nil;
    }
    ResourceTextures* ret=[[ResourceTextures alloc] init];
    ret.textures=[self getTextures:identity name:name];
    ret.animationData=animationData;
    return ret;
}
@end
@implementation ResourceAnimationData
-(CGFloat)scaleWidth{
    return _width*_scaleX;
}
-(CGFloat)scaleHeight{
    return _height*_scaleY;
}

-(UIBezierPath*)getPath:(NSString*)tag closed:(bool)closed{
    NSInteger i=1;
    NSString* tnor=[NSString stringWithFormat:@"%@%i",tag,(int)i++];
    NSValue* p= _rects[tnor];
    UIBezierPath* ret=nil;
    if (p!=nil) {
        ret=[UIBezierPath bezierPath];
        [ret moveToPoint:p.CGRectValue.origin];
        NSString* tnor=[NSString stringWithFormat:@"%@%i",tag,(int)i++];
        NSValue* p= _rects[tnor];
        while (p!=nil) {
            [ret addLineToPoint:p.CGRectValue.origin];
            NSString* tnor=[NSString stringWithFormat:@"%@%i",tag,(int)i++];
            p= _rects[tnor];
        }
        if (closed) {
            [ret closePath];
        }
    }
    return ret;
}

-(CGRect)getRect:(NSString*)tag{
    NSValue* p= _rects[tag];
    if (p) {
        return p.CGRectValue;
    }
    return CGRectZero;
}
-(CGPoint)getPoint:(NSString*)tag{
    NSValue* p= _rects[tag];
    if (p) {
        return p.CGRectValue.origin;
    }
    return CGPointZero;
}

-(ResourceAnimationData*)getCompsiteAnimationData:(NSString*)compsiteName{
    ResourceCompsiteAnimationData* data=_compsiteAnimations[compsiteName];
    if(data==nil){
        NSLog(@"ResourceCompsiteAnimation::getCompsiteAnimationData compsite name is %@",compsiteName);
        return nil;
    }
    ResourceAnimationData* compsiteAnimationData=[[ResourceService sharedInstance] getAnimationData:data.targetRid name:data.targetDimension];
    if (compsiteAnimationData==nil) {
        NSLog(@"ResourceCompsiteAnimation::getCompsiteAnimationData compsite animation is null,compsite name is %@",compsiteName);
        return nil;
    }
    CGFloat tscalex=data.targetScaleX/100.0;
    CGFloat tscaley=data.targetScaleY/100.0;
    CGFloat xscale=tscalex/compsiteAnimationData.scaleX;
    CGFloat yscale=tscaley/compsiteAnimationData.scaleY;
    NSDictionary* rects=compsiteAnimationData.rects;
    NSMutableDictionary* nrects=[[NSMutableDictionary alloc] init];
    [rects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        CGRect rect=((NSValue*)obj).CGRectValue;
        CGRect nrect=CGRectMake(rect.origin.x*xscale,rect.origin.y*yscale,rect.size.width*xscale, rect.size.height*yscale);
        nrects[key]=[NSValue valueWithCGRect:nrect];
    }];
    compsiteAnimationData.rects=nrects;
    compsiteAnimationData.scaleX=data.targetScaleX;
    compsiteAnimationData.scaleY=data.targetScaleY;
    return compsiteAnimationData;
}
@end
@implementation ResourceAnimation

@end
@implementation ResourceCompsiteAnimation
-(void)addCompsiteTexture:(NSString*)compsiteName frameIndex:(NSInteger)frameIndex node:(SKNode*)node{
    NSDictionary* compsiteAnimations=  self.animationData.compsiteAnimations;
    ResourceCompsiteAnimationData* data=compsiteAnimations[compsiteName];
    if(data==nil){
        NSLog(@"ResourceCompsiteAnimation::addCompsiteTexture compsite name is %@",compsiteName);
        return ;
    }
    ResourceTexture* targetResourceTexture=[[ResourceService sharedInstance] getResourceTexture:data.targetRid name:data.targetDimension frameIndex:frameIndex];
    if (targetResourceTexture==nil) {
        NSLog(@"ResourceCompsiteAnimation::addCompsiteTexture compsite animation is null,compsite name is %@",compsiteName);
        return;
    }
    ResourceAnimationData* targetAnimationData=targetResourceTexture.animationData;
    SKSpriteNode* compsiteAnimationSprite=(SKSpriteNode*)[node childNodeWithName:data.name];
    if (compsiteAnimationSprite==nil) {
        compsiteAnimationSprite=[[SKSpriteNode alloc] init];
        ((SKSpriteNode*)compsiteAnimationSprite).anchorPoint=CGPointMake(0, 0);
        NSString* name=[NSString stringWithFormat:@"%@_%i",data.name,(int)frameIndex];
        compsiteAnimationSprite.name=name;
        ((SKSpriteNode*)compsiteAnimationSprite).size=CGSizeMake(targetAnimationData.width, targetAnimationData.height);
        [node addChild:compsiteAnimationSprite];
    }
    NSDictionary* rects=self.animationData.rects;
    CGFloat mainAnimationRealHeight=self.animationData.scaleHeight;
    NSDictionary* targetRects=targetAnimationData.rects;
    CGRect sourceSignRect;
    CGRect targetSignRect;
    if (![data.sourceSignRectangleName isEqualToString:@""]) {
        sourceSignRect=((NSValue*)rects[data.sourceSignRectangleName]).CGRectValue;
    }else{
        sourceSignRect=CGRectMake(0, 0, 0, 0);
    }
    if (![data.targetSignRectangleName isEqualToString:@""]) {
        targetSignRect=((NSValue*)targetRects[data.targetSignRectangleName]).CGRectValue;
    }else{
        targetSignRect=CGRectMake(0, 0, 0, 0);
    }
    CGFloat tscalex=data.targetScaleX/100.0;
    CGFloat tscaley=data.targetScaleY/100.0;
    compsiteAnimationSprite.xScale=tscalex;
    compsiteAnimationSprite.yScale=tscaley;
    compsiteAnimationSprite.position=CGPointMake(sourceSignRect.origin.x-targetSignRect.origin.x*tscalex/targetAnimationData.scaleX,(mainAnimationRealHeight-sourceSignRect.origin.y)-(targetAnimationData.scaleHeight-targetSignRect.origin.y)*tscaley/targetAnimationData.scaleY);
    compsiteAnimationSprite.texture=targetResourceTexture.texture;
}
@end
@implementation ResourceTexture

@end
@implementation ResourceTextures

@end
@implementation ResourceCompsiteAnimationData

@end

