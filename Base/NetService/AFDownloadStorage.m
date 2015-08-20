//
//  AFHTTPRequestOperationUtils.m 
//

#import "AFDownloadStorage.h"

@interface AFDownloadStorage()
{
    NSObject *transLock;
}
@property (nonatomic,assign) long  fileIndex;
@property (nonatomic,strong) NSString *timeIndex;
@end




@implementation AFDownloadStorage{
    NSString* _cacheFullPath;
}


- (instancetype)initWithStoragePath:(NSString*)storagePath
{
    self = [super init];
    if (self) {
        transLock =[[NSObject alloc] init];
        self.fileIndex =0;
        
        NSString *documentsDirectory = NSTemporaryDirectory();
        NSLog(@"documentsDirectory:%@",documentsDirectory);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
         _cacheFullPath=[documentsDirectory stringByAppendingPathComponent:storagePath];
        BOOL isDir=false;
        if(![fileManager fileExistsAtPath:_cacheFullPath isDirectory:&isDir]&&!isDir){
            [fileManager createDirectoryAtPath:_cacheFullPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}


-(NSString *)loadSequence{
    NSString *sequence;
    @synchronized(transLock) {
        
        NSString *_timeIndex_ = [NSString stringWithFormat:@"%ld", (long)(CFAbsoluteTimeGetCurrent())];
        
        if(self.timeIndex==nil){
            self.timeIndex = _timeIndex_;
        }
        
        if(![_timeIndex_ isEqualToString:self.timeIndex]){
            self.fileIndex =0;
            self.timeIndex = _timeIndex_;
        }
        
        sequence = [NSString stringWithFormat:@"http_%@_%07ld",self.timeIndex,self.fileIndex];
        
        self.fileIndex+=1;
    } 
    return sequence;
}

#pragma mark - cache path


-(NSString *)getStorageDataFileWithUrl:(NSURL*)url{
    //NSString *fileName = [self loadSequence];
    NSString* fileName=[url.relativePath stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    fileName=[fileName stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    return [_cacheFullPath stringByAppendingPathComponent:fileName];
}

-(NSData*)getStorageData:(NSURL*)url{
    NSString* path=[self getStorageDataFileWithUrl:url];
    NSFileManager* fmgr=[NSFileManager new];
    if ([fmgr fileExistsAtPath:path]) {
        return [NSData dataWithContentsOfFile:path];
    }
    return nil;
}

-(void)saveStorageData:(NSData*)data url:(NSURL*)url{
    NSString* file=[self getStorageDataFileWithUrl:url];
   [data writeToFile:file atomically:NO];
}







-(void)clear{
    [self clearPath:_cacheFullPath];
}

-(void)clearPath:(NSString*)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    for (int i=0; i<[files count]; i++) {
        NSString *filePath = [path stringByAppendingPathComponent:[files objectAtIndex:i]];
        BOOL isDir;
        if([fileManager fileExistsAtPath:filePath isDirectory:&isDir]){
            if(isDir){
                [self clearPath:filePath];
            }
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}
@end
