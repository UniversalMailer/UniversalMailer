//
//  UMTextView.m
//  UniversalMailer
//
//  Created by luca on 29/07/2016.
//  Copyright © 2016 noware. All rights reserved.
//

#import "UMTextView.h"

@implementation UMTextView

- (void)didChangeText {
    if( [self.umDelegate respondsToSelector: @selector(textChanged:)] ){
        [self.umDelegate textChanged: self];
    }
}

@end
