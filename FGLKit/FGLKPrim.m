//
//  FGLKPrim.m
//  FGLKit
//
//  Created by Masa Jow on 4/29/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKPrim.h"

#import "FGLKPrim_Protected.h"

#import "FGLKTypes.h"
#import "FGLKVertexAttribArrayBuffer.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES3/gl.h>

@interface FGLKPrim()

// Protected methods to be implemented by subclasses

// property override to re-initialize the prim
- (void)setUseVertexArray:(BOOL)useVertexArray;

@property (nonatomic) GLKVector4 defaultColor;

// The FGLKPrimVertex quasi-constants (every compile)
@property (nonatomic, readwrite) GLsizeiptr positionOffset;
@property (nonatomic, readwrite) GLsizeiptr normalOffset;
@property (nonatomic, readwrite) GLsizeiptr colorOffset;
@property (nonatomic, readwrite) GLsizeiptr textureOffset;

@end

@implementation FGLKPrim
{
    BOOL _useVertexArray;
    GLuint _vertexArrayID;
    CGImageRef _currentTextureImage;
}


- (id)init
{
    return [self initAsVertexArray:NO];
}

- (id)initAsVertexArray:(BOOL)useVertexArray;
{
    if ((self = [super init]) != nil) {
        self.positionOffset = offsetof(FGLKPrimVertex, position);
        self.normalOffset = offsetof(FGLKPrimVertex, normal);
        self.colorOffset = offsetof(FGLKPrimVertex, color);
        self.textureOffset = offsetof(FGLKPrimVertex, texture);
        self.selected = NO;
        self.useVertexArray = NO;
        //self.updateVertices = FALSE; Why is this false - we should do this first, right?
        self.updateVertices = YES;
        self.transformable = NO;
        self.followProjection = YES;

        self.transform = GLKMatrix4Identity;
        self.projection = GLKMatrix4Identity;
        self.drawNormals = NO;
        
        self.defaultColor = GLKVector4Make(1.0f, // Red
                                           0.36f, // Green
                                           0.0f, // Blue
                                           1.0f);// Alpha0.0, 0.0, 0.0, 0.0);
        // Don't use the setters!
        _color = self.defaultColor;
        _selectedColor = _color;

        // avoid the setters
        _center = GLKVector3Make(0.0, 0.0, 0.0);
        _scale = GLKVector3Make(1.0, 1.0, 1.0);
    }
    
    return self;
}

- (void)setUseVertexArray:(BOOL)useVertexArray
{
    _useVertexArray = useVertexArray;
}

- (void)setColor:(GLKVector4)color
{
    _color = color;
    if (GLKVector4AllEqualToVector4(_selectedColor, self.defaultColor))
        _selectedColor = color;
}

- (void)setSelectedColor:(GLKVector4)color
{
    _selectedColor = color;
}

- (void)setCenter:(GLKVector3)center
{
    _center = center;
    // Set it back to zero, and then translate again
    self.transform = GLKMatrix4MakeScale(self.scale.x,
                                         self.scale.y,
                                         self.scale.z);
    self.transform = GLKMatrix4TranslateWithVector3(self.transform,
                                                    self.center);
    self.transformable = YES;
}

- (void)setScale:(GLKVector3)scale
{
    _scale = scale;
    // Set it back to zero, and then translate again
    self.transform = GLKMatrix4MakeTranslation(self.center.x,
                                               self.center.y,
                                               self.center.z);
    self.transform = GLKMatrix4ScaleWithVector3(self.transform,
                                                self.scale);
    self.transformable = YES;
}

- (void)dealloc
{
    if (_useVertexArray)
        glDeleteVertexArrays(1, &_vertexArrayID);
    if (_currentTextureImage) {
        CGImageRelease(_currentTextureImage);
    }
    for (FGLKVertexAttribArrayBuffer *b in self.vertexBuffers) {
        [b freeBuffer];
    }
    self.texture = nil;
    self.textureInfo = nil;
}

// (re)prepares this prim to be drawn for the drawMode.
- (void)preparePrimForMode:(FGLKDrawMode)drawMode
{
    FGLKPrimVertex *vertices = NULL;
    GLsizei numPoints = 0;

    GLsizei numBuffers = [self _getNumBuffers];
    
    // Clear out the old buffers
    self.vertexBuffers = nil;
    
    NSMutableArray *arrayBuffers =
        [[NSMutableArray alloc] initWithCapacity:numBuffers];
    for (int i = 0; i < numBuffers ; ++i) {
        [self _getVertices:&vertices
                 withCount:&numPoints
               forDrawMode:drawMode
            forBufferIndex:i];

        if (_useVertexArray) {
            glGenVertexArrays(1, &_vertexArrayID);
            glBindVertexArray(_vertexArrayID);
        }

        FGLKVertexAttribArrayBuffer *vertexBuffer =
            [[FGLKVertexAttribArrayBuffer alloc]
             initWithAttribStride:sizeof(FGLKPrimVertex)
                 numberOfVertices:numPoints
                            bytes:vertices
                            usage:GL_STATIC_DRAW];
        // Free the client side memory.
        free((void *)vertices);
        
        // If there's a texture, for example, load it.
        [self _initializePrimForBuffer:i];
    
        if (_useVertexArray) {
            [self setBufferToDraw:vertexBuffer atIndex:i withMode:drawMode];
            glBindVertexArray(0);
        }

        [arrayBuffers addObject:vertexBuffer];
    }
    
    self.vertexBuffers = [[NSArray alloc] initWithArray:arrayBuffers];
}

- (void)setBufferToDraw:(FGLKVertexAttribArrayBuffer *)buffer
                atIndex:(GLsizei)index
               withMode:(FGLKDrawMode)mode
{
    [buffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                numberOfCoordinates:3
                       attribOffset:self.positionOffset
                       shouldEnable:YES];
    [buffer prepareToDrawWithAttrib:GLKVertexAttribColor
                numberOfCoordinates:4
                       attribOffset:self.colorOffset
                       shouldEnable:YES];
    [self _setBufferToDraw:buffer atIndex:index withMode:mode];
}

- (void)updateBuffersForMode:(FGLKDrawMode)drawMode
{
    [self _updateBuffersForDrawMode:drawMode];
}

- (void)updateEffect:(GLKBaseEffect *)effect
{
    [self _updateEffect:effect];
}

- (void)prepareEffectToDraw
{
    if (!self.effect) {
        NSLog(@"prepareEffectToDraw with no effect!");
        return;
    }
    [self updateEffect:self.effect];   
    [self.effect prepareToDraw];
}

- (void)drawWithMode:(FGLKDrawMode)drawMode
{    for (int i = 0 ; i < [self.vertexBuffers count] ; ++i) {
        FGLKVertexAttribArrayBuffer *buffer =
            [self.vertexBuffers objectAtIndex:i];

        // Bind the buffer
        if (not _useVertexArray) {
            [self setBufferToDraw:buffer atIndex:i withMode:drawMode];
        } else {
            glBindVertexArray(_vertexArrayID);
        }
        [self.effect prepareToDraw];
        // Draw the array
        [self _drawBuffer:buffer atIndex:i withMode:drawMode];
    }
}

#pragma protected methods

- (BOOL)_getVertices:(FGLKPrimVertex **)vertices
           withCount:(GLsizei *)numPoints
         forDrawMode:(FGLKDrawMode)drawMode
      forBufferIndex:(GLsizei)bufferIndex
{
    NSAssert(TRUE,@"This method must be overridden");
    
    return FALSE;
}

- (void)_initializePrimForBuffer:(GLsizei)bufferIndex
{
    // override for custom initialization.
}

- (GLsizei)_getNumBuffers
{
    // Override if there is more than one buffer
    return 1;
}

- (void)_setBufferToDraw:(FGLKVertexAttribArrayBuffer *)buffer
                 atIndex:(GLsizei)index
                withMode:(FGLKDrawMode)mode
{
    // override for custom
}

- (void)_updateEffect:(GLKBaseEffect *)effect
{
    // This one overrides completely
    if (! self.followProjection) {
        effect.transform.projectionMatrix = self.projection;
    }
    
    // This one adds it to the existing.
    if (self.transformable) {
        effect.transform.modelviewMatrix =
        GLKMatrix4Multiply(effect.transform.modelviewMatrix,
                           self.transform);
    }

    if (self.texture) {
        effect.texture2d0.enabled = GL_TRUE;
        effect.texture2d0.envMode = self.texture.envMode;
        effect.texture2d0.name = self.texture.name;
        effect.texture2d0.target = self.texture.target;
    }
    
    if (self.isPrimLit) {
        effect.light0.enabled = GL_TRUE;
        if (self.selected) {
            effect.light0.diffuseColor = self.selectedColor;
        } else {
            effect.light0.diffuseColor = self.color;
        }
    }
}

- (void)_updateBuffersForDrawMode:(FGLKDrawMode)drawMode
{
    FGLKPrimVertex *vertices = NULL;
    GLsizei numPoints = 0;
    
    if (not self.updateVertices)
        return;
    
    for (int i = 0 ; i < [self.vertexBuffers count]; ++i) {
        FGLKVertexAttribArrayBuffer *buffer =
        [self.vertexBuffers objectAtIndex:i];
        
        [self _getVertices:&vertices
                 withCount:&numPoints
               forDrawMode:drawMode
            forBufferIndex:i];
        /*
         for (int i = 0 ; i < numPoints ; ++i) {
         NSLog(@"vert %i: (%g,%g,%g)", i,
         vertices[i].position.x,
         vertices[i].position.y,
         vertices[i].position.z);
         }
         */
        [buffer reinitWithAttribStride:sizeof(FGLKPrimVertex)
                      numberOfVertices:numPoints
                                 bytes:vertices];
        
        // Free the client side memory.
        free((void *)vertices);
    }
    self.updateVertices = NO;
}

- (void)_drawBuffer:(FGLKVertexAttribArrayBuffer *)buffer
            atIndex:(GLsizei)index
           withMode:(FGLKDrawMode)drawMode
{
    // Subclasses probably want to override
    [buffer drawArrayWithMode:GL_LINES startVertexIndex:0];
}

- (GLKTextureInfo *)_createTextureInfoFromImageName:(NSString *)imageName
{
    NSError *error;
    if (_currentTextureImage) {
        CGImageRelease(_currentTextureImage);
    }
    _currentTextureImage = [[UIImage imageNamed:imageName] CGImage];
    GLKTextureInfo *textInfo =
    [GLKTextureLoader textureWithCGImage:_currentTextureImage
                                 options:nil
                                   error:&error];
    if (error) {
        NSLog(@"Unable to create texture info: %@", error.localizedDescription);
    }

    return textInfo;
}

- (GLKEffectPropertyTexture *)_textureFromTexInfo:(GLKTextureInfo *)texInfo
{
    // Also, want better sampling here.
    GLKEffectPropertyTexture *texture = [[GLKEffectPropertyTexture alloc] init];
    //    texture.envMode = GLKTextureEnvModeReplace;
    texture.envMode = GLKTextureEnvModeDecal;
    texture.name = self.textureInfo.name;
    texture.target = GLKTextureTarget2D;
    
    return texture;
}

- (BOOL)_allocateVertices:(FGLKPrimVertex **)verts
                numPoints:(GLsizei)num
{
    *verts = (FGLKPrimVertex *)malloc(sizeof(FGLKPrimVertex)*(num));
    
    return (*verts) ? TRUE : FALSE;
}


// normal of vec2-vec1 x vec2-vec3
- (GLKVector3)_getNormalVec1:(GLKVector3)vec1
                        vec2:(GLKVector3)vec2
                        vec3:(GLKVector3)vec3
{
    GLKVector3 v1 = GLKVector3Subtract(vec2, vec1);
    GLKVector3 v2 = GLKVector3Subtract(vec3, vec1);
    GLKVector3 normal = GLKVector3Normalize(GLKVector3CrossProduct(v1, v2));
    
    return normal;
}

- (void)_setTextureValues:(FGLKPrimVertex *)vertices
           forNumVertices:(NSInteger)numVerts
               isTriStrip:(BOOL)isTriStrip
{
    
    if ((numVerts < 3) || (numVerts > 4))
        return;

    for (int i = 0 ; i < numVerts ; ++i) {
        // Strips have a different order
        switch (i) {
                // Textures apparently have different a coord system?
            case 0:
                vertices[i].texture = GLKVector2Make(1.0f, 1.0f);
                break;
            case 1:
                vertices[i].texture = GLKVector2Make(0.0f, 1.0f);
                break;
            case 2:
                if (isTriStrip) {
                    vertices[i].texture = GLKVector2Make(1.0f, 0.0f);
                } else {
                    vertices[i].texture = GLKVector2Make(0.0f, 0.0f);
                }
                break;
            case 3:
                if (isTriStrip) {
                    vertices[i].texture = GLKVector2Make(0.0f, 0.0f);
                } else {
                    vertices[i].texture = GLKVector2Make(1.0f, 0.0f);
                }
                break;
        }
    }

}

- (void)_populateQuadVertices:(FGLKPrimVertex *)vertices
                forAttributes:(FGLKVertexAttributeFlag)attribs
              asTriangleStrip:(BOOL)asTriStrip
                 withVertices:(GLKVector3 *)posVertices
                    withColor:(GLKVector4)colorVertex
{
    // a quad will share the same normal for all vertices
    int order[4];
    if (asTriStrip) {
        // Order for GL_TRIANGLE_STRIP
        order[0] = 0;
        order[1] = 1;
        order[2] = 3;
        order[3] = 2;
    } else {
        order[0] = 0;
        order[1] = 1;
        order[2] = 2;
        order[3] = 3;
    }

    if (attribs & FGLKVertexPositionAttribute) {
        for (int i = 0; i < 4; ++i) {
            vertices[i].position = posVertices[order[i]];
            if (attribs & FGLKVertexColorAttribute) {
                vertices[i].color = colorVertex;
            }
        }
    }

    if (attribs & FGLKVertexNormalAttribute) {
        // a quad will share the same normal for all vertices.  Done at the
        // end so we've already fetched the vertices from the array
        GLKVector3 normal1 = [self _getNormalVec1:vertices[2].position
                                             vec2:vertices[1].position
                                             vec3:vertices[0].position];
        normal1 = GLKVector3Negate(normal1);
        GLKVector3 normal2;
        if (asTriStrip) {
            normal2 = [self _getNormalVec1:vertices[3].position
                                      vec2:vertices[1].position
                                      vec3:vertices[2].position];
        } else {
            normal2 = [self _getNormalVec1:vertices[3].position
                                      vec2:vertices[1].position
                                      vec3:vertices[2].position];
        }
        normal2 = GLKVector3Negate(normal2);
    
        vertices[0].normal = normal1;
        vertices[1].normal = normal1;
        vertices[2].normal = normal2;
        vertices[3].normal = normal2;
    }

    if (attribs & FGLKVertexTextureAttribute) {
        [self _setTextureValues:vertices forNumVertices:4
                     isTriStrip:asTriStrip];
    }
}

@end
