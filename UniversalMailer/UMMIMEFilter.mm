// Copyright (C) 2013 noware
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

#import "UMMIMEFilter.h"

#import <sys/time.h>
#import <iostream>
#import <mimetic/mimetic.h>
#import <CommonCrypto/CommonDigest.h>

#import "Constants.h"
#import "UniversalMailer.h"
#import "NSString+UMExtension.h"
#import "UMStyleFilter.h"

NSString *md5( const char *string );
NSString *md5( const char *string ){
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), result);
    NSMutableString *hash = [@"" mutableCopy];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

std::string decodeBody(mimetic::MimeEntity* pMe, int tabcount);
std::string decodeBody(mimetic::MimeEntity* pMe, int tabcount = 0) {
    mimetic::Header& h = pMe->header();
    std::string ctype("text/html");
    std::cout << h.contentType().str() << std::endl;
	if( !h.contentType().str().compare( 0, ctype.size(), ctype ) ){
		if( !h.contentTransferEncoding().str().compare( "quoted-printable" ) ){
            mimetic::QP::Decoder qp;
			pMe->body().code(qp);
		}
		if( !h.contentTransferEncoding().str().compare( "base64" ) ){
            mimetic::Base64::Decoder qp;
			pMe->body().code(qp);
		}
	}
	return pMe->body();
}

bool deleteMimeEntity(mimetic::MimeEntity* pMe, const char *newBodyEntity, char *charset, int tabcount );
bool deleteMimeEntity(mimetic::MimeEntity* pMe, const char *newBodyEntity, char *charset = NULL, int tabcount = 0) {
    static bool found = false;
    
    if( tabcount == 0 )
        found = false;
    mimetic::Header& h = pMe->header();
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
    std::list<mimetic::MimeEntityList::iterator> toBeRemoved;
    mimetic::MimeEntityList& parts = pMe->body().parts();
    mimetic::MimeEntityList::iterator mbit = parts.begin(), meit = parts.end();
    for(; *mbit && mbit != meit; ++mbit){
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
                toBeRemoved.push_back(mbit);
        }
    }
    
    std::list<mimetic::MimeEntityList::iterator>::iterator it = toBeRemoved.begin(), eit = toBeRemoved.end();
    for( ; it != eit; ++it )
        parts.erase(*it);
    return false;
}

void updateCIDHeaders( mimetic::MimeEntity *pMe, std::list<mimetic::MimeEntity*> *cids );
void updateCIDHeaders( mimetic::MimeEntity *pMe, std::list<mimetic::MimeEntity*> *cids ){
    if( pMe->header().contentType().type().compare( "image" ) == 0 &&
       pMe->header().contentDisposition().type().compare( "inline" ) == 0 ){
        std::list<mimetic::MimeEntity*>::iterator it;
        
        if( [[NSUserDefaults standardUserDefaults] boolForKey: UMDisableImageInlining] ){
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
                    std::list<mimetic::MimeEntity*>::iterator it2;
                    for( it2 = cids->begin(); it2 != cids->end(); ++it2 ){
                        printf( "cid: %s\n", (*it2)->header().contentId().str().c_str() );
                    }
                    break;
                }
            }
        }
    }
    
    mimetic::MimeEntityList& parts = pMe->body().parts();
    mimetic::MimeEntityList::iterator mbit = parts.begin(), meit = parts.end();
    for(; mbit != meit; ++mbit){
        updateCIDHeaders( *mbit, cids );
    }
}

@implementation UMMIMEFilter {
    NSString *_inputFile;
}

- (id)initWithData: (NSData*)input {
    if( self = [super init] ){
        struct timeval tv;
        
        gettimeofday( &tv, NULL );
        srand( tv.tv_usec );
        long r = rand()*1.f/RAND_MAX*10000000;
        if( r < 0 )
            r *= -1;
        
        NSString *prefix = [[NSSearchPathForDirectoriesInDomains( NSApplicationSupportDirectory, NSUserDomainMask,  YES ) objectAtIndex: 0] stringByAppendingPathComponent: @"Mail/"];
        NSString *fName = [NSString stringWithFormat: @"umailer-%ld.dat", r];
        _inputFile = [prefix stringByAppendingPathComponent: fName];
        [input writeToFile: _inputFile atomically: NO];
    }
    return self;
}

- (void)dealloc {
    [[NSFileManager defaultManager] removeItemAtPath: _inputFile error: nil];
}

- (NSData*)filteredMIME {
    struct timeval tv;
    
    mimetic::File inFile( [_inputFile cStringUsingEncoding: NSUTF8StringEncoding] );
    
    mimetic::MimeEntity me;
    me.load( inFile.begin(), inFile.end() );
    
    mimetic::MimeEntityList &parts = me.body().parts();
    mimetic::MimeEntityList::iterator mbit = parts.begin(), meit = parts.end();

    // To find new constants for encoding look here: http://www.opensource.apple.com/source/CF/CF-476.14/CFStringEncodingExt.h
    // then take the output from this with the desired encoding:
    //  NSLog( @"%ld", CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_JP) );
    NSDictionary *encodings = [NSDictionary dictionaryWithContentsOfFile:
                               [[NSBundle bundleForClass: [UniversalMailer class]] pathForResource: @"encodings" ofType: @"plist"]];
	NSMutableString *finalHTMLString = [@"" mutableCopy];
    
	std::list<mimetic::MimeEntity*> cids;
	std::list<mimetic::MimeEntity*> attachments;
    
    NSMutableDictionary *charsetDictionary = [@{} mutableCopy];
    BOOL firstTextEntityFound = NO;
	for( ; mbit != meit; ++mbit ){
		if( (*mbit)->header().contentType().isMultipart() ){
            mimetic::MimeEntityList &subparts = (*mbit)->body().parts();
            mimetic::MimeEntityList::iterator bit = subparts.begin(), eit = subparts.end();
            for( ; bit != eit; ++bit ){
                mimetic::MimeEntity *pMe = *bit;
                if( pMe->header().contentDisposition().type().compare("attachment") == 0 ||
                   pMe->header().contentDisposition().type().compare("inline") == 0 ){
                    if( pMe->header().contentType().type().compare( "image" ) == 0 &&
                       pMe->header().contentDisposition().type().compare( "inline" ) == 0 ){
                        if( [[NSUserDefaults standardUserDefaults] boolForKey: UMDisableImageInlining] ) {
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
                        	NSString *cid = [NSString stringWithFormat: @"%ld%.0f@%@", r, [NSDate timeIntervalSinceReferenceDate]*1000000, [self MD5HashForCString: pMe->header().from().str().c_str()]];
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
                    mimetic::string decodedBody = decodeBody(*bit);
                    NSString *charset = [[NSString stringWithCString: (*bit)->header().contentType().str().c_str() encoding: NSUTF8StringEncoding] lowercaseString];
                    NSArray *elements = [charset componentsSeparatedByString: @";"];
                    for( NSString *s in elements ){
                        NSString *str = [s stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \t"]];
                        if( [str startsWithString: @"charset="] ){
                            str = [str stringByReplacingOccurrencesOfString: @"charset=" withString: @""];
                            charset = [str stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \t\""]];
                        }
                    }
                    if( ![charset isEqualToString: @"us-ascii"] )
                        [charsetDictionary setObject: @(YES) forKey: charset];
                    if( !encodings[charset] ){
                        UMErrorLog( @"Universal Mailer did find an unsupported charset encoding (%@). Please file an issue by specifying this message", charset );
                    }
                    NSStringEncoding encoding = [encodings[charset] intValue];
                    if( encoding < 1 )
                        encoding = NSUTF8StringEncoding;
                    NSString *str = [[NSString alloc] initWithCString: decodedBody.c_str() encoding: encoding];
                    str = [str stringByReplacingOccurrencesOfString: @"<html>" withString: @""];
                    NSRange chtmlRange = [str rangeOfString: @"</html>"];
                    if( chtmlRange.location != NSNotFound ){
                        chtmlRange.length = str.length - chtmlRange.location;
                        str = [str stringByReplacingCharactersInRange: chtmlRange withString: @""];
                    }
                    str = [str stringByRemovingPatternsMatchingRE: @"<head>.*</head>"];
                    str = [str stringByReplacingOccurrencesOfString: @"<body" withString: @"<div"];
                    str = [str stringByReplacingOccurrencesOfString: @"</body>" withString: @"</div>"];
                    if( !str ){
                        UMErrorLog( @"Universal Mailer encoutered a serious error while parsing the following email. Please file an issue with this log if possible. %s", [_inputFile cStringUsingEncoding: NSUTF8StringEncoding] );
                    }
                    [finalHTMLString appendString: str];
                }
            }
		}
        else if( !(*mbit)->header().contentType().type().compare( "text" ) && !(*mbit)->header().contentType().subtype().compare( "html" ) ){
            if( !firstTextEntityFound ){
                [finalHTMLString appendString: @"<html><head></head><body>"];
                firstTextEntityFound = YES;
            }
            mimetic::string decodedBody = decodeBody(*mbit);
            NSString *charset = [[NSString stringWithCString: (*mbit)->header().contentType().str().c_str() encoding: NSUTF8StringEncoding] lowercaseString];
            NSArray *elements = [charset componentsSeparatedByString: @";"];
            for( NSString *s in elements ){
                NSString *str = [s stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \t"]];
                if( [str startsWithString: @"charset="] ){
                    str = [str stringByReplacingOccurrencesOfString: @"charset=" withString: @""];
                    charset = [str stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @" \t\""]];
                }
            }
            if( ![charset isEqualToString: @"us-ascii"] )
                [charsetDictionary setObject: [NSNumber numberWithBool:YES] forKey: charset];
            if( !encodings[charset] ){
                UMErrorLog( @"Universal Mailer did find an unsupported charset encoding (%@). Please file an issue by specifying this message", charset );
            }
            NSStringEncoding encoding = [encodings[charset] intValue];
            if( encoding < 1 )
                encoding = NSUTF8StringEncoding;
            NSString *str = [[NSString alloc] initWithCString: decodedBody.c_str() encoding: encoding];
            str = [str stringByReplacingOccurrencesOfString: @"<html>" withString: @""];
            NSRange chtmlRange = [str rangeOfString: @"</html>"];
            if( chtmlRange.location != NSNotFound ){
                chtmlRange.length = str.length - chtmlRange.location;
                str = [str stringByReplacingCharactersInRange: chtmlRange withString: @""];
            }
            NSRange headStartRange = [str rangeOfString: @"<head>"];
            NSRange headEndRange = [str rangeOfString: @"</head>"];
            if( headEndRange.location != NSNotFound && headStartRange.location != NSNotFound ){
                NSRange remRange;
                remRange.location = headStartRange.location;
                remRange.length = (headEndRange.location+headEndRange.length)-headStartRange.location;
                str = [str stringByReplacingCharactersInRange: remRange withString: @""];
            }
            str = [str stringByRemovingPatternsMatchingRE: @"<head>.*</head>"];
            str = [str stringByReplacingOccurrencesOfString: @"<body" withString: @"<div"];
            str = [str stringByReplacingOccurrencesOfString: @"</body>" withString: @"</div>"];
            if( !str ){
                UMErrorLog( @"Universal Mailer encoutered a serious error while parsing the following email. Please file an issue with this log if possible. %s", [_inputFile cStringUsingEncoding: NSUTF8StringEncoding] );
            }
            [finalHTMLString appendString: str];
        }
	}
    
    char *charset = NULL;
    if( charsetDictionary.count != 1 )
        charset = (char*)"utf-8";
    else
        charset = (char*)[[charsetDictionary allKeys][0] cStringUsingEncoding: NSASCIIStringEncoding];
	if( finalHTMLString.length > 0 ){
    	[finalHTMLString appendString: @"</body></html>"];
        
    	NSString *completeHTML = [NSString stringWithString: finalHTMLString];
        
        if( [[NSUserDefaults standardUserDefaults] boolForKey: UMFontFilterEnabled] ){
            NSColor *color = [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            NSData *serializedColor = [[NSUserDefaults standardUserDefaults] objectForKey: UMOutgoingFontColor];
            if( serializedColor )
                color = [[NSUnarchiver unarchiveObjectWithData: serializedColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            
            if( completeHTML ){
                UMStyleFilter *filter = [[UMStyleFilter alloc] initWithString: completeHTML
                                                                     fontName: [[NSUserDefaults standardUserDefaults] objectForKey: UMOutgoingFontName]
                                                                     fontSize: [[NSUserDefaults standardUserDefaults] objectForKey: UMOutgoingFontSize]
                                                                    fontColor: color
                                                                    usePoints: [[NSUserDefaults standardUserDefaults] boolForKey: UMUsePointsForFontSizes]];
                completeHTML = filter.filteredString;
            }
        }
        
        mimetic::MimeEntity *textEntity = new mimetic::MimeEntity;
        textEntity->body().assign( [completeHTML cStringUsingEncoding: [encodings[[NSString stringWithCString: charset encoding: NSASCIIStringEncoding]] intValue]] );
        mimetic::QP::Encoder qpenc;
        textEntity->body().code(qpenc);
        
        finalHTMLString = [NSMutableString stringWithCString: textEntity->body().c_str() encoding: NSISOLatin1StringEncoding];
	}
    
    mimetic::MimeEntity cleanEntity;
	cleanEntity.load( inFile.begin(), inFile.end() );
    
    char *htmlString = strdup([finalHTMLString cStringUsingEncoding: [encodings[[NSString stringWithCString: charset encoding: NSUTF8StringEncoding]] intValue]]);
    deleteMimeEntity( &cleanEntity, htmlString, charset );
    updateCIDHeaders( &cleanEntity, &cids );
    
    std::ofstream of([_inputFile cStringUsingEncoding: NSUTF8StringEncoding]);
	of << cleanEntity << std::endl;
    free(htmlString);
    
    NSString *outString = [NSString stringWithContentsOfFile: _inputFile encoding: NSUTF8StringEncoding error: nil];
    outString = [outString stringByReplacingOccurrencesOfString: @"\r" withString: @""];
	NSData *returnData = [[outString dataUsingEncoding: NSUTF8StringEncoding] copy];
    
    return returnData;
}

#pragma mark -
#pragma mark Private methods

- (NSString*)MD5HashForCString: (const char*)string {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), result);
    NSMutableString *hash = [@"" mutableCopy];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
