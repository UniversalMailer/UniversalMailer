// Copyright (C) 2013 noware
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

#import "Constants.h"
#import "NSPreferences+UMExtension.h"
#import "MCMessageGenerator+UMExtension.h"

@interface UniversalMailer (Methods)

+ (void)registerBundle;

@end

static void swizzle_class_methods( SEL m1, NSString *c1, SEL m2, NSString *c2 ){
	Method original = class_getClassMethod( NSClassFromString( c1 ), m1 );
	Method target = class_getClassMethod( NSClassFromString( c2 ), m2 );
	if( !original ) {
		UMLog( @"Original method (%@ - %@) not found", c1, NSStringFromSelector(m1) );
	}
	else if( !target ){
		UMLog( @"Target method (%@ - %@) not found", c2, NSStringFromSelector(m2) );
	}
	else {
		method_exchangeImplementations( original, target );
	}
}

static void* replace_instance_method( NSString *classString, SEL sel, IMP imp ){
    Method original = class_getInstanceMethod( NSClassFromString(classString), sel );
    return class_replaceMethod( NSClassFromString(classString), sel, imp, method_getTypeEncoding(original) );
}

@implementation UniversalMailer

+ (void)initialize {
    [super initialize];
    
    UMLog( @"UniversalMailer loaded!" );
    
    Class mvMailBundleClass = NSClassFromString( @"MVMailBundle" );
    if( mvMailBundleClass ){
        [mvMailBundleClass registerBundle];
        
        NSData *colorData = [NSArchiver archivedDataWithRootObject: [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace]];
        NSDictionary *defaults = @{
                                   UMMailFilterEnabled: @(YES),
                                   UMFontFilterEnabled: @(YES),
                                   UMDisableImageInlining: @(NO),
                                   UMUsePointsForFontSizes: @(YES),
                                   UMOutgoingFontName: [[NSUserDefaults standardUserDefaults] objectForKey: @"NSFont"],
                                   UMOutgoingFontSize: [[NSUserDefaults standardUserDefaults] objectForKey: @"NSFontSize"],
                                   UMOutgoingFontColor: colorData,
                                   };
        [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
        
        swizzle_class_methods( @selector(UMSharedPreferences),
                              @"NSPreferences",
                              @selector(sharedPreferences),
                              @"NSPreferences" );
        
    }
}

+ (void)load {
    [super load];
    
    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMMailFilterEnabled] ){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        newMessageWithHtmlStringP =
            replace_instance_method( @"MCMessageGenerator",
                                    @selector(newMessageWithHtmlString:plainTextAlternative:otherHtmlStringsAndAttachments:headers:),
                                    (IMP)UMnewMessageWithHtmlStringP );
#pragma clang diagnostic pop
    }
}

@end
