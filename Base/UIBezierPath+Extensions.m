//
//  UIBezierPath+Extensions.m
//  PocketSVG
//
//  Created by MacBook on 8/17/14.
//
//
#import "SCGeomery.h"
#import "UIBezierPath+Extensions.h"
static void applyGetPoint(void* info, const CGPathElement* element)
{
	NSMutableArray* a = (__bridge NSMutableArray*) info;
	int nPoints;
	switch (element->type)
	{
		case kCGPathElementMoveToPoint:
			nPoints = 1;
			break;
		case kCGPathElementAddLineToPoint:
			nPoints = 1;
			break;
		case kCGPathElementAddQuadCurveToPoint:
			nPoints = 2;
			break;
		case kCGPathElementAddCurveToPoint:
			nPoints = 3;
			break;
		case kCGPathElementCloseSubpath:
			nPoints = 0;
			break;
		default:
			[a replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:NO]];
			return;
	}
    
	NSNumber* type = [NSNumber numberWithInt:element->type];
	NSData* points = [NSData dataWithBytes:element->points length:nPoints*sizeof(CGPoint)];
	[a addObject:[NSDictionary dictionaryWithObjectsAndKeys:type,@"type",points,@"points",nil]];
}
CGFloat CubicN(CGFloat T,CGFloat a,CGFloat b,CGFloat c,CGFloat d) {
    CGFloat t2 = T*T;
    CGFloat t3 = t2*T;
    return a + (-a * 3 + T * (3 * a - a * T)) * T
    + (3 * b + T * (-6 * b + b * 3 * T)) * T
    + (c * 3 - c * 3 * T) * t2
    + d * t3;
}
CGPoint getCubicBezierXYatT(CGPoint startPt,CGPoint controlPt1,CGPoint controlPt2,CGPoint endPt,CGFloat T){
    CGFloat x=CubicN(T,startPt.x,controlPt1.x,controlPt2.x,endPt.x);
    CGFloat y=CubicN(T,startPt.y,controlPt1.y,controlPt2.y,endPt.y);
    return CGPointMake(x, y);
}

@implementation UIBezierPath (Extensions)
-(NSArray*)getLines{
    NSMutableArray* lines=[[NSMutableArray alloc] init];
    UIBezierLine* bline;
    
    NSMutableArray* bezierPoints = [NSMutableArray arrayWithObject:[NSNumber numberWithBool:YES]];
    CGPathApply(self.CGPath, (__bridge void *)(bezierPoints), applyGetPoint);
    CGPoint previousBezierPoint;
    for (NSInteger i = 1, l = [bezierPoints count]; i < l; i++)
	{
		NSDictionary* bezierDic = bezierPoints[i];
        
		CGPoint* bezierPoint = (CGPoint*) [bezierDic[@"points"] bytes];
        
		switch ([bezierDic[@"type"] intValue])
		{
			case kCGPathElementMoveToPoint:{
                if(bline!=nil){
                    [lines addObject:bline];
                }
                bline=[[UIBezierLine alloc] init];
                
                [bline.points addObject:[NSValue valueWithCGPoint:bezierPoint[0]]];
                previousBezierPoint=bezierPoint[0];
				break;
            }case kCGPathElementAddLineToPoint:{
                [bline.points addObject:[NSValue valueWithCGPoint:bezierPoint[0]]];
                previousBezierPoint=bezierPoint[0];
				break;
            }case kCGPathElementAddQuadCurveToPoint:
            {
                CGPoint startPoint=previousBezierPoint;
				CGPoint controlPoint1=bezierPoint[0];
                CGPoint controlPoint2=bezierPoint[0];
                CGPoint endPoint=bezierPoint[1];
                
                CGFloat t=0.1;
                CGFloat bw=8;
                CGPoint inerPoint=getCubicBezierXYatT(startPoint,controlPoint1,controlPoint2,endPoint,t);
                CGFloat rbw=pointWithBetween(startPoint, inerPoint);
                t=t*bw/rbw;
                if(t>=1){
                    t=1;
                }
                NSInteger count=1.0/t;
                for(NSInteger j=0;j<count;j++){
                    CGFloat t=j/(CGFloat)count;
                    CGPoint inerPoint=getCubicBezierXYatT(startPoint,controlPoint1,controlPoint2,endPoint,t);
                    [bline.points addObject:[NSValue valueWithCGPoint:inerPoint]];
                }
                [bline.points addObject:[NSValue valueWithCGPoint:endPoint]];
                previousBezierPoint=endPoint;
				break;
            }
			case kCGPathElementAddCurveToPoint:
            {
                CGPoint startPoint=previousBezierPoint;
				CGPoint controlPoint1=bezierPoint[0];
                CGPoint controlPoint2=bezierPoint[1];
                CGPoint endPoint=bezierPoint[2];
                CGFloat t=0.1;
                CGFloat bw=5;
                CGPoint inerPoint=getCubicBezierXYatT(startPoint,controlPoint1,controlPoint2,endPoint,t);
                CGFloat rbw=pointWithBetween(startPoint, inerPoint);
                t=t*bw/rbw;
                if(t>=1){
                    t=1;
                }
                NSInteger count=1.0/t;
                for(NSInteger j=1;j<count;j++){
                    CGFloat t=j/(CGFloat)count;
                    CGPoint inerPoint=getCubicBezierXYatT(startPoint,controlPoint1,controlPoint2,endPoint,t);
                    [bline.points addObject:[NSValue valueWithCGPoint:inerPoint]];
                }
                [bline.points addObject:[NSValue valueWithCGPoint:endPoint]];
                
                previousBezierPoint=endPoint;
                break;
            }
			case kCGPathElementCloseSubpath:
                bline.closed=true;
                break;
			default:
                break;
		}
        
	}
    
    if(bline!=nil){
        [lines addObject:bline];
    }
    
    return lines;
}

-(UIBezierLine*)getLine{
    NSArray* lines=[self getLines];
    if(lines.count>0){
        return lines.firstObject;
    }else{
        return nil;
    }
}

-(UIImage*)getImageWithStrokeSize:(CGFloat)strokeSize strokeColor:(UIColor*)strokeColor fillColor:(UIColor*)fillColor border:(CGFloat)border{
    CGRect rect=CGPathGetBoundingBox(self.CGPath);
    CGAffineTransform trans=CGAffineTransformMakeTranslation(-rect.origin.x, -rect.origin.y);
    CGPathRef path=CGPathCreateCopyByTransformingPath(self.CGPath,&trans);
    CGSize size=CGSizeMake(rect.size.width+border*2, rect.size.height+border*2);
    UIGraphicsBeginImageContextWithOptions(size, NO,1);
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx,border, border);
    CGContextAddPath(ctx, path);
    if(strokeColor!=nil){
        CGContextSetLineWidth(ctx, strokeSize);
        CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);
    }
    if(fillColor!=nil){
        CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    }
    if(fillColor!=nil&&strokeColor!=nil){
         CGContextDrawPath(ctx, kCGPathFillStroke);
    }else if(fillColor!=nil){
         CGContextDrawPath(ctx, kCGPathStroke);
    }else{
         CGContextDrawPath(ctx, kCGPathFill);
    }
    
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGPathRelease(path);
    return image;
}

-(void)addSmoothLine:(NSArray*)ps smoothValue:(CGFloat)smoothValue closed:(bool)closed{
    if(ps.count<=2)return;
    NSMutableArray* points=[[NSMutableArray alloc] initWithArray:ps];
    NSInteger index=0;
    NSMutableArray* controlPoints=[[NSMutableArray alloc] initWithCapacity:points.count];
    if(closed){
        [points addObject:[NSValue valueWithCGPoint:((NSValue*)points[0]).CGPointValue]];
    }
    for (index=0; index<points.count-1; index++) {
        CGPoint previousPoint;
        CGPoint nextPoint;
        CGPoint currentPoint;
        if(index==0){
            if(closed){
                previousPoint=((NSValue*)points[points.count-2]).CGPointValue;
                nextPoint=((NSValue*)points[index+1]).CGPointValue;
                currentPoint=((NSValue*)points[index]).CGPointValue;
            }else{
                [controlPoints addObject:@{@"p":points[index]}];
                continue;
            }
        }else{
            previousPoint=((NSValue*)points[index-1]).CGPointValue;
            nextPoint=((NSValue*)points[index+1]).CGPointValue;
            currentPoint=((NSValue*)points[index]).CGPointValue;
        }
        
        CGFloat angle1=pointWithAngle(currentPoint, previousPoint);
        CGFloat angle2=pointWithAngle(currentPoint, nextPoint);
        CGFloat angle=angle1+(angle2-angle1)/2;
        if(angle>angle1){
            angle1=angle-RADIAN90;
        }else{
            angle1=angle+RADIAN90;
        }
        if(angle>angle2){
            angle2=angle-RADIAN90;
        }else{
            angle2=angle+RADIAN90;
        }
        CGPoint p1= CGPointMake(currentPoint.x+smoothValue*cos(angle1), currentPoint.y+smoothValue*sin(angle1));
        CGPoint p2= CGPointMake(currentPoint.x+smoothValue*cos(angle2), currentPoint.y+smoothValue*sin(angle2));
        [controlPoints addObject:@{@"p":points[index],@"c1":[NSValue valueWithCGPoint:p1],@"c2":[NSValue valueWithCGPoint:p2]}];
    }
    if(closed){
        NSDictionary* cpp=controlPoints[0];
        [controlPoints addObject:@{@"p":cpp[@"p"],@"c1":cpp[@"c1"],@"c2":cpp[@"c2"]}];
    }else{
        [controlPoints addObject:@{@"p":points[index]}];
    }
    
    if(closed){
        [self moveToPoint:((NSValue*)((NSDictionary*)controlPoints[0])[@"p"]).CGPointValue];
        for (index=1; index<controlPoints.count; index++) {
             NSDictionary* pp=controlPoints[index-1];
             NSDictionary* cpp=controlPoints[index];
            [self addCurveToPoint:((NSValue*)cpp[@"p"]).CGPointValue controlPoint1:((NSValue*)pp[@"c2"]).CGPointValue controlPoint2:((NSValue*)cpp[@"c1"]).CGPointValue];
        }
        [self closePath];
    }else{
        [self moveToPoint:((NSValue*)((NSDictionary*)controlPoints[0])[@"p"]).CGPointValue];
        NSDictionary* cpp=controlPoints[1];
        [self addQuadCurveToPoint:((NSValue*)cpp[@"p"]).CGPointValue controlPoint:((NSValue*)cpp[@"c1"]).CGPointValue];
        for (index=2; index<controlPoints.count-1; index++) {
            NSDictionary* pp=controlPoints[index-1];
            NSDictionary* cpp=controlPoints[index];
            [self addCurveToPoint:((NSValue*)cpp[@"p"]).CGPointValue controlPoint1:((NSValue*)pp[@"c2"]).CGPointValue controlPoint2:((NSValue*)cpp[@"c1"]).CGPointValue];
        }
         NSDictionary* pp=controlPoints[index-1];
         cpp=controlPoints[index];
         [self addQuadCurveToPoint:((NSValue*)cpp[@"p"]).CGPointValue controlPoint:((NSValue*)pp[@"c2"]).CGPointValue];
    }
}




@end
@implementation UIBezierLine
-(id)init{
    self=[super init];
    if(self){
        _points=[[NSMutableArray alloc] init];
    }
    return self;
}
@end