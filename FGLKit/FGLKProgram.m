//
//  FGLKProgram.m
//  FGLKit
//
//  Created by Masa Jow on 5/10/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKProgram.h"

#import <GLKit/GLKit.h>
#import "FGLKTypes.h"

@interface FGLKProgram()

- (NSString *)getPath:(NSString *)fileName extension:(NSString *)ext;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type path:(NSString *)path;
- (BOOL)validate;

@end


@implementation FGLKProgram
{
    GLuint _programID;
    GLuint _vertexShaderID;
    GLuint _fragmentShaderID;
}

- (id)initWithVertexShaderName:(NSString *)vertexFileName
            fragmentShaderName:(NSString *)fragmentFileName
{
    if ((self = [super init]) != nil) {
        self.vertexShaderName = vertexFileName;
        self.fragmentShaderName = fragmentFileName;

        _programID = glCreateProgram();
    }
    
    return self;
}

- (void)dealloc
{
    glDeleteProgram(_programID);
}

- (NSString *)getPath:(NSString *)fileName extension:(NSString *)ext
{
    return [[NSBundle mainBundle] pathForResource:@"Shader" ofType:ext];

}

- (BOOL)compile
{
    NSString *vertexShaderPath = [self getPath:self.vertexShaderName
                                     extension:@"vsh"];
    NSString *fragmentShaderPath = [self getPath:self.fragmentShaderName
                                       extension:@"fsh"];
    
    if (not [self compileShader:&_vertexShaderID type:GL_VERTEX_SHADER
                           path:vertexShaderPath]) {
        NSLog(@"Compilation of %@ failed", vertexShaderPath);
        return FALSE;
    }
    
    if (not [self compileShader:&_fragmentShaderID type:GL_FRAGMENT_SHADER
                           path:fragmentShaderPath]) {
        NSLog(@"Compilation of %@ failed", fragmentShaderPath);
        return FALSE;
    }
    
    glAttachShader(_programID, _vertexShaderID);
    glAttachShader(_programID, _fragmentShaderID);
    
    return TRUE;
}

- (void)bindAttributes:(NSDictionary *)indexNames
{
    NSEnumerator *enu = [indexNames keyEnumerator];
    NSNumber *indexKey;
    while (indexKey = [enu nextObject]) {
        int index = [indexKey intValue];
        NSString *val = [indexNames objectForKey:indexKey];
        glBindAttribLocation(_programID,
                             index,
                             [val cStringUsingEncoding: NSASCIIStringEncoding]);
    }
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type path:(NSString *)path
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)link
{
    GLint status;
    glLinkProgram(_programID);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(_programID, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_programID, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(_programID, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (NSArray *)getUniformsForNames:(NSArray *)names;
{
    NSMutableArray *uniforms = [[NSMutableArray alloc] initWithCapacity:[names count]];

    for (int i = 0 ; i < [names count] ; ++i) {
        const char *name =
            [[names objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding];
        GLint uniform = glGetUniformLocation(_programID, name);
        [uniforms setObject:[NSNumber numberWithInt:uniform] atIndexedSubscript:i];
    }
    
    return uniforms;
}

- (void)setActive
{
    glUseProgram(_programID);
}

- (BOOL)validate
{
    GLint logLength, status;
    
    glValidateProgram(_programID);
    glGetProgramiv(_programID, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_programID, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(_programID, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
