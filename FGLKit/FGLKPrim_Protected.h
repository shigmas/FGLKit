//
//  FGLKPrim_Protected.h
//  FGLKit
//
//  Created by Masa Jow on 7/28/14.
//  Copyright (c) 2014 Futomen. All rights reserved.
//

#import <FGLKit/FGLKit.h>

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface FGLKPrim (ForSubclassEyesOnly)

// determines the vertices to be used to create the VBO for the
// given index.
- (BOOL)_getVertices:(FGLKPrimVertex **)vertices
           withCount:(GLsizei *)numPoints
         forDrawMode:(FGLKDrawMode)drawMode
      forBufferIndex:(GLsizei)bufferIndex;

// Custom code for the subclass after the normal setBufferToDraw
// has been done.  For instance, if we have normals...
- (void)_setBufferToDraw:(FGLKVertexAttribArrayBuffer *)buffer
                 atIndex:(GLsizei)index
                withMode:(FGLKDrawMode)mode;

// Custom code for the subclass after the normal setBufferToDraw
// has been done
- (void)_initializePrimForBuffer:(GLsizei)bufferIndex;

// Returns the number of vertex buffers in this prim.  Often, just
// one.  Override if there are more.
- (GLsizei)_getNumBuffers;

- (void)_updateBuffersForDrawMode:(FGLKDrawMode)drawMode;

// Prepares the effect to draw.  This set the appropriate GLKEffect
// or similar GLSL code as current.  If we're just using a GLKEffect,
// no need to override.  But, if we have some shaders, we definitely
// need to override.
- (void)_updateEffect:(GLKBaseEffect *)effect;

// Actually draw the buffer.  This uses the GL_LINE mode by default, so
// override this if we have triangles, etc.
- (void)_drawBuffer:(FGLKVertexAttribArrayBuffer *)buffer
            atIndex:(GLsizei)index
           withMode:(FGLKDrawMode)drawMode;

@property (nonatomic, readonly) GLsizeiptr positionOffset;
@property (nonatomic, readonly) GLsizeiptr normalOffset;
@property (nonatomic, readonly) GLsizeiptr colorOffset;
@property (nonatomic, readonly) GLsizeiptr textureOffset;

// Helper functions

// Property that is allocated and populated by the _textureFromImage.
- (GLKTextureInfo *)_createTextureInfoFromImageName:(NSString *)imageName;
- (GLKEffectPropertyTexture *)_textureFromTexInfo:(GLKTextureInfo *)texInfo;

// Allocate the memory for verts.  One of those where we need to manually
// allocate memory.
- (BOOL)_allocateVertices:(FGLKPrimVertex **)verts
                numPoints:(GLsizei)num;


- (GLKVector3)_getNormalVec1:(GLKVector3)vec1
                        vec2:(GLKVector3)vec2
                        vec3:(GLKVector3)vec3;

- (void)_setTextureValues:(FGLKPrimVertex *)vertices
           forNumVertices:(NSInteger)numVerts
               isTriStrip:(BOOL)isTriStrip;

// Populate a quad PrimVertices with the specified data.  The flag
// attribs indicates which attributes of the FGLKPrimVertex we populate.
// e.g. If only FGLKVertexPositionAttribute is set, we just copy the
// posVertices into the position attributes.  
- (void)_populateQuadVertices:(FGLKPrimVertex *)vertices
                forAttributes:(FGLKVertexAttributeFlag)attribs
              asTriangleStrip:(BOOL)asTriStrip
                 withVertices:(GLKVector3 *)posVertices
                    withColor:(GLKVector4)colorVertex;

@end
