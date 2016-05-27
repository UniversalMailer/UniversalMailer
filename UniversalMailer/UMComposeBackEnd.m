//
//  UMComposeBackEnd.m
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import "UMComposeBackEnd.h"

#import "UMConstants.h"
#import "UMLog.h"

@implementation UMComposeBackEnd

- (id)UMhtmlStringForSignature: (id)signature {
    NSString *ret = [self UMhtmlStringForSignature: signature];
    UMLog(@"%s - original signature: [%@]", __PRETTY_FUNCTION__, ret);
    ret = [ret stringByReplacingOccurrencesOfString: @"<DIV id=\"AppleMailSignature\" >"
                                                     withString: @"<DIV id=\"AppleMailSignature\" ><span id=\"" UMSignatureMarkerBegin "\">"];
    ret = [ret stringByReplacingOccurrencesOfString: @"</DIV>"
                                                     withString: @"<span id=\"" UMSignatureMarkerEnd "\"></DIV>"];
    UMLog(@"%s - modified signature: [%@]", __PRETTY_FUNCTION__, ret);
    return ret;
}

@end
