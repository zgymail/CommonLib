// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import <ProtocolBuffers/ProtocolBuffers.h>

// @@protoc_insertion_point(imports)

@class SignRectangle;
@class SignRectangleBuilder;



@interface SignRectangleRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

#define SignRectangle_name @"name"
#define SignRectangle_x @"x"
#define SignRectangle_y @"y"
#define SignRectangle_width @"width"
#define SignRectangle_height @"height"
@interface SignRectangle : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasX_:1;
  BOOL hasY_:1;
  BOOL hasWidth_:1;
  BOOL hasHeight_:1;
  BOOL hasName_:1;
  SInt32 x;
  SInt32 y;
  SInt32 width;
  SInt32 height;
  NSString* name;
}
- (BOOL) hasName;
- (BOOL) hasX;
- (BOOL) hasY;
- (BOOL) hasWidth;
- (BOOL) hasHeight;
@property (readonly, strong) NSString* name;
@property (readonly) SInt32 x;
@property (readonly) SInt32 y;
@property (readonly) SInt32 width;
@property (readonly) SInt32 height;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SignRectangleBuilder*) builder;
+ (SignRectangleBuilder*) builder;
+ (SignRectangleBuilder*) builderWithPrototype:(SignRectangle*) prototype;
- (SignRectangleBuilder*) toBuilder;

+ (SignRectangle*) parseFromData:(NSData*) data;
+ (SignRectangle*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SignRectangle*) parseFromInputStream:(NSInputStream*) input;
+ (SignRectangle*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SignRectangle*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SignRectangle*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SignRectangleBuilder : PBGeneratedMessageBuilder {
@private
  SignRectangle* resultSignRectangle;
}

- (SignRectangle*) defaultInstance;

- (SignRectangleBuilder*) clear;
- (SignRectangleBuilder*) clone;

- (SignRectangle*) build;
- (SignRectangle*) buildPartial;

- (SignRectangleBuilder*) mergeFrom:(SignRectangle*) other;
- (SignRectangleBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SignRectangleBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasName;
- (NSString*) name;
- (SignRectangleBuilder*) setName:(NSString*) value;
- (SignRectangleBuilder*) clearName;

- (BOOL) hasX;
- (SInt32) x;
- (SignRectangleBuilder*) setX:(SInt32) value;
- (SignRectangleBuilder*) clearX;

- (BOOL) hasY;
- (SInt32) y;
- (SignRectangleBuilder*) setY:(SInt32) value;
- (SignRectangleBuilder*) clearY;

- (BOOL) hasWidth;
- (SInt32) width;
- (SignRectangleBuilder*) setWidth:(SInt32) value;
- (SignRectangleBuilder*) clearWidth;

- (BOOL) hasHeight;
- (SInt32) height;
- (SignRectangleBuilder*) setHeight:(SInt32) value;
- (SignRectangleBuilder*) clearHeight;
@end


// @@protoc_insertion_point(global_scope)