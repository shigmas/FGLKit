//
//  FGLKMath.h
//  FGLKit
//
//  Created by Masa Jow on 12/16/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

@interface FGLKMath : NSObject

// Rounds num to the number of digits after the decimal specified by
// digits
+ (double)roundNumber:(double)num toFractionalDigits:(NSInteger)digits;

// Creates a set of four points that make a quadrant.  points is an
// array of 4 GLKVectors.
+(void)createQuad:(GLKVector3 *)points
         atCenter:(GLKVector3)center
        withWidth:(GLfloat)width
       withHeight:(GLfloat)height
      fromForward:(GLKVector3)forward
           fromUp:(GLKVector3)up
        fromRight:(GLKVector3)right;

+(void)createDisc:(GLKVector3 *)points
        numPoints:(NSUInteger)numPoints
         atCenter:(GLKVector3)center
       withRadius:(GLfloat)radius
      fromForward:(GLKVector3)forward
           fromUp:(GLKVector3)up
        fromRight:(GLKVector3)right;

// Gets a camera point given a screen point
+(GLKVector3)getOrthoCameraPointFromScreen:(GLKVector2)point
                                     depth:(GLfloat)distance
                               camPosition:(GLKVector3)position
                                 camFoward:(GLKVector3)forward
                                     camUp:(GLKVector3)up
                                  camRight:(GLKVector3)right
                                  camWidth:(GLfloat)width
                                 camHeight:(GLfloat)height;

@end
