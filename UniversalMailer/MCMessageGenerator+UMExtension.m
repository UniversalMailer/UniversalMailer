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

id UMnewMessageWithHtmlStringP(id self, SEL _cmd, id str, id plain, NSArray* other, id hdrs){
    UMLog( @"%s", __PRETTY_FUNCTION__ );
    
    // TODO: add new GPGMail and S/MIME fix

    // Normal HTML manipulation
    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMMailFilterEnabled] ){
        if( [str length] > 0 && !other ){
            if( [[NSUserDefaults standardUserDefaults] boolForKey: UMFontFilterEnabled] ){
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
        // 10.9 has _rawData property in MCOutgoingMessage
        if( other.count > 0 && [ret isKindOfClass: NSClassFromString( @"MCOutgoingMessage" )] ){            
            if( [ret valueForKey: @"_rawData"] ){
                UMMIMEFilter *mimeFilter = [[UMMIMEFilter alloc] initWithData: [ret valueForKey: @"_rawData"]];
                NSData *filteredData = mimeFilter.filteredMIME;
                if( filteredData )
                    [ret setValue: filteredData forKey: @"_rawData"];
            }
        }
    }
    
    return ret;
}
