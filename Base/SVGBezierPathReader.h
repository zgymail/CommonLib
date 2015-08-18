//
//  PocketSVG.h
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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@interface SVGBezierPath : NSObject
@property(nonatomic,strong)NSString* identity;
@property(nonatomic,strong)UIBezierPath* bezierPath;
@property(nonatomic,assign)NSString* fillColorHex;
@property(nonatomic,assign)NSString* strokeColorHex;
@end

@interface SVGBezierPathReader : NSObject<NSXMLParserDelegate> {
	@private
	float			pathScale;
    UIBezierPath    *bezier;
	CGPoint			lastPoint;
	CGPoint			lastControlPoint;
	BOOL			validLastControlPoint;
	NSCharacterSet  *separatorSet;
	NSCharacterSet  *commandSet;

}
@property(nonatomic, readonly) NSMutableArray *svgBezierPaths;
@property (nonatomic,strong)NSMutableArray* svgImageInfo;
- (id)initWithSVGFileNamed:(NSString *)nameOfSVG;

-(SVGBezierPath*)getSVGBezierPathWithFillColorHex:(NSString*)color;
-(SVGBezierPath*)getSVGBezierPathWithStrokeColorHex:(NSString*)color;
-(SVGBezierPath*)getSVGBezierPathWithIdentity:(NSString*)identity;
-(NSDictionary*)getSVGImageInfoWithIdentity:(NSString*)identity;
-(SVGBezierPath*)getSVGBezierPathWithFirst;
-(NSDictionary*)getSVGImageInfoWithFirst;
@end
