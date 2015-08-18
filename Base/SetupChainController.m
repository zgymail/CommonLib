//
//  Controller.m
//  SSAdventure
//
//  Created by MacBook on 5/20/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import "SetupChainController.h"

@implementation SetupChainController{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _setupChains=[[NSMutableArray alloc] init];
    }
    return self;
}
-(void)registerSetupChain:(SetupChain*)setupChain{
    [((NSMutableArray*)_setupChains) addObject:setupChain];
}

-(void)startSetup:(ControllerCompleteBlock)completeBlock{
    _completeBlock=completeBlock;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
       if(_setupChains.count>0){
            for (NSInteger i=0; i<_setupChains.count-1; i++) {
                SetupChain* setupChain=_setupChains[i];
                setupChain.next=_setupChains[i+1];
                setupChain.chainController=self;
            }
            ((SetupChain*)_setupChains[_setupChains.count-1]).chainController=self;
            [((SetupChain*)_setupChains[0]) start];
        }else{
            [self complete:true];
        }
    });
}
-(void)complete:(bool)success{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
       dispatch_sync(dispatch_get_main_queue(), ^{
           if(_completeBlock!=nil){
               _completeBlock(success);
               _completeBlock=nil;
           }
        });
    });
}
@end
@implementation SetupChain
-(void)start{
    [self complete];
}
-(void)complete{
    if(_next==nil){
        [_chainController complete:true];
    }else{
        [_next start];
    }
}
-(void)cancel{
   [_chainController complete:false];
}

@end