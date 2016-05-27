//
//  UMMessageGenerator.h
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMMessageGenerator : NSObject

- (id)UMnewMessageWithAttributedString: (NSMutableAttributedString*)string headers: (id)headers;
- (id)UMnewMessageWithHtmlString: (NSString*)string html: (NSMutableAttributedString*)html other: (id)other headers: (id)headers;


@end
