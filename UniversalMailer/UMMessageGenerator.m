//
//  UMMessageGenerator.m
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import "UMMessageGenerator.h"

#import <GoogleAnalyticsTracker/GoogleAnalyticsTracker.h>
#import "UMConstants.h"
#import "UMLog.h"
#import "UMFilter.h"

@interface DummyObject : NSObject
- (BOOL)signsOutput;
@end

@interface UMMessageGenerator ()
- (id)newMessageWithHtmlString: (NSString*)string plainTextAlternative: (NSMutableAttributedString*)html otherHtmlStringsAndAttachments: (id)other headers: (id)headers;
@end

@implementation UMMessageGenerator

- (id)UMnewMessageWithAttributedString: (NSMutableAttributedString*)string headers: (id)headers {
    UMLog(@"%s", __PRETTY_FUNCTION__);
    BOOL alwaysSendRich = [[NSUserDefaults standardUserDefaults] boolForKey: UMAlwaysSendRichTextEmails];
    id ret = nil;

    UMLog(@"%s - always send rich text email: %d", __PRETTY_FUNCTION__, alwaysSendRich);
    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMSendUsageStats] ){
        [MPGoogleAnalyticsTracker trackEventOfCategory: @"Message"
                                                action: @"New Message"
                                                 label: @"Plain Text"
                                                 value: @(alwaysSendRich)];
    }
    
    ret = [self UMnewMessageWithAttributedString: string headers: headers];
    
    BOOL gpgMailDetected = NO;
    DummyObject *dummy = (id)self;
    if( [self respondsToSelector: @selector(signsOutput)] && [dummy signsOutput] )
        gpgMailDetected = YES;

    if( !gpgMailDetected && alwaysSendRich ){
        UMLog(@"%s - original plain data: [%@]", __PRETTY_FUNCTION__, [[NSString alloc] initWithData: [ret valueForKey: @"_rawData"] encoding: NSUTF8StringEncoding]);
        UMFilter *filter = [[UMFilter alloc] initWithData: [ret valueForKey: @"_rawData"]];
        [ret setValue: [filter filteredDataByForcingHTML: YES] forKey: @"_rawData"];
        UMLog(@"%s - filtered plain data: [%@]", __PRETTY_FUNCTION__, [[NSString alloc] initWithData: [ret valueForKey: @"_rawData"] encoding: NSUTF8StringEncoding]);
    }
    
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

    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMSendUsageStats] ){
        [MPGoogleAnalyticsTracker trackEventOfCategory: @"Message"
                                                action: @"New Message"
                                                 label: @"Rich Text"
                                                 value: @0];
    }
    
    if( !gpgMailDetected && [ret valueForKey: @"_rawData"] ){
        UMLog(@"%s - original data: [%@]", __PRETTY_FUNCTION__, [[NSString alloc] initWithData: [ret valueForKey: @"_rawData"] encoding: NSUTF8StringEncoding]);
        UMFilter *filter = [[UMFilter alloc] initWithData: [ret valueForKey: @"_rawData"]];
        [ret setValue: [filter filteredDataByForcingHTML: NO] forKey: @"_rawData"];
        UMLog(@"%s - filtered data: [%@]", __PRETTY_FUNCTION__, [[NSString alloc] initWithData: [ret valueForKey: @"_rawData"] encoding: NSUTF8StringEncoding]);
    }
    return ret;
}

@end
