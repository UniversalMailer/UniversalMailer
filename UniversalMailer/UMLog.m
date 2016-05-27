//
//  UMLog.m
//  UniversalMailer
//
//  Created by luca on 27/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import "UMLog.h"

#import "UMConstants.h"

@implementation UMLog

+ (void)logWithFormat: (NSString*)format, ... {
    if( [[NSUserDefaults standardUserDefaults] boolForKey: UMLoggingEnabled] ){
        va_list args;
        NSString *outString;
        
        va_start(args, format);
        outString = [[NSString alloc] initWithFormat: format arguments: args];
        va_end(args);
        
        NSLog(@"%@", outString);
    }
}

@end
