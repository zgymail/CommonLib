//
//  PocketSVG.m
//
//  Copyright (c) 2013 Ponderwell, Ariel Elkin, and Contributors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UIColor+DSColor.h"
#import "SVGBezierPathReader.h"

NSInteger const maxPathComplexity	= 1000;
NSInteger const maxParameters		= 64;
NSInteger const maxTokenLength		= 64;
NSString* const separatorCharString = @"-, CcMmLlHhVvZzqQaAsS";
NSString* const commandCharString	= @"CcMmLlHhVvZzqQaAsS";
unichar const invalidCommand		= '*';


@interface Token : NSObject {
	@private
	unichar			command;
	NSMutableArray  *values;
}
- (id)initWithCommand:(unichar)commandChar;
- (void)addValue:(CGFloat)value;
- (CGFloat)parameter:(NSInteger)index;
- (NSInteger)valence;
@property(nonatomic, assign) unichar command;
@end

@implementation SVGBezierPath

@end

@implementation Token

- (id)initWithCommand:(unichar)commandChar {
	self = [self init];
    if (self) {
		command = commandChar;
		values = [[NSMutableArray alloc] initWithCapacity:maxParameters];
	}
	return self;
}

- (void)addValue:(CGFloat)value {
	[values addObject:[NSNumber numberWithDouble:value]];
}

- (CGFloat)parameter:(NSInteger)index {
	return [[values objectAtIndex:index] doubleValue];
}

- (NSInteger)valence
{
	return [values count];
}


@synthesize command;

@end


@interface SVGBezierPathReader ()
@property (nonatomic,strong)NSMutableArray* svgPathElements;
@property (nonatomic,strong)NSMutableArray* svgPolylineElements;
@end


@implementation SVGBezierPathReader{
    
}


- (id)initWithSVGFileNamed:(NSString *)nameOfSVG{
    self=[super init];
    if(self){
        if([nameOfSVG hasSuffix:@".svg"]){
            nameOfSVG=[nameOfSVG substringToIndex:nameOfSVG.length-4];
        }
        NSString *pathOfSVGFile = [[NSBundle mainBundle] pathForResource:nameOfSVG ofType:@"svg"];
        if(pathOfSVGFile == nil){
            NSLog(@"*** PocketSVG Error: No SVG file named \"%@\".", nameOfSVG);
            return nil;
        }
        pathScale = 0;
        [self reset];
        separatorSet = [NSCharacterSet characterSetWithCharactersInString:separatorCharString];
        commandSet = [NSCharacterSet characterSetWithCharactersInString:commandCharString];
        _svgPathElements=[[NSMutableArray alloc] init];
        _svgImageInfo=[[NSMutableArray alloc] init];
        _svgPolylineElements=[[NSMutableArray alloc] init];
        NSData *svgFileData = [[NSData alloc]initWithContentsOfFile:pathOfSVGFile];
        NSXMLParser* parser = [[NSXMLParser alloc]initWithData:svgFileData];
        parser.delegate = self;
        _svgBezierPaths=[[NSMutableArray alloc] init];
        if([parser parse]){
            if([_svgPathElements count]>0){
                for(int i = 0;i < [_svgPathElements count];i++){
                    NSDictionary* pathAttribute = [_svgPathElements objectAtIndex:i];
                    NSString* d=pathAttribute[@"d"];
                    NSString* fill=pathAttribute[@"fill"];
                    NSString* stroke=pathAttribute[@"stroke"];
                    
                    NSMutableArray* tokens = [self parsePath:d];
                    UIBezierPath* bezierPath=[self generateBezier:tokens];
                    SVGBezierPath* bp=[[SVGBezierPath alloc] init];
                    bp.bezierPath=bezierPath;
                    if(fill!=nil&&![@"none" isEqualToString:fill]){
                        bp.fillColorHex=fill;
                    }
                    
                    if(stroke!=nil&&![@"none" isEqualToString:stroke]){
                        bp.strokeColorHex=stroke;
                    }
                    if(pathAttribute[@"id"]!=nil){
                        bp.identity=pathAttribute[@"id"];
                    }
                    [_svgBezierPaths addObject:bp];
                }
            }
            if(_svgPolylineElements.count>0){
                 for(int i = 0;i < [_svgPolylineElements count];i++){
                     NSDictionary* polylineAttribute = [_svgPolylineElements objectAtIndex:i];
                     NSString* points=polylineAttribute[@"points"];
                     NSString* fill=polylineAttribute[@"fill"];
                     NSString* stroke=polylineAttribute[@"stroke"];
                     NSArray* ps=[points componentsSeparatedByString:@" "];
                     SVGBezierPath* bp=[[SVGBezierPath alloc] init];
                     UIBezierPath* bezierPath=[[UIBezierPath alloc] init];
                     CGMutablePathRef cpath=CGPathCreateMutable();
                     for(NSInteger j=0;j<ps.count;j++){
                         NSString* pstr=ps[j];
                         NSArray* p=[pstr componentsSeparatedByString:@","];
                         if(p.count==2){
                             if(j==0){
                                 CGPathMoveToPoint(cpath, nil,((NSString*)p[0]).floatValue, ((NSString*)p[1]).floatValue);
                             }else{
                                 CGPathAddLineToPoint(cpath, nil,((NSString*)p[0]).floatValue, ((NSString*)p[1]).floatValue);
                             }
                         }
                
                     }
                     bezierPath.CGPath=cpath;
                     CGPathRelease(cpath);
                     bp.bezierPath=bezierPath;
                     if(fill!=nil&&![@"none" isEqualToString:fill]){
                         bp.fillColorHex=fill;
                     }
                     
                     if(stroke!=nil&&![@"none" isEqualToString:stroke]){
                         bp.strokeColorHex=stroke;
                     }
                     if(polylineAttribute[@"id"]!=nil){
                         bp.identity=polylineAttribute[@"id"];
                     }
                     [_svgBezierPaths addObject:bp];
                 }
            }
        }
    }
    return self;
}

- (NSMutableArray *)parsePath:(NSString *)attr
{
	NSMutableArray *stringTokens = [NSMutableArray arrayWithCapacity: maxPathComplexity];
	
	NSInteger index = 0;
	while (index < [attr length]) {
        unichar	charAtIndex = [attr characterAtIndex:index];
        //Jagie:Skip whitespace
        if (charAtIndex == 32) {
            index ++;
            continue;
        }
		NSMutableString *stringToken = [[NSMutableString alloc] initWithCapacity:maxTokenLength];
		[stringToken setString:@""];
		
		if (charAtIndex != ',') {
			[stringToken appendString:[NSString stringWithFormat:@"%c", charAtIndex]];
		}
		if (![commandSet characterIsMember:charAtIndex] && charAtIndex != ',') {
			while ( (++index < [attr length]) && ![separatorSet characterIsMember:(charAtIndex = [attr characterAtIndex:index])] ) {
				[stringToken appendString:[NSString stringWithFormat:@"%c", charAtIndex]];
			}
		}
		else {
			index++;
		}
        
		if ([stringToken length]) {
			[stringTokens addObject:stringToken];
		}
	}
	
	if ([stringTokens count] == 0) {
		NSLog(@"*** PocketSVG Error: Path string is empty of tokens");
		return nil;
	}
	
	// turn the stringTokens array into Tokens, checking validity of tokens as we go
	NSMutableArray* tks = [[NSMutableArray alloc] initWithCapacity:maxPathComplexity];
	index = 0;
	NSString *stringToken = [stringTokens objectAtIndex:index];
	unichar command = [stringToken characterAtIndex:0];
	while (index < [stringTokens count]) {
		if (![commandSet characterIsMember:command]) {
			NSLog(@"*** PocketSVG Error: Path string parse error: found float where expecting command at token %d in path %s.",
					(int)index, [attr cStringUsingEncoding:NSUTF8StringEncoding]);
			return nil;
		}
		Token *token = [[Token alloc] initWithCommand:command];
		
		// There can be any number of floats after a command. Suck them in until the next command.
		while ((++index < [stringTokens count]) && ![commandSet characterIsMember:
				(command = [(stringToken = [stringTokens objectAtIndex:index]) characterAtIndex:0])]) {
			
			NSScanner *floatScanner = [NSScanner scannerWithString:stringToken];
			float value;
			if (![floatScanner scanFloat:&value]) {
				NSLog(@"*** PocketSVG Error: Path string parse error: expected float or command at token %d (but found %s) in path %s.",
					  (int)index, [stringToken cStringUsingEncoding:NSUTF8StringEncoding], [attr cStringUsingEncoding:NSUTF8StringEncoding]);
				return nil;
			}
			// Maintain scale.
			pathScale = (fabs(value) > pathScale) ? fabs(value) : pathScale;
			[token addValue:value];
		}
		
		// now we've reached a command or the end of the stringTokens array
		[tks	addObject:token];
	}
	//[stringTokens release];
	return tks;
}



- (UIBezierPath *)generateBezier:(NSArray *)inTokens
{
	bezier = [[UIBezierPath alloc] init];
	[self reset];
	for (Token *thisToken in inTokens) {
		unichar command = [thisToken command];
		switch (command) {
			case 'M':
			case 'm':
				[self appendSVGMCommand:thisToken];
				break;
			case 'L':
			case 'l':
			case 'H':
			case 'h':
			case 'V':
			case 'v':
				[self appendSVGLCommand:thisToken];
				break;
			case 'C':
			case 'c':
				[self appendSVGCCommand:thisToken];
				break;
			case 'S':
			case 's':
				[self appendSVGSCommand:thisToken];
				break;
			case 'Z':
			case 'z':
				[bezier closePath];
				break;
			default:
				NSLog(@"*** PocketSVG Error: Cannot process command : '%c'", command);
				break;
		}
	}
	return bezier;
}

- (void)reset
{
	lastPoint = CGPointMake(0, 0);
	validLastControlPoint = NO;
}

- (void)appendSVGMCommand:(Token *)token
{
	validLastControlPoint = NO;
	NSInteger index = 0;
	BOOL first = YES;
	while (index < [token valence]) {
		CGFloat x = [token parameter:index] + ([token command] == 'm' ? lastPoint.x : 0);
		if (++index == [token valence]) {
			NSLog(@"*** PocketSVG Error: Invalid parameter count in M style token");
			return;
		}
		CGFloat y = [token parameter:index] + ([token command] == 'm' ? lastPoint.y : 0);
		lastPoint = CGPointMake(x, y);
		if (first) {
			[bezier moveToPoint:lastPoint];
			first = NO;
		}
		else {
            [bezier addLineToPoint:lastPoint];
		}
		index++;
	}
}

- (void)appendSVGLCommand:(Token *)token
{
	validLastControlPoint = NO;
	NSInteger index = 0;
	while (index < [token valence]) {
		CGFloat x = 0;
		CGFloat y = 0;
		switch ( [token command] ) {
			case 'l':
				x = lastPoint.x;
				y = lastPoint.y;
			case 'L':
				x += [token parameter:index];
				if (++index == [token valence]) {
					NSLog(@"*** PocketSVG Error: Invalid parameter count in L style token");
					return;
				}
				y += [token parameter:index];
				break;
			case 'h' :
				x = lastPoint.x;				
			case 'H' :
				x += [token parameter:index];
				y = lastPoint.y;
				break;
			case 'v' :
				y = lastPoint.y;
			case 'V' :
				y += [token parameter:index];
				x = lastPoint.x;
				break;
			default:
				NSLog(@"*** PocketSVG Error: Unrecognised L style command.");
				return;
		}
		lastPoint = CGPointMake(x, y);
		[bezier addLineToPoint:lastPoint];
		index++;
	}
}

- (void)appendSVGCCommand:(Token *)token
{
	NSInteger index = 0;
	while ((index + 5) < [token valence]) {  // we must have 6 floats here (x1, y1, x2, y2, x, y).
		CGFloat x1 = [token parameter:index++] + ([token command] == 'c' ? lastPoint.x : 0);
		CGFloat y1 = [token parameter:index++] + ([token command] == 'c' ? lastPoint.y : 0);
		CGFloat x2 = [token parameter:index++] + ([token command] == 'c' ? lastPoint.x : 0);
		CGFloat y2 = [token parameter:index++] + ([token command] == 'c' ? lastPoint.y : 0);
		CGFloat x  = [token parameter:index++] + ([token command] == 'c' ? lastPoint.x : 0);
		CGFloat y  = [token parameter:index++] + ([token command] == 'c' ? lastPoint.y : 0);
		lastPoint = CGPointMake(x, y);

		[bezier addCurveToPoint:lastPoint 
				  controlPoint1:CGPointMake(x1,y1) 
				  controlPoint2:CGPointMake(x2, y2)];
        lastControlPoint = CGPointMake(x2, y2);
		validLastControlPoint = YES;
	}
	if (index == 0) {
		NSLog(@"*** PocketSVG Error: Insufficient parameters for C command");
	}
}

- (void)appendSVGSCommand:(Token *)token
{
	if (!validLastControlPoint) {
		NSLog(@"*** PocketSVG Error: Invalid last control point in S command");
	}
	NSInteger index = 0;
	while ((index + 3) < [token valence]) {  // we must have 4 floats here (x2, y2, x, y).
		CGFloat x1 = lastPoint.x + (lastPoint.x - lastControlPoint.x); // + ([token command] == 's' ? lastPoint.x : 0);
		CGFloat y1 = lastPoint.y + (lastPoint.y - lastControlPoint.y); // + ([token command] == 's' ? lastPoint.y : 0);
		CGFloat x2 = [token parameter:index++] + ([token command] == 's' ? lastPoint.x : 0);
		CGFloat y2 = [token parameter:index++] + ([token command] == 's' ? lastPoint.y : 0);
		CGFloat x  = [token parameter:index++] + ([token command] == 's' ? lastPoint.x : 0);
		CGFloat y  = [token parameter:index++] + ([token command] == 's' ? lastPoint.y : 0);
		lastPoint = CGPointMake(x, y);
		[bezier addCurveToPoint:lastPoint 
				  controlPoint1:CGPointMake(x1,y1)
				  controlPoint2:CGPointMake(x2, y2)];
		lastControlPoint = CGPointMake(x2, y2);
		validLastControlPoint = YES;
	}
	if (index == 0) {
		NSLog(@"*** PocketSVG Error: Insufficient parameters for S command");
	}
}
    
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    self.svgPathElements = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if([elementName isEqualToString:@"path"]){
        [self.svgPathElements addObject:attributeDict];
    }else if([elementName isEqualToString:@"image"]){
        [self.svgImageInfo addObject:attributeDict];
    }else if([elementName isEqualToString:@"polyline"]){
         [self.svgPolylineElements addObject:attributeDict];
        
    }
}

-(SVGBezierPath*)getSVGBezierPathWithIdentity:(NSString*)identity{
    for(SVGBezierPath* bp in _svgBezierPaths){
        if([bp.identity isEqualToString:identity]){
            return bp;
        }
    }
    return nil;
}

-(SVGBezierPath*)getSVGBezierPathWithFillColorHex:(NSString*)colorHex{
    for(SVGBezierPath* bp in _svgBezierPaths){
        if([bp.fillColorHex isEqualToString:colorHex]){
            return bp;
        }
    }
    return nil;
}
-(SVGBezierPath*)getSVGBezierPathWithStrokeColorHex:(NSString*)colorHex{
    for(SVGBezierPath* bp in _svgBezierPaths){
        if([bp.strokeColorHex isEqualToString:colorHex]){
            return bp;
        }
    }
    return nil;
}

-(SVGBezierPath*)getSVGBezierPathWithFirst{
    return _svgBezierPaths.firstObject;
}

-(NSDictionary*)getSVGImageInfoWithIdentity:(NSString*)identity{
    for(NSDictionary* bp in _svgImageInfo){
        if([bp[@"id"] isEqualToString:identity]){
            return bp;
        }
    }
    return nil;
}

-(NSDictionary*)getSVGImageInfoWithFirst{
    return _svgImageInfo.firstObject;
}

@end
