//
//  FGLKObjParser.m
//  FGLKit
//
//  Created by Masa Jow on 5/14/13.
//  Copyright (c) 2013 Futomen. All rights reserved.
//

#import "FGLKObjParser.h"

#import "FGLKFaceVertices.h"
#import "FGLKParseObject.h"

#import <FFKit/FFKit.h>

#define FGLK_OBJ_OBJECT @"o"
#define FGLK_OBJ_GROUP @"g"
#define FGLK_OBJ_VERTEX @"v"
#define FGLK_OBJ_TEXTURE_VERTEX @"vt"
#define FGLK_OBJ_NORMAL @"vn"
#define FGLK_OBJ_FACE @"f"

@interface FGLKObjParser()

// Index to vertex for all vertices in the file.
@property(nonatomic, strong) NSMutableDictionary *tmpVertices;
@property(nonatomic, strong) NSMutableArray *tmpNormals;
@property(nonatomic, strong) NSMutableArray *tmpUvs;
@property(nonatomic, strong) NSMutableArray *tmpFaces;
@property(nonatomic, strong) NSMutableArray *tmpParsedObjects;

@end

@implementation FGLKObjParser

- (id)initWithFile:(NSString *)objFile
{
    if ((self = [super init]) != nil) {
        self.objFile = objFile;
    }
    return self;
}

- (void)dealloc
{
    // Just for fun:
    [self.tmpVertices removeAllObjects];
    [self.tmpNormals removeAllObjects];
    [self.tmpUvs removeAllObjects];
    [self.tmpFaces removeAllObjects];
    [self.tmpParsedObjects removeAllObjects];

}

- (NSString *)scanHeader:(NSScanner *)scanner
{
    NSString *header;
    NSCharacterSet *delim = [NSCharacterSet whitespaceCharacterSet];

    [scanner scanUpToCharactersFromSet:delim intoString:&header];
    
    return header;
}

- (float)scanFloat:(NSScanner *)scanner
          charSet:(NSCharacterSet *)delim
{
    NSString *tmp;
    [scanner scanUpToCharactersFromSet:delim intoString:&tmp];
    
    return [tmp floatValue];
}

- (GLKVector3)scanVector3:(NSScanner *)scanner
{
    NSCharacterSet *delim = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    float x = [self scanFloat:scanner charSet:delim];
    float y = [self scanFloat:scanner charSet:delim];
    float z = [self scanFloat:scanner charSet:delim];

    return GLKVector3Make(x, y, z);
}

- (GLKVector2)scanVector2:(NSScanner *)scanner
{
    NSCharacterSet *delim = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    float x = [self scanFloat:scanner charSet:delim];
    float y = [self scanFloat:scanner charSet:delim];
    
    return GLKVector2Make(x, y);
}

- (NSArray *)scanIntArray:(NSScanner *)scanner
{
    NSCharacterSet *delim = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *val;
    while ([scanner scanUpToCharactersFromSet:delim intoString:&val]) {
        NSNumber *num = [NSNumber numberWithInt:[val intValue]];
        [arr addObject:num];
    }

    return arr;
}

- (NSString *)scanString:(NSScanner *)scanner
{
    NSCharacterSet *delim = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *str;
    
    [scanner scanUpToCharactersFromSet:delim intoString:&str];

    return str;
}

- (FGLKParseObject *)beginParseObject:(NSString *)name
{
    // Allocate the temporary arrays
    self.tmpVertices = [[NSMutableDictionary alloc] init];
    self.tmpNormals = [[NSMutableArray alloc] init];
    self.tmpUvs = [[NSMutableArray alloc] init];
    self.tmpFaces = [[NSMutableArray alloc] init];

    return [[FGLKParseObject alloc] initWithName:name];
}

- (void)addToParseObjectAndAppend:(FGLKParseObject *)parseObject
{
    if (parseObject != nil) {
        parseObject.vertices =
            [[NSDictionary alloc] initWithDictionary:self.tmpVertices];
        parseObject.texVertices = [[NSArray alloc] initWithArray:self.tmpUvs];
        parseObject.normals = [[NSArray alloc] initWithArray:self.tmpNormals];
        parseObject.faces = [[NSArray alloc] initWithArray:self.tmpFaces];
        [self.tmpParsedObjects addObject:parseObject];
    }
}

- (BOOL)parse
{
    BOOL result = NO;
    
    NSArray *contents = [self getFileContents:self.objFile];
    if (contents == nil)
        return NO;
    self.tmpParsedObjects = [[NSMutableArray alloc] init];

    uint vertexCounter = 1;
    FGLKParseObject *parseObject;
    for (NSString *line in contents) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:line];
        NSString *header = [self scanHeader:scanner];

        if (([header isEqualToString:FGLK_OBJ_OBJECT]) ||
            ([header isEqualToString:FGLK_OBJ_GROUP])) {
            // Is there an existing object?
            if (parseObject != nil) {
                [self addToParseObjectAndAppend:parseObject];
            }
            NSString *name = [self scanString:scanner];
            parseObject = [self beginParseObject:name];
        } else if ([header isEqualToString:FGLK_OBJ_VERTEX]) {
            GLKVector3 vertex = [self scanVector3:scanner];
            NSNumber *vIndex = [NSNumber numberWithInt:vertexCounter++];
            [self.tmpVertices setObject:[NSValue valueWithBytes:&vertex
                                                       objCType:@encode(GLKVector3)]
                             forKey:vIndex];
        } else if ([header isEqualToString:FGLK_OBJ_TEXTURE_VERTEX]) {
            GLKVector2 texVertex = [self scanVector2:scanner];
            [self.tmpUvs addObject:[NSValue value: &texVertex
                                     withObjCType:@encode(GLKVector2)]];
        } else if ([header isEqualToString:FGLK_OBJ_NORMAL]) {
            GLKVector3 normalVertex = [self scanVector3:scanner];
            [self.tmpNormals addObject:[NSValue value: &normalVertex
                                         withObjCType:@encode(GLKVector3)]];
        } else if ([header isEqualToString:FGLK_OBJ_FACE]) {
            NSArray *indices = [self scanIntArray:scanner];
            FGLKFaceVertices *face =
                [[FGLKFaceVertices alloc] initWithIndices:indices];
            [self.tmpFaces addObject:face];
        }
    }
    
    // We finished parsing, so finish up
    [self addToParseObjectAndAppend:parseObject];
    
    self.parsedObjects = [[NSArray alloc] initWithArray:self.tmpParsedObjects];
    return result;
}

- (void)dump
{
    NSLog(@"parsed %lu objects", (unsigned long)[self.parsedObjects count]);
    
    for (FGLKParseObject *p in self.parsedObjects) {
        NSLog(@"object [%@] has %lu vertices", p.name, (unsigned long)[p.vertices count]);
        int i = 0;
        for (FGLKFaceVertices *f in p.faces) {
            NSLog(@"Face %d: %lu vertices", i++, (unsigned long)[f.indices count]);
        }
    }
}

- (NSString *)_findObjectFile:(NSString *)name
{
    NSArray *bundles = [FFKBundleFinder getAllBundles];
    
    NSString *ext = @"obj";
    for (NSBundle *bundle in bundles) {
        NSArray *keyPaths =
        [bundle pathsForResourcesOfType:ext inDirectory:nil];
        
        NSString *fname = [name stringByAppendingPathExtension:ext];
        for (NSString *objCandidate in keyPaths) {
            NSString *last = [objCandidate lastPathComponent];
            if ([last isEqualToString:fname]) {
                return objCandidate;
            }
        }
    }
    
    return nil;
}

- (NSArray *)getFileContents:(NSString *)objFile
{
    NSString *objPath = [self _findObjectFile:objFile];
    if (objPath == nil) {
        NSLog(@"No such file %@.obj found in bundle",objFile);
        return nil;
    }
    //NSLog(@"Loading file [%@]", objPath);
    NSString *contents = [NSString stringWithContentsOfFile:objPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    
    return [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}


- (NSString *)getPath:(NSString *)fileName extension:(NSString *)ext
{
    NSString *resourceDir = [[NSBundle mainBundle] resourcePath];

    return [resourceDir stringByAppendingFormat:@"/%@.%@",fileName, ext];
}

@end
