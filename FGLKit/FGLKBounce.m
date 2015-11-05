//
//  FGLKBounce.m
//  FGLKit
//
//  Created by Masa Jow on 6/6/15.
//  Copyright (c) 2015 Futomen. All rights reserved.
//

#import "FGLKBounce.h"

#include <math.h>

@interface FGLKBounce()

@property (nonatomic) double startHeight;
@property (nonatomic) double startVelocity;
@property (nonatomic) double acceleration;
@property (nonatomic) double coefOfRestitution;

// Seconds when we hit the ground, and the velocity until then
@property (nonatomic) NSMutableDictionary *bounceVelocities;
@property (nonatomic) NSMutableArray *bounceTimes;

- (void)_preFillBounceData;

@end

@implementation FGLKBounce

- (instancetype)initAt:(double)startHeight
         startVelocity:(double)startVelocity
          acceleration:(double)accel
        cOfRestitution:(double)coef
{
    if ((self = [super init]) != nil) {
        self.startHeight = startHeight;
        self.startVelocity = startVelocity;
        accel = accel > 0 ? -1.0 * accel : accel;
        self.acceleration = accel;
        self.coefOfRestitution = coef;
        
        [self _preFillBounceData];
    }
    
    return self;
}

// Note that not sampling often enough will result in just returning a 0.
// If you're not sampling often enough, you won't see the bounce anyway.
- (double)getHeightAtTime:(double)time
{
    // since we'll be calling this repeatedly with incrementing time, we should
    // keep a counter.  (We should also have a method that calculates the
    // bounces over an interval...)
    double velocity = 0.0;
    double lastTime = 0.0;
    NSInteger counter;
    for (counter = 0 ; counter < self.bounceTimes.count ;
         ++counter) {
        NSNumber* storedSec = self.bounceTimes[counter];
        if (time < storedSec.doubleValue) {
            counter--;
            break;
        }
        NSNumber *storedVel = self.bounceVelocities[storedSec];
        velocity = storedVel.doubleValue;
        lastTime = storedSec.doubleValue;
    }
    if (counter == self.bounceTimes.count) {
        return -1.0;
    }
    double startHeight = counter == 0 ? self.startHeight : 0;
    double sinceCycle = time - lastTime;
    return startHeight + velocity * sinceCycle + 0.5 * self.acceleration * sinceCycle * sinceCycle;
}

double _getCycleTime(double startHeight, double initV,
                     double accel)
{
    if (accel > 0) {
        NSLog(@"Acceleration is positive.  Bounce will not end.");
        return -1;
    }
    double t = sqrt(pow(initV/accel, 2) - 2*startHeight/accel) - initV/accel;
    return t;
}

- (void)_preFillBounceData
{
    self.bounceTimes = [[NSMutableArray alloc] init];
    self.bounceVelocities = [[NSMutableDictionary alloc] init];
    double velocity = self.startVelocity;
    double runTime = 0.0;
    
    // first is just a drop, and we start with zero velocity
    NSNumber *sec = @0.0;
    [self.bounceTimes addObject:sec];
    self.bounceVelocities[sec] = [NSNumber numberWithDouble:self.startVelocity];

    // Stop when our bounce is 5% of when we dropped.  Using our standard
    // s = s0 + vt + 1/2at^2, solving for t, we get:
    // t = ((v/a)^2 - 2*s0/a)^1/2 - v/a
    // start high, so we run this at least once.
    double cycleTime = 500.0;
    while (cycleTime > 0.3) {
        // break up the lines for readability
        if (velocity == self.startVelocity) {
            // First iteration.  velocity is actually negative.
            cycleTime = _getCycleTime(self.startHeight, -1*velocity,
                                     self.acceleration);
        } else {
            cycleTime = _getCycleTime(0, velocity, self.acceleration);
        }
        sec = [NSNumber numberWithDouble:runTime += cycleTime];
        [self.bounceTimes addObject:sec];
        if (velocity == self.startVelocity) {
            velocity = (velocity + -1.0 * (self.acceleration * cycleTime)) *
            self.coefOfRestitution;
        } else {
            // previous velocity * coef
            velocity = velocity * self.coefOfRestitution;
        }
        NSNumber *vNum = [NSNumber numberWithDouble:velocity];
        self.bounceVelocities[sec] = vNum;
    }
}

@end
