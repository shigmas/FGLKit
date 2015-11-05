//
//  FGLKObjParser.h
//  FGLKit
//
//  Created by Masa Jow on 5/14/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

@interface FGLKObjParser : NSObject

- (id)initWithFile:(NSString *)objPath;

- (BOOL)parse;

- (void)dump;

@property (nonatomic, strong) NSString *objFile;

// The actual data.  Array of FGLKParseObject's
@property (nonatomic, strong) NSArray *parsedObjects;

@end
