//
//  FGLKProgram.h
//  FGLKit
//
//  Created by Masa Jow on 5/10/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

// Usage:
// 1. init
// 2. compile
// 3. bind attribs
// 4. link
// 5. get uniforms

@interface FGLKProgram : NSObject

- (id)initWithVertexShaderName:(NSString *)vertexFileName
            fragmentShaderName:(NSString *)fragmentFileName;

- (BOOL)compile;

- (void)bindAttributes:(NSDictionary *)indexNames;

- (BOOL)link;

- (NSArray *)getUniformsForNames:(NSArray *)names;

- (void)setActive;

@property (nonatomic, strong) NSString *vertexShaderName;
@property (nonatomic, strong) NSString *fragmentShaderName;

@end
