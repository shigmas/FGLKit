//
//  FGLKSpline3.m
//  FGLKit
//
//  Created by Masa Jow on 9/3/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKSpline3.h"

@implementation FGLKSpline3

- (id)init
{
    if ((self = [super init]) != nil) {
        
    }
    return self;
}

- (id)initWithBasis:(FGLKSplineBasis)basis andKnots:(NSArray *)knots
{
    if ((self = [super initWithBasis:basis andKnots:knots]) != nil) {
        // Could verify we're holding GLKVector2's
    }
    return self;
}

- (GLKVector3) getVecAt:(GLfloat)index
{
    GLKVector3 vec;
    NSValue *val = [self.knots objectAtIndex:index];
    [val getValue:&vec];
    //NSLog(@"Vector at %g: (%g,%g)", index, vec.x, vec.y);
    return vec;
}

- (GLKVector3) evalAt:(GLfloat)x withExtrapolation:(BOOL)extrapolation
{
    if ([self.knots count] < 4) {
        // Error
        NSLog(@"Cannot evaluate spline with fewer than 4 knots.");
        return GLKVector3Make(0.0f, 0.0f, 0.0f);
    }
    
    // If x is an invalid value, return 0 too;
    if (isnan(x)) {
        NSLog(@"Cannot evalulate spline at an invalid parameter:(%g)", x);
        return GLKVector3Make(0.0f, 0.0f, 0.0f);
    }
    
    if (extrapolation) {
        if (x < 0.0f) {
            return GLKVector3Add([self evalAt:0.0f withExtrapolation:FALSE],
                                 GLKVector3MultiplyScalar([self evalDerivAt:0],x));
        } else if (x > 1.0f) {
            return GLKVector3Add([self evalAt:1.0f withExtrapolation:FALSE],
                                 GLKVector3MultiplyScalar([self evalDerivAt:1], (x-1.0f)));
        }
    }
    
    FGLKSplineKnotInfo ki = [self getKnotAt:x];
    size_t i = ki.t;
    x = ki.val;
    
    GLKVector4 c = [self evalCoeffsAt:x];
    
    // No operator overloading, so we break this up to make it readable
    GLKVector3 wVec = GLKVector3MultiplyScalar([self getVecAt:i], c.w);
    GLKVector3 xVec = GLKVector3MultiplyScalar([self getVecAt:i+1], c.x);
    GLKVector3 yVec = GLKVector3MultiplyScalar([self getVecAt:i+2], c.y);
    GLKVector3 zVec = GLKVector3MultiplyScalar([self getVecAt:i+3], c.z);
    
    return GLKVector3Add(GLKVector3Add(GLKVector3Add(zVec, yVec), xVec), wVec);
}

- (GLKVector3) evalDerivAt:(GLfloat)x
{
    if ([self.knots count] < 4) {
        // Error
        NSLog(@"Cannot evaluate spline with fewer than 4 knots.");
        return GLKVector3Make(0.0f, 0.0f, 0.0f);
    }
    
    // If x is an invalid value, return 0 too;
    if (isnan(x)) {
        NSLog(@"Cannot evalulate spline at an invalid parameter:(%g)", x);
        return GLKVector3Make(0.0f, 0.0f, 0.0f);
    }
    
    GLfloat bs = [self getBasisScale];
    
    FGLKSplineKnotInfo ki = [self getKnotAt:x];
    size_t i = ki.t;
    x = ki.val;
    
    GLKVector4 c = GLKVector4MultiplyScalar([self evalDerivCoeffsAt:x],bs);
    
    // No operator overloading, so we break this up to make it readable
    GLKVector3 wVec = GLKVector3MultiplyScalar([self getVecAt:i], c.w);
    GLKVector3 xVec = GLKVector3MultiplyScalar([self getVecAt:i+1], c.x);
    GLKVector3 yVec = GLKVector3MultiplyScalar([self getVecAt:i+2], c.y);
    GLKVector3 zVec = GLKVector3MultiplyScalar([self getVecAt:i+3], c.z);
    
    return GLKVector3Add(GLKVector3Add(GLKVector3Add(zVec, yVec), xVec), wVec);
}

@end
