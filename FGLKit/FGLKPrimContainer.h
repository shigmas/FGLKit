//
//  FGLKPrimContainer.h
//  FGLKit
//
//  Created by Masa Jow on 9/17/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

#include "FGLKTypes.h"

@class FGLKCamera;
@class FGLKPrim;

@protocol FGLKPrimContainer <NSObject>

- (FGLKDrawMode)drawMode;

- (BOOL)isDrawModeDirty;
- (GLKBaseEffect *)effect;
- (FGLKCamera *)camera;

- (CGFloat)widthInNDC:(CGFloat)widthInPixels;
- (CGFloat)heightInNDC:(CGFloat)heightInPixels;

- (GLKVector3)convertToScreenSpace:(GLKVector3)point;

- (void)convertToScreenSpace:(GLKVector3 *)points
           destinationPoints:(GLKVector3 *)destPoints
                   numPoints:(int)count;

- (void)update;

- (void)clear;

// Draws the scene
- (void)draw;

- (void)addPrim:(FGLKPrim *)prim;

@end
