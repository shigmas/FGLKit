//
//  FGLKTypes.h
//  FGLKit
//
//  Created by Masa Jow on 4/29/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

#ifndef not
#define not !
#endif

#ifndef or
#define or ||
#endif

#ifndef and
#define and &&
#endif

#define DEG_TO_RAD(x) x*M_PI/180.0f

/// Possibly loosely packed structure to send to the
/// Vertex Buffer.  In practice, we'll probably be concerned
/// about space, and have a custom one that doesn't have every
/// possible parameter.
typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector4 color;
    GLKVector2 texture;
} FGLKPrimVertex;

typedef NS_ENUM(NSInteger, FGLKDrawMode)  {
    FGLKWireFrameMode,
    FGLKSolidMode,
    FGLKTextureMode,
    FGLKNormalMode,
};

// This, of course, is based on the camera.  So, we take this as the
// camera in the positive Z axis, looking towards the origin.  The "standard"
// orientation.
typedef NS_ENUM(NSInteger, FGLKCorner) {
    FGLKLowerRightCorner,
    FGLKLowerLeftCorner,
    FGLKUpperLeftCorner,
    FGLKUpperRightCorner,
};

typedef NS_ENUM(NSInteger, FGLKFrustumType) {
    FGLKPerspectiveFrustum,
    FGLKOrthographicFrustum,
    FGLKPickFrustum,
};

typedef NS_ENUM(NSInteger, FGLKFrustumPlanePointIndex) {
    FGLKFrustumTopRight = 0,
    FGLKFrustumTopLeft,
    FGLKFrustumBottomRight,
    FGLKFrustumBottomLeft,
};

//
typedef NS_OPTIONS(NSUInteger, FGLKVertexAttributeFlag) {
    FGLKVertexNoneAttribute     = 0,
    FGLKVertexPositionAttribute = 1 << 0,
    FGLKVertexColorAttribute    = 1 << 1,
    FGLKVertexNormalAttribute   = 1 << 2,
    FGLKVertexTextureAttribute  = 1 << 3,
};

void fglDebug(NSString *prefix);

void fglPreDebug(NSString *function);
void fglPostDebug(NSString *function);

/// Debugging GL
#define fglBindBuffer(...) {        \
    fglPreDebug(@"glBindBuffer");   \
    glBindBuffer(__VA_ARGS__);      \
    fglPostDebug(@"glBindBuffer");  \
}

#define fglDrawArrays(...) {         \
    fglPreDebug(@"glDrawArrays");    \
    glDrawArrays(__VA_ARGS__);       \
    fglPostDebug(@"fglDrawArrays");  \
}

#define fglDeleteBuffers(...) {        \
    fglPreDebug(@"glDeleteBuffers");   \
    glDeleteBuffers(__VA_ARGS__);      \
    fglPostDebug(@"glDeleteBuffers");  \
}

#define fglBufferData(...) {        \
    fglPreDebug(@"glBufferData");   \
    glBufferData(__VA_ARGS__);      \
    fglPostDebug(@"glBufferData");  \
}
