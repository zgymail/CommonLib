//
//  UIBezierPath+Extensions.h
//  PocketSVG
//
//  Created by MacBook on 8/17/14.
//
//

#import <UIKit/UIKit.h>
@interface UIBezierLine : NSObject
@property(nonatomic,strong)NSMutableArray* points;
@property(nonatomic,assign)bool closed;
@end
@interface UIBezierPath (Extensions)
-(NSArray*)getLines;
-(UIBezierLine*)getLine;
-(UIImage*)getImageWithStrokeSize:(CGFloat)strokeSize strokeColor:(UIColor*)strokeColor fillColor:(UIColor*)fillColor border:(CGFloat)border;
-(void)addSmoothLine:(NSArray*)points smoothValue:(CGFloat)smoothValue closed:(bool)closed;

@end


