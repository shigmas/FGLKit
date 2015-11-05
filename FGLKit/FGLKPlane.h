//
//  FGLKPlane.h
//  FGLKit
//
//  Created by Masa Jow on 7/10/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

@interface FGLKPlane : NSObject

@property (nonatomic) GLKVector3 normal;
@property (nonatomic) GLKVector3 point;
@property (nonatomic) GLfloat d;

/// Initializes the plane with an array of 3 points.  We want the normal to
/// be facing in the right way (i.e. the plane 
- (id)initWithPointA:(GLKVector3)v1 pointB:(GLKVector3)v2
              pointC:(GLKVector3) v3;

/// with a given definition of the plane (by the 3 points), which define
/// a normal, this can be negative.  Useful for determining which side of the
/// plane the point is on.
- (GLfloat)distanceFromPlane:(GLKVector3)point;

@end
