//
//  UMMessageGenerator.m
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import "UMMessageGenerator.h"

#import "UMConstants.h"
#import "UMLog.h"
#import "UMFilter.h"

@interface DummyObject : NSObject
- (BOOL)signsOutput;
@end

@implementation UMMessageGenerator

- (id)UMnewMessageWithAttributedString: (NSMutableAttributedString*)string headers: (id)headers {
    UMLog(@"%s", __PRETTY_FUNCTION__);
    BOOL alwaysSendRich = [[NSUserDefaults standardUserDefaults] boolForKey: UMAlwaysSendRichTextEmails];
    id ret = nil;

    UMLog(@"%s - always send rich text email: %d", __PRETTY_FUNCTION__, alwaysSendRich);
    if( alwaysSendRich )
        ret = [self UMnewMessageWithHtmlString: [NSString stringWithFormat: @"<html><head></head><body>%@</body></html>", string] html: string other: nil headers: headers];
    else
        ret = [self UMnewMessageWithAttributedString: string headers: headers];
    
    return  ret;
}

- (id)UMnewMessageWithHtmlString: (NSString*)string html: (NSMutableAttributedString*)html other: (id)other headers: (id)headers {
    UMLog(@"%s", __PRETTY_FUNCTION__);
    id ret = [self UMnewMessageWithHtmlString: string html: html other: other headers: headers];

    // GPGMail and S/MIME fix
    BOOL gpgMailDetected = NO;
    DummyObject *dummy = (id)self;
    if( [self respondsToSelector: @selector(signsOutput)] && [dummy signsOutput] )
        gpgMailDetected = YES;

    if( !gpgMailDetected && [ret valueForKey: @"_rawData"] ){
        UMLog(@"%s - original data: [%@]", __PRETTY_FUNCTION__, [[NSString alloc] initWithData: [ret valueForKey: @"_rawData"] encoding: NSUTF8StringEncoding]);
        UMFilter *filter = [[UMFilter alloc] initWithData: [ret valueForKey: @"_rawData"]];
        [ret setValue: [filter filteredData] forKey: @"_rawData"];
        UMLog(@"%s - filtered data: [%@]", __PRETTY_FUNCTION__, [[NSString alloc] initWithData: [ret valueForKey: @"_rawData"] encoding: NSUTF8StringEncoding]);
    }
    return ret;
}

@end
