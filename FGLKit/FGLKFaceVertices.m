//
//  FGLKFaceVertices.m
//  FGLKit
//
//  Created by Masa Jow on 5/15/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKFaceVertices.h"

@implementation FGLKFaceVertices

- (id)initWithIndices:(NSArray *)indices
{
    if ((self = [super init]) != nil) {
        self.indices = indices;
    }
    
    return self;
}

@end
