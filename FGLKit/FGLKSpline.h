//
//  FGLKSpline.h
//  FGLKit
//
//  Created by Masa Jow on 9/3/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

typedef enum  {
    FGLKLinearBasis,
    FGLKBezierBasis,
    FGLKBSplineBasis,
    FGLKCatmullRomBasis
} FGLKSplineBasis;

typedef struct
{
    size_t t;
    GLfloat val;
}  FGLKSplineKnotInfo;


@interface FGLKSpline : NSObject

- (id)init;

- (id)initWithBasis:(FGLKSplineBasis)basis andKnots:(NSArray *)knots;

- (int) getStep:(FGLKSplineBasis) basis;

- (GLfloat) getBasisScale;

- (FGLKSplineKnotInfo) getKnotAt:(GLfloat) x;

//! Evaluate knot coefficients for the spline at \p x.
- (GLKVector4) evalCoeffsAt:(GLfloat) x;

- (GLKVector4) evalDerivCoeffsAt:(GLfloat) x;

@property (nonatomic) FGLKSplineBasis basis;
// Array of GLKVector2 or GLKVector3's
@property (nonatomic, strong) NSArray * knots;
@property (nonatomic) int step;

@end
