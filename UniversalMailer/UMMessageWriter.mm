// Copyright (C) 2012-2013 noware
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
// AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "UMMessageWriter.h"

#import <objc/runtime.h>

#import "MessageBeautifier.h"
#import "CommonHeaders.h"
#import <iostream>
#import <mimetic/mimetic.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <sys/time.h>
#import "UMString.h"
#import "Macros.h"

#import "NSString+UMExtensions.h"

#import "Constants.h"

using namespace std;
using namespace mimetic;

#define _kEncondingsDictionary [NSDictionary dictionaryWithObjectsAndKeys:\
[NSNumber numberWithInt: NSASCIIStringEncoding], @"us-ascii",\
[NSNumber numberWithInt: NSJapaneseEUCStringEncoding], @"euc-jp",\
[NSNumber numberWithInt: NSUTF8StringEncoding], @"utf-8",\
[NSNumber numberWithInt: NSISOLatin1StringEncoding], @"iso-8859-1",\
[NSNumber numberWithInt: NSISOLatin2StringEncoding], @"iso-8859-2",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin3)], @"iso-8859-3",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin4)], @"iso-8859-4",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinCyrillic)], @"iso-8859-5",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinCyrillic)], @"koi8-r",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinArabic)], @"iso-8859-6",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinGreek)], @"iso-8859-7",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinHebrew)], @"iso-8859-8",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin5)], @"iso-8859-9",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin6)], @"iso-8859-10",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinThai)], @"iso-8859-11",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin7)], @"iso-8859-13",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin8)], @"iso-8859-14",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin9)], @"iso-8859-15",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin10)], @"iso-8859-16",\
[NSNumber numberWithInt: NSWindowsCP1250StringEncoding], @"windows-1250",\
[NSNumber numberWithInt: NSWindowsCP1251StringEncoding], @"windows-1251",\
[NSNumber numberWithInt: NSWindowsCP1252StringEncoding], @"windows-1252",\
[NSNumber numberWithInt: NSWindowsCP1253StringEncoding], @"windows-1253",\
[NSNumber numberWithInt: NSWindowsCP1254StringEncoding], @"windows-1254",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsHebrew)], @"windows-1255",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsArabic)], @"windows-1256",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsBalticRim)], @"windows-1257",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsVietnamese)], @"windows-1258",\
[NSNumber numberWithInt: NSISO2022JPStringEncoding], @"iso-2022-jp",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_CN)], @"gb2312",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_CN)], @"x-euc-cn",\
[NSNumber numberWithLong: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_KR)], @"ks_c_5601-1987",\
nil]


#define _kSimmetricKey @"universal_mailer"
#define _kHTMLClosingTagWithDisclaimer @"LupiwffFF9z9BSKzjQU7aQ=="

NSString *md5( const char *string );
NSString *md5( const char *string ){
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

std::string decodeBody(MimeEntity* pMe, int tabcount);
std::string decodeBody(MimeEntity* pMe, int tabcount = 0) {
	Header& h = pMe->header();
	string ctype("text/html");
    cout << h.contentType().str() << endl;
	if( !h.contentType().str().compare( 0, ctype.size(), ctype ) ){
		if( !h.contentTransferEncoding().str().compare( "quoted-printable" ) ){
			QP::Decoder qp;
			pMe->body().code(qp);
		}
		if( !h.contentTransferEncoding().str().compare( "base64" ) ){
			Base64::Decoder qp;
			pMe->body().code(qp);
		}
	}
	return pMe->body();
}

bool deleteMimeEntity(MimeEntity* pMe, const char *newBodyEntity, char *charset, int tabcount );
bool deleteMimeEntity(MimeEntity* pMe, const char *newBodyEntity, char *charset = NULL, int tabcount = 0) {
    static bool found = false;
    
    if( tabcount == 0 )
        found = false;
    Header& h = pMe->header();
    if( !h.contentType().type().compare( "text" ) && !h.contentType().subtype().compare( "html" ) ){
        if( !found ){
            pMe->header().contentTransferEncoding().set("quoted-printable");
            if( charset )
                pMe->header().contentType().param( "charset", charset );
            else
                pMe->header().contentType().param( "charset", "utf-8" );
            pMe->body().assign(newBodyEntity);
            found = true;
        }
        else {
            if( strlen(h.contentDisposition().type().c_str()) > 0 &&
               (h.contentDisposition().type().compare("inline") ||
                h.contentDisposition().type().compare("attachment")) )
                return false;
            else
                return true;
        }
    }
    MimeEntityList& parts = pMe->body().parts();
    MimeEntityList::iterator mbit = parts.begin(), meit = parts.end();
    for(; mbit != meit; ++mbit){
        bool iterate = false;
        if( tabcount == 0 ){
            if( !h.contentType().type().compare( "multipart" ) && !h.contentType().subtype().compare( "alternative" ) )
                iterate = true;
        }
        else if( tabcount == 1 ){
            if( !h.contentType().type().compare( "multipart" ) &&
               (!h.contentType().subtype().compare( "mixed" ) || !h.contentType().subtype().compare( "related" )) )
                iterate = true;
        }
        if( iterate ){
            if( deleteMimeEntity(*mbit, newBodyEntity, charset, 1 + tabcount) )
                parts.erase( mbit );
        }
    }
    return false;
}

void updateCIDHeaders( MimeEntity *pMe, std::list<MimeEntity*> *cids );
void updateCIDHeaders( MimeEntity *pMe, std::list<MimeEntity*> *cids ){
    if( pMe->header().contentType().type().compare( "image" ) == 0 &&
       pMe->header().contentDisposition().type().compare( "inline" ) == 0 ){
        std::list<MimeEntity*>::iterator it;
        
        if( DEFAULT_GET_BOOL(UMDisableImageInlining) ){
            pMe->header().contentDisposition().set( "attachment" );
        }
		else if( !pMe->header().hasField("Content-ID") ){
            NSString *pmeMD5 = md5(pMe->body().c_str());
            for( it = cids->begin(); it != cids->end(); ++it ){
                NSString *cidMD5 = md5((*it)->body().c_str());
                if( [pmeMD5 isEqualToString: cidMD5] ){
                    printf( "Removing contentId %s\n", (*it)->header().contentId().str().c_str() );
                    pMe->header().contentId().set((*it)->header().contentId().str());
                    cids->erase(it);
                    std::list<MimeEntity*>::iterator it2;
                    for( it2 = cids->begin(); it2 != cids->end(); ++it2 ){
                        printf( "cid: %s\n", (*it2)->header().contentId().str().c_str() );
                    }
                    break;
                }
            }
        }
    }
    
    MimeEntityList& parts = pMe->body().parts();
    MimeEntityList::iterator mbit = parts.begin(), meit = parts.end();
    for(; mbit != meit; ++mbit){
        updateCIDHeaders( *mbit, cids );
    }
}

NSData *umMimeFilter( NSData *inData );
NSData *umMimeFilter( NSData *inData ) {
	NSData *returnData = nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	struct timeval tv;
	
	gettimeofday( &tv, NULL );
	srand( tv.tv_usec );
	long r = rand()*1.f/RAND_MAX*10000000;
	if( r < 0 )
		r *= -1;
    
    NSString *prefix = nil;
    if( ![[NSArray array] respondsToSelector: @selector(objectAtIndexedSubscript:)] ){ // Lion or below
        prefix = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex: 0];
    }
    else { // ML or above
        prefix = [[NSSearchPathForDirectoriesInDomains( NSApplicationSupportDirectory, NSUserDomainMask,  YES ) objectAtIndex: 0] stringByAppendingPathComponent: @"Mail/"];
    }
    NSString *fName = [NSString stringWithFormat: @"umailer-%ld.dat", r];
    NSString *tempFileName = [prefix stringByAppendingPathComponent: fName];
	[inData writeToFile: tempFileName atomically: NO];
    
	File inFile([tempFileName cStringUsingEncoding: NSUTF8StringEncoding]);
    
	MimeEntity me;
	me.load( inFile.begin(), inFile.end() );
    
    MimeEntityList &parts = me.body().parts();
	MimeEntityList::iterator mbit = parts.begin(), meit = parts.end();
    
	NSMutableString *finalHTMLString = [NSMutableString string];
    
	std::list<MimeEntity*> cids;
	std::list<MimeEntity*> attachments;
    
    NSMutableDictionary *charsetDictionary = [NSMutableDictionary dictionary];
    BOOL foundMultipart = NO;
    BOOL firstTextEntityFound = NO;
	for( ; mbit != meit; ++mbit ){
		if( (*mbit)->header().contentType().isMultipart() ){
            foundMultipart = YES;
            MimeEntityList &subparts = (*mbit)->body().parts();
            MimeEntityList::iterator bit = subparts.begin(), eit = subparts.end();
            for( ; bit != eit; ++bit ){
                MimeEntity *pMe = *bit;
                if( pMe->header().contentDisposition().type().compare("attachment") == 0 ||
                   pMe->header().contentDisposition().type().compare("inline") == 0 ){
                    if( pMe->header().contentType().type().compare( "image" ) == 0 &&
                       pMe->header().contentDisposition().type().compare( "inline" ) == 0 ){
                        if( DEFAULT_GET_BOOL(UMDisableImageInlining) ) {
                            if( pMe->header().hasField("Content-ID") ){
                                NSString *cid = [NSString stringWithCString: pMe->header().contentId().str().c_str() encoding: NSUTF8StringEncoding];
                                cid = [cid stringByReplacingOccurrencesOfString: @"<" withString: @""];
                                cid = [cid stringByReplacingOccurrencesOfString: @">" withString: @""];
                                cid = [NSString stringWithFormat: @"cid:%@\">", cid];
                                NSRange cidRange = [finalHTMLString rangeOfString: cid];
                                if( cidRange.location != NSNotFound ){
                                    NSRange searchRange;
                                    searchRange.location = 0;
                                    searchRange.length = cidRange.location;
                                    NSRange startCidRange = [finalHTMLString rangeOfString: @"<img" options: NSBackwardsSearch range: searchRange];
                                    if( startCidRange.location != NSNotFound ){
                                        NSRange deleteRange;
                                        deleteRange.location = startCidRange.location;
                                        deleteRange.length = cidRange.location+cidRange.length-startCidRange.location;
                                        [finalHTMLString replaceCharactersInRange: deleteRange withString: @""];
                                    }
                                }
                            }
                            attachments.insert( attachments.end(), pMe );
                        }
                        else if( !pMe->header().hasField("Content-ID") ){
                            gettimeofday( &tv, NULL );
                            srand( tv.tv_usec );
                            long r = rand()*1.f/RAND_MAX*10000000;
                            if( r < 0 )
                                r *= -1;
                        	NSString *cid = [NSString stringWithFormat: @"%ld%.0f@%@", r, [NSDate timeIntervalSinceReferenceDate]*1000000, md5(pMe->header().from().str().c_str())];
                        	pMe->header().contentId().set( [cid cStringUsingEncoding: NSUTF8StringEncoding] );
                            [finalHTMLString appendFormat: @"<img src=\"cid:%@\">", cid];
                            cids.insert( cids.end(), pMe );
                        }
                    }
                    else {
                        attachments.insert( attachments.end(), pMe );
                    }
                }
                else if( !(*bit)->header().contentType().type().compare( "text" ) && !(*bit)->header().contentType().subtype().compare( "html" ) ){
                    if( !firstTextEntityFound ){
                        [finalHTMLString appendString: @"<html><head></head><body>"];
                        firstTextEntityFound = YES;
                    }
                    string decodedBody = decodeBody(*bit);
                    NSString *charset = [[NSString stringWithCString: (*bit)->header().contentType().str().c_str() encoding: NSUTF8StringEncoding] lowercaseString];
                    NSArray *elements = [charset componentsSeparatedByString: @";"];
                    for( NSString *s in elements ){
                        UMString *str = [UMString stringWithString: [s stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \t"]]];
                        if( [str startsWithString: @"charset="] ){
                            str = [str stringByRemovingPatternsMatchingRE: @"charset="];
                            charset = [str stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \t\""]];
                        }
                    }
                    if( ![charset isEqualToString: @"us-ascii"] )
                        [charsetDictionary setObject: [NSNumber numberWithBool:YES] forKey: charset];
                    NSStringEncoding encoding = [[_kEncondingsDictionary objectForKey: charset] intValue];
                    if( encoding < 1 )
                        encoding = NSUTF8StringEncoding;
                    UMString *str = [[[UMString alloc] initWithCString: decodedBody.c_str() encoding: encoding] autorelease];
                    str = [UMString stringWithString: [str stringByReplacingOccurrencesOfString: @"<html>" withString: @""]];
                    NSRange chtmlRange = [str rangeOfString: @"</html>"];
                    if( chtmlRange.location != NSNotFound ){
                        chtmlRange.length = str.length - chtmlRange.location;
                        str = [UMString stringWithString: [str stringByReplacingCharactersInRange: chtmlRange withString: @""]];
                    }
                    NSRange headStartRange = [str rangeOfString: @"<head>"];
                    NSRange headEndRange = [str rangeOfString: @"</head>"];
                    if( headEndRange.location != NSNotFound && headStartRange.location != NSNotFound ){
                        NSRange remRange;
                        remRange.location = headStartRange.location;
                        remRange.length = (headEndRange.location+headEndRange.length)-headStartRange.location;
                        str = [UMString stringWithString: [str stringByReplacingCharactersInRange: remRange withString: @""]];
                    }
                    str = [str stringByRemovingPatternsMatchingRE: @"<head>.*</head>"];
                    str = [UMString stringWithString: [str stringByReplacingOccurrencesOfString: @"<body" withString: @"<div"]];
                    str = [UMString stringWithString: [str stringByReplacingOccurrencesOfString: @"</body>" withString: @"</div>"]];
                    [finalHTMLString appendString: str];
                }
            }
		}
        else if( !(*mbit)->header().contentType().type().compare( "text" ) && !(*mbit)->header().contentType().subtype().compare( "html" ) ){
            if( !firstTextEntityFound ){
                [finalHTMLString appendString: @"<html><head></head><body>"];
                firstTextEntityFound = YES;
            }
            string decodedBody = decodeBody(*mbit);
            NSString *charset = [NSString stringWithCString: (*mbit)->header().contentType().str().c_str() encoding: NSUTF8StringEncoding];
            NSArray *elements = [charset componentsSeparatedByString: @";"];
            for( NSString *s in elements ){
                UMString *str = [UMString stringWithString: [s stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \t"]]];
                if( [str startsWithString: @"charset="] ){
                    str = [str stringByRemovingPatternsMatchingRE: @"charset="];
                    charset = [str stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \t\""]];
                }
            }
            if( ![[charset lowercaseString] isEqualToString: @"us-ascii"] )
                [charsetDictionary setObject: [NSNumber numberWithBool:YES] forKey: charset];
            NSStringEncoding encoding = [[_kEncondingsDictionary objectForKey: charset] intValue];
            if( encoding < 1 )
                encoding = NSUTF8StringEncoding;
            UMString *str = [[[UMString alloc] initWithCString: decodedBody.c_str() encoding: encoding] autorelease];
            str = [UMString stringWithString: [str stringByReplacingOccurrencesOfString: @"<html>" withString: @""]];
            NSRange chtmlRange = [str rangeOfString: @"</html>"];
            if( chtmlRange.location != NSNotFound ){
                chtmlRange.length = str.length - chtmlRange.location;
                str = [UMString stringWithString: [str stringByReplacingCharactersInRange: chtmlRange withString: @""]];
            }
            NSRange headStartRange = [str rangeOfString: @"<head>"];
            NSRange headEndRange = [str rangeOfString: @"</head>"];
            if( headEndRange.location != NSNotFound && headStartRange.location != NSNotFound ){
                NSRange remRange;
                remRange.location = headStartRange.location;
                remRange.length = (headEndRange.location+headEndRange.length)-headStartRange.location;
                str = [UMString stringWithString: [str stringByReplacingCharactersInRange: remRange withString: @""]];
            }
            str = [str stringByRemovingPatternsMatchingRE: @"<head>.*</head>"];
            str = [UMString stringWithString: [str stringByReplacingOccurrencesOfString: @"<body" withString: @"<div"]];
            str = [UMString stringWithString: [str stringByReplacingOccurrencesOfString: @"</body>" withString: @"</div>"]];
            [finalHTMLString appendString: str];
        }
	}
    
    char *charset = NULL;
    if( charsetDictionary.count != 1 )
        charset = (char*)"utf-8";
    else
        charset = (char*)[[[charsetDictionary allKeys] objectAtIndex: 0] cStringUsingEncoding: NSASCIIStringEncoding];
	if( finalHTMLString.length > 0 ){
    	[finalHTMLString appendString: [_kHTMLClosingTagWithDisclaimer AES256DecryptWithKey: _kSimmetricKey]];
        
    	NSString *completeHTML = [NSString stringWithString: finalHTMLString];
    	if( DEFAULT_GET_BOOL(UMFontFilterEnabled) ){
        
        	NSString *font = DEFAULT_GET( UMOutgoingFontName );
        	NSString *fontSize = DEFAULT_GET( UMOutgoingFontSize );
            NSData *colorData = DEFAULT_GET(UMOutgoingFontColor);
            NSColor *color = [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            if( colorData )
                color = [[NSUnarchiver unarchiveObjectWithData: colorData] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            
            completeHTML = [MessageBeautifier stringByAddingBodyFontStyleToHTML: completeHTML withFontName: font andFontSize: fontSize fontColor: color];
            completeHTML = [MessageBeautifier stringByChangingForwardHeaderStyle: completeHTML withFontName: font andFontSize: fontSize fontColor: color];
    	}
        MimeEntity *textEntity = new MimeEntity;
        textEntity->body().assign( [completeHTML cStringUsingEncoding: [[_kEncondingsDictionary objectForKey: [NSString stringWithCString: charset encoding: NSASCIIStringEncoding]] intValue]] );
        QP::Encoder qpenc;
        textEntity->body().code(qpenc);
        
        finalHTMLString = [NSMutableString stringWithCString: textEntity->body().c_str() encoding: NSISOLatin1StringEncoding];
	}
    
	MimeEntity cleanEntity;
	cleanEntity.load( inFile.begin(), inFile.end() );
    deleteMimeEntity( &cleanEntity, [finalHTMLString cStringUsingEncoding: [[_kEncondingsDictionary objectForKey: [NSString stringWithCString: charset encoding: NSUTF8StringEncoding]] intValue]], charset );
    updateCIDHeaders( &cleanEntity, &cids );
    
	ofstream of([tempFileName cStringUsingEncoding: NSUTF8StringEncoding]);
	of << cleanEntity << endl;
    
    NSString *outString = [NSString stringWithContentsOfFile: tempFileName encoding: NSUTF8StringEncoding error: nil];
    outString = [outString stringByReplacingOccurrencesOfString: @"\r" withString: @""];    
	returnData = [[outString dataUsingEncoding: NSUTF8StringEncoding] copy];
    
#ifdef RELEASE_VERSION
	[[NSFileManager defaultManager] removeItemAtPath: tempFileName error: nil];
#endif
    
	[pool release];
    
	return [returnData autorelease];
}

@implementation MessageWriter (UMMessageWriterExtensions)

- (void)_logMessage: (OutgoingMessage*) message prefix: (NSString*)prefix {
#ifndef RELEASE_VERSION
	struct timeval tv;
	
	gettimeofday( &tv, NULL );
	srand( tv.tv_usec );
	long r = rand()*1.f/RAND_MAX*10000000;
	if( r < 0 )
		r *= -1;
    
    if( [message class] == [OutgoingMessage class] && message.sender ){
        NSString *prefixDir = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex: 0];
        NSString *fName = [NSString stringWithFormat: @"umailer-%@-%d.dat", prefix];
        NSString *tempFileName = [prefixDir stringByAppendingPathComponent: fName];
        [[message messageDataIncludingFromSpace: YES] writeToFile: tempFileName atomically: NO];
        NSString *messageDataString = [[[NSString alloc] initWithData: [message messageDataIncludingFromSpace: YES] encoding: NSUTF8StringEncoding] autorelease];
    }
#endif
}

- (id)umNewMessageWithAttributedString:(id)arg1 headers:(id)arg2 {
    OutgoingMessage *message = [self umNewMessageWithAttributedString: arg1 headers: arg2];
    // Avoid breaking signed messages (should be a problem for S/MIME too, it's definitely a problem for GPGMail.)
	if([self respondsToSelector:@selector(signsOutput)] && [self signsOutput])
		return message;
	
    [self _logMessage: message prefix: @"pre"];
    NSAttributedString *string = arg1;
    int *array = (int*)calloc( sizeof(int), string.length );
    [string enumerateAttributesInRange: NSMakeRange(0, string.length) options: NULL usingBlock: ^(NSDictionary *dictionary, NSRange range, BOOL *stop){
        if( [dictionary objectForKey: NSAttachmentAttributeName] )
            for( NSUInteger i=range.location; i<range.location+range.length; i++ )
                array[i] = 1;
    }];
    BOOL hasText = NO;
    for( NSUInteger i=0; i<string.length; i++ )
        if( array[i] == 0 ){
            hasText = YES;
            break;
        }
    free( array );
    if( hasText && [message class] == [OutgoingMessage class] && message.sender ){
        if( DEFAULT_GET_BOOL(UMMailFilterEnabled) ){
            NSData *filteredData = umMimeFilter([message messageDataIncludingFromSpace: YES]);
            if( [message respondsToSelector: @selector(setRawData:)] )
                [message setRawData: filteredData];
            else if( [message respondsToSelector: @selector(setRawData:offsetOfBody:)] ){
                [message setRawData: filteredData offsetOfBody: 0];
            }
            else if( [message respondsToSelector: @selector(_setRawData:)] )
                [message _setRawData: filteredData];
            else {
                [filteredData retain];
                object_setInstanceVariable( message, "_rawData", filteredData );
            }
        }
    }
    [self _logMessage: message prefix: @"post"];

    return message;
}

- (id)umNewMessageWithHtmlString:(id)arg1 attachments:(NSArray*)arg2 headers:(id)arg3 {
    // Avoid breaking signed messages (should be a problem for S/MIME too, it's definitely a problem for GPGMail.)
	if([self respondsToSelector:@selector(signsOutput)] && [self signsOutput])
		return [self umNewMessageWithHtmlString:arg1 attachments:arg2 headers:arg3];
	
    if( arg2.count == 0 ){
        if( DEFAULT_GET_BOOL(UMMailFilterEnabled) )
            arg1 = [MessageBeautifier stringByReplacingClosingTagWithTag: [_kHTMLClosingTagWithDisclaimer AES256DecryptWithKey: _kSimmetricKey] withHTML: arg1];
        if( DEFAULT_GET_BOOL(UMFontFilterEnabled) ){
            NSString *font = DEFAULT_GET( UMOutgoingFontName );
            NSString *fontSize = DEFAULT_GET( UMOutgoingFontSize );
            NSData *colorData = DEFAULT_GET(UMOutgoingFontColor);
            NSColor *color = [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            if( colorData )
                color = [[NSUnarchiver unarchiveObjectWithData: colorData] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            arg1 = [MessageBeautifier stringByAddingBodyFontStyleToHTML: arg1 withFontName: font andFontSize: fontSize fontColor: color];
            arg1 = [MessageBeautifier stringByChangingForwardHeaderStyle: arg1 withFontName: font andFontSize: fontSize fontColor: color];
        }
    }
    OutgoingMessage *message = [self umNewMessageWithHtmlString: arg1 attachments: arg2 headers: arg3];
    [self _logMessage: message prefix: @"pre"];
    if( arg2.count > 0 && [message class] == [OutgoingMessage class] && message.sender ){    
        if( DEFAULT_GET_BOOL(UMMailFilterEnabled) ){
            NSData *filteredData = umMimeFilter([message messageDataIncludingFromSpace: YES]);
            if( [message respondsToSelector: @selector(setRawData:)] )
                [message setRawData: filteredData];
            else if( [message respondsToSelector: @selector(setRawData:offsetOfBody:)] ){
                [message setRawData: filteredData offsetOfBody: 0];
            }
            else if( [message respondsToSelector: @selector(_setRawData:)] )
                [message _setRawData: filteredData];
            else {
                [filteredData retain];
                object_setInstanceVariable( message, "_rawData", filteredData );
            }
        }
    }
    [self _logMessage: message prefix: @"post"];

    return message;
}

- (id)umNewMessageWithHtmlString:(id)arg1 plainTextAlternative:(id)arg2 otherHtmlStringsAndAttachments:(NSArray*)arg3 headers:(id)arg4 {
	// Avoid breaking signed messages (should be a problem for S/MIME too, it's definitely a problem for GPGMail.)
	if([self respondsToSelector:@selector(signsOutput)] && [self signsOutput])
		return [self umNewMessageWithHtmlString:arg1 plainTextAlternative:arg2 otherHtmlStringsAndAttachments:arg3 headers:arg4];
	
    if( arg3.count == 0 ){
        if( DEFAULT_GET_BOOL(UMMailFilterEnabled) )
            arg1 = [MessageBeautifier stringByReplacingClosingTagWithTag: [_kHTMLClosingTagWithDisclaimer AES256DecryptWithKey: _kSimmetricKey] withHTML: arg1];
        if( DEFAULT_GET_BOOL(UMFontFilterEnabled) ){
            NSString *font = DEFAULT_GET( UMOutgoingFontName );
            NSString *fontSize = DEFAULT_GET( UMOutgoingFontSize );
            NSData *colorData = DEFAULT_GET(UMOutgoingFontColor);
            NSColor *color = [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            if( colorData )
                color = [[NSUnarchiver unarchiveObjectWithData: colorData] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            arg1 = [MessageBeautifier stringByAddingBodyFontStyleToHTML: arg1 withFontName: font andFontSize: fontSize fontColor: color];
            arg1 = [MessageBeautifier stringByChangingForwardHeaderStyle: arg1 withFontName: font andFontSize: fontSize fontColor: color];
        }
    }
    OutgoingMessage *message = [self umNewMessageWithHtmlString: arg1 plainTextAlternative: arg2 otherHtmlStringsAndAttachments: arg3 headers: arg4];    
    [self _logMessage: message prefix: @"pre"];
    if( arg3.count > 0 && [message class] == [OutgoingMessage class] && message.sender ){    
        if( DEFAULT_GET_BOOL(UMMailFilterEnabled) ){
            [self _dumpMethodsForClass: [message class]];
            NSData *filteredData = umMimeFilter([message messageDataIncludingFromSpace: YES]);
            if( [message respondsToSelector: @selector(setRawData:)] ){
                [message setRawData: filteredData];
            }
            else if( [message respondsToSelector: @selector(setRawData:offsetOfBody:)] ){
                [message setRawData: filteredData offsetOfBody: 0];
            }
            else if( [message respondsToSelector: @selector(_setRawData:)] ){
                [message _setRawData: filteredData];
            }
            else {
                [filteredData retain];
                object_setInstanceVariable( message, "_rawData", filteredData );
            }
        }
    }
    [self _logMessage: message prefix: @"post"];
    
    return message;
}

- (void)_dumpMethodsForClass: (Class)aClass {
#ifndef RELEASE_VERSION
    Class currentClass = aClass;
    unsigned int count = 0;
    NSMutableString *methodList = [NSMutableString string];
    NSMutableString *propertyList = [NSMutableString string];
    while( currentClass ){
        Method *methods = class_copyMethodList( currentClass, &count );
        for( int i=0; i<count; i++ ){
            [methodList appendString: [NSString stringWithCString: sel_getName(method_getName(methods[i]))
                                                         encoding: NSUTF8StringEncoding]];
            [methodList appendString: @" /// "];
        }
        
        Ivar *properties = class_copyIvarList( currentClass, &count );
        for( int i=0; i<count; i++ ){
            [propertyList appendString: [NSString stringWithCString: ivar_getName(properties[i])
                                                         encoding: NSUTF8StringEncoding]];
            [propertyList appendString: @" /// "];
        }
        
        currentClass = class_getSuperclass(currentClass);
    }
#endif
}

@end
