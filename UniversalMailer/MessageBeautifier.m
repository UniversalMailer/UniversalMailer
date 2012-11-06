// Copyright (C) 2012 noware
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

#import "MessageBeautifier.h"
#import "UMParser.h"

#import <AppKit/AppKit.h>

#import "Constants.h"
#import "Macros.h"

#define kSizeLookupDictionary [NSDictionary dictionaryWithObjectsAndKeys: \
@"9.0", @"1", \
@"10.0", @"2", \
@"12.0", @"3", \
@"14.0", @"4", \
@"18.0", @"5", \
@"24.0", @"6", \
@"48.0", @"7", \
nil]

@implementation MessageBeautifier

+ (NSString*)stringByAddingBodyFontStyleToHTML: (NSString*)htmlMessage withFontName: (NSString*)fontName andFontSize: (NSString*)fontSize fontColor: (NSColor*)color {
    NSRange body = [htmlMessage rangeOfString: @"<body"];
    NSRange startingRange = NSMakeRange( body.location+1, htmlMessage.length-body.location-1 );
    NSRange endRange = [htmlMessage rangeOfString: @">" options: NSCaseInsensitiveSearch range: startingRange];
    NSString *bodyTag = [htmlMessage substringWithRange: NSMakeRange( body.location, endRange.location+endRange.length-body.location )];
    UMParser *parser = [UMParser parserWithData: [bodyTag dataUsingEncoding: NSUTF8StringEncoding]];
    NSString *currentStyle = [[parser.XML valueForKeyPath: @"body.attributes.style"] stringByReplacingOccurrencesOfString: @"\"" withString: @"'"];
    if( !currentStyle )
        currentStyle = @"";
    NSFont *font = [NSFont fontWithName: fontName size: [fontSize floatValue]];
    NSString *colorString = [NSString stringWithFormat: @"rgb(%2d, %2d, %2d)", (int)(color.redComponent*255), (int)(color.greenComponent*255), (int)(color.blueComponent*255)];
    currentStyle = [currentStyle stringByAppendingFormat: @"; font-family: '%@'; font-size: %@%@; color: %@", font.familyName, fontSize, DEFAULT_GET_BOOL(UMUsePointsForFontSizes)?@"pt":@"px", colorString];
    
    BOOL styleFound = NO;
    NSMutableString *newBody = [NSMutableString stringWithString: @"<body "];
    NSArray *attributes = [parser.XML valueForKeyPath: @"body.attributes"];
    for( NSString *attribute in attributes ){
        if( [attribute isEqualToString: @"style"] ){
            styleFound = YES;
            [newBody appendFormat: @"style=\"%@; \"", currentStyle];
        }
        else {
            [newBody appendFormat: @"%@=\"%@\"", attribute, [attributes valueForKeyPath: attribute]];
        }
    }
    if( !styleFound ){
        [newBody appendFormat: @"style=\"%@\"", currentStyle];
    }
    [newBody appendString: @">"];
    [newBody appendFormat: @"<span style=\"font-family: '%@'; font-size: %@%@; color: %@\">", font.familyName, fontSize, DEFAULT_GET_BOOL(UMUsePointsForFontSizes)?@"pt":@"px", colorString];
    
    htmlMessage = [htmlMessage stringByReplacingCharactersInRange: NSMakeRange( body.location, endRange.location+endRange.length-body.location )
                                                       withString: newBody];
    htmlMessage = [htmlMessage stringByReplacingOccurrencesOfString: @"</body>" withString: @"</span></body>"];
    
    return htmlMessage;
}

+ (NSString*)stringByChangingForwardHeaderStyle: (NSString*)htmlMessage withFontName: (NSString*)fontName andFontSize: (NSString*)fontSize fontColor: (NSColor*)color {
    NSRange fwdHeader = [htmlMessage rangeOfString: @":</div><br class=\"Apple-interchange-newline\"><blockquote type=\"cite\">"];
    if( fwdHeader.location != NSNotFound ){
        NSRange searchRange = fwdHeader;
        searchRange.length = htmlMessage.length-fwdHeader.location;
        NSRange endFwdHeader = [htmlMessage rangeOfString: @"<br></span></div><br>" options: NSCaseInsensitiveSearch range: searchRange];
        if( endFwdHeader.location != NSNotFound ){
            NSRange hdrFwdRange = fwdHeader;
            hdrFwdRange.length = endFwdHeader.location+endFwdHeader.length-fwdHeader.location;
            NSString *headerString = [htmlMessage substringWithRange: hdrFwdRange];
            NSFont *font = [NSFont fontWithName: fontName size: [fontSize floatValue]];
            NSString *colorString = [NSString stringWithFormat: @"rgb(%2d, %2d, %2d)", (int)(color.redComponent*255), (int)(color.greenComponent*255), (int)(color.blueComponent*255)];
            NSString *newSpan = [NSString stringWithFormat: @"<span style=\"font-family: '%@'; font-size: %@%@; color: %@", font.familyName, fontSize, DEFAULT_GET_BOOL(UMUsePointsForFontSizes)?@"pt":@"px", colorString];
            headerString = [headerString stringByReplacingOccurrencesOfString: @"<span style=\"font-family:'Helvetica'; font-size:medium;"
                                                                   withString: newSpan];
            htmlMessage = [htmlMessage stringByReplacingCharactersInRange: hdrFwdRange withString: headerString];
        }
    }
    return htmlMessage;
}

+ (NSString*)stringWithFontStyleForHTML: (NSString*)htmlMessage {
    NSRange font = [htmlMessage rangeOfString: @"<font"];
    while( font.location != NSNotFound ){
        NSRange startingRange = NSMakeRange( font.location+1, htmlMessage.length-font.location-1 );
        NSRange endRange = [htmlMessage rangeOfString: @">" options: NSCaseInsensitiveSearch range: startingRange];
        NSString *fontTag = [htmlMessage substringWithRange: NSMakeRange( font.location, endRange.location+endRange.length-font.location )];
        UMParser *parser = [UMParser parserWithData: [fontTag dataUsingEncoding: NSUTF8StringEncoding]];
        NSString *newFontTag = [NSString stringWithFormat: @"<font class=\"%@\" style=\"%@; font-family: '%@'; font-size: %@%@; color: %@;\">",
                                [parser.XML valueForKeyPath: @"font.attributes.class"],
                                [[parser.XML valueForKeyPath: @"font.attributes.style"] length]>0?[[parser.XML valueForKeyPath: @"font.attributes.style"] stringByReplacingOccurrencesOfString: @"\"" withString: @"'"]:@"",
                                [parser.XML valueForKeyPath: @"font.attributes.face"]?[parser.XML valueForKeyPath: @"font.attributes.face"]:[[NSUserDefaults standardUserDefaults] objectForKey: @"NSFont"],
                                [kSizeLookupDictionary objectForKey: [parser.XML valueForKeyPath: @"font.attributes.size"]]?[kSizeLookupDictionary objectForKey: [parser.XML valueForKeyPath: @"font.attributes.size"]]:[[NSUserDefaults standardUserDefaults] objectForKey: @"NSFontSize"],
                                DEFAULT_GET_BOOL(UMUsePointsForFontSizes)?@"pt":@"px",
                                [parser.XML valueForKeyPath: @"font.attributes.color"]?[parser.XML valueForKeyPath: @"font.attributes.color"]:@"black"];
        htmlMessage = [htmlMessage stringByReplacingCharactersInRange: NSMakeRange( font.location, endRange.location+endRange.length-font.location ) withString: newFontTag];
        font = [htmlMessage rangeOfString: @"<font" options: NSCaseInsensitiveSearch range: startingRange];
    }
    
    return htmlMessage;
}

+ (NSString*)stringByReplacingClosingTagWithTag: (NSString*)newTag withHTML: (NSString*)htmlMessage {
    NSRange closingBody = [htmlMessage rangeOfString: @"</body></html>"];
    if( closingBody.location != NSNotFound ){
        htmlMessage = [htmlMessage stringByReplacingOccurrencesOfString: @"</body></html>" withString: newTag];
    }
    
    return htmlMessage;
}

@end
