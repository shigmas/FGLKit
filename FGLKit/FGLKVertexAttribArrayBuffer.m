//
//  FGLKVertexAttribArrayBuffer.m
//  FGLKit
//
//  Created by Masa Jow on 4/29/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKVertexAttribArrayBuffer.h"

#include "FGLKTypes.h"
#define DEBUG 1

@interface FGLKVertexAttribArrayBuffer ()

@property (nonatomic, assign) GLsizeiptr bufferSizeBytes;
@property (nonatomic, assign) GLsizeiptr stride;

@property (nonatomic) GLuint name;

@end

@implementation FGLKVertexAttribArrayBuffer

- (id)initWithAttribStride:(GLsizeiptr)aStride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage
{
    NSParameterAssert(0 < aStride);
    NSAssert((0 < count && NULL != dataPtr) ||
             (0 == count && NULL == dataPtr),
             @"data must not be NULL or count > 0");
    
    if (nil != (self = [super init])) {
        self.stride = aStride;
        self.bufferSizeBytes = _stride * count;
        self.numVertices =  count;
        glGenBuffers(1, &_name);
        glBindBuffer(GL_ARRAY_BUFFER, _name);
        
        // Copy the data into the buffer we just bound.
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, usage);
        NSAssert(0 != _name, @"Failed to generate name");
    }

    return self;
}

- (void)freeBuffer
{
    if (_name != 0) {
        glDeleteBuffers(1, &_name);
        self.name = 0;
    }
}

// Delete the buffers when we are deallocated
- (void)dealloc
{
    [self freeBuffer];
}

- (void)reinitWithAttribStride:(GLsizeiptr)aStride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr
{
    NSParameterAssert(0 < aStride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    NSAssert(0 != self.name, @"Invalid name");
    
    self.stride = aStride;
    self.bufferSizeBytes = aStride * count;
    
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    glBufferData(GL_ARRAY_BUFFER, self.bufferSizeBytes, dataPtr,
                 GL_DYNAMIC_DRAW);
}

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable
{
    // Vectors with dimensions between 1 and 4.
    NSParameterAssert((0 < count) && (count <= 4));
    NSParameterAssert(offset < self.stride);
    NSAssert(0 != self.name, @"Invalid name");
    
    // Bind this buffer
    GLint boundBuffer;
    glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &boundBuffer);
    if (boundBuffer != self.self.name)
        glBindBuffer(GL_ARRAY_BUFFER, _name);
    
    if (not shouldEnable) {
        glDisableVertexAttribArray(index);
        return;
    }
    
    glEnableVertexAttribArray(index);
    glVertexAttribPointer(index,          // Attribute to use
                          count,          // Number of coordinates for attribute
                          GL_FLOAT,       // data type
                          GL_FALSE,       // normalized (no fixed point scaling)
                          (int)self.stride,    // total num bytes per vertex
                          NULL + offset); // first coordinate for attribute
    
#ifdef DEBUG
    { // report any errors
        GLenum error = glGetError();
        if (GL_NO_ERROR != error) {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif
}

- (void)getBufferData:(const GLvoid *)dataPtr
{
}

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
{
    [self drawArrayWithMode:mode startVertexIndex:first
             endVertexIndex:self.numVertices];
}

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
           endVertexIndex:(GLint)last
{
    GLenum error = glGetError();
    if (GL_NO_ERROR != error) {
        NSLog(@"GL Error: 0x%x", error);
    }

    if (self.bufferSizeBytes < (last * self.stride)) {
        NSLog(@"Attempt to draw more vertex data than available: %ld, att: %ld",
              self.bufferSizeBytes, last*self.stride);
        return;
    }
    glDrawArrays(mode, first, last-first);
}

+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count
{
    glDrawArrays(mode, first, count);
}

@end
