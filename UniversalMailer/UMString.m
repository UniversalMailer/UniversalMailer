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

#import "UMString.h"

#import "Macros.h"

#import <regex.h>

@implementation UMString

@synthesize usedEncoding = _usedEncoding;

#pragma mark -
#pragma mark UMString new methods

- (BOOL)containsString: (NSString*)string {
    NSRange range = [_backingStore rangeOfString: string];
    if( range.location != NSNotFound ){
        return YES;
    }
    
    return NO;
}

- (BOOL)startsWithString: (NSString*)string {
    NSRange range = [_backingStore rangeOfString: string];
    if( range.location != NSNotFound && range.location == 0 ){
        return YES;
    }
    
    return NO;
}

- (BOOL)matchesRegularExpression: (NSString*)regularExpression {
    int status = 0;
    regex_t re;
    
    if( _backingStore.length < 1 )
        return NO;
    
    if( regcomp( &re, [regularExpression UTF8String], REG_EXTENDED | REG_NOSUB ) != 0 ){
        return NO;
    }
    
    status = regexec( &re, [_backingStore UTF8String], 0, NULL, 0 );
    
    regfree( &re );
    if( status == 0 ){
        return YES;
    }
    
    return NO;
}

- (NSArray*)splitUsingRegularExpression: (NSString*)regularExpression {
    int status = 0;
    regex_t re;
    regmatch_t rmatch[1];
    
    if( _backingStore.length < 1 )
        return nil;
    
    if( regcomp( &re, [regularExpression UTF8String], REG_EXTENDED) != 0 ){
        return nil;
    }
    
    NSMutableArray *matches = [NSMutableArray array];
    NSRange range;
    status = regexec( &re, [_backingStore UTF8String], 1, (regmatch_t*)&rmatch, 0 );
    if( status == 0 ){
        range = NSMakeRange( rmatch[0].rm_so, rmatch[0].rm_eo-rmatch[0].rm_so );
        [matches addObject: [_backingStore substringWithRange: range]];
    }
    while( !status ){
        range.location += rmatch[0].rm_eo-rmatch[0].rm_so;
        status = regexec( &re, [_backingStore UTF8String]+range.location, 1, (regmatch_t*)&rmatch, REG_NOTBOL );
        if( status == 0 ){
            range.location += rmatch[0].rm_so;
            range.length = rmatch[0].rm_eo-rmatch[0].rm_so;
            [matches addObject: [_backingStore substringWithRange: range]];
        }
    }
    
    regfree( &re );
    if( matches.count > 0 ){
        return matches;
    }
    
    return nil;
}

- (UMString*)stringByRemovingPatternsMatchingRE: (NSString*)regularExpression {
 	NSArray *ranges = [self rangesForRE: regularExpression];
    return [self substringByRemovingRanges: ranges];
}

- (NSArray*)extractSubstringsWithREPattern: (NSString*)regularExpression {
	NSArray *ranges = [self rangesForRE: regularExpression];
	NSMutableArray *results = [NSMutableArray array];
	for( NSValue *vRange in ranges ){
		NSRange range = [vRange rangeValue];
		[results addObject: [_backingStore substringWithRange: range]];
	}
	return results;
}

- (UMString*)substringByRemovingRanges: (NSArray*)ranges {
    if( ranges.count == 0 ){
        return [UMString stringWithString: _backingStore];
    }
    
    u_char *tmpString = (u_char*)calloc( sizeof(u_char), _backingStore.length );
    
    int currentRangeIndex = 0;
    int stringIndex = 0;
    NSRange range = [[ranges objectAtIndex: currentRangeIndex] rangeValue];
    for( int i=0; i<_backingStore.length; i++ ){
        if( i >= range.location+range.length && currentRangeIndex+1 < ranges.count ){
            currentRangeIndex++;
            range = [[ranges objectAtIndex: currentRangeIndex] rangeValue];
        }
        if( !NSLocationInRange( i, range ) ){
            tmpString[stringIndex++] = [_backingStore characterAtIndex: i];
        }
    }
    
    UMString *string = [UMString stringWithCString: (char*)tmpString encoding: _usedEncoding];
    free( tmpString );
    
    if( string.length < 1 )
        return [UMString stringWithString: _backingStore];
    
    return string;
}

- (NSArray*)rangesForRE: (NSString*)regularExpression {
    int status = 0;
    regex_t re;
    regmatch_t rmatch[1];
    
    if( _backingStore.length < 1 )
        return nil;
    
    if( regcomp( &re, [regularExpression UTF8String], REG_EXTENDED) != 0 ){
        return nil;
    }
    
    NSMutableArray *ranges = [NSMutableArray array];
    
    NSRange range;
    status = regexec( &re, [_backingStore cStringUsingEncoding: _usedEncoding], 1, (regmatch_t*)&rmatch, 0 );
    if( status == 0 ){
        range = NSMakeRange( rmatch[0].rm_so, rmatch[0].rm_eo-rmatch[0].rm_so );
        [ranges addObject: [NSValue valueWithRange: range]];
    }
    while( !status ){
        range.location += rmatch[0].rm_eo-rmatch[0].rm_so;
        status = regexec( &re, [_backingStore cStringUsingEncoding: _usedEncoding]+range.location, 1, (regmatch_t*)&rmatch, REG_NOTBOL );
        if( status == 0 ){
            range.location += rmatch[0].rm_so;
            range.length = rmatch[0].rm_eo-rmatch[0].rm_so;
            [ranges addObject: [NSValue valueWithRange: range]];
        }
    }
    
    regfree( &re );
	return ranges;
}

#pragma mark -
#pragma mark Primitive methods

+ (id)stringWithString:(NSString *)string {
    UMString *str = [[[self alloc] initWithString: string] autorelease];
    str.usedEncoding = str.smallestEncoding;
    return str;
}

+ (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc {
    UMString *str = [[[self alloc] initWithCString: cString encoding: enc] autorelease];
    str.usedEncoding = enc;
    return str;
}

- (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    if( (self = [super initWithCString: nullTerminatedCString encoding: encoding]) ){
        _usedEncoding = encoding;
    }
    
    return self;
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding {
    if( (self = [super init]) ){
        _backingStore = [[NSString alloc] initWithBytes: bytes length: length encoding: encoding]; 
    }
    
    return self;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)flag {
    if( (self = [super init]) ){
        _backingStore = [[NSString alloc] initWithBytesNoCopy: bytes length: length encoding: encoding freeWhenDone: flag];
    }
    
    return self;
}

- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList {
    if( (self = [super init]) ){
        _backingStore = [[NSString alloc] initWithFormat: format locale: locale arguments: argList]; 
    }
    
    return self;
}

- (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length {
    if( (self = [super init]) ){
        _backingStore = [[NSString alloc] initWithCharacters: characters length: length]; 
    }
    
    return self;
}

- (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer {
    if( (self = [super init]) ){
        _backingStore = [[NSString alloc] initWithCharactersNoCopy: characters length: length freeWhenDone: freeBuffer];
    }
    return self;
}

- (NSUInteger)length {
    return _backingStore.length;
}

- (unichar)characterAtIndex: (NSUInteger)index {
    return [_backingStore characterAtIndex: index];
}

#pragma mark -
#pragma mark NSObject management

- (void)dealloc {
    CLEAN_RELEASE( _backingStore );
    [super dealloc];
}

@end
