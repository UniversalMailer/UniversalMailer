//
//  MCMessageGenerator+UMExtensions.h
//  UniversalMailer
//
//  Created by luca on 14/11/13.
//  Copyright (c) 2013 noware. All rights reserved.
//

#import "MailCore.h"

@interface MCMessageGenerator (UMExtensions)

- (id)UMnewMessageWithHtmlStringP: (id)str plain: (id)plain other: (NSArray*)other hdrs: (id)hdrs;

@end
