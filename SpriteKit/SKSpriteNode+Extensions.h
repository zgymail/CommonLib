//
//  SKSpriteNode+Extensions.h
//  SSAdventure
//
//  Created by MacBook on 8/6/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (Extensions)
-(SKTexture*)runTextureAtlas:(NSString*)atlasName withKey:(NSString*)key;
+(SKSpriteNode*)spriteNodeWithSVGFile:(NSString*)svgFile;
@end
