//
//  NSString+UMExtension.m
//  UniversalMailer
//
//  Created by luca on 23/06/13.
//  Copyright (c) 2013 noware. All rights reserved.
//

#import "NSString+UMExtension.h"

@implementation NSString (UMExtension)

- (BOOL)containsString: (NSString*)string {
    NSRange range = [self rangeOfString: string];
    if( range.location != NSNotFound )
        return YES;
    
    return NO;
}

- (BOOL)startsWithString: (NSString*)string {
    NSRange range = [self rangeOfString: string];
    if( range.location != NSNotFound && range.location == 0 )
        return YES;
    
    return NO;
}

- (NSString*)stringByRemovingPatternsMatchingRE: (NSString*)regexString {
    NSMutableArray *ranges = [@[] mutableCopy];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: regexString
                                                                           options: NSRegularExpressionCaseInsensitive
                                                                             error: nil];
    [regex enumerateMatchesInString: self
                            options: 0
                              range: NSMakeRange(0, self.length)
                         usingBlock: ^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             [ranges addObject: match];
                         }];
    return [self substringByRemovingTextMatches: ranges];
}

- (NSString*)substringByRemovingTextMatches: (NSArray*)matches {
    if( matches.count == 0 )
        return self;
    
    NSMutableString *tmpString = [@"" mutableCopy];
    
    int currentRangeIndex = 0;
    NSRange range = [matches[currentRangeIndex] range];
    for( int i=0; i<self.length; i++ ){
        if( i >= range.location+range.length && currentRangeIndex+1 < matches.count ){
            currentRangeIndex++;
            range = [matches[currentRangeIndex] range];
        }
        if( !NSLocationInRange( i, range ) )
            [tmpString appendString: [self substringWithRange: NSMakeRange( i, 1 )]];
    }
    
    if( tmpString.length < 1 )
        return self;
    
    return tmpString;
}

@end
