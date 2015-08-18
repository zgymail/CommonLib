//
//  Controller.h
//  SSAdventure
//
//  Created by MacBook on 5/20/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
typedef void (^ControllerCompleteBlock)(bool success);
@class SetupChainController;
@interface SetupChain:NSObject
@property(nonatomic,weak)SetupChain* next;
@property(nonatomic,weak)SetupChainController* chainController;
-(void)start;
-(void)complete;
-(void)cancel;
@end
@interface SetupChainController : NSObject
@property(nonatomic,strong)NSArray* setupChains;
@property(nonatomic,strong)ControllerCompleteBlock completeBlock;
-(void)registerSetupChain:(SetupChain*)setupChain;
-(void)startSetup:(ControllerCompleteBlock)completeBlock;
-(void)complete:(bool)success;
@end
