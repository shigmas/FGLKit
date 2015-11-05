//
//  FGLKBounce.h
//  FGLKit
//
//  Created by Masa Jow on 6/6/15.
//  Copyright (c) 2015 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGLKBounce : NSObject

- (instancetype)initAt:(double)startHeight
         startVelocity:(double)startVelocity
          acceleration:(double)accel
        cOfRestitution:(double)coef;

- (double)getHeightAtTime:(double)time;

@property (nonatomic, readonly) double startHeight;
@property (nonatomic, readonly) double startVelocity;
@property (nonatomic, readonly) double acceleration;
@property (nonatomic, readonly) double coefOfRestitution;
@end
