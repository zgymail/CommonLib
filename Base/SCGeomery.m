//
//  SCGeomery.m
//  StarCraft
//
//  Created by MacBook on 12/17/13.
//  Copyright (c) 2013 yn. All rights reserved.
//

#import "SCGeomery.h"
CGFloat pointWithAngle(CGPoint previous,CGPoint current){
    CGFloat kx = current.x-previous.x;
    CGFloat ky = current.y-previous.y;
    CGFloat betweenLen=sqrt(pow(kx, 2)+pow(ky,2));
    CGFloat radian = acos(kx/betweenLen);
    if (ky<0) {
        radian = -radian;
    }
    return radian;
}
CGFloat pointWithBetween(CGPoint previous,CGPoint current){
    CGFloat kx = current.x-previous.x;
    CGFloat ky = current.y-previous.y;
    return sqrt(pow(kx, 2)+pow(ky,2));
}

bool angleEquals(CGFloat currentAngle,CGFloat priviousAngle,CGFloat offset){
    return currentAngle>priviousAngle-offset&&currentAngle<priviousAngle+offset;
}

CGPoint pointWithLeftPoint(CGPoint previousPoint,CGPoint currentPoint,CGFloat len){
    CGFloat currentAngle=pointWithAngle(previousPoint,currentPoint);
    return CGPointMake(currentPoint.x+len*cos(currentAngle+RADIAN90), currentPoint.y+len*sin(currentAngle+RADIAN90));
}

CGPoint pointWithRightPoint(CGPoint previousPoint,CGPoint currentPoint,CGFloat len){
    CGFloat currentAngle=pointWithAngle(previousPoint,currentPoint);
    return CGPointMake(currentPoint.x+len*cos(currentAngle-RADIAN90), currentPoint.y+len*sin(currentAngle-RADIAN90));
}
// (currentPoint)--len--?-------(fowardPoint)
CGPoint pointWithBetweenPoint(CGPoint currentPoint,CGPoint fowardPoint,CGFloat len){
    CGFloat currentAngle=pointWithAngle(currentPoint,fowardPoint);
    return CGPointMake(currentPoint.x+len*cos(currentAngle), currentPoint.y+len*sin(currentAngle));
}
// (currentPoint)---------(fowardPoint)---len---?
CGPoint pointWithOutPoint(CGPoint currentPoint,CGPoint fowardPoint,CGFloat len){
    CGFloat currentAngle=pointWithAngle(currentPoint,fowardPoint);
    return CGPointMake(fowardPoint.x+len*cos(currentAngle), fowardPoint.y+len*sin(currentAngle));
}

CGPoint pointWithCenterPoint(CGPoint currentPoint,CGPoint fowardPoint){
    return CGPointMake(currentPoint.x+(fowardPoint.x-currentPoint.x)/2, currentPoint.y+(fowardPoint.y-currentPoint.y)/2);
}

static CGPoint p0;					// 起点
static CGPoint p1;					// 贝塞尔点
static CGPoint p2;					// 终点
static uint step;					// 分割份数

//  辅助变量
static int ax;
static int ay;
static int bx;
static int by;

static CGFloat A;
static CGFloat B;
static CGFloat C;

static CGFloat total_length;			// 长度

static bool curveType;
//  速度函数
CGFloat s(CGFloat t)
{
    return sqrtf(A * t * t + B * t + C);
}
static CGFloat L(CGFloat t)
{
    CGFloat temp1 = sqrtf(C + t * (B + A * t));
    CGFloat temp2 = (2 * A * t * temp1 + B *(temp1 - sqrtf(C)));
    CGFloat temp3 = logf(B + 2 * sqrtf(A) * sqrtf(C));
    CGFloat temp4 = logf(B + 2 * A * t + 2 * sqrtf(A) * temp1);
    CGFloat temp5 = 2 * sqrtf(A) * temp2;
    CGFloat temp6 = (B * B - 4 * A * C) * (temp3 - temp4);
    return (temp5 + temp6) / (8 * powf(A, 1.5));
}

//  返回所需总步数
uint initBezier (CGPoint $p0,CGPoint $p1,CGPoint $p2,CGFloat $speed)
{
    p0   = $p0;
    p1   = $p1;
    p2   = $p2;
    //step = 30;
    
    ax = p0.x - 2 * p1.x + p2.x;
    ay = p0.y - 2 * p1.y + p2.y;
    bx = 2 * p1.x - 2 * p0.x;
    by = 2 * p1.y - 2 * p0.y;
    
    A = 4*(ax * ax + ay * ay);
    B = 4*(ax * bx + ay * by);
    C = bx * bx + by * by;
    
    //  计算长度
    total_length = L(1);
    
    if(total_length==NAN){
        curveType=false;
        total_length=sqrtf(powf(p0.x-p2.x,2)+powf(p0.y-p2.y,2));
    }else{
        curveType=true;
    }
    
    //  计算步数
    
    step = floorf(total_length / $speed);
    if (fmodf(total_length, $speed) > $speed/2)	step ++;
    
    //	trace("曲长：" + total_length);
    //	trace("步数：" + step);
    //	trace("曲线：" + curveType);
    return step;
}
void retrieveAnchorPoint (CGFloat nIndex,CGPoint* point,CGFloat* degrees)
{
    CGFloat t = nIndex/step;
    if(curveType){
        
        //  如果按照线行增长，此时对应的曲线长度
        //CGFloat l = t*total_length;
        //  根据L函数的反函数，求得l对应的t值
        //t = InvertL(t, l);
        
        //  根据贝塞尔曲线函数，求得取得此时的x,y坐标
        CGFloat xx = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
        CGFloat yy = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
        
        //  获取切线
        CGPoint Q0 =CGPointMake((1 - t) * p0.x + t * p1.x, (1 - t) * p0.y + t * p1.y);
        CGPoint Q1 = CGPointMake((1 - t) * p1.x + t * p2.x, (1 - t) * p1.y + t * p2.y);
        
        //  计算角度
        CGFloat dx = Q1.x - Q0.x;
        CGFloat dy = Q1.y - Q0.y;
       
        CGFloat radians = atan2f(dy, dx);
        
        *point=CGPointMake(xx, yy);
        *degrees=radians * 180 / M_PI;
    }else{
        //求得取得此时的x,y坐标
        CGFloat xx1=p0.x+(p2.x-p0.x)*t;
        CGFloat yy1=p0.y+(p2.y-p0.y)*t;
        //  计算角度
        CGFloat dx1 = p2.x - p0.x;
        CGFloat dy1 = p2.y - p0.y;
        
        CGFloat radians1 = atan2f(dy1, dx1);
        
        *point=CGPointMake(xx1, yy1);
        *degrees=radians1 * 180 / M_PI;
    }
    
}

bool testIntersectPoint(CGPoint* intrPoint,CGPoint a,CGPoint b,CGPoint c,CGPoint d){
    // 三角形abc 面积的2倍
    CGFloat area_abc = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
    
    // 三角形abd 面积的2倍
    CGFloat area_abd = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);
    
    // 面积符号相同则两点在线段同侧,不相交 (对点在线段上的情况,本例当作不相交处理);
    //area_abc*area_abd>=0
    if ( area_abc*area_abd>=0 ) {
        return false;
    }
    
    // 三角形cda 面积的2倍
    CGFloat area_cda = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);
    // 三角形cdb 面积的2倍
    // 注意: 这里有一个小优化.不需要再用公式计算面积,而是通过已知的三个面积加减得出.
    CGFloat area_cdb = area_cda + area_abc - area_abd ;
    if (  area_cda * area_cdb > 0 ) {
        return false;
    }
    //计算交点坐标
    CGFloat t = area_cda / ( area_abd- area_abc );
    CGFloat dx= t*(b.x - a.x);
    CGFloat dy= t*(b.y - a.y);
    CGPoint p=CGPointMake(a.x + dx, a.y + dy);
    *intrPoint=p;
    return true;
}

bool testIntersectPointWithRay(CGPoint* intrPoint,CGPoint a,CGPoint b,CGPoint c,CGPoint d){
    CGFloat denominator = (b.y - a.y)*(d.x - c.x) - (a.x - b.x)*(c.y - d.y);
    if (denominator==0) {
        return false;
    }
    
    // 线段所在直线的交点坐标 (x , y)
    CGFloat x = ( (b.x - a.x) * (d.x - c.x) * (c.y - a.y)
             + (b.y - a.y) * (d.x - c.x) * a.x
             - (d.y - c.y) * (b.x - a.x) * c.x ) / denominator ;
    CGFloat y = -( (b.y - a.y) * (d.y - c.y) * (c.x - a.x)
              + (b.x - a.x) * (d.y - c.y) * a.y
              - (d.x - c.x) * (b.y - a.y) * c.y ) / denominator;
    *intrPoint=CGPointMake(x,y);
    return true;
}

bool pointWithRectContains(CGPoint point,CGPoint point_lb,CGPoint point_rb,CGPoint point_lt,CGPoint point_rt){
    float ab = pointWithBetween(point_lb, point_lt);
    float bc = pointWithBetween(point_lt, point_rt);
    float cd = pointWithBetween(point_rt, point_rb);
    float da = pointWithBetween(point_rb, point_lb);
    
    float oa = pointWithBetween(point, point_lb);
    float ob = pointWithBetween(point, point_lt);
    float oc = pointWithBetween(point, point_rt);
    float od = pointWithBetween(point, point_rb);
    
    float cos_AOB = (oa * oa + ob * ob - ab * ab) / (2 * oa * ob);
    float cos_BOC = (ob * ob + oc * oc - bc * bc) / (2 * ob * oc);
    float cos_COD = (oc * oc + od * od - cd * cd) / (2 * oc * od);
    float cos_DOA = (od * od + oa * oa - da * da) / (2 * oa * od);
    
    float AOB = acosf(cos_AOB);
    float BOC = acosf(cos_BOC);
    float COD = acosf(cos_COD);
    float DOA = acosf(cos_DOA);
    
    if(fabs(AOB + BOC + COD + DOA - M_PI * 2) < 0.01f)
        return YES;
    
    return NO;
}

SCGeomeryLeftOrRight pointWithRightOrLeft(CGPoint poiM,CGPoint poiA,CGPoint poiB)
{
    double ax = poiB.x - poiA.x;
    double ay = poiB.y - poiA.y;
    double bx = poiM.x - poiA.x;
    double by = poiM.y - poiA.y;
    double judge = ax * by - ay * bx;
    if(judge>0)
    {
        return Left;
    }
    else if(judge<0)
    {
        return Right;
    }
    else
    {
        return Online;
    }
}

CGFloat angleToZero360Between(CGFloat angle){
    if(angle<0){
        NSInteger k=ceil(fabs(angle)/RADIAN360);
        angle=angle+k*RADIAN360;
    }
    if(angle>=RADIAN360){
        NSInteger k=floor(angle/RADIAN360);
        angle=angle-k*RADIAN360;
    }
    return angle;
}
CGPoint centerPointWithPoints(NSArray* points,CGPoint(^itemPoint)(id point)){
    CGFloat minx=CGFLOAT_MAX;
    CGFloat maxx=CGFLOAT_MIN;
    CGFloat miny=CGFLOAT_MAX;
    CGFloat maxy=CGFLOAT_MIN;
    for(id item in points){
        CGPoint p=itemPoint(item);
        if(p.x<minx){
            minx=p.x;
        }
        if(p.x>maxx){
            maxx=p.x;
        }
        if(p.y<miny){
            miny=p.y;
        }
        if(p.y>maxy){
            maxy=p.y;
        }
    }
    return CGPointMake(minx+(maxx-minx)/2, miny+(maxy-miny)/2);
}

CGRect rectWithPoints(NSArray* points,CGPoint(^itemPoint)(id point)){
    CGFloat minx=CGFLOAT_MAX;
    CGFloat maxx=CGFLOAT_MIN;
    CGFloat miny=CGFLOAT_MAX;
    CGFloat maxy=CGFLOAT_MIN;
    for(id item in points){
        CGPoint p=itemPoint(item);
        if(p.x<minx){
            minx=p.x;
        }
        if(p.x>maxx){
            maxx=p.x;
        }
        if(p.y<miny){
            miny=p.y;
        }
        if(p.y>maxy){
            maxy=p.y;
        }
    }
    return CGRectMake(minx, miny, maxx-minx, maxy-miny);
}
