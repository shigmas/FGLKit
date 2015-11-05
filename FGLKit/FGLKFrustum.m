//
//  FGLKFrustum.m
//  FGLKit
//
//  Created by Masa Jow on 7/9/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKFrustum.h"

#import "FGLKFaceVertices.h"
#import "FGLKPlane.h"
#import "FGLKTypes.h"

typedef enum
{
    FGLKFrustumNearTopRight = 0,
    FGLKFrustumNearTopLeft,
    FGLKFrustumNearBottomRight,
    FGLKFrustumNearBottomLeft,
    FGLKFrustumFarTopRight,
    FGLKFrustumFarTopLeft,
    FGLKFrustumFarBottomRight,
    FGLKFrustumFarBottomLeft,
} FGLKFrustumPointIndex;

typedef enum
{
    FGLKFrustumNearPlane = 0,
    FGLKFrustumFarPlane,
    FGLKFrustumTopPlane,
    FGLKFrustumBottomPlane,
    FGLKFrustumLeftPlane,
    FGLKFrustumRightPlane,
} FGLKFrustumPlaneIndex;

@interface FGLKFrustum()

// perspective and orthographic planes
- (void) setPlanePoints:(GLKVector3 *)pointsArray
            rightNormal:(GLKVector3)right upNormal:(GLKVector3)up
                 center:(GLKVector3)center
                  width:(GLfloat)width height:(GLfloat)height;

// Perspective pick frustum
- (void) setPlanePoints:(GLKVector3 *)pointsArray
                 origin:(GLKVector3)origin
               fovAngle:(GLfloat)fov
            aspectRatio:(GLfloat)aspect
          forwardNormal:(GLKVector3)forward upNormal:(GLKVector3)up
            rightNormal:(GLKVector3)right
     distanceFromCamera:(GLfloat)distance
              pickPoint:(GLKVector2)pickPoint pickSize:(GLfloat)size;

// Orthographic frustum
/*
- (void)setPlanePoints:(GLKVector3 *)pointsArray
    currentPlanePoints:(GLKVector3 *)planePoints
             pickPoint:(GLKVector2)pickPoint
              pickSize:(GLfloat)size;
*/

@property (nonatomic) FGLKFrustumType frustumType;

@end

@implementation FGLKFrustum {
    GLKVector3 _position;
    GLKVector3 _lookAt;
    GLfloat _near;
    GLfloat _far;
    GLfloat _fov;
    GLfloat _width;
    GLfloat _height;
    
    GLKVector3 _points[8];
    NSArray *_planes;
}


- initWithWidth:(GLfloat)width height:(GLfloat)height fovAngle:(GLfloat)fov
         nearDistance:(GLfloat)near farDistance:(GLfloat)far
               origin:(GLKVector3)position lookingAt:(GLKVector3)lookAt
             upVector:(GLKVector3)up
{
    if ((self = [super init]) != nil) {
        _position = position;
        _lookAt = lookAt;
        _near = near;
        _far = far;
        _fov = fov;
        _width = width;
        _height = height;
        
        GLKVector3 dirNormal = [self getDirectionNormalFromPosition:position
                                                             lookAt:lookAt];
        GLKVector3 rightNormal = [self getRightNormalFromUp:up
                                                  dirNormal:dirNormal];
        GLKVector3 upNormal = GLKVector3Normalize(up);
        GLfloat aspect = width/height;
        GLfloat halfHeight;
        GLKVector3 center;
        // Set the four points at the near plane
        halfHeight = [self getHeightFromDistance:near angle:fov];
        center = GLKVector3Add(position,
                               GLKVector3MultiplyScalar(dirNormal, near));
        [self setPlanePoints:&_points[FGLKFrustumNearTopRight]
                 rightNormal:rightNormal upNormal:upNormal
                      center:center
                       width:halfHeight*width height:halfHeight];

        // Set the four points at the far plane
        halfHeight = [self getHeightFromDistance:far angle:fov];
        center = GLKVector3Add(position,
                               GLKVector3MultiplyScalar(dirNormal, far));
        
        [self setPlanePoints:&_points[FGLKFrustumFarTopRight]
                 rightNormal:rightNormal upNormal:upNormal
                      center:center
                       width:halfHeight*aspect height:halfHeight];
        
        _planes = [self buildPlanesFromPoints:_points];
        
        self.frustumType = FGLKPerspectiveFrustum;
    }
    
    return self;
}

// This is just a rhomboid
- initWithWidth:(GLfloat)width height:(GLfloat)height
            near:(GLfloat)near far:(GLfloat)far
          origin:(GLKVector3)position lookingAt:(GLKVector3)lookAt
        upVector:(GLKVector3)up
{
    if ((self = [super init]) != nil) {
        _position = position;
        _lookAt = lookAt;
        _near = near;
        _far = far;
        _width = width;
        _height = height;
        GLKVector3 dirNormal = [self getDirectionNormalFromPosition:position
                                                             lookAt:lookAt];
        GLKVector3 rightNormal = [self getRightNormalFromUp:up
                                                  dirNormal:dirNormal];
        GLKVector3 upNormal = GLKVector3Normalize(up);

        GLKVector3 center;
        // Set the four points at the near plane
        center = GLKVector3Add(position,
                               GLKVector3MultiplyScalar(dirNormal, near));        
        [self setPlanePoints:&_points[FGLKFrustumNearTopRight]
                 rightNormal:rightNormal upNormal:upNormal
                      center:center
                       width:width*.5f height:height*.5f];
        // Set the four points at the far plane
        center = GLKVector3Add(position,
                               GLKVector3MultiplyScalar(dirNormal, far));
        [self setPlanePoints:&_points[FGLKFrustumFarTopRight]
                 rightNormal:rightNormal upNormal:upNormal
                      center:center
                       width:width*.5f height:height*.5f];
        
        _planes = [self buildPlanesFromPoints:_points];
        self.frustumType = FGLKOrthographicFrustum;
    }
    
    return self;
}

- initForPerspectivePickWidth:(GLfloat)width height:(GLfloat)height
                     fovAngle:(GLfloat)fov
                 nearDistance:(GLfloat)near farDistance:(GLfloat)far
                       origin:(GLKVector3)position
                    lookingAt:(GLKVector3)lookAt upVector:(GLKVector3)up
                    pickPoint:(GLKVector2)pick
                     pickSize:(GLfloat)size
{
    if ((self = [super init]) != nil) {
        _position = position;
        _lookAt = lookAt;
        _near = near;
        _far = far;
        _fov = fov;
        _width = width;
        _height = height;
        
        GLfloat aspect = width/height;
        
        GLKVector3 fwNormal = [self getDirectionNormalFromPosition:position
                                                             lookAt:lookAt];
        GLKVector3 rightNormal = [self getRightNormalFromUp:up
                                                  dirNormal:fwNormal];
        GLKVector3 upNormal = GLKVector3Normalize(up);

        // So, grab the four points with the two normals, and the other data
        // for the near place
        [self setPlanePoints:&_points[FGLKFrustumNearTopRight]
                      origin:_position
                    fovAngle:fov aspectRatio:aspect
               forwardNormal:fwNormal upNormal:upNormal rightNormal:rightNormal
          distanceFromCamera:near pickPoint:pick pickSize:size];
        [self setPlanePoints:&_points[FGLKFrustumFarTopRight]
                      origin:_position
                    fovAngle:fov aspectRatio:aspect
               forwardNormal:fwNormal upNormal:upNormal rightNormal:rightNormal
          distanceFromCamera:far*.90f pickPoint:pick pickSize:size];

        _planes = [self buildPlanesFromPoints:_points];
        self.frustumType = FGLKPickFrustum;
    }
    
    return self;
}

- initForOrthographicPickOrigin:(GLKVector3)position
                          width:(GLfloat)width height:(GLfloat)height
                   nearDistance:(GLfloat)near farDistance:(GLfloat)far
                      lookingAt:(GLKVector3)lookAt upVector:(GLKVector3)up
                      pickPoint:(GLKVector2)pick
                       pickSize:(GLfloat)size
{
    if ((self = [self init]) != nil) {
        _position = position;
        _lookAt = lookAt;
        _near = near;
        _far = far;
        _width = width;
        _height = height;
        
        float widthOff = width*0.5f;
        float heightOff = height*0.5f;

        // All the same for the frustum we're picking in .
        GLKVector3 fwNormal = [self getDirectionNormalFromPosition:position
                                                            lookAt:lookAt];
        GLKVector3 rightNormal = [self getRightNormalFromUp:up
                                                  dirNormal:fwNormal];
        GLKVector3 upNormal = GLKVector3Normalize(up);

        // Convert NDC to our camera "units"
        GLKVector3 rightPick =
            GLKVector3MultiplyScalar(rightNormal, widthOff*pick.x);
        GLKVector3 upPick =
            GLKVector3MultiplyScalar(upNormal, heightOff*pick.y);
        
        GLKVector3 center =
            GLKVector3Add(_position,
                          GLKVector3MultiplyScalar(fwNormal, _near));
        GLKVector3 frustCenter =  
            GLKVector3Add(center, GLKVector3Add(rightPick, upPick));
        
        [self setPlanePoints:&_points[FGLKFrustumNearTopRight]
                 rightNormal:rightNormal
                    upNormal:upNormal
                      center:frustCenter
                       width:size*0.5f height:size*0.5f];
        center = GLKVector3Add(_position,
                               GLKVector3MultiplyScalar(fwNormal, _far));
        
        frustCenter = GLKVector3Add(center, GLKVector3Add(rightPick, upPick));
        [self setPlanePoints:&_points[FGLKFrustumFarTopRight]
                 rightNormal:rightNormal
                    upNormal:upNormal
                      center:frustCenter
                       width:size*0.5f height:size*0.5f];
        _planes = [self buildPlanesFromPoints:_points];
        self.frustumType = FGLKPickFrustum;
    }
    return self;
}

// Not declared in the interface.
- initWithPoints:(GLKVector3 *)points andPlanes:(NSArray *)planes
        withType:(FGLKFrustumType)frustumType
{
    if ((self = [super init]) != nil) {
        memcpy(_points,points, sizeof(GLKVector3)*8);
        _planes = planes;
        _frustumType = frustumType;
    }
    
    return self;
}

- (FGLKFrustum *)getPickFrustum:(GLKVector2)pick pickSize:(GLfloat)size
{
    GLKVector3 points[8];
    GLKVector3 fwNormal = [self getDirectionNormalFromPosition:_position
                                                        lookAt:_lookAt];
    // The near and far planes are parallel, so we can use the same up normal
    GLKVector3 upNormal =
        GLKVector3Normalize(GLKVector3Subtract(_points[FGLKFrustumTopLeft],
                                               _points[FGLKFrustumBottomLeft]));
    // The right pointing normal.  Same for near and far.
    GLKVector3 rightNormal =
    GLKVector3Normalize(GLKVector3Subtract(_points[FGLKFrustumTopRight],
                                           _points[FGLKFrustumTopLeft]));
    GLfloat aspect = _width/_height;
    
    if (self.frustumType == FGLKPerspectiveFrustum) {
        // So, grab the four points with the two normals, and the other
        // data for the near place
        [self setPlanePoints:&points[FGLKFrustumNearTopRight]
                      origin:_position
                    fovAngle:_fov aspectRatio:aspect
               forwardNormal:fwNormal
                    upNormal:upNormal rightNormal:rightNormal
          distanceFromCamera:_near pickPoint:pick pickSize:size];
        [self setPlanePoints:&points[FGLKFrustumFarTopRight]
                      origin:_position
                    fovAngle:_fov aspectRatio:aspect
               forwardNormal:fwNormal upNormal:upNormal
                 rightNormal:rightNormal
          distanceFromCamera:_far*.90f pickPoint:pick pickSize:size];
    } else if (self.frustumType == FGLKOrthographicFrustum) {
        GLKVector3 center;
        float widthOff = _width*0.5f;
        float heightOff = _height*0.5f;
        GLKVector3 rightPick = GLKVector3MultiplyScalar(rightNormal,
                                                         widthOff*pick.x);
        GLKVector3 upPick = GLKVector3MultiplyScalar(upNormal,
                                                     heightOff*pick.y);
        
        // Set the four points at the near plane
        center = GLKVector3Add(_position,
                               GLKVector3MultiplyScalar(fwNormal, _near));
        GLKVector3 frustCenter = GLKVector3Add(center, GLKVector3Add(rightPick, upPick));
        [self setPlanePoints:&points[FGLKFrustumNearTopRight]
                 rightNormal:rightNormal upNormal:upNormal
                      center:frustCenter
                       width:size*.5f height:size*.5f];
        // Set the four points at the far plane
        center = GLKVector3Add(_position,
                               GLKVector3MultiplyScalar(fwNormal, _far));
        frustCenter = GLKVector3Add(center, GLKVector3Add(rightPick, upPick));
        [self setPlanePoints:&points[FGLKFrustumFarTopRight]
                 rightNormal:rightNormal upNormal:upNormal
                      center:frustCenter
                       width:size*.5f height:size*.5f];
    }
    return [[FGLKFrustum alloc]
            initWithPoints:points
                 andPlanes:[self buildPlanesFromPoints:points]
                  withType:FGLKPickFrustum];
}

- (void)printPoints
{
    NSLog(@"Near: (%.2f,%.2f,%.2f), (%.2f,%.2f,%.2f), (%.2f,%.2f,%.2f), (%.2f,%.2f,%.2f)",
          _points[0].x, _points[0].y, _points[0].z,
          _points[1].x, _points[1].y, _points[1].z,
          _points[2].x, _points[2].y, _points[2].z,
          _points[3].x, _points[3].y, _points[3].z);
    NSLog(@"Far: (%.2f,%.2f,%.2f), (%.2f,%.2f,%.2f), (%.2f,%.2f,%.2f), (%.2f,%.2f,%.2f)",
          _points[4].x, _points[4].y, _points[4].z,
          _points[5].x, _points[5].y, _points[5].z,
          _points[6].x, _points[6].y, _points[6].z,
          _points[7].x, _points[7].y, _points[7].z);

}

- (NSArray *)getPoints
{
    return [[NSArray alloc] initWithObjects:
            [NSValue value:&_points[0] withObjCType:@encode(GLKVector3)],
            [NSValue value:&_points[1] withObjCType:@encode(GLKVector3)],
            [NSValue value:&_points[2] withObjCType:@encode(GLKVector3)],
            [NSValue value:&_points[3] withObjCType:@encode(GLKVector3)],
            [NSValue value:&_points[4] withObjCType:@encode(GLKVector3)],
            [NSValue value:&_points[5] withObjCType:@encode(GLKVector3)],
            [NSValue value:&_points[6] withObjCType:@encode(GLKVector3)],
            [NSValue value:&_points[7] withObjCType:@encode(GLKVector3)],
            nil];
}

- (BOOL)isPointInFrustum:(GLKVector3)point
{
    return [self isPointInFrustum:point withTransform:GLKMatrix4Identity];
}

- (BOOL)isPointInFrustum:(GLKVector3)point withTransform:(GLKMatrix4)transform
{
    BOOL result = TRUE;
    GLKVector3 transformedPoint = GLKMatrix4MultiplyVector3(transform, point);
    for (int i = 0 ; i < 6 ; ++i) {
        FGLKPlane *plane = [_planes objectAtIndex:i];
        GLfloat distance = [plane distanceFromPlane:transformedPoint];
        if (distance > 0) {
            // we're outside the plane.
            result = FALSE;
            //NSLog(@"Outside: %g", distance);
            break;

        }
    }
    
    // Went through all planes and we're inside.
    return result;
}

- (BOOL)isFaceInFrustum:(NSArray *)verts
{
    GLKMatrix4 id = GLKMatrix4Make(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f,
                                   0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f,
                                   0.0f, 0.0f, 0.0f, 1.0f);
    return [self isFaceInFrustum:verts withTransform:id];
}

- (BOOL)isFaceInFrustum:(NSArray *)verts withTransform:(GLKMatrix4)transform
{
    int inFrust;
    int outFrust;
    int inPlanes = 0;
    BOOL intersect = FALSE;

    for (int i = 0 ; i < 6 ; ++i) {
        inFrust = 0;
        outFrust = 0;
        
        FGLKPlane *plane = [_planes objectAtIndex:i];
        // for each vertex in the face do ...
		// get out of the cycle as soon as a box as corners
		// both inside and out of the frustum
		for (int k = 0; k < [verts count] && (inFrust==0 || outFrust==0);
             k++) {
            GLKVector3 point;
            NSValue *val = [verts objectAtIndex:k];
            [val getValue:&point];
            point = GLKMatrix4MultiplyVector3(transform, point);
            GLfloat distance = [plane distanceFromPlane:point];
            if (distance < 0) {
                outFrust++;
            } else {
                inFrust++;
            }
        }
        if (inFrust == 0) {
            // everything was on one side (outside) of this plane.  so
            // definitely outside the frustum
            return FALSE;
        } else if (outFrust) {
            // point was inside at least one plane, so there's some
            // some intersection
            intersect = TRUE;
        } else {
            inPlanes++;
        }
    }
    
    // There was *some* intersection with more than one plane.  So, we'll
    // just say that there *was* an intersection.  There's a case where this
    // isn't true, but we'll let it go for now.
    return intersect or (inPlanes == 6);
}

- (GLfloat)getHeightFromDistance:(GLfloat)near angle:(GLfloat)fov
{
    // from tan(alpha) = opp/adj;
    GLfloat angle = DEG_TO_RAD(fov)/2.0f;
    return tanf(angle)*near;
}

- (GLKVector3)getDirectionNormalFromPosition:(GLKVector3)position
                                      lookAt:(GLKVector3)lookAt
{
    GLKVector3 dirVector = GLKVector3Subtract(lookAt, position);
    return GLKVector3Normalize(dirVector);
}

- (GLKVector3)getRightNormalFromUp:(GLKVector3)up
                         dirNormal:(GLKVector3)direction
{
    return GLKVector3Normalize(GLKVector3CrossProduct(direction, up));
}

// perspective frustum constructor
- (void) setPlanePoints:(GLKVector3 *)pointsArray
            rightNormal:(GLKVector3)right upNormal:(GLKVector3)up
                 center:(GLKVector3)center
                  width:(GLfloat)width height:(GLfloat)height
{
    // temporary Vectors:
    GLKVector3 upVector = GLKVector3MultiplyScalar(up, height);
    GLKVector3 rightVector = GLKVector3MultiplyScalar(right, width);
    
    GLKVector3 topCenter = GLKVector3Add(center, upVector);
    
    pointsArray[FGLKFrustumTopRight] = GLKVector3Add(topCenter,
                                                     rightVector);
    pointsArray[FGLKFrustumTopLeft] = GLKVector3Subtract(topCenter,
                                                         rightVector);
    GLKVector3 bottomCenter = GLKVector3Subtract(center, upVector);
    pointsArray[FGLKFrustumBottomRight] = GLKVector3Add(bottomCenter,
                                                        rightVector);
    pointsArray[FGLKFrustumBottomLeft] = GLKVector3Subtract(bottomCenter,
                                                            rightVector);
}


- (GLKVector3)getPointFromForward:(GLKVector3)forward
                               up:(GLKVector3)up
                            right:(GLKVector3)right
                            width:(GLfloat)width
                           height:(GLfloat)height
{
    GLKVector3 pickUp = GLKVector3MultiplyScalar(up, height);
    GLKVector3 pickWidth = GLKVector3MultiplyScalar(right, width);
    
    return GLKVector3Add(forward, GLKVector3Add(pickUp, pickWidth));
}

// Perspective pick frustum
- (void) setPlanePoints:(GLKVector3 *)pointsArray
                 origin:(GLKVector3)origin
               fovAngle:(GLfloat)fov
            aspectRatio:(GLfloat)aspect
          forwardNormal:(GLKVector3)forward upNormal:(GLKVector3)up
            rightNormal:(GLKVector3)right
     distanceFromCamera:(GLfloat)distance
              pickPoint:(GLKVector2)pickPoint pickSize:(GLfloat)size
{
    // Get the actual height and width
    GLfloat height = [self getHeightFromDistance:distance angle:fov];
    GLfloat width = height*aspect;

    // Get our real hxwxd w/ the normals
    GLKVector3 dirVec = GLKVector3Add(origin, GLKVector3MultiplyScalar(forward, distance));
    GLKVector3 upVec = GLKVector3MultiplyScalar(up, height);
    GLKVector3 rightVec = GLKVector3MultiplyScalar(right, width);

    pointsArray[FGLKFrustumTopRight] =
        [self getPointFromForward:dirVec
                               up:upVec
                            right:rightVec
                            width:pickPoint.x + size
                           height:pickPoint.y + size];
    pointsArray[FGLKFrustumTopLeft] =
        [self getPointFromForward:dirVec
                               up:upVec
                            right:rightVec
                            width:pickPoint.x - size
                           height:pickPoint.y + size];
    pointsArray[FGLKFrustumBottomRight] =
        [self getPointFromForward:dirVec
                               up:upVec
                            right:rightVec
                            width:pickPoint.x + size
                           height:pickPoint.y - size];
    pointsArray[FGLKFrustumBottomLeft] =
        [self getPointFromForward:dirVec
                               up:upVec
                            right:rightVec
                            width:pickPoint.x - size
                           height:pickPoint.y - size];
}

/*
 - (void)setPlanePoints:(GLKVector3 *)pointsArray
    currentPlanePoints:(GLKVector3 *)planePoints
             pickPoint:(GLKVector2)pickPoint pickSize:(GLfloat)size
{
    // These vectors go from the top left corner
    GLKVector3 topToMid = GLKVector3DivideScalar(
         GLKVector3Subtract(planePoints[FGLKFrustumTopRight],
                            planePoints[FGLKFrustumTopLeft]), 2.0);
    GLKVector3 leftToMid = GLKVector3DivideScalar(
         GLKVector3Subtract(planePoints[FGLKFrustumBottomLeft],
                            planePoints[FGLKFrustumTopLeft]), 2.0);

    pointsArray[FGLKFrustumTopRight] =
        GLKVector3Add(GLKVector3MultiplyScalar(topToMid, pickPoint.x+size),
                      GLKVector3MultiplyScalar(leftToMid, pickPoint.y-size));
    pointsArray[FGLKFrustumTopLeft] =
    GLKVector3Add(GLKVector3MultiplyScalar(topToMid, pickPoint.x-size),
                  GLKVector3MultiplyScalar(leftToMid, pickPoint.y-size));
    pointsArray[FGLKFrustumBottomRight] =
    GLKVector3Add(GLKVector3MultiplyScalar(topToMid, pickPoint.x+size),
                  GLKVector3MultiplyScalar(leftToMid, pickPoint.y+size));
    pointsArray[FGLKFrustumBottomLeft] =
    GLKVector3Add(GLKVector3MultiplyScalar(topToMid, pickPoint.x-size),
                  GLKVector3MultiplyScalar(leftToMid, pickPoint.y+size));
}
*/

- (NSArray *)buildPlanesFromPoints:(GLKVector3 *)pointsArray
{
    // Shortcut to build near and far planes:
    FGLKPlane *nearPlane =
    [[FGLKPlane alloc] initWithPointA:pointsArray[FGLKFrustumNearTopRight]
                               pointB:pointsArray[FGLKFrustumNearTopLeft]
                               pointC:pointsArray[FGLKFrustumNearBottomRight]];
    FGLKPlane *farPlane =
    [[FGLKPlane alloc] initWithPointA:pointsArray[FGLKFrustumFarBottomLeft]
                               pointB:pointsArray[FGLKFrustumFarTopLeft]
                               pointC:pointsArray[FGLKFrustumFarBottomRight]];
    FGLKPlane *topPlane =
    [[FGLKPlane alloc] initWithPointA:pointsArray[FGLKFrustumFarTopLeft]
                               pointB:pointsArray[FGLKFrustumNearTopLeft]
                               pointC:pointsArray[FGLKFrustumFarTopRight]];
    FGLKPlane *bottomPlane =
    [[FGLKPlane alloc] initWithPointA:pointsArray[FGLKFrustumFarBottomRight]
                               pointB:pointsArray[FGLKFrustumNearBottomRight]
                               pointC:pointsArray[FGLKFrustumFarBottomLeft]];
    FGLKPlane *leftPlane =
    [[FGLKPlane alloc] initWithPointA:pointsArray[FGLKFrustumFarBottomLeft]
                               pointB:pointsArray[FGLKFrustumNearBottomLeft]
                               pointC:pointsArray[FGLKFrustumFarTopLeft]];
    FGLKPlane *rightPlane =
    [[FGLKPlane alloc] initWithPointA:pointsArray[FGLKFrustumFarBottomRight]
                               pointB:pointsArray[FGLKFrustumFarTopRight]
                               pointC:pointsArray[FGLKFrustumNearBottomRight]];
    
    return [[NSArray alloc] initWithObjects:nearPlane, farPlane, topPlane,                bottomPlane, leftPlane, rightPlane, nil];

}

- (BOOL)isDirty
{
    return TRUE;
}

#pragma FGLKPointSource protocol
// Generates points to create a wire frame
- (NSArray *)getPoints:(GLenum)mode
{
    // each line segment will be draw, regardless of mode.  This means
    // 8 points per face, and 6 faces.  But, we only need to do front
    // and back, and the 4 lines connecting the two faces.
    // 
    return
        [[NSArray alloc] initWithObjects:
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearTopRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearTopLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearTopLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearBottomLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearBottomLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearBottomRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearBottomRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearTopRight]
                               objCType:@encode(GLKVector3)],

         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarTopRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarTopLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarTopLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarBottomLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarBottomLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarBottomRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarBottomRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarTopRight]
                               objCType:@encode(GLKVector3)],

         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearTopRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarTopRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarBottomRight]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearBottomRight]
                               objCType:@encode(GLKVector3)],

         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearTopLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarTopLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumFarBottomLeft]
                               objCType:@encode(GLKVector3)],
         [[NSValue alloc] initWithBytes:&_points[FGLKFrustumNearBottomLeft]
                               objCType:@encode(GLKVector3)],
         nil];
}


@end
