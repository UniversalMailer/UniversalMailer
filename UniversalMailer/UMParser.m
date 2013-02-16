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

#import "UMParser.h"
#import "Macros.h"

#define SPUSH(o) [self _pushState: o withStack: _stack]
#define SPOP [self _popStateFromStack: _stack]
#define APUSH(o) [self _pushState: o withStack: _arrayStack]
#define APOP [self _popStateFromStack: _arrayStack]
#define ASPUSH(v) [self _pushState: [NSNumber numberWithBool: v] withStack: _arrayState]
#define ASPOP [self _popStateFromStack: _arrayState]
#define ASTATE [[self _topStack: _arrayState] boolValue]
#define TPUSH(o) [self _pushState: o withStack: _textStack]
#define TPOP [self _popStateFromStack: _textStack]

@interface UMParser (PrivateMethods)

- (void)_pushState: (id)state withStack: (NSMutableArray*)stack;
- (id)_popStateFromStack: stack;
- (id)_topStack: (NSMutableArray*)stack;

@end

@implementation UMParser

@synthesize XML = _rootElement;
@synthesize arrayElements = _arrayElementsArray;

+ (UMParser*)parserWithXmlFile: (NSString*)fileName {
	return [self parserWithXmlFile: fileName withArrayElements: nil];
}

+ (UMParser*)parserWithXmlFile: (NSString*)fileName withArrayElements: (NSArray*)array{
	UMParser *parser = [[UMParser alloc] init];
	parser.arrayElements = array;
	[parser readXmlFile: fileName];
	return [parser autorelease];
}

+ (UMParser*)parserWithData: (NSData*)data {
    return [self parserWithData: data withArrayElements: nil];
}

+ (UMParser*)parserWithData: (NSData*)data withArrayElements: (NSArray*)array {
	UMParser *parser = [[UMParser alloc] init];
	parser.arrayElements = array;
	[parser readData: data];
	return [parser autorelease];    
}

- (void)readXmlFile: (NSString*)fileName {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath: fileName] ){
		NSData *xml = [NSData dataWithContentsOfFile: fileName];
        [self readData: xml];
	}
	
	[pool release];
}

- (void)readData: (NSData*)data {
    _stack = [[NSMutableArray array] retain];
    _arrayStack = [[NSMutableArray array] retain];
    _arrayState = [[NSMutableArray array] retain];
    _textStack = [[NSMutableArray array] retain];
    _rootElement = [[NSMutableDictionary dictionary] retain];
    _currentElement = _rootElement;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData: data];
    [parser setShouldProcessNamespaces: YES];
    [parser setShouldResolveExternalEntities: NO];
    [parser setShouldReportNamespacePrefixes: NO];
    [parser setDelegate: self];
    
    [parser parse];
    
    [parser release];    
}

- (void)dealloc {
	CLEAN_RELEASE( _arrayElementsArray );
	CLEAN_RELEASE( _stack );
	CLEAN_RELEASE( _arrayStack );
	CLEAN_RELEASE( _arrayState );
	CLEAN_RELEASE( _textStack );
	CLEAN_RELEASE( _rootElement );
	[super dealloc];
}

#pragma mark -
#pragma mark NSXMLParser delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {	
	TPUSH( _currentText );
	_currentText = [[NSMutableString string] retain];
	
	NSMutableDictionary *next = [NSMutableDictionary dictionary];
	if( [_arrayElementsArray containsObject: elementName] ){
		ASPUSH(YES);
		if( ![_currentElement objectForKey: elementName] )
			[_currentElement setObject: [NSMutableArray array] forKey: elementName];
		APUSH( _currentArray );
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject: next forKey: elementName];
		[[_currentElement objectForKey: elementName] addObject: dictionary];
	}
	else {
		[_currentElement setObject: next forKey: elementName];			
		ASPUSH(NO);
	}
	
	SPUSH( _currentElement );
	_currentElement = next;
	
	if( attributeDict.count > 0 ){
		[_currentElement setObject: attributeDict forKey: @"attributes"];
	}
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if( _currentText.length > 0 ){
		[_currentElement setObject: [_currentText stringByTrimmingCharactersInSet:
									 [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey: @"value"];
	}
	[_currentText release];
	_currentText = TPOP;
	
	ASPOP;	
	_currentElement = SPOP;
	if( [_arrayElementsArray containsObject: elementName] ){
		_currentArray = APOP;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[_currentText appendString: string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	NSString *string = [[NSString alloc] initWithData: CDATABlock encoding: NSUTF8StringEncoding];
	[_currentText appendString: string];
	[string release];
}

#pragma mark -
#pragma mark Private methods

#pragma mark -
#pragma mark Stack methods

- (void)_pushState: (id)state withStack: (NSMutableArray*)stack {
	if( state )
		[stack addObject: state];
}

- (id)_popStateFromStack: (NSMutableArray*) stack {
	id lastObject = [[stack lastObject] retain];
	if( stack.count > 0 ){
		[stack removeLastObject];
	}
	return [lastObject autorelease];
}

- (id)_topStack: (NSMutableArray*)stack {
	return [stack lastObject];
}

@end
