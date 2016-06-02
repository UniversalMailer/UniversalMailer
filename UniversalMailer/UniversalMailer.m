//
//  UniversalMailer.m
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import "UniversalMailer.h"

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import <GoogleAnalyticsTracker/GoogleAnalyticsTracker.h>
#import <objc/runtime.h>

#import "UMConstants.h"
#import "UMLog.h"
#import "NSObject+UMExtensions.h"
#import "NSString+UMExtensions.h"

#import "UMMessageGenerator.h"
#import "UMComposeBackEnd.h"
#import "UMSharedPreferences.h"

@interface NSObject ()
+ (void)registerBundle;
@end

@implementation UniversalMailer

+ (void)initialize {
    [super initialize];
    
    UMLog(@"UniversalMailer loaded!");
    
    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMMailFilterEnabled] ){
        SUUpdater *updater = [SUUpdater updaterForBundle: [NSBundle bundleForClass: [self class]]];
        updater.updateCheckInterval = 604800; // once per week
    }
    
    NSData *colorData = [NSArchiver archivedDataWithRootObject: [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace]];
    NSDictionary *defaults = @{
                               UMLoggingEnabled: @(NO),
                               UMMailFilterEnabled: @(YES),
                               UMDisableImageInlining: @(NO),
                               UMAlwaysSendRichTextEmails: @(NO),
                               UMOverrideInjectedCSS: @(NO),
                               UMUsePointsInsteadOfPixels: @(YES),
                               UMOutgoingFontName: [[NSUserDefaults standardUserDefaults] objectForKey: @"NSFont"],
                               UMOutgoingFontSize: [[NSUserDefaults standardUserDefaults] objectForKey: @"NSFontSize"],
                               UMOutgoingFontColor: colorData,
                               UMSendUsageStats: @(YES),
                               UMFirstInstallation: @(YES),
                               };
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];

    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMSendUsageStats] ){
        MPAnalyticsConfiguration *configuration = [[MPAnalyticsConfiguration alloc] initWithAnalyticsIdentifier: @"UA-41621933-1"];
        [MPGoogleAnalyticsTracker activateConfiguration: configuration];
        
        if( [[NSUserDefaults standardUserDefaults] boolForKey: UMFirstInstallation] ){
            NSBundle *bundle = [NSBundle bundleForClass: [self class]];
            NSString *shortVersion = [bundle objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
            NSString *build = [bundle objectForInfoDictionaryKey: (NSString*)kCFBundleVersionKey];
            NSString *version = [NSString stringWithFormat: @"%@ (%@)", shortVersion, build];
            [MPGoogleAnalyticsTracker trackEventOfCategory: @"Plugin"
                                                    action: @"First Installation"
                                                     label: version
                                                     value: @0];
            [[NSUserDefaults standardUserDefaults] setBool: NO forKey: UMFirstInstallation];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
        
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    if( mvMailBundleClass ){
        [mvMailBundleClass registerBundle];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if( [[NSUserDefaults standardUserDefaults] boolForKey: UMMailFilterEnabled] ){
            UMLog(@"UniversalMailer is enabled, injecting required code");
            Class messageGenerator = NSClassFromString(@"MCMessageGenerator");
            [messageGenerator addMethod: @selector(UMnewMessageWithAttributedString:headers:) fromClass: [UMMessageGenerator class]];
            [messageGenerator swizzleMethod: @selector(newMessageWithAttributedString:headers:) withMethod: @selector(UMnewMessageWithAttributedString:headers:)];
            
            [messageGenerator addMethod: @selector(UMnewMessageWithHtmlString:html:other:headers:) fromClass: [UMMessageGenerator class]];
            [messageGenerator swizzleMethod: @selector(newMessageWithHtmlString:plainTextAlternative:otherHtmlStringsAndAttachments:headers:) withMethod: @selector(UMnewMessageWithHtmlString:html:other:headers:)];
            
            Class composeBackEnd = NSClassFromString(@"ComposeBackEnd");
            [composeBackEnd addMethod: @selector(UMhtmlStringForSignature:) fromClass: [UMComposeBackEnd class]];
            [composeBackEnd swizzleMethod: @selector(htmlStringForSignature:) withMethod: @selector(UMhtmlStringForSignature:)];
        }
        
        Class preferences = NSClassFromString(@"NSPreferences");
        [preferences swizzleClassMethod: @selector(sharedPreferences) withMethod: @selector(UMsharedPreferences)];
#pragma clang diagnostic pop
    }
}

@end
