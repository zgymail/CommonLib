//
//  CLViewController.m
//  CommonLib
//
//  Created by zgy_mail on 08/16/2015.
//  Copyright (c) 2015 zgy_mail. All rights reserved.
//

#import "CLViewController.h"
#import "ResourceService.h"
#import <AFNetworking/AFNetworking.h>
#import "NetService.h"
@interface CLViewController ()

@end

@implementation CLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self testNetService];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)testResourceService{
    ResourceService* rs=[ResourceService sharedInstance];
    [rs setRemoteResourceUrl:@"http://localhost:8080/ssaeditor/uele/"];
    [rs loadRemoteResourceConfigItem:^(bool success) {
        
        ResourceAnimation* resourceAnimation=[rs getResourceAnimation:@"1" name:@"BODY-1"];
        //  spnode.xScale=resourceAnimation.animationData.scaleX;
        //  spnode.yScale=resourceAnimation.animationData.scaleY;
        // [spnode runAction:[SKAction repeatActionForever:resourceAnimation.action]];
        
        //[rs runResourceAnimation:@"1" name:@"BODY-1" node:spnode];
        // [rs runResourceCompsiteAnimation:@"1" name:@"BODY-1" node:spnode];
        
    }];
}
-(void)testNetService{
    [[NetService shareInstance] loadImage:@"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_81d09391.png" complete:^(UIImage *image) {
        NSLog(@"image: %@" , image);
    }];
    
    [[NetService shareInstance] loadData:@"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_81d09391.png" complete:^(id data, NetServiceResponseStatus responseStatus, NetServiceResponseInfo *responseInfo) {
       // NSLog(@"data: %@" , data);
    } parse:[[NetServiceBaseParse alloc] init]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
