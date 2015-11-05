//
//  FGLKParseObject.m
//  FGLKit
//
//  Created by Masa Jow on 5/14/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKParseObject.h"

@implementation FGLKParseObject

- (id)initWithName:(NSString *)name
{
    if ((self = [super init]) != nil) {
        self.name = name;
    }
    
    return self;
}

@end
