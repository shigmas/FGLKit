//
//  FGLKSpline.m
//  FGLKit
//
//  Created by Masa Jow on 9/3/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKSpline.h"

@implementation FGLKSpline

- (int)getStep:(FGLKSplineBasis)basis
{
    if (basis == FGLKBezierBasis)
        return 3;
    else
        return 1;
}

- (id)init
{
    return [self init];
}

- (id)initWithBasis:(FGLKSplineBasis)basis andKnots:(NSArray *)knots
{
    if ((self = [super init]) != nil) {
        self.basis = basis;
        self.knots = knots;
        self.step = [self getStep:basis];
    }
    
    return self;
}

- (GLfloat)getBasisScale
{
    NSInteger numKnots = [self.knots count];
    if (self.basis == FGLKBezierBasis)
        return (int)((numKnots-1.0 ) / self.step);
    else
        return numKnots-3.0;
}

#define _GF_SPLINE_EPSILON 1.0e-6

- (FGLKSplineKnotInfo) getKnotAt:(GLfloat)x
{
    NSInteger ki;             // knots [i...i+3] are used
    
    if (x < 0.0) {      // Clamp to the first point
        x = 0.0;
        ki = 0;
    }
    else if (x >= 1.0) {// Clamp to the last point
        x = (1 - _GF_SPLINE_EPSILON);
        ki = [self.knots count]-4;
    }
    else {
        x *= ((([self.knots count]-4) / self.step) + 1);
        ki = (int)x;
        x -= ki;
        ki *= self.step;
    }
    FGLKSplineKnotInfo info;
    info.t = ki;
    info.val = x;
    return info;
}

- (GLKVector4) evalCoeffsAt:(GLfloat)t
{
    GLKVector4 c;
    double t2 = t*t;
    double t3 = t*t2;
    // Extra parens are just laziness from copying C++ code
    switch (self.basis) {
        case FGLKLinearBasis:
            c.w = (0);
            c.x = (1-t);
            c.y = (t);
            c.z = (0);
            break;
        case FGLKBezierBasis:
            c.w = (-t3 + 3*t2 -3*t + 1);
            c.x = (3*t3 - 6*t2 + 3*t);
            c.y = (-3*t3 + 3*t2);
            c.z = (t3);
            break;
        case FGLKBSplineBasis:
            c.w = (-(1.0/6.0)*t3 + 0.5*t2 - 0.5*t + (1.0/6.0));
            c.x = (0.5*t3 - t2 + (2.0/3.0));
            c.y = (-0.5*t3 + 0.5*t2 + 0.5*t + (1.0/6.0));
            c.z = ((1.0/6.0)*t3);
            break;
        case FGLKCatmullRomBasis:
            c.w = (-0.5*t3 + t2 - 0.5*t);
            c.x = (1.5*t3 - 2.5*t2 + 1);
            c.y = (-1.5*t3 + 2*t2 + 0.5*t);
            c.z = (0.5*t3 - 0.5*t2);
            break;
        default:
            NSLog(@"Unknown spline basis");
            c = GLKVector4Make(0,0,0,0);
    }
    return c;
}

- (GLKVector4) evalDerivCoeffsAt:(GLfloat)t
{
    GLKVector4 c;
    double t2 = t*t;
    switch (self.basis) {
        case FGLKLinearBasis:
            c.w = (0);
            c.x = (-1);
            c.y = (1);
            c.z = (0);
            break;
        case FGLKBezierBasis:
            c.w = (-3*t2 + 6*t - 3);
            c.x = (9*t2 - 12*t + 3);
            c.y = (-9*t2 + 6* t);
            c.z = (3*t2);
            break;
        case FGLKBSplineBasis:
            c.w = (-0.5*t2 + t - 0.5);
            c.x = (1.5*t2 - 2*t);
            c.y = (-1.5*t2 + t + 0.5);
            c.z = (0.5*t2);
            break;
        case FGLKCatmullRomBasis:
            c.w = (-1.5*t2 + 2*t - 0.5);
            c.x = (4.5*t2 - 5*t);
            c.y = (-4.5*t2 + 4*t + 0.5);
            c.z = (1.5*t2 - t);
            break;
        default:
            NSLog(@"Unknown spline basis");
            c = GLKVector4Make(0,0,0,0);
    }
    
    return c;
}

@end
