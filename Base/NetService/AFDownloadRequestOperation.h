#import "AFCustomRequestOperation.h"
#import "AFDownloadStorage.h"

@interface AFDownloadRequestOperation : AFCustomRequestOperation

@property (assign) BOOL shouldOverwrite;


@property (assign, readonly) BOOL shouldResume;

/** 
 Deletes the temporary file if operations is cancelled. Defaults to `NO`.
 */
@property (assign, getter=isDeletingTempFileOnCancel) BOOL deleteTempFileOnCancel;

/** 
 Expected total length. This is different than expectedContentLength if the file is resumed.
 
 Note: this can also be zero if the file size is not sent (*)
 */
@property (assign, readonly) long long totalContentLength;

/** 
 Indicator for the file offset on partial downloads. This is greater than zero if the file download is resumed.
 */
@property (assign, readonly) long long offsetContentLength;

/**
 The callback dispatch queue on progressive download. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t progressiveDownloadCallbackQueue;

///----------------------------------
/// @name Creating Request Operations
///----------------------------------

/**
 Creates and returns an `AFDownloadRequestOperation`
 @param urlRequest The request object to be loaded asynchronously during execution of the operation
 @param targetPath The target path (with or without file name)
 @param shouldResume If YES, tries to resume a partial download if found.
 @return A new download request operation
 */
- (id)initWithRequest:(NSURLRequest *)urlRequest storage:(AFDownloadStorage*)storage shouldResume:(BOOL)shouldResume;

/** 
 Deletes the temporary file.
 
 Returns `NO` if an error happened, `YES` if the file is removed or did not exist in the first place.
 */
- (BOOL)deleteTempFileWithError:(NSError **)error;

/** 
 Returns the path used for the temporary file. Returns `nil` if the targetPath has not been set.
 */
- (NSString *)tempPath;


- (void)setProgressiveDownloadProgressBlock:(void (^)(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile))block;

@end
