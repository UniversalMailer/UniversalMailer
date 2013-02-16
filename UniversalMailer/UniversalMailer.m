// Copyright (C) 2012-2013 noware
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
// AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "UniversalMailer.h"

#import <objc/runtime.h>
#import "UMMessageWriter.h"

#import "Constants.h"
#import "Macros.h"

@interface UniversalMailer (PrivateMethods)
+ (void)registerBundle;
@end

static void swizzle_instance_methods( SEL m1, NSString *c1, SEL m2, NSString *c2 ){
	Method original = class_getInstanceMethod( NSClassFromString( c1 ), m1 );
	Method target = class_getInstanceMethod( NSClassFromString( c2 ), m2 );
	if( !original ) {
		NSLog( @"Original method not found" );
	}
	else if( !target ){
		NSLog( @"Target method not found" );
	}
	else {
		method_exchangeImplementations( original, target );
	}
}

static void swizzle_class_methods( SEL m1, NSString *c1, SEL m2, NSString *c2 ){
	Method original = class_getClassMethod( NSClassFromString( c1 ), m1 );
	Method target = class_getClassMethod( NSClassFromString( c2 ), m2 );
	if( !original ) {
		NSLog( @"Original method not found" );
	}
	else if( !target ){
		NSLog( @"Target method not found" );
	}
	else {
		method_exchangeImplementations( original, target );
	}
}

@implementation UniversalMailer

+ (void)initialize {
    [super initialize];
    
    if( !DEFAULT_GET(UMMailFilterEnabled) ){
        DEFAULT_SET_BOOL( YES, UMMailFilterEnabled );
    }
    if( !DEFAULT_GET(UMFontFilterEnabled) ){
        DEFAULT_SET_BOOL( YES, UMFontFilterEnabled );
    }
    if( !DEFAULT_GET(UMDisableImageInlining) ){
        DEFAULT_SET_BOOL( NO, UMDisableImageInlining );
    }
    
    if( !DEFAULT_GET(UMOutgoingFontColor) || !DEFAULT_GET(UMOutgoingFontColorVersion132) ){
        NSData *colorData = [NSArchiver archivedDataWithRootObject: [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace]];
        DEFAULT_SET( colorData, UMOutgoingFontColor );
        DEFAULT_SET( [NSNumber numberWithBool: YES], UMOutgoingFontColorVersion132 );
    }
    
    if( !DEFAULT_GET(UMOutgoingFontName) ){
        NSString *font = [[NSUserDefaults standardUserDefaults] objectForKey: @"NSFont"];
        NSString *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey: @"NSFontSize"];

        DEFAULT_SET( font, UMOutgoingFontName );
        DEFAULT_SET( fontSize, UMOutgoingFontSize );
    }
    
        
    Class mvMailBundleClass = NSClassFromString( @"MVMailBundle" );
    if( mvMailBundleClass ){
        [mvMailBundleClass registerBundle];

        // Methods for 10.7.x compatibility (Mail 5.x)
        swizzle_instance_methods( @selector(umNewMessageWithHtmlString:plainTextAlternative:otherHtmlStringsAndAttachments:headers:),
                                 @"MessageWriter",
                                 @selector(newMessageWithHtmlString:plainTextAlternative:otherHtmlStringsAndAttachments:headers:),
                                 @"MessageWriter" );
        swizzle_instance_methods( @selector(umNewMessageWithAttributedString:headers:),
                                 @"MessageWriter",
                                 @selector(newMessageWithAttributedString:headers:),
                                 @"MessageWriter" );
        swizzle_instance_methods( @selector(umNewMessageWithHtmlString:attachments:headers:),
                                 @"MessageWriter",
                                 @selector(newMessageWithHtmlString:attachments:headers:),
                                 @"MessageWriter" );

        // Methods for 10.6.x compatibility (Mail 4.x)
        swizzle_instance_methods( @selector(umNewMessageWithHtmlString:plainTextAlternative:otherHtmlStringsAndAttachments:headers:),
                                 @"MessageWriter",
                                 @selector(createMessageWithHtmlString:plainTextAlternative:otherHtmlStringsAndAttachments:headers:),
                                 @"MessageWriter" );
        swizzle_instance_methods( @selector(umNewMessageWithAttributedString:headers:),
                                 @"MessageWriter",
                                 @selector(createMessageWithAttributedString:headers:),
                                 @"MessageWriter" );
        swizzle_instance_methods( @selector(umNewMessageWithHtmlString:attachments:headers:),
                                 @"MessageWriter",
                                 @selector(createMessageWithHtmlString:attachments:headers:),
                                 @"MessageWriter" );

        swizzle_class_methods( @selector(UMSharedPreferences),
                              @"NSPreferences",
                              @selector(sharedPreferences),
                              @"NSPreferences" );
    }
}

@end
