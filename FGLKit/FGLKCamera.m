//
//  FGLKCamera.m
//  FGLKit
//
//  Created by Masa Jow on 4/29/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKCamera.h"

#import "FGLKFrustum.h"
#import "FGLKMath.h"
#import "FGLKTypes.h"

static const CGFloat revolution = 2*M_PI;

@interface FGLKPerspectiveProperties : NSObject

- (id)initWithWidth:(GLfloat)width
             height:(GLfloat)height
           fovAngle:(GLfloat)fov
          nearPlane:(GLfloat)near
           farPlane:(GLfloat)far;


@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat fovAngle;
@property (nonatomic) CGFloat nearPlane;
@property (nonatomic) CGFloat farPlane;

@end

@interface FGLKOrthographicProperties : NSObject

- (id)initWithLeft:(GLfloat)left
             right:(GLfloat)right
            bottom:(GLfloat)bottom
               top:(GLfloat)top
              near:(GLfloat)near
               far:(GLfloat)far;

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat nearPlane;
@property (nonatomic) CGFloat farPlane;

@end

@implementation FGLKPerspectiveProperties

- (id)initWithWidth:(GLfloat)width
             height:(GLfloat)height
           fovAngle:(GLfloat)fov
          nearPlane:(GLfloat)near
           farPlane:(GLfloat)far
{
    if ((self = [super init]) != nil) {
        self.width = width;
        self.height = height;
        self.fovAngle = fov;
        self.nearPlane = near;
        self.farPlane = far;
    }
    return self;
}

@end

@implementation FGLKOrthographicProperties

- (id)initWithLeft:(GLfloat)left
             right:(GLfloat)right
            bottom:(GLfloat)bottom
               top:(GLfloat)top
              near:(GLfloat)near
               far:(GLfloat)far
{
    if ((self = [super init]) != nil) {
        self.left = left;
        self.right = right;
        self.bottom = bottom;
        self.top = top;
        self.nearPlane = near;
        self.farPlane = far;
    }
    
    return self;
}

@end

@interface FGLKCamera()
{
    FGLKOrthographicProperties * _orthoProps;
    FGLKPerspectiveProperties *_perspProps;
    GLKMatrix4 _projectionMatrix;

    // For moving to a destination
    GLKVector3 _startPos;
    GLKVector3 _destPos;
    GLKVector3 _destUp;
    GLKVector3 _startUp;
    GLKVector3 _destStartVec;
    GLKVector3 _destEndNormal;
    // essentially, the radius
    float _distToLookAt;
    
    float _angleToDest;
}	

// cumulative rotation about the x-axis
@property (nonatomic) CGFloat xzRot;
// cumulative rotation about the y-axis
@property (nonatomic) CGFloat yzRot;
// cumulative roll of the camera (used for the up vector
@property (nonatomic) CGFloat roll;


// Removes the extra revolutions from the angle if it's over 2*M_PI
- (CGFloat)toRadians:(CGFloat)degrees withExisting:(CGFloat)existingRadians;

- (GLKVector3)alignPositionWithAxis:(GLKVector3)axis;

@end

@implementation FGLKCamera

- (id)initWithPosition:(GLKVector3)position lookingAt:(GLKVector3)lookingAt
{
    self = [super init];
    
    if (self) {
        self.position = position;
        self.lookAt = lookingAt;
        self.up = GLKVector3Make(0.0, 1.0, 0.0);
        
        // Initialize the two rotation angles
        self.xzRot = 0;
        self.yzRot = 0;
        
        self.didUpdate = TRUE;
    }
    
    return self;
}

- (GLKMatrix4)projectionMatrix
{
    return _projectionMatrix;
}


- (GLKMatrix4)setPerspectiveWidth:(GLfloat)width height:(GLfloat)height
                         fovAngle:(GLfloat)fov
                             near:(GLfloat)near far:(GLfloat)far
{
    _perspProps =
    [[FGLKPerspectiveProperties alloc] initWithWidth:width
                                              height:height
                                            fovAngle:fov
                                           nearPlane:near
                                            farPlane:far];

    [self setToPerspective];
    
    return _projectionMatrix;
}

- (GLKMatrix4)setOrthographicLeft:(GLfloat)left right:(GLfloat)right
                           bottom:(GLfloat)bottom top:(GLfloat)top
                             near:(GLfloat)near far:(GLfloat)far
{
    _orthoProps =
    [[FGLKOrthographicProperties alloc] initWithLeft:left
                                               right:right
                                              bottom:bottom
                                                 top:top
                                                near:near
                                                 far:far];

    [self setToOrthographic];
    return _projectionMatrix;
}

- (BOOL)setToPerspective
{
    if (!_perspProps)
        return FALSE;
    
    float aspect = fabs(_perspProps.width/_perspProps.height);
    _projectionMatrix =
    GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_perspProps.fovAngle),
                              aspect, _perspProps.nearPlane,
                              _perspProps.farPlane);
    
    self.didUpdate = TRUE;
    self.isPerspective = TRUE;

    return TRUE;
}

- (BOOL)setToOrthographic
{
    if (!_orthoProps)
        return FALSE;

    _projectionMatrix =
    GLKMatrix4MakeOrtho(_orthoProps.left, _orthoProps.right,
                        _orthoProps.bottom, _orthoProps.top,
                        _orthoProps.nearPlane, _orthoProps.farPlane);
    self.didUpdate = TRUE;
    self.isPerspective = FALSE;

    return TRUE;
}

- (GLfloat)nearPlane
{
    if (_orthoProps)
        return _orthoProps.nearPlane;
    else
        return _perspProps.nearPlane;

}
- (GLfloat)farPlane
{
    if (_orthoProps)
        return _orthoProps.farPlane;
    else
        return _perspProps.farPlane;
}

- (GLKVector3)forward
{
    // Get some of the vectors to create the quad
    return GLKVector3Normalize(GLKVector3Subtract(self.lookAt, self.position));
}

// Skips an extra subtraction and normalization.
- (GLKVector3)rightFromForward:(GLKVector3)forward
{
    return GLKVector3Normalize(GLKVector3CrossProduct(forward, self.up));
}

- (GLKVector3)right
{
    return [self rightFromForward:self.forward];
}

- (GLKMatrix4)modelViewTransform
{
    return
    GLKMatrix4MakeLookAt(self.position.x, self.position.y, self.position.z,
                         self.lookAt.x, self.lookAt.y, self.lookAt.z,
                         self.up.x, self.up.y, self.up.z);

}

- (GLKMatrix4)cameraTransform
{
    GLKMatrix4 transform = GLKMatrix4Identity;
    
    // I think the info is in the OpenGL super bible.  Each frame is a column.
    return transform;
}


- (void)setDestinationPosition:(GLKVector3)position up:(GLKVector3)up
{
    _startPos = self.position;
    _destPos = position;
    _startUp = self.up;
    _destUp = up;
    
    _destStartVec = GLKVector3Subtract(_destPos, _startPos);

    _distToLookAt = GLKVector3Distance(self.position, self.lookAt);
    float startToDest = GLKVector3Distance(position,
                                           self.position);
    _angleToDest = (asinf(startToDest/2/_distToLookAt))*2;
    //NSLog(@"angle to dest: %f", _angleToDest);
}

- (void)moveToDestinationByIncrement:(GLfloat)increment
{
    // Some math needs to be fixed here!!
    if (increment == 1.0) {
        self.position = _destPos;
        self.up = _destUp;
        self.didUpdate = TRUE;
/*
        NSLog(@"final pos (%g,%g,%g) up (%g,%g,%g",
              self.position.x, self.position.y, self.position.z,
              self.up.x, self.up.y, self.up.z);
*/
 return;
    }
    GLKVector3 incVec = GLKVector3MultiplyScalar(_destStartVec, increment);
    GLKVector3 posNorm =
        GLKVector3Normalize(GLKVector3Add(_startPos, incVec));
    
    self.position = GLKVector3MultiplyScalar(posNorm, _distToLookAt);
    self.up = GLKVector3Normalize(GLKVector3Lerp(_startUp, _destUp,
                                                 increment));
    self.didUpdate = TRUE;
}

- (GLKVector3)alignPositionWithAxis:(GLKVector3)axis
{
    float distance = GLKVector3Distance(self.lookAt, self.position);

    GLKVector3 offset =
        GLKVector3MultiplyScalar(GLKVector3Normalize(axis), distance);
    //NSLog(@"offset vector: (%g,%g,%g)", offset.x, offset.y, offset.z);
    GLKVector3 position = GLKVector3Add(offset, self.lookAt);
    //NSLog(@"position vector: (%g,%g,%g)", position.x, position.y, position.z);
    return position;
}

- (void)getXAlignPosition:(GLKVector3 *)position up:(GLKVector3 *)up
{
    *position = [self alignPositionWithAxis:GLKVector3Make(1.0f, 0.0f, 0.0f)];
    *up = GLKVector3Make(0.0f, 1.0f, 0.0f);
}

- (void)getYAlignPosition:(GLKVector3 *)position up:(GLKVector3 *)up
{
    *position = [self alignPositionWithAxis:GLKVector3Make(0.0f, 1.0f, 0.0f)];
    *up = GLKVector3Make(0.0f, 0.0f, 1.0f);
}

- (void)getZAlignPosition:(GLKVector3 *)position up:(GLKVector3 *)up
{
    // Open GL has positive Z pointing into the screen.  So, we set -1.0
    *position = [self alignPositionWithAxis:GLKVector3Make(0.0f, 0.0f, -1.0f)];
    *up = GLKVector3Make(0.0f, 1.0f, 0.0f);
}

- (void)getViewHeight:(float *)height width:(float *)width
              atDepth:(float)depth
{
    NSLog(@"getViewHeight no implementation");
}

- (void)getPickRay:(GLKVector3 *)points
           atPoint:(CGPoint)pickPoint
{
    // We work in GLKVectors from here
    GLKVector2 center = GLKVector2Make(pickPoint.x, pickPoint.y);
    if (self.isPerspective) {
        NSLog(@"PickRay not implemented");
        return;
    } else {
        GLfloat width = _orthoProps.right - _orthoProps.left;
        GLfloat height = _orthoProps.top - _orthoProps.bottom;
        
        points[0] = [FGLKMath getOrthoCameraPointFromScreen:center
                                                      depth:0
                                                camPosition:self.position
                                                  camFoward:self.forward
                                                      camUp:self.up
                                                   camRight:self.right
                                                   camWidth:width
                                                  camHeight:height];
        points[1] = [FGLKMath getOrthoCameraPointFromScreen:center
                                                      depth:self.farPlane
                                                camPosition:self.position
                                                  camFoward:self.forward
                                                      camUp:self.up
                                                   camRight:self.right
                                                   camWidth:width
                                                  camHeight:height];
    }
}

- (void)getPickQuad:(GLKVector3 *)points
            atPoint:(GLKVector3)center
          pickWidth:(GLfloat)width
         pickHeight:(GLfloat)height
{
    GLKVector3 forward = self.forward;

    [FGLKMath createQuad:points
                atCenter:center
               withWidth:width
              withHeight:height
             fromForward:forward
                  fromUp:self.up
               fromRight:[self rightFromForward:forward]];
}

- (FGLKFrustum *)getFrustum
{
    if (self.isPerspective) {
        return [[FGLKFrustum alloc] initWithWidth:_perspProps.width
                                           height:_perspProps.height
                                         fovAngle:_perspProps.fovAngle
                                     nearDistance:_perspProps.nearPlane
                                      farDistance:_perspProps.farPlane
                                            origin:self.position
                                        lookingAt:self.lookAt
                                         upVector:self.up];
    } else {
        GLfloat width = _orthoProps.right - _orthoProps.left;
        GLfloat height = _orthoProps.top - _orthoProps.bottom;
        return [[FGLKFrustum alloc] initWithWidth:width
                                           height:height
                                         fovAngle:0
                                     nearDistance:_orthoProps.nearPlane
                                      farDistance:_orthoProps.farPlane
                                           origin:self.position
                                        lookingAt:self.lookAt
                                         upVector:self.up];
        
    }
}

- (FGLKFrustum *)getPickFrustum:(CGPoint)pickPoint withPickSize:(GLfloat)size
{
    GLKVector2 point = GLKVector2Make(pickPoint.x,
                                      pickPoint.y);
    if (self.isPerspective) {
        return [[FGLKFrustum alloc]
                initForPerspectivePickWidth:_perspProps.width
                                     height:_perspProps.height
                                   fovAngle:_perspProps.fovAngle
                               nearDistance:_perspProps.nearPlane
                                farDistance:_perspProps.farPlane
                                     origin:self.position
                                  lookingAt:self.lookAt
                                   upVector:self.up
                                  pickPoint:point
                                   pickSize:size];
    } else {
        GLfloat width = _orthoProps.right - _orthoProps.left;
        GLfloat height = _orthoProps.top - _orthoProps.bottom;
        return [[FGLKFrustum alloc]
            initForOrthographicPickOrigin:self.position
                                    width:width
                                   height:height
                             nearDistance:_orthoProps.nearPlane
                              farDistance:_orthoProps.farPlane
                                lookingAt:self.lookAt
                                 upVector:self.up
                                pickPoint:point
                                 pickSize:size];
    }
}

- (float) aspect
{
    GLfloat width;
    GLfloat height;
    if (self.isPerspective) {
        width = _perspProps.width;
        height = _perspProps.height;
    } else {
        width = _orthoProps.right - _orthoProps.left;
        height = _orthoProps.top - _orthoProps.bottom;
    }
    
    return width/height;
}

- (void) roll:(CGFloat) angle
{
    self.roll = [self toRadians:angle withExisting:self.roll];
    GLKVector3 upVec = GLKVector3Make(sinf(self.roll),
                                      cosf(self.roll), self.up.z);
    self.up = GLKVector3Normalize(upVec);
    self.didUpdate = TRUE;
}

- (void) rotateYAngle:(CGFloat)yAng xAngle:(CGFloat)xAng
               zAngle:(CGFloat)zAng
{
    CGFloat yRad = [self toRadians:yAng withExisting:0.0f];
    CGFloat xRad = [self toRadians:xAng withExisting:0.0f];
    CGFloat zRad = [self toRadians:zAng withExisting:0.0f];

    // two angles of rotation, two quaternions
    GLKQuaternion yQuat =
    GLKQuaternionMakeWithAngleAndAxis(yRad, 0.0, 1.0f, 0.0f);
    GLKQuaternion xQuat =
    GLKQuaternionMakeWithAngleAndAxis(xRad, 1.0f, 0.0f, 0.0f);
    GLKQuaternion zQuat =
    GLKQuaternionMakeWithAngleAndAxis(zRad, 0.0f, 0.0f, 1.0f);

    // Rotate position (around look at) and up (which is relative to
    // origin)
    GLKVector3 posRel = GLKVector3Subtract(self.position, self.lookAt);

    posRel = GLKQuaternionRotateVector3(yQuat, posRel);
    posRel = GLKQuaternionRotateVector3(xQuat, posRel);
    posRel = GLKQuaternionRotateVector3(zQuat, posRel);
    self.position = GLKVector3Add(posRel, self.lookAt);

    self.up = GLKQuaternionRotateVector3(yQuat, self.up);
    self.up = GLKQuaternionRotateVector3(xQuat, self.up);
    self.up = GLKVector3Normalize(GLKQuaternionRotateVector3(zQuat, self.up));

    self.didUpdate = TRUE;

}

- (void) rotateXZAngle:(CGFloat)xzAng YZAngle:(CGFloat)yzAng
{
    return [self rotateYAngle:xzAng xAngle:yzAng zAngle:0];
}

- (void) zoom:(CGFloat)increment
{
    // Increase or decrease the distance to the look at point.
    CGFloat newDist = 1.0f + increment;
    
    GLKVector3 diff = GLKVector3Subtract(self.position, self.lookAt);
    diff = GLKVector3MultiplyScalar(diff, newDist);
    
    // Move the vector to the offset from the lookat
    self.position = GLKVector3Add(self.lookAt, diff);
    
    self.didUpdate = TRUE;
}

- (float)getHeightAt:(float)distance
{
    if (self.isPerspective) {
        return distance*tanf(_perspProps.fovAngle)*.5;
    } else {
        return (_orthoProps.top - _orthoProps.bottom)/2.0;
    }
}

- (float)getWidthAt:(float)distance
{
    if (self.isPerspective) {
        return [self getHeightAt:distance]*self.aspect;
    } else {
        return (_orthoProps.right - _orthoProps.left)/2.0;
    }

}

//
- (CGFloat)toRadians:(CGFloat)degrees withExisting:(CGFloat)existingRadians
{
    CGFloat resulting = DEG_TO_RAD(degrees) + existingRadians;
    
    if (fabs((double)resulting) < revolution)
        return resulting;
    
    CGFloat remainder = fmod(resulting, revolution);
    
    return remainder*revolution;
}

@end
