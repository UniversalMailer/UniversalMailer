// Copyright (C) 2012 noware
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

#import "UMPreferences.h"

#import "Constants.h"
#import "Macros.h"
#import "UniversalMailer.h"

#define _kFullVersionCopyright @"Copyright © 2012 noware. All rights reserved. This program comes with no warranties. Use at your own risk."

@implementation UMPreferences

- (void)awakeFromNib {
    NSString *fontDescription = [NSString stringWithFormat: @"%@ %@", DEFAULT_GET(UMOutgoingFontName), DEFAULT_GET(UMOutgoingFontSize)];
    NSData *colorData = DEFAULT_GET(UMOutgoingFontColor);
    NSColor *color = [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    if( colorData )
        color = [[NSUnarchiver unarchiveObjectWithData: colorData] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    _colorWell.color = color;
    NSString *versionString = [NSString stringWithFormat: @"Version %@", [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey: (NSString*)kCFBundleVersionKey]];
    [_UMVersion setStringValue: versionString];
    [_copyrightTextField setStringValue: _kFullVersionCopyright];
    [_outgoingFontTextField setStringValue: fontDescription];
	[_UMEnabledButton setState: DEFAULT_GET_BOOL( UMMailFilterEnabled )];
	[_UMForceFontButton setState: DEFAULT_GET_BOOL( UMFontFilterEnabled )];
    [_UMForceAttachments setState: DEFAULT_GET_BOOL( UMDisableImageInlining )];
    [_UMUsePointsButton setState: DEFAULT_GET_BOOL( UMUsePointsForFontSizes )];
	if( !DEFAULT_GET_BOOL( UMMailFilterEnabled ) ){
        DEFAULT_SET_BOOL( NO, UMFontFilterEnabled );
        DEFAULT_SET_BOOL( NO, UMDisableImageInlining );
        DEFAULT_SET_BOOL( NO, UMUsePointsForFontSizes );
		[_UMForceFontButton setEnabled: NO];
        [_UMSelectFontButton setEnabled: NO];
        [_UMForceAttachments setEnabled: NO];
        [_UMUsePointsButton setEnabled: NO];
	}
}

- (IBAction)colorSelection:(id)sender {
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    panel.color = _colorWell.color;
    [panel setTarget: self];
    [panel setAction: @selector(colorSelected:)];
    [panel makeKeyAndOrderFront: self];
}

- (IBAction)donationPressed:(id)sender {
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSURL * url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=X4NT6BB7DARBA"];
    [ws openURL: url];
}

- (IBAction)UMEnabledPressed: (NSButton*)sender {
	if( [sender state] ){
		DEFAULT_SET_BOOL( YES, UMMailFilterEnabled );
		[_UMForceFontButton setEnabled: YES];
	}
	else {
		DEFAULT_SET_BOOL( NO, UMMailFilterEnabled );
		[_UMForceFontButton setEnabled: NO];
	}
}

- (IBAction)UMForceFontPressed: (NSButton*)sender {
	if( [sender state] ){
		DEFAULT_SET_BOOL( YES, UMFontFilterEnabled );
        [_UMSelectFontButton setEnabled: YES];
	}
	else {
		DEFAULT_SET_BOOL( NO, UMFontFilterEnabled );
        [_UMSelectFontButton setEnabled: NO];
	}
}

- (IBAction)UMForceAttachmentsPressed: (id)sender {
    if( [sender state] ){
        DEFAULT_SET_BOOL( YES, UMDisableImageInlining );
    }
    else {
        DEFAULT_SET_BOOL( NO, UMDisableImageInlining );
    }
}

- (IBAction)selectFont:(id)sender {
    [[NSFontPanel sharedFontPanel] setDelegate: self];
    [[NSFontPanel sharedFontPanel] setEnabled: YES];
    [[NSFontPanel sharedFontPanel] makeKeyAndOrderFront: self];
}

- (void)changeFont:(id)sender {
    NSFont *oldFont = _outgoingFontTextField.font;
    NSFont *newFont = [sender convertFont: oldFont];
    NSString *newFontDescription = [NSString stringWithFormat: @"%@ %.0f", newFont.fontName, newFont.pointSize];
    DEFAULT_SET( newFont.fontName, UMOutgoingFontName );
    NSString *fontSize = [NSString stringWithFormat: @"%.0f", newFont.pointSize];
    DEFAULT_SET( fontSize, UMOutgoingFontSize );
    [_outgoingFontTextField setStringValue: newFontDescription];
}

- (IBAction)UMUsePointsPressed:(id)sender {
    if( [sender state] ){
        DEFAULT_SET_BOOL( YES, UMUsePointsForFontSizes );
    }
    else {
        DEFAULT_SET_BOOL( NO, UMUsePointsForFontSizes );
    }
}

- (BOOL)isResizable {
	return NO;
}

- (id)preferencesNibName {
	return [NSString stringWithString: @"UMPreferencePane.nib"];
}

- (id)imageForPreferenceNamed:(id)fp8 {
	NSString *iconPath = [[NSBundle bundleForClass: [UniversalMailer class]] pathForResource: @"UniversalMailerIcon" ofType: @"png"];
	return [[[NSImage alloc] initWithContentsOfFile: iconPath] autorelease];
}

- (void)colorSelected: (NSColorPanel*)sender {
    _colorWell.color = sender.color;
    NSData *colorData = [NSArchiver archivedDataWithRootObject: [sender.color colorUsingColorSpaceName: NSCalibratedRGBColorSpace]];
    DEFAULT_SET( colorData, UMOutgoingFontColor );
}

@end
