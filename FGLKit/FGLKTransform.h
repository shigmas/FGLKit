//
//  FGLKTransform.h
//  FGLKit
//
//  Created by Masa Jow on 6/5/15.
//  Copyright (c) 2015 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FGLKTransformMode) {
    // asymptotic, fast in the beginning
    FGLKTransformLog10Mode,
    // asymptotic, slow in the beginning
    FGLKTransformLog10InverseMode,
    // Curve, with a peak, and then levels out again
    FGLKTransformAtanMode,
    // traditional bell curve
    FGLKTransformGaussianMode,
};

// Set a limit that we never reach.
@interface FGLKTransform : NSObject

+ (instancetype)transformWithOutputMin:(double)outputMin
                             outputMax:(double)outputMax
                              inputMin:(double)inputMin
                              inputMax:(double)inputMax
                             deviation:(double)deviation
                                method:(FGLKTransformMode)mode;

// Creates a "transformer".  For input, we'll produce an output.  The mode
// also dictates whether or not it's a curve or an asymptote.
// XXX - atm, this expects input min to be 0.
- (instancetype)initWithOutputMin:(double)outputMin
                        outputMax:(double)outputMax
                         inputMin:(double)inputMin
                         inputMax:(double)inputMax
                        deviation:(double)deviation
                           method:(FGLKTransformMode)mode;

- (double)transformValue:(double)val;

@end
