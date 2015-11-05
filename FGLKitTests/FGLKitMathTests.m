//
//  FGLKitMathTests.m
//  FGLKit
//
//  Created by Masa Jow on 6/9/15.
//  Copyright (c) 2015 Futomen. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "FGLKBounce.h"
#import "FGLKTransform.h"
#import "FGLKMath.h"

@interface FGLKitMathTests : XCTestCase

@end

@implementation FGLKitMathTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRound {
    double t1 = 3.141592673;
    double t2 = 0.999998211;
    double t3 = -0.00192480301;
    
    double roundedT1 = [FGLKMath roundNumber:t1 toFractionalDigits:2];
    double roundedT2 = [FGLKMath roundNumber:t2 toFractionalDigits:2];
    double roundedT3 = [FGLKMath roundNumber:t3 toFractionalDigits:2];
    NSLog(@"t1 %f rounded %f",t1, roundedT1);
    NSLog(@"t2 %f rounded %f",t2, roundedT2);
    NSLog(@"t3 %f rounded %f",t3, roundedT3);

    XCTAssertEqual(roundedT1, 3.14);
    XCTAssertEqual(roundedT2, 1.00);
    XCTAssertEqual(roundedT3, 0.00);
}

- (void)testLog10Transform {
    double start = 0.0;
    double end = 45.0;
    double valStart = 0.0;
    double valEnd = 400.0;
    FGLKTransform *trans =
    [FGLKTransform transformWithOutputMin:start outputMax:end
                                 inputMin:valStart inputMax:valEnd
                                deviation:0.0 method:FGLKTransformLog10Mode];
    for (double i = valStart ; i < valEnd ; ++i) {
        NSLog(@"range: %ld: %f", (long)i, [trans transformValue:i]);
    }

}

- (void)testAtanTransform {
    double start = 0.0;
    double end = 90.0;
    double valStart = 0.0;
    double valEnd = 400.0;
    FGLKTransform *trans =
    [FGLKTransform transformWithOutputMin:start outputMax:end
                                 inputMin:valStart inputMax:valEnd
                                deviation:0.0 method:FGLKTransformAtanMode];
    for (double i = valStart ; i < valEnd ; ++i) {
        NSLog(@"range: %ld: %f", (long)i, [trans transformValue:i]);
    }
    
}

- (void)testBounce {
    double time = 0.0;
    double inc = .2;
    double acc = -9.8;
    double height = 20.0;
    double coef = 0.6;
    
    FGLKBounce *bounce = [[FGLKBounce alloc] initAt:height
                                      startVelocity:0.0
                                       acceleration:acc
                                     cOfRestitution:coef];
    for ( ; time < 16.0 ; ) {
        double h = [bounce getHeightAtTime:time];
        NSLog(@"%f: %f", time, h);
        time += inc;
    }
}

- (void)testGLUKBounce {
    FGLKBounce *bounce = [[FGLKBounce alloc] initAt:117
                                      startVelocity:0.0
                                       acceleration:-9.8
                                     cOfRestitution:0.75];
    double time = 0.0;
    double inc = .01;
    for ( ; time < 8.0 ; ) {
        double h = [bounce getHeightAtTime:time];
        NSLog(@"%f: %f", time, h);
        time += inc;
    }

}

@end
