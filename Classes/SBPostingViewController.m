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

#import "SBPostingViewController.h"
#import "SBAppDelegate.h"
#import "SBTwitterManager.h"
#import "MGTwitterEngine.h"
#import "SBPostingTitleView.h"
#import "SBTweet.h"
#import "SBAccountManager.h"
#import "CCoreDataManager.h"
#import "RegexKitLite.h"
#import "SBAddressBookViewController.h"
#import "SBActivityButton.h"
#import "SBLocationView.h"
#import "SBStatusImportOperation.h"

@interface SBPostingViewController ()
- (void)setupKeyboardToolbar;
- (void)restoreReplyToStatus;
- (void)restoreInProgressTweet;
- (void)restoreLocationData;
- (void)saveInProgressTweet;
- (void)updateCharacterCount;
- (BOOL)underCharacterCount;
- (void)clearTweetText;
- (void)toggleHud:(BOOL)shouldShow;
- (BOOL)hasEnabledGeoPosting;
- (void)showLocationView;
- (void)hideLocationView;
@end

@implementation SBPostingViewController

@synthesize closeButton;
@synthesize postButton;
@synthesize tweetTextView;
@synthesize keyboardToolbar;
@synthesize deleteButton;
@synthesize addGeoDataButton;
@synthesize removeGeoDataButton;
@synthesize postPictureButton;
@synthesize activityButton;
@synthesize characterCountButton;
@synthesize characterCountView;
@synthesize titleView;
@synthesize inReplyToStatus;
@synthesize addressBookViewController;
@synthesize geoCoder;
@synthesize currentLocation;
@synthesize currentLocationString;
@synthesize locationView;
@synthesize logicalParentViewController;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
  if ((self = [super initWithNibName:nibName bundle:nibBundle]))
  {
    twitter = [[SBTwitterManager createTwitterEngineForCurrentUserWithDelegate:self] retain];
  }
  
  return self;
}

#pragma mark -
#pragma mark View Lifecycle

// +--------------------------------------------------------------------
// | View Lifecycle
// +--------------------------------------------------------------------

- (void)viewDidLoad 
{
  [super viewDidLoad];  
  self.titleView = [[[SBPostingTitleView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
  
  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  self.navigationItem.titleView = titleView;
  self.navigationItem.leftBarButtonItem = self.closeButton;
  self.navigationItem.rightBarButtonItem = self.postButton;
  
  [self setupKeyboardToolbar];
}

- (void)viewWillAppear:(BOOL)animated 
{
  [super viewWillAppear:animated];
  
  [self.tweetTextView becomeFirstResponder];
  [self restoreInProgressTweet];
}


- (void)viewDidAppear:(BOOL)animated 
{
  [super viewDidAppear:animated];
  [self restoreLocationData];
  
  BOOL autoGeoEnabled = [[SBAccountManager manager] loggedInUserAccount].locationPostingPreference == SBAccountLocationAuto;
  if ((autoGeoEnabled) && (self.currentLocation == nil))
  {
    [self attachGeocoordinates:nil];
  }  
}

- (void)viewWillDisappear:(BOOL)animated 
{
  [super viewWillDisappear:animated];
  [self saveInProgressTweet];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)post:(id)sender
{
  NSString *tweetText = self.tweetTextView.text;
  CGFloat latitude = self.currentLocation.coordinate.latitude;
  CGFloat longitude = self.currentLocation.coordinate.longitude;
  
  if ((inReplyToStatus != nil))
  {
    if ((longitude == 0.0f))
    {
      [twitter sendUpdate:tweetText inReplyTo:[self.inReplyToStatus engineID]];  
    } 
    else 
    {
      [twitter sendUpdate:tweetText inReplyTo:[self.inReplyToStatus engineID] withLatitude:latitude longitude:longitude];
    }
  }
  else
  {
    if ((longitude == 0.0f))
    {
      [twitter sendUpdate:tweetText];
    }
    else 
    {
      [twitter sendUpdate:tweetText withLatitude:latitude longitude:longitude];
    }
   
  }
  
  [self toggleHud:YES];
}

- (IBAction)close:(id)sender
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)clearTweet:(id)sender
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle:NSLocalizedString(@"Clear Tweet", nil)
                                                  otherButtonTitles:nil];
  
  SBAppDelegate *delegate = (SBAppDelegate *)[[UIApplication sharedApplication] delegate];
  [actionSheet showInView:delegate.window];
  [actionSheet release];  
}

- (IBAction)shrinkURLs:(id)sender
{
  NSString *stringToSearch = self.tweetTextView.text;
  NSString *urlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
  NSArray *matchedURLsArray = [stringToSearch componentsMatchedByRegex:urlRegex];
  
  SBAccount *loggedInAccount = [[SBAccountManager manager] loggedInUserAccount];
  NSString *bitlyUser = (([loggedInAccount.bitlyUserName length] == 0)) ? kDefaultBitlyUserName : loggedInAccount.bitlyUserName;
  NSString *bitlyApiKey = (([loggedInAccount.bitlyApiKey length] == 0)) ? kDefaultBitlyApiKey : loggedInAccount.bitlyApiKey;
  
  SBBitlyHelper *bitly = [[[SBBitlyHelper alloc] initWithUserName:bitlyUser apiKey:bitlyApiKey] autorelease];
  bitly.delegate = self;
  
  for (NSString *string in matchedURLsArray)
  {
    [bitly shortenURL:string];
  }
}

- (void)updateToolbarWithActivityButton:(BOOL)shouldShow
{
  NSMutableArray *toolbarItems = [[NSMutableArray arrayWithArray:self.keyboardToolbar.items] retain];
  if ((shouldShow))
  {
    [toolbarItems replaceObjectAtIndex:5 withObject:self.activityButton];
    [(SBActivityButton *)self.activityButton.customView startAnimating];
  }
  else 
  {
    if ((self.currentLocation == nil))
    {
      [toolbarItems replaceObjectAtIndex:5 withObject:self.addGeoDataButton];
    }
    else 
    {
      [toolbarItems replaceObjectAtIndex:5 withObject:self.removeGeoDataButton];
    }
    
    [(SBActivityButton *)self.activityButton.customView stopAnimating];
  }
  
  self.keyboardToolbar.items = toolbarItems;
  [toolbarItems release];
}

- (IBAction)attachGeocoordinates:(id)sender
{
  if (([self hasEnabledGeoPosting]))
  {  
    [self updateToolbarWithActivityButton:YES];
    [locationController.locationManager startUpdatingLocation];
  }
}

- (IBAction)removeGeocoordinates:(id)sender
{
  self.currentLocation = nil;
  self.currentLocationString = nil;
  self.geoCoder = nil;
  [self updateToolbarWithActivityButton:NO];
  [self hideLocationView];
}

- (IBAction)postPicture:(id) sender
{
  NSLog(@"Post a picture to a service");
}

- (IBAction)showAddressBook:(id)sender
{
  if ((self.addressBookViewController == nil))
  {
    SBAddressBookViewController *viewController = [[SBAddressBookViewController alloc] initWithNibName:NSStringFromClass([SBAddressBookViewController class]) bundle:nil];
    self.addressBookViewController = viewController;
    [viewController release];
  }
  
  NSRange selectedRange = [self.tweetTextView selectedRange];
  cursorSelectionRange = selectedRange;
  
  UINavigationController *newAccountNavigationController = [[UINavigationController alloc] initWithRootViewController:self.addressBookViewController];
  newAccountNavigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  [self.navigationController presentModalViewController:newAccountNavigationController animated:YES];
  [newAccountNavigationController release];    
  
}

#pragma mark -
#pragma mark Memory Management
// +--------------------------------------------------------------------
// | Memory Management
// +--------------------------------------------------------------------

- (void)didReceiveMemoryWarning 
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
  self.closeButton = nil;
  self.postButton = nil;
  self.tweetTextView = nil;
  self.keyboardToolbar = nil;
  self.deleteButton = nil;
  self.addGeoDataButton = nil;
  self.removeGeoDataButton = nil;
  self.activityButton = nil;
  self.characterCountButton = nil;
  self.characterCountView = nil;
  self.titleView = nil;
  self.inReplyToStatus = nil;
  self.addressBookViewController = nil;
  [locationController release];
  
  [[NSNotificationCenter defaultCenter] removeObserver:PTSelectedUserFromAddressBook];
  [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillShowNotification];
  [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
}

- (void)dealloc 
{
  [twitter closeAllConnections];
  
  [closeButton release];
  [postButton release];
  [tweetTextView release];
  [keyboardToolbar release];
  [deleteButton release];
  [addGeoDataButton release];
  [removeGeoDataButton release];
  [activityButton release];
  [characterCountButton release];
  [characterCountView release];
  [twitter release];
  [titleView release];
  [inReplyToStatus release];
  [addressBookViewController release];
  [locationController release];
  [geoCoder release];
  [currentLocation release];
  [currentLocationString release];
  [locationView release];
  
  [super dealloc];
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)userNameSelectedFromAddressBook:(NSNotification *)notification
{
  NSString *username = [notification object];
  NSMutableString *tweetContents = [[NSMutableString alloc] initWithString:self.tweetTextView.text];
  [tweetContents replaceCharactersInRange:cursorSelectionRange withString:username];
  self.tweetTextView.text = tweetContents;
  [tweetContents release];
  [self saveInProgressTweet];
  [self updateCharacterCount];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
// +--------------------------------------------------------------------
// | UIActionSheet Delegate Methods
// +--------------------------------------------------------------------

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	static NSInteger kClearTweetButton = 0;
	if (buttonIndex == kClearTweetButton)
	{
    [self clearTweetText];
	}
}

#pragma mark -
#pragma mark PTGeolocationControllerDelegate Methods
// +--------------------------------------------------------------------
// | PTGeolocationControllerDelegate Methods
// +--------------------------------------------------------------------

- (void)locationUpdate:(CLLocation *)theLocation
{
  [locationController.locationManager stopUpdatingLocation];
  self.currentLocation = theLocation;
  
  self.geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.currentLocation.coordinate];
  geoCoder.delegate=self;
  [geoCoder start];
    
  [self updateToolbarWithActivityButton:NO];
}

- (void)locationError:(NSError *)theError
{
  UIAlertViewQuick(@"Location Error", [theError localizedDescription], @"OK");  
  [self updateToolbarWithActivityButton:NO];
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate Methods
// +--------------------------------------------------------------------
// | MKReverseGeocoderDelegate Methods
// +--------------------------------------------------------------------

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)theError
{
  UIAlertViewQuick(@"Reverse Geocoding Error", [theError localizedDescription], @"OK");  
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
  [placemark retain];
  self.currentLocationString = [NSString stringWithFormat:@"Near %@, %@, %@", placemark.thoroughfare, placemark.locality, placemark.administrativeArea];
  
  [self.geoCoder cancel];
  self.geoCoder = nil;
  [self showLocationView];
  DebugLog(@"Reverse Geocoded Value is %@", self.currentLocationString);
}

#pragma mark -
#pragma mark SGBitlyHelperDelegate Methods
// +--------------------------------------------------------------------
// | SGBitlyHelperDelegate Methods
// +--------------------------------------------------------------------

- (void)shorteningSucceededForURL:(NSString *)originalURL withShortenedURL:(NSString *)shortenedURL;
{
  NSString *updatedString = [self.tweetTextView.text stringByReplacingOccurrencesOfString:originalURL withString:shortenedURL];
  self.tweetTextView.text = updatedString;
}

- (void)shorteningFailedWithError:(NSError *)error;
{
  NSDictionary *errorDictionary = [error userInfo];
  UIAlertViewQuick(@"Shortening Error", [errorDictionary valueForKey:@"errorMessage"], @"OK");
}

#pragma mark -
#pragma mark UITextView Delegate Methods
// +--------------------------------------------------------------------
// | UITextView Delegate Methods
// +--------------------------------------------------------------------

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView 
{
  if ((tweetTextView.inputAccessoryView == nil))
  {
    [[NSBundle mainBundle] loadNibNamed:@"PostingAccessoryView" owner:self options:nil];
    tweetTextView.inputAccessoryView = self.keyboardToolbar;
  }
  
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
  [self updateCharacterCount];
  self.postButton.enabled = (([self underCharacterCount])) ? YES : NO;
}

#pragma mark -
#pragma mark Keyboard Notification Methods
// +--------------------------------------------------------------------
// | Keyboard Notification Methods
// +--------------------------------------------------------------------

- (void)keyboardWillShow:(NSNotification *)notification
{
  NSDictionary *userInfo = [notification userInfo];
  
  // Get the origin of the keyboard when it's displayed.
  NSValue *keyboardOriginValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
  
  // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
  CGRect keyboardRect = [keyboardOriginValue CGRectValue];
  keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
  
  CGFloat keyboardTop = keyboardRect.origin.y;
  CGRect newTextViewFrame = self.view.bounds;
  newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
  
  NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration;
  [animationDurationValue getValue:&animationDuration];
  
  // Animate the resize of the text view's frame in sync with the keyboard's appearance.
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:animationDuration];
  
  tweetTextView.frame = newTextViewFrame;
  
  [UIView commitAnimations];  
}

- (void)keyboardWillHide:(NSNotification *)notification
{
  NSDictionary* userInfo = [notification userInfo];
  
  /*
   Restore the size of the text view (fill self's view).
   Animate the resize so that it's in sync with the disappearance of the keyboard.
   */
  NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration;
  [animationDurationValue getValue:&animationDuration];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:animationDuration];
  
  tweetTextView.frame = self.view.bounds;
  
  [UIView commitAnimations];
}

#pragma mark -
#pragma mark UIAlertView Delegate Methods
// +--------------------------------------------------------------------
// | UIAlertView Delegate Methods
// +--------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  static NSInteger kOKButton = 1;
  
  if (buttonIndex == kOKButton)
	{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/account/settings/geo"]];
	}
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
  [self toggleHud:NO];
  
  DebugLog(@"Request succeeded for connectionIdentifier = %@", connectionIdentifier);  
  [self clearTweetText];
  [self.navigationController dismissModalViewControllerAnimated:YES];  
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
  [self toggleHud:NO];
  
  UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Unable to Post to Twitter" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [failedAlert show];
  [failedAlert release];
  
  DebugLog(@"Request failed for connectionIdentifier = %@, error = %@ (%@)", connectionIdentifier, [error localizedDescription], [error userInfo]);
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
  if (([statuses count] == 0)) return;
  
  SBTimelineViewController *timelineViewController = (SBTimelineViewController *)self.logicalParentViewController;
  SBStatusImportOperation *operation = [[SBStatusImportOperation alloc] initWithStatuses:statuses delegate:timelineViewController];
  
  if (!(queue))
  {
    queue = [[NSOperationQueue alloc] init];
  }
  
  [queue addOperation:operation];
  [operation release];
  
  DebugLog(@"Should insert the new status into the data cache.");
}

#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (void)setupKeyboardToolbar 
{
  SBActivityButton *activityIndicator = [[SBActivityButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
  self.activityButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];    
  [activityIndicator release];  
  
  locationController = [[SBGeolocationController alloc] init];
  locationController.delegate = self;
  
  self.keyboardToolbar.tintColor = DEFAULT_TINT_COLOR;
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  [nc addObserver:self selector:@selector(userNameSelectedFromAddressBook:) name:PTSelectedUserFromAddressBook object:nil];
  [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)restoreReplyToStatus 
{
  NSString *inReplyTweetID = [[NSUserDefaults standardUserDefaults] valueForKey:kTweetInProgressReplyStatus];
  if ((inReplyTweetID != nil))
  {
    NSURL *moIDURL = [NSURL URLWithString:inReplyTweetID];
    NSManagedObjectID *moID = [[SBAppDelegate instance].coreDataManager.persistentStoreCoordinator managedObjectIDForURIRepresentation:moIDURL];
    self.inReplyToStatus = (SBTweet *)[[SBAppDelegate instance].coreDataManager.managedObjectContext objectWithID:moID];
  }
}

- (void)restoreLocationData
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  CLLocationDegrees latitude = [[defaults objectForKey:kTweetInProgressLatitude] doubleValue];
  CLLocationDegrees longitude = [[defaults objectForKey:kTweetInProgressLongitude] doubleValue];
  
  if ((latitude != 0.0))
  {    
    self.currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    self.currentLocationString = [defaults objectForKey:kTweetInProgressLocationString];
    if (!(locationViewVisible))
    {
      [self showLocationView];
    }
    [self updateToolbarWithActivityButton:NO];
  }
  
}

- (void)restoreInProgressTweet 
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  [self restoreReplyToStatus];
  
  NSString *inProgressTweet = [defaults valueForKey:kTweetInProgressText];

  if ((self.inReplyToStatus != nil))
  {
    self.titleView.titleLabel.text = [NSString stringWithFormat:@"Reply\nto %@", self.inReplyToStatus.user.screenName];

    NSString *vanillaReply = [NSString stringWithFormat:@"@%@ ", self.inReplyToStatus.user.screenName];
    self.tweetTextView.text = ((inProgressTweet != nil)) ? inProgressTweet : vanillaReply;
  }
  else 
  {
    self.tweetTextView.text = inProgressTweet;
  }
}

- (void)saveInProgressTweet 
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ((self.inReplyToStatus != nil))
  {
    NSURL *replyStatusIDURL = [[self.inReplyToStatus objectID] URIRepresentation];
    [defaults setObject:[replyStatusIDURL absoluteString] forKey:kTweetInProgressReplyStatus];
  }
  else 
  {
    [defaults setValue:nil forKey:kTweetInProgressReplyStatus];
  }

  if ((self.currentLocation != nil))
  {
    [defaults setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.latitude] forKey:kTweetInProgressLatitude];
    [defaults setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.longitude] forKey:kTweetInProgressLongitude];
    [defaults setObject:self.currentLocationString forKey:kTweetInProgressLocationString];
  }
  else 
  {
    [defaults setValue:nil forKey:kTweetInProgressLatitude];
    [defaults setValue:nil forKey:kTweetInProgressLongitude];
    [defaults setValue:nil forKey:kTweetInProgressLocationString];  
  }

  [defaults setValue:self.tweetTextView.text forKey:kTweetInProgressText];
}

- (void)toggleHud:(BOOL)shouldShow
{
  if (shouldShow)
  {
    UIView *viewToUse = self.navigationController.navigationBar.superview;
    [DSBezelActivityView activityViewForView:viewToUse withLabel:NSLocalizedString(@"Posting...", nil)];
    [DSActivityView currentActivityView].showNetworkActivityIndicator = YES;
  }
  else 
  {
    [DSBezelActivityView removeViewAnimated:YES];
  }
}

- (void)updateCharacterCount
{
  NSInteger charCount = [self.tweetTextView.text length];
  NSInteger remainderCount = 140 - charCount;
  self.characterCountView.label.text = [NSString stringWithFormat:@"%ld", remainderCount];  
}

- (BOOL)underCharacterCount
{
  NSInteger length = [self.tweetTextView.text length];
  return ((length <= 140) && (length != 0));  
}

- (void)clearTweetText
{
  self.tweetTextView.text = @"";
  self.titleView.titleLabel.text = NSLocalizedString(@"New Tweet", nil);
  self.inReplyToStatus = nil;
  self.currentLocation = nil;
  self.currentLocationString = @"";;
  [self saveInProgressTweet];
  [self hideLocationView];
  [self updateToolbarWithActivityButton:NO];
  [self updateCharacterCount];  
}

- (BOOL)hasEnabledGeoPosting
{
  if (!([[SBAccountManager manager] loggedInUserAccount].enabledGeoPosting))
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Posting" message:@"Location posting must be enabled via the Twitter website to attach locations to tweets.  Would you like to visit the site now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
    
    return NO;
  }  
  
  return YES;
}

- (void)showLocationView
{
  static CGFloat kLocationViewHeight = 26.0f;
  CGRect theFrame = self.tweetTextView.frame;  
  theFrame.origin.y = CGRectGetMaxY(theFrame);
  theFrame.size.height = kLocationViewHeight;

  if (!(self.locationView))
  {
    self.locationView = [[SBLocationView alloc] initWithFrame:theFrame];    
  }

  self.locationView.locationString = self.currentLocationString;
  
  CGRect tweetViewFrame = self.tweetTextView.frame;
  tweetViewFrame.size.height -= locationView.frame.size.height;
  self.tweetTextView.frame = tweetViewFrame;
  locationViewVisible = YES;
  [self.view insertSubview:self.locationView belowSubview:self.tweetTextView.inputAccessoryView];
 
  // Slide the view up from the under the keyboard toolbar
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.15];
  theFrame.origin.y -= kLocationViewHeight;
  locationView.frame = theFrame;  
  [UIView commitAnimations];
}

- (void)hideLocationView
{
  static CGFloat kLocationViewHeight = 26.0f;
  CGRect locationFrame = self.locationView.frame;
  
  CGRect tweetViewFrame = self.tweetTextView.frame;
  tweetViewFrame.size.height += locationView.frame.size.height;
  self.tweetTextView.frame = tweetViewFrame;
    
  // Slide the view down under the toolbar again.
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.30];
  locationFrame.origin.y += kLocationViewHeight;
  locationView.frame = locationFrame;  
  [UIView commitAnimations];
  
  locationViewVisible = NO;
}
@end

