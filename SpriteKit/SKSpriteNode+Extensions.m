//
//  SKSpriteNode+Extensions.m
//  SSAdventure
//
//  Created by MacBook on 8/6/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import "SKSpriteNode+Extensions.h"
#import "SVGBezierPathReader.h"
#import "UIBezierPath+Extensions.h"
@implementation SKSpriteNode (Extensions)
-(SKTexture*)runTextureAtlas:(NSString*)atlasName withKey:(NSString*)key{
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    NSArray* textureNames=[atlas textureNames];
    NSMutableArray* textures=[[NSMutableArray alloc] initWithCapacity:textureNames.count];
    for(NSString* textureName in textureNames){
        [textures addObject:[atlas textureNamed:textureName]];
    }
    SKAction* runAction =[SKAction animateWithTextures:textures timePerFrame:0.2 resize:NO restore:YES];
    SKAction* repeatAction=[SKAction repeatActionForever:runAction];
    [self runAction:repeatAction withKey:key];
    SKTexture* t=textures[0];
    return t;
}

+(SKSpriteNode*)spriteNodeWithSVGFile:(NSString*)svgFile{
    SVGBezierPathReader* reader= [[SVGBezierPathReader alloc] initWithSVGFileNamed:svgFile];
    NSDictionary* imageInfo=[reader getSVGImageInfoWithFirst];
    SVGBezierPath* bezierPath=[reader getSVGBezierPathWithFirst];
    NSString* imageName=imageInfo[@"xlink:href"];
    CGFloat width=[imageInfo[@"width"] floatValue];
    CGFloat height=[imageInfo[@"height"] floatValue];
    SKSpriteNode* sprite=[[SKSpriteNode alloc] initWithImageNamed:imageName];
    sprite.size=CGSizeMake(width, height);
    UIBezierPath* bpath=bezierPath.bezierPath;
    CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
    CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
    CGAffineTransform trans=CGAffineTransformMakeScale(1, -1);
    trans=CGAffineTransformTranslate(trans, -offsetX,-sprite.size.height+offsetY);
    [bpath applyTransform:trans];
    sprite.physicsBody=[SKPhysicsBody bodyWithPolygonFromPath:bpath.CGPath];
    return sprite;
}

@end
