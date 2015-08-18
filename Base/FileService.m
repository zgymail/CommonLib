//
//  FileService.m
//  SSAdventure
//
//  Created by MacBook on 5/29/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import "FileService.h"
#import "NSData+Des.h"
@implementation FileService{
    NSString* _currentDir;
}
SYNTHESIZE_SINGLETON_FOR_IMPL(FileService)
- (instancetype)init
{
    self = [super init];
    if (self) {
        _documentDir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return self;
}

-(FileService*)dir:(NSString *)dirName{
    _currentDir=dirName;
     NSString* _currentDirPath=[NSString stringWithFormat:@"%@/%@",_documentDir,_currentDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager fileExistsAtPath:_currentDirPath]){
        [fileManager createDirectoryAtPath:_currentDirPath
               withIntermediateDirectories:YES attributes:nil
                                     error:&error];
    }
    if(error!=nil){
        NSLog(@"FileService create dir Fail, dir path is:%@,message:%@",_currentDirPath,[error localizedDescription]);
    }
    return self;
}

-(void)saveFile:(NSString *)fileName data:(NSData *)data{
    NSString* filePath=[NSString stringWithFormat:@"%@/%@/%@",_documentDir,_currentDir,fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]){
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    NSError* error;
    [data writeToFile:filePath options:NSDataWritingWithoutOverwriting error:&error];
    if(error){
        NSLog(@"save file %@ error:%@",fileName,error.description);
    }
}
-(bool)existFile:(NSString *)fileName{
    NSString* filePath=[NSString stringWithFormat:@"%@/%@/%@",_documentDir,_currentDir,fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}
-(NSData*)getFile:(NSString *)fileName{
    NSString* filePath=[NSString stringWithFormat:@"%@/%@/%@",_documentDir,_currentDir,fileName];
    NSData* data=[NSData dataWithContentsOfFile:filePath];
    return data;
}

-(NSData*)getDecryptFile:(NSString*)fileName{
    NSData* data=[self getFile:fileName];
    data=[data desDecoded];
    return data;
}

-(void)saveEncryptFile:(NSString*)fileName data:(NSData*)data{
    data=[data desEncoded];
    [self saveFile:fileName data:data];
}

-(void)deleteFile:(NSString*)fileName{
    NSString* filePath=[NSString stringWithFormat:@"%@/%@/%@",_documentDir,_currentDir,fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
}


@end
