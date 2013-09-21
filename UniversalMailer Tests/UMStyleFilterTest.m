//
//  UMStyleFilterTest.m
//  UniversalMailer
//
//  Created by luca on 22/06/13.
//  Copyright (c) 2013 noware. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Cocoa/Cocoa.h>
#import "UMStyleFilter.h"

@interface UMStyleFilterTest : XCTestCase

@end

@interface UMStyleFilter (TestableMethods)
- (NSString*)styleString;
@end

@implementation UMStyleFilterTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testStyleString {
    UMStyleFilter *filter = [UMStyleFilter filterString: @""
                                           withFontName: @"Helvetica"
                                               fontSize: @"12"
                                              fontColor: [NSColor colorWithCalibratedRed: .5f green: .5f blue: .5f alpha: 1.f]
                                              usePoints: NO];
    XCTAssertTrue( [filter.styleString isEqualToString: @"font-family: 'Helvetica'; font-size: 12px; color: rgb(127, 127, 127);"], @"invalid output style string" );
    filter = [UMStyleFilter filterString: @""
                            withFontName: @"Helvetica"
                                fontSize: @"12"
                               fontColor: [NSColor colorWithCalibratedRed: .5f green: .5f blue: .5f alpha: 1.f]
                               usePoints: YES];
    XCTAssertTrue( [filter.styleString isEqualToString: @"font-family: 'Helvetica'; font-size: 12pt; color: rgb(127, 127, 127);"], @"invalid output style string" );
}

- (void)testFilterSimple {
    NSString *desiredOutput = @"<html><head><meta http-equiv=\"Content-Type\" content=\"abcdef\"></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\"><span style=\"font-family: 'Helvetica'; font-size: 12px; color: rgb(127, 127, 127);\">test<div></div></span></body></html>";
    NSString *input = @"<html><head><meta http-equiv=\"Content-Type\" content=\"abcdef\"></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\">test<div></div></body></html>";

    UMStyleFilter *filter = [UMStyleFilter filterString: input
                                           withFontName: @"Helvetica"
                                               fontSize: @"12"
                                              fontColor: [NSColor colorWithCalibratedRed: .5f green: .5f blue: .5f alpha: 1.f]
                                              usePoints: NO];
    NSString *output = [filter filteredString];
    XCTAssertTrue( [output isEqualToString: desiredOutput], @"filtered string is not valid" );
}

- (void)testFilterForwardHeader {
    NSString *desiredOutput = @"<html><head><meta http-equiv=\"Content-Type\" content=\"abcdef\"></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\"><span style=\"font-family: 'Helvetica'; font-size: 12px; color: rgb(127, 127, 127);\">test<div><div><br><div>Begin forwarded message:</div><br class=\"Apple-interchange-newline\"><blockquote type=\"cite\"><div style=\"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;\"><span style=\"font-family:'Helvetica';font-size:medium; color:rgba(0, 0, 0, 1.0);\"><b>From: </b></span><span style=\"font-family: 'Helvetica'; font-size: 12px; color: rgb(127, 127, 127);\">\">Test Test Test &lt;<a href=\"mailto:test@test.com\">test@test.com</a>&gt;<br></span></div><div style=\"margin-top: 0px;margin-right: 0px; margin-bottom: 0px; margin-left: 0px;\"><span style=\"font-family: 'Helvetica'; font-size: 12px; color: rgb(127, 127, 127);\"> color:rgba(0, 0, 0, 1.0);\"><b>Subject: </b></span><span style=\"font-family: 'Helvetica'; font-size: 12px; color: rgb(127, 127, 127);\">\"><b>FW:<br></span></div><br></div></span></body></html>";
    NSString *input = @"<html><head><meta http-equiv=\"Content-Type\" content=\"abcdef\"></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\">test<div><div><br><div>Begin forwarded message:</div><br class=\"Apple-interchange-newline\"><blockquote type=\"cite\"><div style=\"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px;\"><span style=\"font-family:'Helvetica';font-size:medium; color:rgba(0, 0, 0, 1.0);\"><b>From: </b></span><span style=\"font-family:'Helvetica'; font-size:medium;\">Test Test Test &lt;<a href=\"mailto:test@test.com\">test@test.com</a>&gt;<br></span></div><div style=\"margin-top: 0px;margin-right: 0px; margin-bottom: 0px; margin-left: 0px;\"><span style=\"font-family:'Helvetica'; font-size:medium; color:rgba(0, 0, 0, 1.0);\"><b>Subject: </b></span><span style=\"font-family:'Helvetica'; font-size:medium;\"><b>FW:<br></span></div><br></div></body></html>";
    
    UMStyleFilter *filter = [UMStyleFilter filterString: input
                                           withFontName: @"Helvetica"
                                               fontSize: @"12"
                                              fontColor: [NSColor colorWithCalibratedRed: .5f green: .5f blue: .5f alpha: 1.f]
                                              usePoints: NO];
    NSString *output = [filter filteredString];
    XCTAssertTrue( [output isEqualToString: desiredOutput], @"filtered string is not valid" );
}

@end
