//
//  UMSharedPreferences.h
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2017 noware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPreferences: NSObject
@end

@interface NSPreferences (UMExtensions)

+ (id)UMsharedPreferences;

@end
