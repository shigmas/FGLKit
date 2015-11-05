//
//  FGLKPrim.h
//  FGLKit
//
//  Created by Masa Jow on 4/29/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "FGLKPrimContainer.h"
#import "FGLKTypes.h"

@class FGLKVertexAttribArrayBuffer;

// Prims represent a graphic primitive, which may be one
// Vertex Buffer Object, or multiple buffer objects.  But, it will
// generally represent one object on the screen.
//
// There are three steps to draw a prim:
// Steps 1 and 2 might be done in the update cycle of a
// GLKViewController.  3 is done in the draw cycle for the GLKView's
// delegate.
// 1. preparePrim/initializePrim (initializePrim if not being used with
//    a Scene.  Scenes aren't strictly necessary, but can provide a
//    context.
// 2. updateTransform.  This can be to update the effect with the scene's
//    transform or use its own effect.
// 3. draw: actually draws the prim.  This will call setBufferToDraw to
//    bind the prims buffer(s) and the call drawArrays

@interface FGLKPrim : NSObject

@property (nonatomic) BOOL useVertexArray;

@property (nonatomic) BOOL updateVertices;

@property (nonatomic) BOOL selected;

// array of FGLKVertexAttribArrayBuffer's
@property (nonatomic, strong) NSArray *vertexBuffers;

@property (nonatomic, weak) GLKBaseEffect *effect;

// For transformable prims, we can set this flag, and then we'll
// use the center and scale when _updateTransform is called.  Note
// that, if _updateTransform is overridden
@property (nonatomic) BOOL transformable;
// For non-projection prims.
@property (nonatomic) BOOL followProjection;
// Turn on the light for this prim.
@property (nonatomic) BOOL isPrimLit;

@property (nonatomic) GLKMatrix4 transform;
@property (nonatomic) GLKMatrix4 projection;

@property (nonatomic) GLKVector4 color;
@property (nonatomic) GLKVector4 selectedColor;

@property (nonatomic) GLKVector3 center;
@property (nonatomic) GLKVector3 scale;

// Draw the normals.  If normals are available.  (It will use the
// normals exist.  If this is true, the prim container will do a second
// draw pass on the prim.
@property (nonatomic) BOOL drawNormals;


- (id)init;

- (id)initAsVertexArray:(BOOL)useVertexArray;

- (void)preparePrimForMode:(FGLKDrawMode)drawMode;

- (void)setBufferToDraw:(FGLKVertexAttribArrayBuffer *)buffer
                atIndex:(GLsizei)index
               withMode:(FGLKDrawMode)mode;

// Called during update so we can update the VBO's for the updating
// vertices
- (void)updateBuffersForMode:(FGLKDrawMode)drawMode;

- (void)updateEffect:(GLKBaseEffect *)effect;

- (void)prepareEffectToDraw;

- (void)drawWithMode:(FGLKDrawMode)drawMode;

@property (nonatomic, strong) GLKTextureInfo *textureInfo;
@property (nonatomic, strong) GLKEffectPropertyTexture *texture;


@end
