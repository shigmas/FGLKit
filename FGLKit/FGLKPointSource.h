//
//  FGLKPointSource.h
//  FGLKit
//
//  Created by Masa Jow on 8/17/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

// Uses by the frustum, and also the point prim.
@protocol FGLKPointSource <NSObject>

// returns true if the points need to be fetched again.
- (BOOL)isDirty;

// Returns an NSArray* of GLKVector3's (as NSValue's).  It is up
// to the implementor to return the points in the necessary order
// and/or duplication to draw them correctly
// \p mode is the GL draw mode
- (NSArray *)getPoints:(GLenum)mode;

@end
