//
//  UMTextView.h
//  UniversalMailer
//
//  Created by luca on 29/07/2016.
//  Copyright © 2017 noware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class UMTextView;

@protocol UMTextViewDelegate <NSObject>
- (void)textChanged: (UMTextView*)textView;

@end

@interface UMTextView : NSTextView
@property (nonatomic, weak) id<UMTextViewDelegate> umDelegate;

@end
