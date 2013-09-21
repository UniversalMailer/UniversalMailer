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

#import "UMStyleFilter.h"

@implementation UMStyleFilter {
    NSString *_input;
    NSFont *_font;
    NSString *_fontSize;
    NSColor *_fontColor;
    BOOL _usePoints;
}

+ (UMStyleFilter*)filterString: (NSString*)input withFontName: (NSString*)fontName fontSize: (NSString*)fontSize fontColor: (NSColor*)fontColor usePoints: (BOOL)usePoints {
    return [[self alloc] initWithString: input fontName: fontName fontSize: fontSize fontColor: fontColor usePoints: usePoints];
}

- (id)initWithString: (NSString*)input fontName: (NSString*)fontName fontSize: (NSString*)fontSize fontColor: (NSColor*)fontColor usePoints: (BOOL)usePoints {
    if( self = [super init] ){
        _input = input;
        _font = [NSFont fontWithName: fontName size: fontSize.floatValue];
        _fontColor = fontColor;
        _fontSize = fontSize;
        _usePoints = usePoints;
    }
    
    return self;
}

- (NSString*)styleString {
    NSString *color = [NSString stringWithFormat: @"rgb(%2d, %2d, %2d)",
                       (int)(_fontColor.redComponent*255),
                       (int)(_fontColor.greenComponent*255),
                       (int)(_fontColor.blueComponent*255)];
    NSString *style = [NSString stringWithFormat: @"font-family: '%@'; font-size: %@%@; color: %@;",
                       _font.familyName,
                       _fontSize,
                       _usePoints?@"pt":@"px",
                       color];
    
    return style;
}

- (NSString*)filteredString {
    NSMutableString *modifiedString = [_input mutableCopy];

    // Enclose body content into <span> element
    NSString *spanString = [NSString stringWithFormat: @"<span style=\"%@\">", self.styleString];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"<body[^>]*>"
                                                                           options: NSRegularExpressionCaseInsensitive
                                                                             error: nil];
    [regex enumerateMatchesInString: _input
                            options: 0
                              range: NSMakeRange(0, _input.length)
                         usingBlock: ^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             NSInteger insertionPoint = match.range.location+match.range.length;
                             [modifiedString insertString: spanString atIndex: insertionPoint];
                             *stop = YES;
    }];
    [modifiedString replaceOccurrencesOfString: @"</body>"
                                    withString: @"</span></body>"
                                       options: NSCaseInsensitiveSearch
                                         range: NSMakeRange( 0, modifiedString.length )];
    
    // Fix font for forward header
    NSRange fwdHeader = [modifiedString rangeOfString: @":</div><br class=\"Apple-interchange-newline\"><blockquote type=\"cite\">"];
    if( fwdHeader.location != NSNotFound ){
        NSRange searchRange = fwdHeader;
        searchRange.length = modifiedString.length-fwdHeader.location;
        NSRange endFwdHeader = [modifiedString rangeOfString: @"<br></span></div><br>" options: NSCaseInsensitiveSearch range: searchRange];
        if( endFwdHeader.location != NSNotFound ){
            NSRange hdrFwdRange = fwdHeader;
            hdrFwdRange.length = endFwdHeader.location+endFwdHeader.length-fwdHeader.location;
            NSString *headerString = [modifiedString substringWithRange: hdrFwdRange];
            headerString = [headerString stringByReplacingOccurrencesOfString: @"<span style=\"font-family:'Helvetica'; font-size:medium;"
                                                                   withString: spanString];
            [modifiedString replaceCharactersInRange: hdrFwdRange withString: headerString];
        }
    }
    
    // Fix <ul> top and bottom margin for Exchange clients
    [modifiedString replaceOccurrencesOfString: @"<ul class=\"MailOutline\">"
                                    withString: @"<ul class=\"MailOutline\" style=\"margin-top: 0px; margin-bottom: 0px;\">"
                                       options: NSCaseInsensitiveSearch
                                         range: NSMakeRange( 0, modifiedString.length )];

    return modifiedString;
}

@end
