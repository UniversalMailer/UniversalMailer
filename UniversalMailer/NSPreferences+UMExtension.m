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

#import "NSPreferences+UMExtension.h"

#import <objc/runtime.h>
#import "UMPreferences.h"

@implementation NSPreferences (UMExtension)

+ (id)UMSharedPreferences {
    static BOOL added = NO;
	id sharedPreferences = [self UMSharedPreferences];
    
    if( sharedPreferences && !added ){
        added = YES;
        [sharedPreferences addPreferenceNamed: @"Universal Mailer" owner: [UMPreferences sharedInstance]];
        
        NSWindow *prefsWindow = nil;
        NSMutableArray *toolbarTitles = nil;
        if( [prefsWindow valueForKey: @"_preferencesPanel"] &&
           [toolbarTitles valueForKey: @"_preferenceTitles"] ) {
            NSToolbar *toolbar = [prefsWindow toolbar];
            NSArray *toolbarItems = [toolbar items];
            NSUInteger itemsCount = [toolbarItems count];
            NSUInteger titlesCount = [toolbarTitles count];
            
            if(itemsCount < titlesCount)
            {
                NSUInteger i;
                for( i = 0 ; i < titlesCount ; i++ )
                {
                    NSString* title = [toolbarTitles objectAtIndex:i];
                    if(i < itemsCount && [[(NSToolbarItem*)[toolbarItems objectAtIndex:i] itemIdentifier] isEqualToString:title] )
                        continue;
                    [toolbar insertItemWithItemIdentifier:title atIndex:i];
                    toolbarItems = [toolbar items];
                    itemsCount++;
                }
            }
        }
    }
    
	return sharedPreferences;
}

@end
