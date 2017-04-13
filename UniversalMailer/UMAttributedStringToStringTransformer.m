//
//  UMAttributedStringToStringTransformer.m
//  testUMPreferences
//
//  Created by luca on 26/05/16.
//  Copyright © 2017 noware. All rights reserved.
//

#import "UMAttributedStringToStringTransformer.h"

@implementation UMAttributedStringToStringTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

- (id)transformedValue: (id)value {
    if( [value isKindOfClass: [NSAttributedString class]] ){
        return [value string];
    }
    return nil;
}

@end
