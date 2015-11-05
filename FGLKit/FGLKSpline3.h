//
//  FGLKSpline3.h
//  FGLKit
//
//  Created by Masa Jow on 9/3/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FGLKSpline.h"

#import <GLKit/GLKit.h>

@interface FGLKSpline3 : FGLKSpline

- (id)init;

// Array of GLKVector3's
- (id)initWithBasis:(FGLKSplineBasis)basis andKnots:(NSArray *)knots;

// Pass a point between 0.0 and 1.0 to find the spline value between
// the knots.  For CatmullRom, this will *not* include the first and
// last knots.
- (GLKVector3) evalAt:(GLfloat)x withExtrapolation:(BOOL)extrapolation;

- (GLKVector3) evalDerivAt:(GLfloat)x;

@end
