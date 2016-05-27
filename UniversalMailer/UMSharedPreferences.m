//
//  UMSharedPreferences.m
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import "UMSharedPreferences.h"

#import "UMPreferencesPanel.h"

@implementation NSPreferences (UMExtensions)

+ (id)UMsharedPreferences {
    static BOOL added = NO;
    
    id ret = [self UMsharedPreferences];
    
    if( ret && !added ){
        added = YES;
        [ret addPreferenceNamed: @"Universal Mailer" owner: [UMPreferencesPanel sharedInstance]];
        
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
    
    return ret;
}

@end
