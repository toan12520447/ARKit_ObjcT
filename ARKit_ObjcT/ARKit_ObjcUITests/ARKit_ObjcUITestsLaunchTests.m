//
//  ARKit_ObjcUITestsLaunchTests.m
//  ARKit_ObjcUITests
//
//  Created by Toan Tran on 20/06/2022.
//

#import <XCTest/XCTest.h>

@interface ARKit_ObjcUITestsLaunchTests : XCTestCase

@end

@implementation ARKit_ObjcUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
