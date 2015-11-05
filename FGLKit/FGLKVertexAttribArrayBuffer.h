//
//  FGLKVertexAttribArrayBuffer.h
//  FGLKit
//
//  Created by Masa Jow on 4/29/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

/// Helper to the GLKit's wrapper on OpenGL ES
/// Stolen from ALKAttribeArrayBuffer from OpenGL ES on iOS
@interface FGLKVertexAttribArrayBuffer : NSObject

/// Submits the drawing command specified by \p mode and instructs
/// OpenGL ES to use \p count vertices from previous prepared buffers
/// starting from the vertex at index \p first in the prepared buffers.
+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;

/// Creates a vertex attribute array buffer in the current
/// OpenGL ES context for the thread upon which this method
/// is called
- (id)initWithAttribStride:(GLsizeiptr)stride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

- (void)freeBuffer;

/// Setups up the OpenGL ES state to perpare for drawing.  Binds the
/// buffer and configures the pointers.
- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

/// Retrieves the buffer data that we sent in init (or reinit)
- (void)getBufferData:(const GLvoid *)dataPtr;

/// Submits the drawing command specified by \p mode and instructs
/// OpenGL ES to use \p count vertices from the buffer starting from
/// the vertex at index \p first.
- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first;

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
           endVertexIndex:(GLint)last;

- (void)reinitWithAttribStride:(GLsizeiptr)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;

@property (nonatomic) GLsizei numVertices;

@end
