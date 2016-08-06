//
//  UMMIMEEntity.m
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import "UMMIMEEntity.h"

#import "UMConstants.h"
#import "UMLog.h"
#import "NSString+UMExtensions.h"

@implementation UMMIMEBody

- (id)initWithString: (NSString*)string {
    if( self = [super init] ){
        self.string = string;
    }
    
    return self;
}

- (id)initWithSubentities: (NSArray*)entities {
    if( self = [super init] ){
        self.subentities = entities;
    }
    return self;
}

@end

@implementation UMMIMEEntity

- (id)initWithContentType: (NSString*)contentType {
    if( self = [super init] ){
        [self parseHeadersFromString: contentType];
        [self _parseBodyFromString: @""];
    }
    return self;
}

- (id)initWithString: (NSString*)string {
    if( self = [super init] ){
        [self _parseFromString: string];
    }
    return self;
}

- (id)initWithData: (NSData*)data {
    if( self = [super init] ){
        NSString *s = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        [self _parseFromString: s];
    }
    
    return self;
}

- (NSString*)description {
    return self.bodyString;
}

- (NSArray*)findSubentitiesOfType: (NSString*)type avoidAttachments: (BOOL)avoidAttachments invertMatches: (BOOL)invertMatches {
    NSMutableArray *array = [@[] mutableCopy];
    if( self.body.string.length > 0 ){
        NSRange r = [self.contentType rangeOfString: type];
        if( !invertMatches ){
            if( r.location != NSNotFound ){
                if( !avoidAttachments || !self.contentDisposition )
                    [array addObject: self];
            }
        }
        else {
            if( r.location == NSNotFound || (!avoidAttachments && self.contentDisposition.length > 0) ){
                [array addObject: self];
            }
        }
    }
    else {
        for( UMMIMEEntity *e in self.body.subentities ){
            [array addObjectsFromArray: [e findSubentitiesOfType: type avoidAttachments: avoidAttachments invertMatches: invertMatches]];
        }
    }
    
    return array;
}

- (void)setContentTypeParameterWithKey: (NSString*)key value: (NSString*)value {
    NSString* ct = self.headers[@"Content-Type"];
    if( ct.length > 0 ){
        BOOL found = NO;
        for( NSString *l in [ct componentsSeparatedByString: @";"] ){
            NSString *ll = [l stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSRange r = [ll rangeOfString: @"="];
            if( r.location != NSNotFound ){
                NSString *okey = [ll substringToIndex: r.location];
                if( [okey isEqualToString: key] ){
                    NSString *ovalue = [ll substringFromIndex: r.location+r.length];
                    ovalue = [ovalue stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\""]];
                    NSString *oldkv = [NSString stringWithFormat: @"%@=%@", okey, ovalue];
                    NSString *newkv = [NSString stringWithFormat: @"%@=%@", key, value];
                    NSString *oldct = self.headers[@"Content-Type"];
                    oldct = [oldct stringByReplacingOccurrencesOfString: oldkv withString: newkv];
                    self.headers[@"Content-Type"] = oldct;
                    found = YES;
                }
            }
            
        }
        
        if( !found ){
            NSString *s = [ct stringByAppendingFormat: @";\n %@=%@", key, value];
            self.headers[@"Content-Type"] = s;
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern: @"Content-Type: ([^\n]*)" options: 0 error: nil];
            NSArray *matches = [regex matchesInString: self.originalHeaders options: 0 range: NSMakeRange(0, self.originalHeaders.length)];
            if( matches.count > 0 ){
                NSString *s = [self.originalHeaders substringWithRange: [matches[0] rangeAtIndex: 0]];
                NSRange r = [s rangeOfString: @";"];
                if( r.location != NSNotFound ){
                    self.originalHeaders = [self.originalHeaders stringByReplacingOccurrencesOfString: s withString: [NSString stringWithFormat: @"%@\n\t%@=\"%@\";", s, key, value]];
                }
                else {
                    self.originalHeaders = [self.originalHeaders stringByReplacingOccurrencesOfString: s withString: [NSString stringWithFormat: @"%@;\n\t%@=\"%@\";", s, key, value]];
                }
            }
        }
    }
}

- (NSString*)charset {
    if( [self.headers[@"Content-Type"] length] > 0 ){
        for( NSString *l in [self.headers[@"Content-Type"] componentsSeparatedByString: @";"] ){
            NSString *ll = [l stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSRange r = [ll rangeOfString: @"="];
            if( r.location != NSNotFound ){
                NSString *key = [ll substringToIndex: r.location];
                if( [key isEqualToString: @"charset"] ){
                    NSString *value = [ll substringFromIndex: r.location+r.length];
                    return [value stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\""]];
                }
            }
        }
    }
    return nil;
}

- (void)setCharset: (NSString*)charset {
    UMLog(@"%s", __PRETTY_FUNCTION__);
    if( [self.headers[@"Content-Type"] length] > 0 ){
        self.originalHeaders = [self.originalHeaders stringByReplacingOccurrencesOfString: [NSString stringWithFormat: @"charset=\"%@\"", self.charset] withString: [NSString stringWithFormat: @"charset=\"%@\"", charset]];
        NSString *ct = self.headers[@"Content-Type"];
        ct = [ct stringByReplacingOccurrencesOfString: self.charset withString: charset];
        UMLog(@"Original Content-Type: [%@]", self.headers[@"Content-Type"]);
        UMLog(@"New Content-Type: [%@]", ct);
        self.headers[@"Content-Type"] = ct;
    }
}

- (NSString*)contentType {
    NSString *ct = self.headers[@"Content-Type"];
    NSArray *comps = [ct componentsSeparatedByString: @";"];
    if( comps.count > 0 ){
        return [[comps[0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\""]];
    }
    return @"";
}

- (void)setContentType: (NSString*)contentType {
    if( [self.headers[@"Content-Type"] length] > 0 ){
        self.originalHeaders = [self.originalHeaders stringByReplacingOccurrencesOfString: [NSString stringWithFormat: @"Content-Type: %@", self.contentType] withString: [NSString stringWithFormat: @"Content-Type: %@", contentType]];
        NSString *ct = self.headers[@"Content-Type"];
        ct = [ct stringByReplacingOccurrencesOfString: self.contentType withString: contentType];
        self.headers[@"Content-Type"] = ct;
    }
}

- (NSString*)contentDisposition {
    NSString *ct = self.headers[@"Content-Disposition"];
    NSArray *comps = [ct componentsSeparatedByString: @";"];
    if( comps.count > 0 )
        return [[comps[0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\""]];
    return nil;
}

- (void)setContentDisposition:(NSString *)contentDisposition {
    if( [self.headers[@"Content-Disposition"] length] > 0 ){
        self.originalHeaders = [self.originalHeaders stringByReplacingOccurrencesOfString: [NSString stringWithFormat: @"Content-Disposition: %@", self.contentDisposition] withString: [NSString stringWithFormat: @"Content-Disposition: %@", contentDisposition]];
        NSString *ct = self.headers[@"Content-Disposition"];
        ct = [ct stringByReplacingOccurrencesOfString: self.contentDisposition withString: contentDisposition];
        self.headers[@"Content-Disposition"] = ct;
    }
}

- (NSString*)contentID {
    return [[self.headers[@"Content-Id"] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""];
}

- (void)setContentID:(NSString *)contentID {
    if( self.contentID.length > 0 ){
        self.originalHeaders = [self.originalHeaders stringByReplacingOccurrencesOfString: [NSString stringWithFormat: @"Content-Id: %@", self.contentID] withString: [NSString stringWithFormat: @"Content-Id: %@", contentID]];
    }
    else {
        self.originalHeaders = [self.originalHeaders stringByAppendingFormat: @"\nContent-Id: %@", contentID];
    }
    self.headers[@"Content-Id"] = contentID;
}

- (NSString*)contentTransferEncoding {
    return self.headers[@"Content-Transfer-Encoding"];
}

- (void)setContentTransferEncoding: (NSString*)contentTransferEncoding {
    if( self.contentTransferEncoding.length > 0 ){
        self.originalHeaders = [self.originalHeaders stringByReplacingOccurrencesOfString: [NSString stringWithFormat: @"Content-Transfer-Encoding: %@", self.contentTransferEncoding] withString: [NSString stringWithFormat: @"Content-Transfer-Encoding: %@", contentTransferEncoding]];
        self.headers[@"Content-Transfer-Encoding"] = contentTransferEncoding;
    }
    else {
        self.headers[@"Content-Transfer-Encoding"] = contentTransferEncoding;
    }
}

- (NSString*)boundary {
    if( [self.headers[@"Content-Type"] length] > 0 ){
        for( NSString *l in [self.headers[@"Content-Type"] componentsSeparatedByString: @";"] ){
            NSString *ll = [l stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSRange r = [ll rangeOfString: @"="];
            if( r.location != NSNotFound ){
                NSString *key = [ll substringToIndex: r.location];
                if( [key isEqualToString: @"boundary"] ){
                    NSString *value = [ll substringFromIndex: r.location+r.length];
                    return [value stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @"\""]];
                }
            }
        }
    }
    return nil;
}

- (void)setBoundary: (NSString*)boundary {
    if( [self.headers[@"Content-Type"] length] > 0 ){
        NSString *ct = self.headers[@"Content-Type"];
        if( self.boundary.length > 0 ){
            self.originalHeaders = [self.originalHeaders stringByReplacingOccurrencesOfString: self.boundary withString: boundary];
            ct = [ct stringByReplacingOccurrencesOfString: self.boundary withString: boundary];
        }
        else {
            NSRange r = [self.originalHeaders rangeOfString: @"Content-Type"];
            NSInteger i = 0;
            for( i = r.location+r.length; i<self.originalHeaders.length; i++ ){
                if( [self.originalHeaders characterAtIndex: i] == '\n' ){
                    if( [self.originalHeaders characterAtIndex: i+1] == '\t' ||
                       [self.originalHeaders characterAtIndex: i+1] == ' ' ){
                        i+=2;
                    }
                    else {
                        i++;
                        break;
                    }
                }
            }
            NSString *pb = [self.originalHeaders substringToIndex: r.location];
            NSString *pm = nil;
            if( [self.originalHeaders characterAtIndex: i-1] == '\n' )
                pm = [self.originalHeaders substringWithRange: NSMakeRange(r.location, (i-1)-r.location)];
            else
                pm = [self.originalHeaders substringWithRange: NSMakeRange(r.location, i-r.location)];
            NSString *pa = [self.originalHeaders substringFromIndex: i];
            self.originalHeaders = [NSString stringWithFormat: @"%@%@;\n\tboundary=\"%@\"\n%@", pb, pm, boundary, pa];
            ct = [ct stringByAppendingFormat: @";\n\tboundary=\"%@\"", boundary];
        }
        self.headers[@"Content-Type"] = ct;
    }
}

- (NSString*)bodyString {
    if( self.body.string.length > 0 ){
        return [NSString stringWithFormat: @"%@\n\n%@", self.originalHeaders, self.body.string];
    }
    else {
        if( self.boundary.length < 1 ){
            self.boundary = [UMBoundaryAlphabet randomizeWithLength: 61];
        }
        NSMutableString *s = [@"" mutableCopy];
        for( UMMIMEEntity *e in self.body.subentities ){
            [s appendFormat: @"--%@\n", self.boundary];
            [s appendFormat: @"%@\n\n", e.bodyString];
        }
        [s appendFormat: @"--%@--", self.boundary];
        return [NSString stringWithFormat: @"%@\b\b%@", self.originalHeaders, s];
    }
}

- (NSString*)encodedBodyString {
    if( self.body.string.length > 0 ){
        if( self.contentTransferEncoding.length > 0 && self.charset.length > 0 ){
            if( [self.contentTransferEncoding isEqualToString: @"quoted-printable"] ){
                NSString *s = [self.body.string encodeQuotedPrintable: self.charset.encodingForCharset];
                return [NSString stringWithFormat: @"%@\n\n%@", self.originalHeaders, s];
            }
            else if( [self.contentTransferEncoding isEqualToString: @"base64"] ){
                NSString *s = [self.body.string base64encodeWithEncoding: self.charset.encodingForCharset];
                return [NSString stringWithFormat: @"%@\n\n%@", self.originalHeaders, s];
            }
        }
        return [NSString stringWithFormat: @"%@\n\n%@", self.originalHeaders, self.body.string];
    }
    else {
        if( self.boundary.length < 1 ){
            self.boundary = [UMBoundaryAlphabet randomizeWithLength: 61];
        }
        NSMutableString *s = [@"" mutableCopy];
        for( UMMIMEEntity *e in self.body.subentities ){
            [s appendFormat: @"--%@\n", self.boundary];
            [s appendFormat: @"%@\n\n", e.encodedBodyString];
        }
        [s appendFormat: @"--%@--", self.boundary];
        return [NSString stringWithFormat: @"%@\n\n%@", self.originalHeaders, s];
    }
    return @"";
}

#pragma mark -
#pragma mark Private methods

- (void)_parseFromString: (NSString*)string {
    NSRange r = [string rangeOfString: @"\n\n"];
    if( r.location != NSNotFound ){
        NSString *h = [string substringToIndex: r.location];
        NSString *b = [string substringFromIndex: r.location+r.length];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"\n$" options: 0L error: nil];
        b = [regex stringByReplacingMatchesInString: b options: 0L range: NSMakeRange(0, b.length) withTemplate: @""];
        regex = [NSRegularExpression regularExpressionWithPattern: @"^\n\n" options: 0L error: nil];
        b = [regex stringByReplacingMatchesInString: b options: 0L range: NSMakeRange(0, b.length) withTemplate: @""];
        
        [self parseHeadersFromString: h];
        if( self.boundary ){
            self.body = [self _parseBodyFromString: b];
        }
        else if( self.contentTransferEncoding.length > 0 && self.charset.length > 0 ){
            if( [self.contentTransferEncoding isEqualToString: @"quoted-printable"] ){
                self.body = [[UMMIMEBody alloc] initWithString: [b decodeQuotedPrintableWithEncoding: self.charset.encodingForCharset]];
            }
            else if( [self.contentTransferEncoding isEqualToString: @"base64"] ){
                self.body = [[UMMIMEBody alloc] initWithString: [b base64decodeWithEncoding: self.charset.encodingForCharset]];
            }
            else {
                self.body = [[UMMIMEBody alloc] initWithString: b];
            }
        }
        else {
            self.body = [[UMMIMEBody alloc] initWithString: b];
        }
    }
}

- (void)parseHeadersFromString: (NSString*)string {
    self.originalHeaders = string;
    self.headers = [@{} mutableCopy];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern: @"[\n\r]+[ \t]+" options: 0 error: nil];
    NSString *s = [regex stringByReplacingMatchesInString: string options: 0 range: NSMakeRange(0, string.length) withTemplate: @""];
    for( NSString *line in [s componentsSeparatedByString: @"\n"] ){
        NSRange sc = [line rangeOfString: @":"];
        if( sc.location != NSNotFound ){
            NSString *key = [line substringToIndex: sc.location];
            NSString *value = [[line substringFromIndex: sc.location+sc.length] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if( key && value ){
                self.headers[key] = value;
            }
        }
    }
}

- (UMMIMEBody*)_parseBodyFromString: (NSString*)string {
    NSMutableArray *entities = [@[] mutableCopy];
    if( self.boundary ){
        for( NSString *b in [string componentsSeparatedByString: [NSString stringWithFormat: @"--%@", self.boundary]] ){
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern: @"^[ \t\n\r]+" options: 0 error: nil];
            NSString *bb = [regex stringByReplacingMatchesInString: b options: 0 range: NSMakeRange(0, b.length) withTemplate: @""];
            if( bb.length > 0 && ![bb isEqualToString: @"--"] ){
                [entities addObject:[[UMMIMEEntity alloc] initWithString: bb]];
            }
        }
    }
    return [[UMMIMEBody alloc] initWithSubentities: entities];
}

@end
