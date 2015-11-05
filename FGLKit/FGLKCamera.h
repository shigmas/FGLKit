//
//  FGLKCamera.h
//  FGLKit
//
//  Created by Masa Jow on 4/29/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


@class FGLKFrustum;

// This isn't tied to OpenGL ES, but closely enough that we'll put it in this
// library.
@interface FGLKCamera : NSObject

- (id)initWithPosition:(GLKVector3) position lookingAt:(GLKVector3)lookingAt;

- (GLKMatrix4)projectionMatrix;

- (GLKMatrix4)setPerspectiveWidth:(GLfloat)width height:(GLfloat)height
                         fovAngle:(GLfloat)fov
                             near:(GLfloat)near far:(GLfloat)far;

- (GLKMatrix4)setOrthographicLeft:(GLfloat)left right:(GLfloat)right
                           bottom:(GLfloat)bottom top:(GLfloat)top
                             near:(GLfloat)near far:(GLfloat)far;

- (GLfloat)nearPlane;
- (GLfloat)farPlane;

// like getters for up, position, etc. properties.
- (GLKVector3)forward;
- (GLKVector3)right;

// Switches to the different project if the properties are set.  If they
// aren't set, FALSE is returned;
- (BOOL)setToPerspective;
- (BOOL)setToOrthographic;

// Set a destination for the camera.  Used with incrementToDestination
- (void)setDestinationPosition:(GLKVector3)position up:(GLKVector3)up;

// Moves to the destination by increment, which is from 0.0 (at start) to
// 1.0 (destination).
- (void)moveToDestinationByIncrement:(GLfloat)increment;

- (GLKVector3)alignPositionWithAxis:(GLKVector3)axis;

// If we are going to transition, we can get the destination vectors
- (void)getXAlignPosition:(GLKVector3 *)position up:(GLKVector3 *)up;
- (void)getYAlignPosition:(GLKVector3 *)position up:(GLKVector3 *)up;
- (void)getZAlignPosition:(GLKVector3 *)position up:(GLKVector3 *)up;

- (void)getViewHeight:(float *)height width:(float *)width
              atDepth:(float)depth;

// Creates a quad of a square with total size of size around the
// center
- (void)getPickQuad:(GLKVector3 *)points
            atPoint:(GLKVector3)center
          pickWidth:(GLfloat)width
         pickHeight:(GLfloat)height;

- (void)getPickRay:(GLKVector3 *)points
           atPoint:(CGPoint)pickPoint;

- (FGLKFrustum *)getFrustum;

// In a simple sceeen, this point could just be the distance from the top left
// corner.  But, we don't depend on that in the general sense, so we pass in
// the pick point in NDC.
- (FGLKFrustum *)getPickFrustum:(CGPoint)pickPoint withPickSize:(GLfloat)size;

- (GLKMatrix4)modelViewTransform;

- (GLKMatrix4)cameraTransform;

- (float) aspect;
- (void) roll:(CGFloat) angle;
- (void) rotateYAngle:(CGFloat)yAng xAngle:(CGFloat)xAng
               zAngle:(CGFloat)zAng;
// Deprecated
- (void) rotateXZAngle:(CGFloat)xzAng YZAngle:(CGFloat)yzAng;

- (void) zoom:(CGFloat)increment;

// Get the height or width.  If perspective, distance is not relevant.
// For perspective, distance is from the camera, and we'll use the
// field of view angle
- (float)getHeightAt:(float)distance;
- (float)getWidthAt:(float)distance;

@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 lookAt;
@property (nonatomic) GLKVector3 up;

@property (nonatomic) BOOL didUpdate;
@property (nonatomic) BOOL isPerspective;
@end
