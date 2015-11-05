//
//  FGLKFaceVertices.h
//  FGLKit
//
//  Created by Masa Jow on 5/15/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

/// set of points.  2 is a line, 3 is a triangle, etc.
/// (Although, OpenGL ES only does triangles and lines.
@interface FGLKFaceVertices : NSObject

- (id)initWithIndices:(NSArray *)indices;

// Array of ints.
@property (nonatomic, strong) NSArray *indices;

@end
