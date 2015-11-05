//
//  FGLKParseObject.h
//  FGLKit
//
//  Created by Masa Jow on 5/14/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FGLKParseObject : NSObject

- (id)initWithName:(NSString *)name;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSDictionary *vertices;
@property (nonatomic, strong) NSArray *texVertices;
@property (nonatomic, strong) NSArray *normals;
@property (nonatomic, strong) NSArray *faces;
@end
