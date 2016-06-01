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
#import <objc/runtime.h>

#import "UMConstants.h"
#import "UMLog.h"
#import "NSObject+UMExtensions.h"

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
        [SUUpdater updaterForBundle: [NSBundle bundleForClass: [self class]]];
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
                               };
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
    
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
