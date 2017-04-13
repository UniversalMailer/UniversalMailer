//
//  NSString+UMExtensions.m
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2017 noware. All rights reserved.
//

#import "NSString+UMExtensions.h"

@implementation NSString (UMExtensions)

// To find new constants for encoding look here: http://www.opensource.apple.com/source/CF/CF-476.14/CFStringEncodingExt.h
- (NSStringEncoding)encodingForCharset {
    static struct { char *name; int encoding; BOOL foundation; } encodings [] = {
        {"ascii", NSASCIIStringEncoding, NO},
        {"us-ascii", NSASCIIStringEncoding, NO},
        {"default", NSASCIIStringEncoding, NO},
        {"utf-8", NSUTF8StringEncoding, NO},
        {"iso-8859-1", NSISOLatin1StringEncoding, NO},
        {"x-user-defined", NSISOLatin1StringEncoding, NO},
        {"unknown", NSISOLatin1StringEncoding, NO},
        {"x-unknown", NSISOLatin1StringEncoding, NO},
        {"unknown-8bit", NSISOLatin1StringEncoding, NO},
        {"0", NSISOLatin1StringEncoding, NO},
        {"", NSISOLatin1StringEncoding, NO},
        {"iso8859_1", NSISOLatin1StringEncoding, NO},
        {"iso-8859-2", NSISOLatin2StringEncoding, NO},
        {"iso-8859-3", kCFStringEncodingISOLatin3, YES},
        {"iso-8859-4", kCFStringEncodingISOLatin4, YES},
        {"iso-8859-5", kCFStringEncodingISOLatinCyrillic, YES},
        {"iso-8859-6", kCFStringEncodingISOLatinArabic, YES},
        {"iso-8859-7", kCFStringEncodingISOLatinGreek, YES},
        {"iso-8859-8", kCFStringEncodingISOLatinHebrew, YES},
        {"iso-8859-9", kCFStringEncodingISOLatin5, YES},
        {"iso-8859-10", kCFStringEncodingISOLatin6, YES},
        {"iso-8859-11", kCFStringEncodingISOLatinThai, YES},
        {"iso-8859-13", kCFStringEncodingISOLatin7, YES},
        {"iso-8859-14", kCFStringEncodingISOLatin8, YES},
        {"iso-8859-15", kCFStringEncodingISOLatin9, YES},
        {"iso-8859-15", kCFStringEncodingISOLatin10, YES},
        {"koi8-r", kCFStringEncodingKOI8_R, YES},
        {"big5", kCFStringEncodingBig5, YES},
        {"cn-big5", kCFStringEncodingBig5, YES},
        {"x-x-big5", kCFStringEncodingBig5, YES},
        {"big5-hkscs", kCFStringEncodingBig5_HKSCS_1999, YES},
        {"euc-kr", kCFStringEncodingEUC_KR, YES},
        {"ks_c_5601-1987", kCFStringEncodingEUC_KR, YES},
        {"gb2312", kCFStringEncodingGB_18030_2000, YES},
        {"shift_jis", kCFStringEncodingShiftJIS, YES},
        {"windows-1250", NSWindowsCP1250StringEncoding, NO},
        {"windows-1251", NSWindowsCP1251StringEncoding, NO},
        {"cyrillic NWEncodingMap(windows-1251)", NSWindowsCP1251StringEncoding, NO},
        {"windows-1252", NSWindowsCP1252StringEncoding, NO},
        {"windows-1253", NSWindowsCP1253StringEncoding, NO},
        {"windows-1254", NSWindowsCP1254StringEncoding, NO},
        {"windows-1255", kCFStringEncodingWindowsHebrew, YES},
        {"windows-1256", kCFStringEncodingWindowsArabic, YES},
        {"windows-1257", kCFStringEncodingWindowsBalticRim, YES},
        {"windows-1258", kCFStringEncodingWindowsVietnamese, YES},
        {"iso-2022-jp", NSISO2022JPStringEncoding, NO},
        {"euc-jp", NSJapaneseEUCStringEncoding, NO},
        {"x-euc-cn", kCFStringEncodingEUC_CN, YES},
        {"iso-2022-cn", kCFStringEncodingGB_18030_2000, YES},
        {"gb18030", kCFStringEncodingGB_18030_2000, YES},
        {"gbk", kCFStringEncodingGBK_95, YES}
    };
    
    const char *enc = [self cStringUsingEncoding: NSASCIIStringEncoding];
    for( int i=0; i<sizeof(encodings)/sizeof(encodings[0]); i++ ){
        if( strcmp(encodings[i].name, enc) == 0 ){
            if( encodings[i].foundation )
                return CFStringConvertEncodingToNSStringEncoding(encodings[i].encoding);
            else
                return encodings[i].encoding;
        }
    }
    return NSASCIIStringEncoding;
}

- (NSString*)decodeQuotedPrintableWithEncoding: (NSStringEncoding)encoding {
    NSDictionary *hexLookup = @{@"0": @0, @"1": @1, @"2": @2, @"3": @3,
                                @"4": @4, @"5": @5, @"6": @6, @"7": @7, @"8": @8, @"9": @9,
                                @"A": @10, @"B": @11, @"C": @12, @"D": @13, @"E": @14, @"F": @15,
                                };
    
    NSString *s = [self stringByReplacingOccurrencesOfString: @"=\n" withString: @""];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern: @"=$" options: 0 error: nil];
    NSMutableString *ms = [s mutableCopy];
    [regex replaceMatchesInString: ms options: 0 range: NSMakeRange(0, s.length) withTemplate: @""];
    
    NSData *d = [ms dataUsingEncoding: encoding];
    NSMutableData *outData = [NSMutableData data];
    for( NSInteger i=0; i<d.length; i++ ){
        char c = 0;
        [d getBytes: &c range: NSMakeRange(i, 1)];
        while( c == 0x3D ){
            char c1, c2;
            [d getBytes: &c1 range: NSMakeRange(i+1, 1)];
            [d getBytes: &c2 range: NSMakeRange(i+2, 1)];
            
            NSString *a = [NSString stringWithFormat: @"%c", c1];
            NSString *b = [NSString stringWithFormat: @"%c", c2];
            NSInteger h = [hexLookup[a] intValue]*16 + [hexLookup[b] intValue];
            [outData appendBytes: &h length: 1];
            
            i+=3;
            if( i<d.length )
                [d getBytes: &c range: NSMakeRange(i, 1)];
            else
                break;
        }
        if( i< d.length )
            [outData appendBytes: &c length: 1];
    }
    return [[NSString alloc] initWithData: outData encoding: encoding];
}

- (NSString*)encodeQuotedPrintable: (NSStringEncoding)encoding {
    char hexLookup[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    
    NSData *d = [self dataUsingEncoding: encoding];
    NSMutableData *outData = [NSMutableData data];
    int counter = 0;
    
    char c;
    for( int i=0; i<d.length; i++ ){
        if( counter >= 76 ){
            counter = 0;
            char c[] = { 0x3D, 0xA };
            [outData appendBytes: &c length: 2];
        }
        
        [d getBytes: &c range: NSMakeRange(i, 1)];
        
        if( c == 0xA || c == 0xD ){
            counter = 0;
        }
        
        if( c == 0x9 || c == 0xA || c == 0xD || (c > 0x1F && c != 0x3D && c< 0x7f) ){
            [outData appendBytes: &c length: 1];
            counter++;
        }
        else {
            counter += 3;
            if( counter >= 76 ){
                counter = 3;
                char c[] = { 0x3D, 0xA };
                [outData appendBytes: &c length: 2];
            }
            
            char cl = hexLookup[c & 0xF];
            char ch = hexLookup[(c>>4) & 0xF];
            char eq = 0x3D;
            [outData appendBytes: &eq length: 1];
            [outData appendBytes: &ch length: 1];
            [outData appendBytes: &cl length: 1];
        }
    }
    
    return [[NSString alloc] initWithData: outData encoding: encoding];
}

- (NSString*)base64decodeWithEncoding: (NSStringEncoding)encoding {
    NSData *data = [[NSData alloc] initWithBase64EncodedData: [self dataUsingEncoding: encoding] options: NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc] initWithData: data encoding: encoding];
}

- (NSString*)base64encodeWithEncoding: (NSStringEncoding)encoding {
    NSData *data = [self dataUsingEncoding: encoding];
    return [data base64EncodedStringWithOptions: NSDataBase64Encoding76CharacterLineLength | NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSString*)randomizeWithLength: (NSInteger)length {
    NSMutableString *s = [@"" mutableCopy];
    for( int i=0; i<length; i++ ){
        [s appendFormat: @"%c", [self characterAtIndex: arc4random_uniform((unsigned int)self.length)]];
    }
    return s;
}

@end
