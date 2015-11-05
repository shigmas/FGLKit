//
//  FGLKFrustum.h
//  FGLKit
//
//  Created by Masa Jow on 7/9/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

#import "FGLKPointSource.h"

@class FGLKFaceVertices;

// A Frustum object.
@interface FGLKFrustum : NSObject
<FGLKPointSource>

// Used for perspective cameras
// aspect: x/y
- initWithWidth:(GLfloat)width height:(GLfloat)height fovAngle:(GLfloat)fov
         nearDistance:(GLfloat)near farDistance:(GLfloat)far
               origin:(GLKVector3)position lookingAt:(GLKVector3)lookAt
             upVector:(GLKVector3)up;

// This is just a rhomboid
- initWithWidth:(GLfloat)width height:(GLfloat)height
            near:(GLfloat)near far:(GLfloat)far
          origin:(GLKVector3)position lookingAt:(GLKVector3)lookAt
        upVector:(GLKVector3)up;

// Pick Frustum is slice of space in the camera viewing area.  This version
// creates it in the perspective projection.  We could create it from an
// existing frustum, but we also want to be able to create it from scratch
- initForPerspectivePickWidth:(GLfloat)width height:(GLfloat)height
                     fovAngle:(GLfloat)fov
                 nearDistance:(GLfloat)near farDistance:(GLfloat)far
                       origin:(GLKVector3)position
                    lookingAt:(GLKVector3)lookAt upVector:(GLKVector3)up
                    pickPoint:(GLKVector2)pick
                     pickSize:(GLfloat)size;

- initForOrthographicPickOrigin:(GLKVector3)position
                          width:(GLfloat)width height:(GLfloat)height
                   nearDistance:(GLfloat)near farDistance:(GLfloat)far
                      lookingAt:(GLKVector3)lookAt upVector:(GLKVector3)up
                      pickPoint:(GLKVector2)pick
                       pickSize:(GLfloat)size;

// If we already have a frustum, we can get a slice of that.
- (FGLKFrustum *)getPickFrustum:(GLKVector2)pickPoint pickSize:(GLfloat)size;

- (void)printPoints;

- (NSArray *)getPoints;

- (BOOL)isPointInFrustum:(GLKVector3)point;
- (BOOL)isPointInFrustum:(GLKVector3)point withTransform:(GLKMatrix4)transform;
- (BOOL)isFaceInFrustum:(NSArray *)face;
- (BOOL)isFaceInFrustum:(NSArray *)face withTransform:(GLKMatrix4)transform;

//- (BOOL)isInFrustum:(other thingies)

@end
