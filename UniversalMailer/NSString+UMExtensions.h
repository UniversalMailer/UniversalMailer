//
//  NSString+UMExtensions.h
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2017 noware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UMExtensions)

- (NSStringEncoding)encodingForCharset;
- (NSString*)decodeQuotedPrintableWithEncoding: (NSStringEncoding)encoding;
- (NSString*)encodeQuotedPrintable: (NSStringEncoding)encoding;
- (NSString*)base64decodeWithEncoding: (NSStringEncoding)encoding;
- (NSString*)base64encodeWithEncoding: (NSStringEncoding)encoding;
- (NSString*)randomizeWithLength: (NSInteger)length;

@end
