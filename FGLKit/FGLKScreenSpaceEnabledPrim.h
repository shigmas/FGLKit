//
//  FGLKScreenSpaceEnabledPrim.h
//  FGLKit
//
//  Created by Masa Jow on 8/4/14.
//  Copyright (c) 2014 Futomen. All rights reserved.
//

#import <FGLKit/FGLKit.h>

@protocol FGLKPrimContainer;

@interface FGLKScreenSpaceEnabledPrim : FGLKPrim

@property (nonatomic, weak) id<FGLKPrimContainer> container;

@end
