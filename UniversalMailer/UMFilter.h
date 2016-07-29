//
//  UMFilter.h
//  UniversalMailer
//
//  Created by luca on 25/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMFilter : NSObject
@property (nonatomic) BOOL inlineAttachments;

- (id)initWithData: (NSData*)data;
- (NSData*)filteredDataByForcingHTML: (BOOL)forceHTML;

@end
