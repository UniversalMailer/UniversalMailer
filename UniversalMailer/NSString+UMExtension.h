//
//  NSString+UMExtension.h
//  UniversalMailer
//
//  Created by luca on 23/06/13.
//  Copyright (c) 2013 noware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UMExtension)

- (BOOL)containsString: (NSString*)string;
- (BOOL)startsWithString: (NSString*)string;
- (NSString*)stringByRemovingPatternsMatchingRE: (NSString*)regexString;

@end
