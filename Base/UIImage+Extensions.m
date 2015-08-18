//
//  UIImage+Extensions.m
//  SSAdventure
//
//  Created by MacBook on 7/5/14.
//  Copyright (c) 2014 yning. All rights reserved.
//

#import "UIImage+Extensions.h"
#import <Accelerate/Accelerate.h>
NSUInteger bitmapByteOffset(NSUInteger x, NSUInteger y, NSUInteger w,NSUInteger offset){
    return y * w * 4 + x * 4 + offset;
}
@implementation UIImage (Extensions)


- (UIImage *)imageWithRotate:(CGFloat)rotation
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(rotation);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap,rotation);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

+ (NSDictionary*)spritesWithContentsOfFile:(NSString*)filename
{
    CGFloat scale = 1;
    NSString* file = [[filename lastPathComponent] stringByDeletingPathExtension];
    //if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
     //   (scale == 2.0))
    //{
        //file = [NSString stringWithFormat:@"%@@2x", file];
   // }
    NSString* extension = [filename pathExtension];
    NSString * filepath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:file ofType:extension]];
    NSDictionary* xmlDictionary = [NSDictionary dictionaryWithContentsOfFile:filepath];
    NSDictionary* xmlTextureAtlas = [xmlDictionary objectForKey:@"meta"];
    UIImage* image = [UIImage imageNamed:[xmlTextureAtlas objectForKey:@"image"]];
    NSString *imageExtension = [[xmlTextureAtlas objectForKey:@"image"] pathExtension];
    CGSize size = CGSizeMake([[xmlTextureAtlas objectForKey:@"width"] integerValue],
                             [[xmlTextureAtlas objectForKey:@"height"] integerValue]);
    
    if (!image || CGSizeEqualToSize(size, CGSizeZero)) return nil;
    CGImageRef spriteSheet = [image CGImage];
    NSMutableDictionary* tempDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary * xmlSprites = [xmlDictionary objectForKey:@"frames"];
    for (id key in xmlSprites)
    {
        NSDictionary * xmlSprite = [xmlSprites objectForKey:key];
        CGRect unscaledRect = CGRectMake([[xmlSprite objectForKey:@"x"] integerValue],
                                         [[xmlSprite objectForKey:@"y"] integerValue],
                                         [[xmlSprite objectForKey:@"w"] integerValue],
                                         [[xmlSprite objectForKey:@"h"] integerValue]);
        CGImageRef sprite = CGImageCreateWithImageInRect(spriteSheet, unscaledRect);
        NSString * imageName = [NSString stringWithFormat:@"%@.%@", key, imageExtension];
        [tempDictionary setObject:[UIImage imageWithCGImage:sprite scale:scale orientation:UIImageOrientationUp] forKey:imageName];
        CGImageRelease(sprite);
    }
    
    return [NSDictionary dictionaryWithDictionary:tempDictionary];
}

-(unsigned char*)getBitmapBytes{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    CGSize size = self.size;
    // void *bitmapData = malloc(size.width * size.height * 4);
    unsigned char *bitmapData = calloc(size.width * size.height * 4, 1); // Courtesy of Dirk. Thanks!
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Error: Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    CGContextRef context = CGBitmapContextCreate (bitmapData, size.width, size.height, 8, size.width * 4, colorSpace,  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace );
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bitmapData);
        return NULL;
    }
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -size.height);
    CGContextDrawImage(context, rect, self.CGImage);
    unsigned char *data = CGBitmapContextGetData(context);
    CGContextRelease(context);
    return data;
}

- (UIImage *)subImage:(CGRect)rect{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO,1);
    CGImageRef cutImage = CGImageCreateWithImageInRect(self.CGImage,rect);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, rect.size.width, rect.size.height), cutImage);
    CGImageRelease(cutImage);
    //[[UIImage imageWithCGImage:cutImage scale:[self scale] orientation:UIImageOrientationUp] drawAtPoint:CGPointMake(0,0)];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
