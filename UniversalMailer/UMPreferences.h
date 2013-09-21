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

#import "NSPreferences.h"

@interface UMPreferences : NSPreferencesModule <NSWindowDelegate> {
    IBOutlet NSButton *_UMEnabledButton;
    IBOutlet NSButton *_UMForceFontButton;
    IBOutlet NSButton *_UMSelectFontButton;
    IBOutlet NSButton *_UMForceAttachments;
    IBOutlet NSButton *_UMUsePointsButton;
    IBOutlet NSTextField *_outgoingFontTextField;
    IBOutlet NSButton *_UMDonateButton;
    IBOutlet NSTextField *_donateTextField;
    IBOutlet NSTextField *_copyrightTextField;
    IBOutlet NSTextField *_UMVersion;
    IBOutlet NSColorWell *_colorWell;
}

- (IBAction)donationPressed:(id)sender;
- (IBAction)UMEnabledPressed:(id)sender;
- (IBAction)UMForceFontPressed:(id)sender;
- (IBAction)UMForceAttachmentsPressed:(id)sender;
- (IBAction)selectFont:(id)sender;
- (IBAction)UMUsePointsPressed:(id)sender;

@end
