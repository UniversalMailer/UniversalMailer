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

#import <Foundation/Foundation.h>

@interface NSPreferences : NSObject
{
    NSWindow *_preferencesPanel;
    NSBox *_preferenceBox;
    NSMatrix *_moduleMatrix;
    NSButtonCell *_okButton;
    NSButtonCell *_cancelButton;
    NSButtonCell *_applyButton;
    NSMutableArray *_preferenceTitles;
    NSMutableArray *_preferenceModules;
    NSMutableDictionary *_masterPreferenceViews;
    NSMutableDictionary *_currentSessionPreferenceViews;
    NSBox *_originalContentView;
    BOOL _isModal;
    double _constrainedWidth;
    id _currentModule;
    void *_reserved;
}

+ (id)sharedPreferences;
+ (void)setDefaultPreferencesClass:(Class)arg1;
+ (Class)defaultPreferencesClass;
+ (void)restoreWindowWithIdentifier:(id)arg1 state:(id)arg2 completionHandler:(id)arg3;
- (id)init;
- (void)dealloc;
- (void)addPreferenceNamed:(id)arg1 owner:(id)arg2;
- (void)_setupToolbar;
- (void)_setupUI;
- (struct CGSize)preferencesContentSize;
- (void)showPreferencesPanel;
- (id)_setupPreferencesPanelForOwner:(id)arg1;
- (id)_setupPreferencesPanelForOwnerAtIndex:(long long)arg1;
- (void)showPreferencesPanelForOwner:(id)arg1;
- (void)window:(id)arg1 willEncodeRestorableState:(id)arg2;
- (long long)showModalPreferencesPanelForOwner:(id)arg1;
- (long long)showModalPreferencesPanel;
- (void)ok:(id)arg1;
- (void)cancel:(id)arg1;
- (void)cancel:(id)arg1;
- (void)apply:(id)arg1;
- (void)_selectModuleOwner:(id)arg1;
- (id)windowTitle;
- (void)confirmCloseSheetIsDone:(id)arg1 returnCode:(long long)arg2 contextInfo:(void *)arg3;
- (BOOL)windowShouldClose:(id)arg1;
- (void)windowDidResize:(id)arg1;
- (struct CGSize)windowWillResize:(id)arg1 toSize:(struct CGSize)arg2;
- (BOOL)usesButtons;
- (id)_itemIdentifierForModule:(id)arg1;
- (void)toolbarItemClicked:(id)arg1;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (id)toolbarSelectableItemIdentifiers:(id)arg1;

@end

@interface NSPreferencesModule : NSObject {
    IBOutlet NSBox *_preferencesView;
    struct CGSize _minSize;
    BOOL _hasChanges;
    void *_reserved;
}

+ (id)sharedInstance;
- (void)dealloc;
- (void)finalize;
- (id)init;
- (id)preferencesNibName;
- (void)setPreferencesView:(id)arg1;
- (id)viewForPreferenceNamed:(id)arg1;
- (id)imageForPreferenceNamed:(id)arg1;
- (id)titleForIdentifier:(id)arg1;
- (BOOL)hasChangesPending;
- (void)saveChanges;
- (void)willBeDisplayed;
- (void)initializeFromDefaults;
- (void)didChange;
- (struct CGSize)minSize;
- (void)setMinSize:(struct CGSize)arg1;
- (void)moduleWillBeRemoved;
- (void)moduleWasInstalled;
- (BOOL)moduleCanBeRemoved;
- (BOOL)preferencesWindowShouldClose;
- (BOOL)isResizable;

@end