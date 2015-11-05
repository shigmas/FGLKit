//
//  FGLKMath.m
//  FGLKit
//
//  Created by Masa Jow on 12/16/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKMath.h"

#import "FGLKTypes.h"

@implementation FGLKMath

+ (double)roundNumber:(double)num toFractionalDigits:(NSInteger)digits
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:digits];
    [formatter setRoundingMode: NSNumberFormatterRoundHalfUp];
    
    NSString *numberString =
    [formatter stringFromNumber:[NSNumber numberWithDouble:num]];

    return numberString.doubleValue;
}

+(void)createQuad:(GLKVector3 *)points
         atCenter:(GLKVector3)center
        withWidth:(GLfloat)width
       withHeight:(GLfloat)height
      fromForward:(GLKVector3)forward
           fromUp:(GLKVector3)up
        fromRight:(GLKVector3)right
{
    GLKVector3 upVec = GLKVector3MultiplyScalar(up, height*0.5);
    GLKVector3 rightVec = GLKVector3MultiplyScalar(up, width*0.5);

    points[FGLKFrustumTopRight] =
        GLKVector3Add(rightVec, GLKVector3Add(center, upVec));
    
    points[FGLKFrustumBottomRight] =
        GLKVector3Add(rightVec, GLKVector3Subtract(center, upVec));

    points[FGLKFrustumTopLeft] =
        GLKVector3Add(upVec, GLKVector3Subtract(center, rightVec));

    points[FGLKFrustumBottomLeft] =
        GLKVector3Subtract(upVec, GLKVector3Subtract(center, rightVec));
}

+(void)createDisc:(GLKVector3 *)points
        numPoints:(NSUInteger)numPoints
         atCenter:(GLKVector3)center
       withRadius:(GLfloat)radius
      fromForward:(GLKVector3)forward
           fromUp:(GLKVector3)up
        fromRight:(GLKVector3)right
{
    
}

+(GLKVector3)getOrthoCameraPointFromScreen:(GLKVector2)point
                                     depth:(GLfloat)distance
                               camPosition:(GLKVector3)position
                                 camFoward:(GLKVector3)forward
                                     camUp:(GLKVector3)up
                                  camRight:(GLKVector3)right
                                  camWidth:(GLfloat)width
                                 camHeight:(GLfloat)height
{
    GLKVector3 camPoint;

    GLfloat hOff = height*0.5*point.y;
    GLfloat rOff = width*0.5*point.x;
    
    GLKVector3 rightVec = GLKVector3MultiplyScalar(right, rOff);
    GLKVector3 upVec = GLKVector3MultiplyScalar(up, hOff);
    
    GLKVector3 fwVec = GLKVector3MultiplyScalar(forward, distance);
    
    camPoint =
        GLKVector3Add(position,
                      GLKVector3Add(fwVec, GLKVector3Add(rightVec, upVec)));
    
    return camPoint;
}

@end
