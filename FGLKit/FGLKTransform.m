//
//  FGLKTransform.m
//  FGLKit
//
//  Created by Masa Jow on 6/5/15.
//  Copyright (c) 2015 Futomen. All rights reserved.
//

#import "FGLKTransform.h"

@interface FGLKTransform()

@property (nonatomic) double outputMin;
@property (nonatomic) double outputMax;

@property (nonatomic) double inputMin;
@property (nonatomic) double inputMax;

@property (nonatomic) double deviation;
@property (nonatomic) FGLKTransformMode mode;

@property (nonatomic) double modeFactor;

@end

@implementation FGLKTransform

// Returns a number between 0 and 1 to be applied to the min/max.
- (double)_getValueForMode:(NSInteger)value
{
    double transform;
    switch(self.mode) {
        case FGLKTransformLog10Mode:
            transform = log10(1+value);
            return transform / log10(self.inputMax);
        case FGLKTransformLog10InverseMode:
            // This returns a number between 0 and log10(self.inputMax)
            transform = -1.0/log10(self.inputMax) - log10(1 + self.inputMax - value);
            return transform / log10(self.inputMax);
        case FGLKTransformAtanMode:
            transform = M_PI/2.0 + atan(value - self.inputMax/2.0);
            return transform / M_PI;
        case FGLKTransformGaussianMode:
            transform = 1.0 / self.deviation * sqrt(2*M_PI) * pow(M_E, -1*pow(value-self.inputMax,2)/2.0) / 2.0*self.deviation*self.deviation;
            return transform / self.deviation; // or something
    }
}

+ (instancetype)transformWithOutputMin:(double)outputMin
                             outputMax:(double)outputMax
                              inputMin:(double)inputMin
                              inputMax:(double)inputMax
                             deviation:(double)deviation
                                method:(FGLKTransformMode)mode
{
    return [[FGLKTransform alloc] initWithOutputMin:outputMin
                                          outputMax:outputMax
                                           inputMin:inputMin
                                           inputMax:inputMax
                                             deviation:deviation
                                             method:mode];
}

// Creates a "transformer".  For input, we'll produce an output.
// Limitation: we only go positive.  If you want negative, you should do it
// in the caller
- (instancetype)initWithOutputMin:(double)outputMin
                        outputMax:(double)outputMax
                         inputMin:(double)inputMin
                         inputMax:(double)inputMax
                        deviation:(double)deviation
                           method:(FGLKTransformMode)mode;
{
    if ((self = [super init]) != nil) {
        // some parameter checking
        if (!((outputMin < outputMax) && (inputMin < inputMax))) {
            NSLog(@"Invalid parameters");
            return self;
        }
        if ((mode == FGLKTransformGaussianMode) &&
            (deviation == 0.0)) {
                NSLog(@"Missing deviation required for mode");
                return self;
        }
        self.outputMin = outputMin;
        self.outputMax = outputMax;
        self.inputMin = inputMin;
        self.inputMax = inputMax;
        
        self.mode = mode;
    }
    
    return self;
}

- (double)transformValue:(double)val
{
    if ((val > self.inputMax) || (val < self.inputMin)) {
        return -1;
    }
    double output = [self _getValueForMode:val];
    double diff = self.outputMax - self.outputMin;
    return output * diff + self.outputMin;
}

@end
