//
//  EventDispatcher.h
//  SSAdventure
//
//  Created by MacBook on 9/24/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Event:NSObject
@property(nonatomic,weak)id target;
-(id)initWithTarget:(id)target;
@end
#if NS_BLOCKS_AVAILABLE
typedef void(^EventBlock)(Event* event);
#endif
@interface DataEvent:Event
@property(nonatomic,strong)id data;
-(id)initWithTarget:(id)target data:(id)data;
@end
@interface EventListener:NSObject
@property(nonatomic,strong)NSString* name;
@property(nonatomic,assign)NSInteger priority;
-(void)dispatcherEvent:(Event*)event;
@end
@interface SELEventListener:EventListener
@property(nonatomic,weak)NSObject* object;
@property(nonatomic,assign)SEL sel;
@end
@interface BlockEventListener:EventListener
@property(nonatomic,strong)EventBlock eventBlock;
@end
@interface EventDispatcher : NSObject
-(void)addEventListener:(NSString*)name object:(id)object sel:(SEL)sel priority:(NSInteger)priority;
-(void)addEventListener:(NSString*)name object:(id)object sel:(SEL)sel;
-(void)addEventListener:(NSString*)name block:(EventBlock)block;
-(void)addEventListener:(NSString*)name block:(EventBlock)block priority:(NSInteger)priority;
-(bool)removeEventListener:(NSString*)name;
-(bool)removeEventListener:(NSString*)name object:(id)object sel:(SEL)sel;
-(bool)removeEventListener:(NSString*)name block:(EventBlock)block;
-(void)removeAllEventListener;
-(bool)hasEventListener:(NSString*)name;
-(bool)hasEventListener:(NSString*)name object:(id)object sel:(SEL)sel;
-(bool)hasEventListener:(NSString*)name block:(EventBlock)block;
-(void)dispatcherEvent:(NSString*)name event:(Event*)event;
+(EventDispatcher*)eventDispatcher;
@end
@interface NSObject(EventDispatcher)
-(void)addEventListener:(NSString*)name object:(id)object sel:(SEL)sel priority:(NSInteger)priority;
-(void)addEventListener:(NSString*)name object:(id)object sel:(SEL)sel;
-(void)addEventListener:(NSString*)name block:(EventBlock)block priority:(NSInteger)priority;
-(void)addEventListener:(NSString*)name block:(EventBlock)block;
-(void)removeEventListener:(NSString*)name;
-(bool)removeEventListener:(NSString*)name object:(id)object sel:(SEL)sel;
-(bool)removeEventListener:(NSString*)name block:(EventBlock)block;
-(void)removeAllEventListener;
-(bool)hasEventListener:(NSString*)name;
-(bool)hasEventListener:(NSString*)name object:(id)object sel:(SEL)sel;
-(bool)hasEventListener:(NSString*)name block:(EventBlock)block;
-(void)dispatcherEvent:(NSString*)name event:(Event*)event;
@end


