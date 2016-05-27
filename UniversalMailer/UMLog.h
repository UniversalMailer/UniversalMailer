//
//  UMLog.h
//  UniversalMailer
//
//  Created by luca on 27/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define UMLog(s, ...) [UMLog logWithFormat: (s), ##__VA_ARGS__];

@interface UMLog: NSObject

+ (void)logWithFormat: (NSString*)format, ...;

@end
