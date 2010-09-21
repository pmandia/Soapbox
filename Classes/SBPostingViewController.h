/*
 
 The MIT License
 
 Copyright (c) 2010 Soapbox Developers
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "MGTwitterEngine.h"
#import "SBGeolocationController.h"
#import "SBCharacterCountView.h"
#import "SBPostingTitleView.h"
#import "SBBitlyHelper.h"

@class SBTweet;
@class SBAddressBookViewController;
@class SBLocationView;

@interface SBPostingViewController : UIViewController <MGTwitterEngineDelegate, MKReverseGeocoderDelegate, UIActionSheetDelegate, SBBitlyHelperDelegate, SBGeolocationControllerDelegate>
{
@private
  SBPostingTitleView *titleView;
  
  UIBarButtonItem *closeButton;
  UIBarButtonItem *postButton;
  UITextView *tweetTextView;  
  
  // Bottom Toolbar
  UIToolbar *keyboardToolbar;
  UIBarButtonItem *deleteButton;
  UIBarButtonItem *addGeoDataButton;
  UIBarButtonItem *removeGeoDataButton;
	UIBarButtonItem *postPictureButton;
  SBCharacterCountView *characterCountView;
  UIBarButtonItem *characterCountButton;
  UIBarButtonItem *activityButton;
  
  // Geolocation Stuff
  BOOL locationViewVisible;
  SBLocationView *locationView;
  SBGeolocationController *locationController;
  MKReverseGeocoder *geoCoder;
  CLLocation *currentLocation;
  NSString *currentLocationString;
  
  UIViewController *logicalParentViewController;
  SBAddressBookViewController *addressBookViewController;
  MGTwitterEngine *twitter;
  NSOperationQueue *queue;

  SBTweet *inReplyToStatus;
  NSRange cursorSelectionRange;
  BOOL keyboardAlreadyResized;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *postButton;
@property (nonatomic, retain) IBOutlet UITextView *tweetTextView;
@property (nonatomic, retain) IBOutlet UIToolbar *keyboardToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addGeoDataButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *removeGeoDataButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *postPictureButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic, retain) IBOutlet SBCharacterCountView *characterCountView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *characterCountButton;
@property (nonatomic, retain) UIBarButtonItem *activityButton;
@property (nonatomic, retain) SBPostingTitleView *titleView;
@property (nonatomic, retain) UIViewController *logicalParentViewController;
@property (nonatomic, retain) SBAddressBookViewController *addressBookViewController;
@property (nonatomic, retain) SBTweet *inReplyToStatus;
@property (nonatomic, retain) MKReverseGeocoder *geoCoder;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) SBLocationView *locationView;
@property (nonatomic, copy) NSString *currentLocationString;

- (IBAction)post:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)clearTweet:(id)sender;
- (IBAction)shrinkURLs:(id)sender;
- (IBAction)showAddressBook:(id)sender;
- (IBAction)attachGeocoordinates:(id)sender;
- (IBAction)removeGeocoordinates:(id)sender;
- (IBAction)postPicture:(id) sender;

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end
