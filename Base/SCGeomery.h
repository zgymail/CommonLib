//
//  SCGeomery.h
//  StarCraft
//
//  Created by MacBook on 12/17/13.
//  Copyright (c) 2013 yn. All rights reserved.
//

#import <Foundation/Foundation.h>
#define RADIAN180 M_PI
#define RADIAN360 360*M_PI/180
#define RADIAN300 300*M_PI/180
#define RADIAN270 270*M_PI/180
#define RADIAN150 150*M_PI/180
#define RADIAN135 135*M_PI/180
#define RADIAN120 120*M_PI/180
#define RADIAN100 100*M_PI/180
#define RADIAN90 90*M_PI/180
#define RADIAN85 85*M_PI/180
#define RADIAN80 80*M_PI/180
#define RADIAN60 60*M_PI/180
#define RADIAN45 45*M_PI/180
#define RADIAN30 30*M_PI/180
#define RADIAN15 15*M_PI/180
#define RADIAN225 22.5*M_PI/180
enum SCGeomeryLeftOrRight {
    Left, Right, Online
};
typedef enum SCGeomeryLeftOrRight SCGeomeryLeftOrRight;
CGFloat pointWithAngle(CGPoint previous,CGPoint current);
CGFloat pointWithBetween(CGPoint previous,CGPoint current);
bool angleEquals(CGFloat currentAngle,CGFloat priviousAngle,CGFloat offset);
CGPoint pointWithLeftPoint(CGPoint previousPoint,CGPoint currentPoint,CGFloat len);
CGPoint pointWithRightPoint(CGPoint previousPoint,CGPoint currentPoint,CGFloat len);
// (currentPoint)--len--?-------(fowardPoint)
CGPoint pointWithBetweenPoint(CGPoint currentPoint,CGPoint fowardPoint,CGFloat len);
// (currentPoint)---------(fowardPoint)---len---?
CGPoint pointWithOutPoint(CGPoint currentPoint,CGPoint fowardPoint,CGFloat len);
CGPoint pointWithCenterPoint(CGPoint currentPoint,CGPoint fowardPoint);
uint initBezier (CGPoint $p0,CGPoint $p1,CGPoint $p2,CGFloat $speed);
void retrieveAnchorPoint (CGFloat nIndex,CGPoint* point,CGFloat* degrees);

bool testIntersectPoint(CGPoint* intrPoint,CGPoint a,CGPoint b,CGPoint c,CGPoint d);
//直线或射线交点
bool testIntersectPointWithRay(CGPoint* intrPoint,CGPoint a,CGPoint b,CGPoint c,CGPoint d);
bool pointWithRectContains(CGPoint point,CGPoint point_lb,CGPoint point_rb,CGPoint point_lt,CGPoint point_rt);
SCGeomeryLeftOrRight pointWithRightOrLeft(CGPoint poiM,CGPoint poiA,CGPoint poiB);
CGFloat angleToZero360Between(CGFloat angle);
CGPoint centerPointWithPoints(NSArray* points,CGPoint(^itemPoint)(id point));
CGRect rectWithPoints(NSArray* points,CGPoint(^itemPoint)(id point));
