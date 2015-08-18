//
//  AFHTTPRequestOperationUtils.h 
//

#import <Foundation/Foundation.h>

@interface AFDownloadStorage : NSObject
@property(nonatomic,strong)NSString* cachePath;
- (instancetype)initWithStoragePath:(NSString*)storagePath;
-(NSString *)getStorageFile;
-(void)clear;

@end
