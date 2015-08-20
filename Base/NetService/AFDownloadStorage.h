//
//  AFHTTPRequestOperationUtils.h 
//

#import <Foundation/Foundation.h>

@interface AFDownloadStorage : NSObject
@property(nonatomic,strong)NSString* cachePath;
- (instancetype)initWithStoragePath:(NSString*)storagePath;
-(NSString *)getStorageDataFileWithUrl:(NSURL*)urlpath;
-(void)clear;
-(NSData*)getStorageData:(NSURL*)url;
-(void)saveStorageData:(NSData*)data url:(NSURL*)url;
@end
