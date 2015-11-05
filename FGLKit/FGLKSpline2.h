//
//  FGLKSpline2.h
//  FGLKit
//
//  Created by Masa Jow on 8/28/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FGLKSpline.h"

#import <GLKit/GLKit.h>

@interface FGLKSpline2 : FGLKSpline

- (id)init;

// Array of GLKVector2's
- (id)initWithBasis:(FGLKSplineBasis)basis andKnots:(NSArray *)knots;

// Pass a point between 0.0 and 1.0 to find the spline value between
// the knots.  For CatmullRom, this will *not* include the first and
// last knots.
- (GLKVector2) evalAt:(GLfloat)x withExtrapolation:(BOOL)extrapolation;

- (GLKVector2) evalDerivAt:(GLfloat)x;

@end
