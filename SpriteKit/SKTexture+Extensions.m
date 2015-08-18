//
//  SKTexture+Extensions.m
//  SSAdventure
//
//  Created by gavin on 15/7/20.
//  Copyright (c) 2015年 yning. All rights reserved.
//

#import "SKTexture+Extensions.h"

@implementation SKTexture(Extensions)
-(UIImage*)image:(UIColor*)backgroundColor{
    SKView*         view    = [[SKView alloc]initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    SKScene*        scene   = [SKScene sceneWithSize:self.size];
    scene.backgroundColor=backgroundColor;
    SKSpriteNode*   sprite  = [SKSpriteNode spriteNodeWithTexture:self];
    sprite.position = CGPointMake( CGRectGetMidX(view.frame), CGRectGetMidY(view.frame) );
    [scene addChild:sprite];
    [view presentScene:scene];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO,[UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
