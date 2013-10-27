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

#import "MCMessageGenerator+UMExtension.h"

#import "Constants.h"
#import "UMMIMEFilter.h"
#import "UMStyleFilter.h"

@interface DummyObject : NSObject
- (BOOL)signsOutput;
@end

id UMnewMessageWithHtmlStringP(id self, SEL _cmd, id str, id plain, NSArray* other, id hdrs){
    UMLog( @"%s", __PRETTY_FUNCTION__ );
    
    UMLog( @"str: [%@]", str );
    UMLog( @"plain: [%@]", plain );
    UMLog( @"other: [%@]", other );
    UMLog( @"hdrs: [%@]", hdrs );
    
    // GPGMail and S/MIME fix
    DummyObject *dummy = self;
    if( [self respondsToSelector: @selector(signsOutput)] && [dummy signsOutput] )
        return UMnewMessageWithHtmlStringP( self, _cmd, str, plain, other, hdrs );

#ifdef DEBUG_LOGS
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
#endif

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
    id ret = newMessageWithHtmlStringP( self, _cmd, str, plain, other, hdrs );
    
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
