//
//  ResourceService.h
//  test2
//
//  Created by gavin on 15/6/30.
//  Copyright (c) 2015年 SC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import <SpriteKit/SpriteKit.h>

typedef void (^ResourceServiceLoadRemoteResourceCompleteBlock)(bool success);
@interface ResourceAnimationData:NSObject
@property(nonatomic,strong)NSString* identity;
@property(nonatomic,strong)NSString* dimension;
@property(nonatomic,strong)NSDictionary* paras;
@property(nonatomic,strong)NSDictionary* rects;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@property(nonatomic,assign)CGFloat scaleX;
@property(nonatomic,assign)CGFloat scaleY;
@property(nonatomic,assign)NSInteger frameCount;
@property(nonatomic,assign)NSTimeInterval timeCount;
@property(nonatomic,assign,readonly)CGFloat scaleWidth;
@property(nonatomic,assign,readonly)CGFloat scaleHeight;
@property(nonatomic,strong)NSDictionary* compsiteAnimations;
-(UIBezierPath*)getPath:(NSString*)tag closed:(bool)closed;
-(CGRect)getRect:(NSString*)tag;
-(CGPoint)getPoint:(NSString*)tag;

-(ResourceAnimationData*)getCompsiteAnimationData:(NSString*)compsiteName;
@end
@interface ResourceCompsiteAnimationData :NSObject
@property(nonatomic,strong)NSString* name;
@property(nonatomic,strong)NSString* targetRid;
@property(nonatomic,strong)NSString* targetDimension;
@property(nonatomic,strong)NSString* targetSignRectangleName;
@property(nonatomic,assign)CGFloat targetScaleX;
@property(nonatomic,assign)CGFloat targetScaleY;
@property(nonatomic,strong)NSString* sourceSignRectangleName;
@end


@interface ResourceAnimation:NSObject
@property(nonatomic,strong)SKAction* action;
@property(nonatomic,strong)ResourceAnimationData* animationData;

@end
@interface ResourceCompsiteAnimation:ResourceAnimation
@property(nonatomic,strong)NSArray* compsiteAnimations;
-(void)addCompsiteTexture:(NSString*)compsiteName frameIndex:(NSInteger)frameIndex node:(SKNode*)node;
@end
@interface ResourceTexture:NSObject
@property(nonatomic,strong)SKTexture* texture;
@property(nonatomic,strong)ResourceAnimationData* animationData;
@end
@interface ResourceTextures:NSObject
@property(nonatomic,strong)NSArray* textures;
@property(nonatomic,strong)ResourceAnimationData* animationData;
@end
@interface ResourceService : NSObject
SYNTHESIZE_SINGLETON_FOR_INTERFACE(ResourceService);
-(void)setLocalResourceDir:(NSString*)dir;
-(void)setRemoteResourceUrl:(NSString*)url;
-(void)loadRemoteResourceConfigItem:(ResourceServiceLoadRemoteResourceCompleteBlock)callback;
-(void)loadLocalResourceConfigItem;
-(void)loadTextureAtlas:(NSString*)identity complete:(void(^)())complete;

-(ResourceAnimationData*)getAnimationData:(NSString*)identity name:(NSString*)name;
-(SKAction*)getAnimationAction:(NSString*)identity name:(NSString*)name;
-(ResourceAnimation*)getResourceAnimation:(NSString*)identity name:(NSString*)name;
-(ResourceAnimation*)runResourceAnimation:(NSString*)identity name:(NSString*)name node:(SKSpriteNode*)node;
-(ResourceCompsiteAnimation*)runResourceCompsiteAnimation:(NSString*)identity name:(NSString*)name node:(SKNode*)node;
-(ResourceCompsiteAnimation*)runResourceCompsiteAnimation:(NSString*)identity name:(NSString*)name node:(SKNode*)node include:(NSArray*)include;
-(ResourceCompsiteAnimation*)runResourceCompsiteAnimation:(NSString*)identity name:(NSString*)name node:(SKNode*)node exclude:(NSArray*)exclude;

-(ResourceTexture*)getResourceTexture:(NSString*)identity name:(NSString*)name frameIndex:(NSInteger)frameIndex;
-(SKTexture*)getTexture:(NSString*)identity name:(NSString*)name frameIndex:(NSInteger)frameIndex;
-(NSArray*)getTextures:(NSString*)identity name:(NSString*)name;
-(ResourceTextures*)getResourceTextures:(NSString*)identity name:(NSString*)name;
@end
