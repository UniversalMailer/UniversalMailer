//
//  MCMessageGenerator+UMExtensions.m
//  UniversalMailer
//
//  Created by luca on 14/11/13.
//  Copyright (c) 2013 noware. All rights reserved.
//

#import "MCMessageGenerator+UMExtensions.h"

#import "Constants.h"
#import "UMMIMEFilter.h"
#import "UMStyleFilter.h"

@interface DummyObject : NSObject
- (BOOL)signsOutput;
@end

@implementation MCMessageGenerator (UMExtensions)

- (id)UMnewMessageWithHtmlStringP: (id)str plain: (id)plain other: (NSArray*)other hdrs: (id)hdrs{
    UMLog( @"%s", __PRETTY_FUNCTION__ );
    
    UMLog( @"str: [%@]", str );
    UMLog( @"plain: [%@]", plain );
    UMLog( @"other: [%@]", other );
    UMLog( @"hdrs: [%@]", hdrs );
    
    // GPGMail and S/MIME fix
    DummyObject *dummy = (id)self;
    if( [self respondsToSelector: @selector(signsOutput)] && [dummy signsOutput] )
        return [self UMnewMessageWithHtmlStringP: str plain: plain other: other hdrs: hdrs];

    NSArray *defaultKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    defaultKeys = [defaultKeys filteredArrayUsingPredicate: [NSPredicate predicateWithBlock: ^(id evaluatedObject, NSDictionary *bindings){
        NSRange sRange = [evaluatedObject rangeOfString: @"UM"];
        if( sRange.location != NSNotFound && sRange.location == 0 )
            return YES;
        return NO;
    }]];
    for( NSString *key in defaultKeys ){
        UMLog( @"%@: %@", key, [[NSUserDefaults standardUserDefaults] objectForKey: key] );
    }
    
    // Normal HTML manipulation
    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMMailFilterEnabled] ){
        if( [str length] > 0 && !other ){
            if( [[NSUserDefaults standardUserDefaults] boolForKey: UMFontFilterEnabled] ){
                UMLog( @"Applying default font to [%@]", str );
                NSColor *color = [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
                NSData *serializedColor = [[NSUserDefaults standardUserDefaults] objectForKey: UMOutgoingFontColor];
                if( serializedColor )
                    color = [[NSUnarchiver unarchiveObjectWithData: serializedColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
                UMStyleFilter *filter = [[UMStyleFilter alloc] initWithString: str
                                                                     fontName: [[NSUserDefaults standardUserDefaults] objectForKey: UMOutgoingFontName]
                                                                     fontSize: [[NSUserDefaults standardUserDefaults] objectForKey: UMOutgoingFontSize]
                                                                    fontColor: color
                                                                    usePoints: [[NSUserDefaults standardUserDefaults] boolForKey: UMUsePointsForFontSizes]];
                NSString *string = filter.filteredString;
                if( string.length > 0 )
                    str = string;
            }
        }
    }
    
    // call original method
    id ret = [self UMnewMessageWithHtmlStringP: str plain: plain other: other hdrs: hdrs];
    
    // MIME re-arrangement
    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMMailFilterEnabled] ){
        UMLog( @"Mail filter is enabled, checking for parts to edit" );
        // 10.9 has _rawData property in MCOutgoingMessage
        if( other.count > 0 && [ret isKindOfClass: NSClassFromString( @"MCOutgoingMessage" )] ){
            if( [ret valueForKey: @"_rawData"] ){
                UMLog( @"Starting MIME filter" );
                UMMIMEFilter *mimeFilter = [[UMMIMEFilter alloc] initWithData: [ret valueForKey: @"_rawData"]];
                NSData *filteredData = mimeFilter.filteredMIME;
                if( filteredData ){
                    UMLog( @"Setting back filtered data [%@]", [[NSString alloc] initWithData: filteredData encoding: NSUTF8StringEncoding] );
                    [ret setValue: filteredData forKey: @"_rawData"];
                }
            }
        }
    }
    
    return ret;
}

@end
