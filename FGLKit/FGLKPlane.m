//
//  FGLKPlane.m
//  FGLKit
//
//  Created by Masa Jow on 7/10/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKPlane.h"

@implementation FGLKPlane

- (id)initWithPointA:(GLKVector3)v0 pointB:(GLKVector3)v1 pointC:(GLKVector3)v2
{
    if ((self = [super init]) != nil) {
        GLKVector3 aux0, aux1;

        aux0 = GLKVector3Subtract(v1, v0);
        aux1 = GLKVector3Subtract(v2, v0);
        
        self.normal = GLKVector3Normalize(GLKVector3CrossProduct(aux0, aux1));
        self.point = v2;

        self.d = -GLKVector3DotProduct(self.normal, self.point);
    }
    
    return self;
}

- (GLfloat)distanceFromPlane:(GLKVector3)point
{
    return (self.d + GLKVector3DotProduct(self.normal, point));
}

@end
