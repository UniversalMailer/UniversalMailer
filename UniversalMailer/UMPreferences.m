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

#import "UMPreferences.h"

#import "Constants.h"
#import "UniversalMailer.h"

#define _kFullVersionCopyright @"Copyright © 2013 noware. All rights reserved. This program comes with no warranties. Use at your own risk."

@implementation UMPreferences

- (void)awakeFromNib {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fontDescription = [NSString stringWithFormat: @"%@ %@",
                                 [defaults objectForKey:UMOutgoingFontName],
                                 [defaults objectForKey: UMOutgoingFontSize]];
    NSData *colorData = [defaults objectForKey: UMOutgoingFontColor];
    UMLog( @"Setting default color to colorData" );
    NSColor *color = [[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    if( colorData ){
        UMLog( @"Found color data in default settings, using it [%@]", colorData );
        color = [[NSUnarchiver unarchiveObjectWithData: colorData] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    }
    _colorWell.color = color;
    NSString *versionString = [NSString stringWithFormat: @"Version %@", [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey: (NSString*)kCFBundleVersionKey]];
    [_UMVersion setStringValue: versionString];
    [_copyrightTextField setStringValue: _kFullVersionCopyright];
    [_outgoingFontTextField setStringValue: fontDescription];
	[_UMEnabledButton setState: [defaults boolForKey: UMMailFilterEnabled]];
	[_UMForceFontButton setState: [defaults boolForKey: UMFontFilterEnabled]];
    [_UMForceAttachments setState: [defaults boolForKey: UMDisableImageInlining]];
    [_UMUsePointsButton setState: [defaults boolForKey: UMUsePointsForFontSizes]];
	if( ![defaults boolForKey: UMMailFilterEnabled] ){
        [defaults setBool: NO forKey: UMFontFilterEnabled];
        [defaults setBool: NO forKey: UMDisableImageInlining];
        [defaults setBool: NO forKey: UMUsePointsForFontSizes];
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
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: UMMailFilterEnabled];
		[_UMForceFontButton setEnabled: YES];
	}
	else {
        [[NSUserDefaults standardUserDefaults] setBool: NO forKey: UMMailFilterEnabled];
		[_UMForceFontButton setEnabled: NO];
	}
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)UMForceFontPressed: (NSButton*)sender {
	if( [sender state] ){
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: UMFontFilterEnabled];
        [_UMSelectFontButton setEnabled: YES];
	}
	else {
        [[NSUserDefaults standardUserDefaults] setBool: NO forKey: UMFontFilterEnabled];
        [_UMSelectFontButton setEnabled: NO];
	}
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)UMForceAttachmentsPressed: (id)sender {
    if( [sender state] ){
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: UMDisableImageInlining];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool: NO forKey: UMDisableImageInlining];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSUserDefaults standardUserDefaults] setObject: newFont.fontName forKey: UMOutgoingFontName];
    NSString *fontSize = [NSString stringWithFormat: @"%.0f", newFont.pointSize];
    [[NSUserDefaults standardUserDefaults] setObject: fontSize forKey: UMOutgoingFontSize];
    [_outgoingFontTextField setStringValue: newFontDescription];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)UMUsePointsPressed:(id)sender {
    if( [sender state] ){
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: UMUsePointsForFontSizes];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool: NO forKey: UMUsePointsForFontSizes];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isResizable {
	return NO;
}

- (id)preferencesNibName {
	return @"UMPreferencePane.nib";
}

- (id)imageForPreferenceNamed:(id)fp8 {
	NSString *iconPath = [[NSBundle bundleForClass: [UniversalMailer class]] pathForResource: @"UniversalMailerIcon" ofType: @"png"];
	return [[NSImage alloc] initWithContentsOfFile: iconPath];
}

- (void)colorSelected: (NSColorPanel*)sender {
    _colorWell.color = sender.color;
    NSData *colorData = [NSArchiver archivedDataWithRootObject: [sender.color colorUsingColorSpaceName: NSCalibratedRGBColorSpace]];
    [[NSUserDefaults standardUserDefaults] setObject: colorData forKey: UMOutgoingFontColor];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
