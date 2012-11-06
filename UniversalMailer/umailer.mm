//
//  umailer.mm
//  UniversalMailer
//
//  Created by Luca on 23/08/11.
//  Copyright (c) 2011 luca. All rights reserved.
//
#import "umailer.h"

#import <iostream>
#import <mimetic/mimetic.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <sys/time.h>
#import "UMString.h"

using namespace std;
using namespace mimetic;

NSString *md5( const char *string );
std::string decodeBody(MimeEntity* pMe, int tabcount);

NSString *md5( const char *string ){
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

std::string decodeBody(MimeEntity* pMe, int tabcount = 0) {
	Header& h = pMe->header();
	string ctype("text/html");
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

NSData *umMimeFilter( NSData *inData ){
	NSData *returnData = nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	struct timeval tv;
	
	gettimeofday( &tv, NULL );
	srand( tv.tv_usec );
	long r = rand()*1.f/RAND_MAX*10000000;
	if( r < 0 )
		r *= -1;

	NSString *tempFileName = [NSString stringWithFormat: @"/tmp/umailer-%d.dat", r];
	[inData writeToFile: tempFileName atomically: NO];

	File inFile([tempFileName cStringUsingEncoding: NSUTF8StringEncoding]);

	MimeEntity *outEntity = new MimeEntity;

	MimeEntity me;
	me.load( inFile.begin(), inFile.end() );

	outEntity->header() = me.header();
	outEntity->header().contentType().set( "multipart/mixed" );

	MultipartEntity *relatedEntity = new MultipartEntity;
	relatedEntity->header().contentType().set( "multipart/related" );
	relatedEntity->header().contentType().param( "type", "multipart/alternative" );

	MultipartAlternative *rootPart = new MultipartAlternative;
	relatedEntity->body().parts().push_back( rootPart );
	outEntity->body().parts().push_back( relatedEntity );

    MimeEntityList &parts = me.body().parts();
	MimeEntityList::iterator mbit = parts.begin(), meit = parts.end();
	NSMutableString *finalHTMLString = [NSMutableString string];
	[finalHTMLString appendString: @"<html><head></head><body>"];

	std::list<MimeEntity*> cids;
	std::list<MimeEntity*> attachments;

    BOOL foundMultipart = NO;
	MimeEntity *firstTextEntity = NULL;
	for( ; mbit != meit; ++mbit ){
		if( (*mbit)->header().contentType().isMultipart() ){
		 MimeEntityList &subparts = (*mbit)->body().parts();
		 MimeEntityList::iterator bit = subparts.begin(), eit = subparts.end();
		 for( ; bit != eit; ++bit ){
		  MimeEntity *pMe = *bit;
		  if( pMe->header().contentDisposition().type().compare("attachment") == 0 ||
			  pMe->header().contentDisposition().type().compare("inline") == 0 ){
		   if( pMe->header().contentType().type().compare( "image" ) == 0 &&
			   pMe->header().contentDisposition().type().compare( "inline" ) == 0 ){
			NSString *cid = [NSString stringWithFormat: @"%.0f@%@", [NSDate timeIntervalSinceReferenceDate]*1000000, md5(pMe->header().from().str().c_str())];
		    NSString *cidHeader = [NSString stringWithFormat: @"<%@>", cid];
		    pMe->header().contentId().set( [cidHeader cStringUsingEncoding: NSUTF8StringEncoding] );
		    [finalHTMLString appendFormat: @"<img src=\"cid:%@\">", cid];
		    cids.insert( cids.end(), pMe );
		   }
		   else {
			attachments.insert( attachments.end(), pMe );
		   }
		  }
		  else {
		   string decodedBody = decodeBody(*bit);
		   UMString *str = [[[UMString alloc] initWithCString: decodedBody.c_str() encoding: NSUTF8StringEncoding] autorelease];
		   str = [str stringByRemovingPatternsMatchingRE: @"<html>"];
		   str = [str stringByRemovingPatternsMatchingRE: @"</html>.*"];
		   str = [str stringByRemovingPatternsMatchingRE: @"<head>.*</head>"];
		   str = [UMString stringWithString: [str stringByReplacingOccurrencesOfString: @"<body" withString: @"<div"]];
		   str = [UMString stringWithString: [str stringByReplacingOccurrencesOfString: @"</body>" withString: @"</div>"]];
		   [finalHTMLString appendString: str];
		   if( !firstTextEntity )
			firstTextEntity = *bit;
		   else
			parts.erase( bit );
		  }
		 }
		 foundMultipart = YES;
		}
		else {
		 MimeEntity *e = new MimeEntity;
		 e->header() = (*mbit)->header();
		 e->body() = (*mbit)->body();
		 rootPart->body().parts().push_back( e );
		}
		if( foundMultipart ){
		 [finalHTMLString appendString: @"</html>\n"];
		 firstTextEntity->body().assign( [finalHTMLString cStringUsingEncoding: NSUTF8StringEncoding] );
		 firstTextEntity->header().contentTransferEncoding().set( "quoted-printable" );
		 QP::Encoder qpenc;
		 firstTextEntity->body().code(qpenc);
		 rootPart->body().parts().push_back( firstTextEntity );

		 std::list<MimeEntity*>::iterator bit = cids.begin(), eit = cids.end();
    	 for( ; bit != eit; ++bit )
		  relatedEntity->body().parts().push_back( *bit );

		 std::list<MimeEntity*>::iterator abit = attachments.begin(), aeit = attachments.end();
    	 for( ; abit != aeit; ++abit )
		  outEntity->body().parts().push_back( *abit );
		}
	}

	ofstream of([tempFileName cStringUsingEncoding: NSUTF8StringEncoding]);
	of << *outEntity << endl;

	returnData = [NSData dataWithContentsOfFile: tempFileName];
	[[NSFileManager defaultManager] removeItemAtPath: tempFileName error: nil];

	[pool release];

	return returnData;
}
