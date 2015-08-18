#define SYNTHESIZE_SINGLETON_FOR_INTERFACE(classname) \
+ (classname *)sharedInstance \

#define SYNTHESIZE_SINGLETON_FOR_IMPL(classname) \
 \
static classname *shared##classname = nil; \
 \
+ (classname *)sharedInstance \
{ \
	@synchronized(self) \
	{ \
		if (shared##classname == nil) \
		{ \
			shared##classname = [[self alloc] init]; \
		} \
	} \
	 \
	return shared##classname; \
}