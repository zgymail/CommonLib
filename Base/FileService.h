//
//  FileService.h
//  SSAdventure
//
//  Created by MacBook on 5/29/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
@interface FileService : NSObject
SYNTHESIZE_SINGLETON_FOR_INTERFACE(FileService);
@property(nonatomic,strong)NSString* documentDir;
-(FileService*)dir:(NSString *)dirName;
-(bool)existFile:(NSString*)fileName;
-(void)deleteFile:(NSString*)fileName;
-(NSData*)getFile:(NSString*)fileName;
-(void)saveFile:(NSString*)fileName data:(NSData*)data;
-(NSData*)getDecryptFile:(NSString*)fileName;
-(void)saveEncryptFile:(NSString*)fileName data:(NSData*)data;
@end
