//
//  EventDispatcher.m
//  SSAdventure
//
//  Created by MacBook on 9/24/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import "EventDispatcher.h"
#import <objc/runtime.h>
#import "config.h"
@implementation EventDispatcher{
    NSMutableDictionary* _listeners;
}
+(EventDispatcher*)eventDispatcher{
    return [[EventDispatcher alloc] init];
}

-(void)addEventListener:(NSString*)name object:(id)object sel:(SEL)sel{
    [self addEventListener:name object:object sel:sel priority:0];
}

-(void)addEventListener:(NSString*)name object:(id)object sel:(SEL)sel priority:(NSInteger)priority{
    if(_listeners==nil){
        _listeners=[[NSMutableDictionary alloc] init];
    }
    NSMutableArray* _listenerGroup=_listeners[name];
    if(_listenerGroup==nil){
        _listenerGroup=[[NSMutableArray alloc] init];
        _listeners[name]=_listenerGroup;
    }
    SELEventListener* eventListener=[[SELEventListener alloc] init];
    eventListener.name=name;
    eventListener.object=object;
    eventListener.sel=sel;
    eventListener.priority=priority;
    NSInteger insertPos=0;
    for (NSInteger i=0; i<_listenerGroup.count; i++) {
        if (priority>((EventListener*)_listenerGroup[i]).priority) {
            insertPos=i;
        }
    }
    [_listenerGroup insertObject:eventListener atIndex:insertPos];
}

-(void)addEventListener:(NSString*)name block:(EventBlock)block{
    [self addEventListener:name block:block priority:0];
}
-(void)addEventListener:(NSString*)name block:(EventBlock)block priority:(NSInteger)priority{
    if(_listeners==nil){
        _listeners=[[NSMutableDictionary alloc] init];
    }
    NSMutableArray* _listenerGroup=_listeners[name];
    if(_listenerGroup==nil){
        _listenerGroup=[[NSMutableArray alloc] init];
        _listeners[name]=_listenerGroup;
    }
    BlockEventListener* eventListener=[[BlockEventListener alloc] init];
    eventListener.name=name;
    eventListener.eventBlock=block;
    eventListener.priority=priority;
    NSInteger insertPos=0;
    for (NSInteger i=0; i<_listenerGroup.count; i++) {
        if (priority>((EventListener*)_listenerGroup[i]).priority) {
            insertPos=i;
        }
    }
    [_listenerGroup insertObject:eventListener atIndex:insertPos];
}


-(bool)removeEventListener:(NSString*)name{
    if(_listeners!=nil){
        if(_listeners[name]!=nil){
            [_listeners removeObjectForKey:name];
            return true;
        }
    }
    return false;
}

-(bool)removeEventListener:(NSString*)name object:(id)object sel:(SEL)sel{
    bool re=false;
    if(_listeners!=nil){
        NSMutableArray* _listenerGroup=_listeners[name];
        if(_listenerGroup!=nil){
            NSMutableArray* removes=[[NSMutableArray alloc] init];
            Class selClass=[SELEventListener class];
            for(EventListener* el in _listenerGroup){
                if([el isKindOfClass:selClass]){
                    SELEventListener* eventListener=(SELEventListener*)el;
                    if(eventListener.object==object&&eventListener.sel==sel){
                        [removes addObject:el];
                    }
                }
            }
            if(removes.count>0){
                [_listenerGroup removeObjectsInArray:removes];
                re=true;
            }
        }
        
    }
    return re;
}

-(bool)removeEventListener:(NSString*)name block:(EventBlock)block{
    bool re=false;
    if(_listeners!=nil){
        NSMutableArray* _listenerGroup=_listeners[name];
        if(_listenerGroup!=nil){
            NSMutableArray* removes=[[NSMutableArray alloc] init];
            Class blockClass=[BlockEventListener class];
            for(EventListener* el in _listenerGroup){
                if([el isKindOfClass:blockClass]){
                    BlockEventListener* eventListener=(BlockEventListener*)el;
                    if(eventListener.eventBlock==block){
                        [removes addObject:el];
                    }
                }
            }
            if(removes.count>0){
                [_listenerGroup removeObjectsInArray:removes];
                re=true;
            }
        }
        
    }
    return re;
}

-(void)removeAllEventListener{
    if(_listeners!=nil){
        [_listeners removeAllObjects];
    }
}

-(bool)hasEventListener:(NSString*)name{
    if(_listeners!=nil){
        if(_listeners[name]!=nil){
            NSMutableArray* _listenerGroup=_listeners[name];
            return _listenerGroup.count>0;
        }
    }
    return false;
}

-(bool)hasEventListener:(NSString*)name object:(id)object sel:(SEL)sel{
    if(_listeners!=nil){
        NSMutableArray* _listenerGroup=_listeners[name];
        if(_listenerGroup!=nil){
            Class selClass=[SELEventListener class];
            for(EventListener* el in _listenerGroup){
                if([el isKindOfClass:selClass]){
                    SELEventListener* eventListener=(SELEventListener*)el;
                    if(eventListener.object==object&&eventListener.sel==sel){
                        return true;
                    }
                }
            }
        }
        
    }
    return false;
}
-(bool)hasEventListener:(NSString*)name block:(EventBlock)block{
    if(_listeners!=nil){
        NSMutableArray* _listenerGroup=_listeners[name];
        if(_listenerGroup!=nil){
             Class blockClass=[BlockEventListener class];
            for(EventListener* el in _listenerGroup){
                if([el isKindOfClass:blockClass]){
                    BlockEventListener* eventListener=(BlockEventListener*)el;
                    if(eventListener.eventBlock==block){
                        return true;
                    }
                }
            }
        }
        
    }
    return false;
}

-(void)dispatcherEvent:(NSString*)name event:(Event*)event{
    if(_listeners!=nil){
        NSMutableArray* _listenerGroup=_listeners[name];
        if(_listenerGroup!=nil){
            for(EventListener* el in _listenerGroup){
                [el dispatcherEvent:event];
            }
        }
        
    }
}
@end
char* const ASSOCIATION_EVENTDISPATCHER_ARRAY = "ASSOCIATION_EVENTDISPATCHER_ARRAY";
@implementation NSObject(EventDispatcher)

-(EventDispatcher*)getEventDispatcher{
    EventDispatcher* eventDispatcher =objc_getAssociatedObject(self,ASSOCIATION_EVENTDISPATCHER_ARRAY);
    if(eventDispatcher==nil){
        eventDispatcher=[EventDispatcher eventDispatcher];
        objc_setAssociatedObject(self, ASSOCIATION_EVENTDISPATCHER_ARRAY, eventDispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return eventDispatcher;
}
-(void)addEventListener:(NSString*)name object:(id)object sel:(SEL)sel{
    [[self getEventDispatcher] addEventListener:name object:object sel:sel];
}
-(void)addEventListener:(NSString*)name object:(id)object sel:(SEL)sel priority:(NSInteger)priority{
     [[self getEventDispatcher] addEventListener:name object:object sel:sel priority:priority];
}
-(void)addEventListener:(NSString*)name block:(EventBlock)block{
    [[self getEventDispatcher] addEventListener:name block:block];
}
-(void)addEventListener:(NSString*)name block:(EventBlock)block priority:(NSInteger)priority{
    [[self getEventDispatcher] addEventListener:name block:block priority:priority];
}
-(void)removeEventListener:(NSString*)name{
    [[self getEventDispatcher] removeEventListener:name];
}
-(bool)removeEventListener:(NSString*)name object:(id)object sel:(SEL)sel{
    return [[self getEventDispatcher] removeEventListener:name object:object sel:sel];
}
-(bool)removeEventListener:(NSString*)name block:(EventBlock)block{
     return [[self getEventDispatcher] removeEventListener:name block:block];
}

-(void)removeAllEventListener{
    [[self getEventDispatcher] removeAllEventListener];
}
-(bool)hasEventListener:(NSString*)name{
    return [[self getEventDispatcher] hasEventListener:name];
}
-(bool)hasEventListener:(NSString*)name object:(id)object sel:(SEL)sel{
    return [[self getEventDispatcher] hasEventListener:name object:object sel:sel];
}
-(bool)hasEventListener:(NSString*)name  block:(EventBlock)block{
    return [[self getEventDispatcher] hasEventListener:name block:block];
}
-(void)dispatcherEvent:(NSString*)name event:(Event*)event{
    [[self getEventDispatcher] dispatcherEvent:name event:event];
}
@end

@implementation Event
-(id)initWithTarget:(id)target{
    self = [super init];
    if (self) {
        _target=target;
    }
    return self;
}
@end
@implementation DataEvent
-(id)initWithTarget:(id)target data:(id)data{
    self = [super initWithTarget:target];
    if (self) {
        _data=data;
    }
    return self;
}
@end
@implementation EventListener
-(void)dispatcherEvent:(Event*)event{
    
}
@end
@implementation SELEventListener
-(void)dispatcherEvent:(Event*)event{
    
     SuppressPerformSelectorLeakWarning([_object performSelector:_sel withObject:event]);
}
@end
@implementation BlockEventListener
-(void)dispatcherEvent:(Event*)event{
    _eventBlock(event);
}
@end

