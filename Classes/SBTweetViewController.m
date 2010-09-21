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

// TODO: Update Action sheet to use SGActionSheet
// TODO: Add button to bottom tooblar for retweeting
// TODO: Add button to bottom toolbar for 'Send to Instapaper'
// TODO: Add "Show Conversation" button to web view where appropriate.
// TODO: Add inline image rendering

#import "SBTweetViewController.h"
#import "SBPostingViewController.h"
#import "SBBrowserViewController.h"
#import "SBTweetHeaderView.h"
#import "SBTweetContentsTableViewCell.h"
#import "SBTwitterManager.h"
#import "SBStatusImportOperation.h"
#import "MGTwitterEngine.h"
#import "SGActionSheet.h"

enum PTTweetViewSections 
{
  kTweetSection = 0,
  kActionSection,
  NUM_SECTIONS
};

enum TweetSection
{
  kLocationSectionPostingPreference = 0,
  NUM_TWEET_SECTION_ROWS
};

enum PersonalActionSection
{
  kPersonalActionSectionReplyRow = 0,
  kPersonalActionSectionGearRow,
  NUM_PERSONAL_ACTION_SECTION_ROWS
};

enum ActionSection 
{
  kActionSectionReplyRow = 0,
  kActionSectionRetweetRow,
  kActionSectionFavoriteRow,
  kActionSectionGearRow,
  NUM_ACTION_SECTION_ROWS
};

@interface SBTweetViewController ()
- (UIImage *)favoritedStatusImage;
- (NSString *)favoritedStatusText;
@end

@implementation SBTweetViewController

@synthesize postingViewController;
@synthesize tweetHeaderView;
@synthesize bottomToolbar;
@synthesize webView;
@synthesize connections;
@synthesize tweet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
  {
    twitter = [[SBTwitterManager createTwitterEngineForCurrentUserWithDelegate:self] retain];
    connections = [[NSMutableDictionary alloc] init];
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
  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;    
  self.navigationController.toolbar.tintColor = DEFAULT_TINT_COLOR;
  self.view.backgroundColor = DEFAULT_TABLE_BG_COLOR;
  self.toolbarItems = self.bottomToolbar.items;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.tweetHeaderView setNeedsDisplay];
  [self.webView loadHTMLString:[self.tweet contentFormattedForDisplay] baseURL:nil];
  self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  self.navigationController.toolbarHidden = YES;
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

  self.postingViewController = nil;
}

- (void)viewDidUnload 
{
  [super viewDidUnload];
  self.tweetHeaderView = nil;
  self.webView = nil;
  self.bottomToolbar = nil;
  self.postingViewController = nil;
  self.tweet = nil;
}


- (void)dealloc 
{
  [tweetHeaderView release];
  [webView release];
  [bottomToolbar release];
  [postingViewController release];
  [tweet release];
  [super dealloc];
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (IBAction)replyToTweet:(id)sender
{
  if ((self.postingViewController == nil))
  {
    SBPostingViewController *newPostingViewController = [[SBPostingViewController alloc] init];
    self.postingViewController = newPostingViewController;
    [newPostingViewController release];
  }
  
  self.postingViewController.inReplyToStatus = self.tweet;
  
  // Override the existing defaults.
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kTweetInProgressReplyStatus];
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kTweetInProgressText];
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kTweetInProgressLatitude];
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kTweetInProgressLongitude];
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kTweetInProgressLocationString];
  
  UINavigationController *postingNavigationController = [[UINavigationController alloc] initWithRootViewController:self.postingViewController];
  postingNavigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  [self.navigationController presentModalViewController:postingNavigationController animated:YES];
  [postingNavigationController release];
}

- (void)addSpinnerToRetweetCell
{
//  NSIndexPath *retweetIndexPath = [NSIndexPath indexPathForRow:kActionSectionRetweetRow inSection:kActionSection];
//  UITableViewCell *retweetCell = [self.tableView cellForRowAtIndexPath:retweetIndexPath];
//  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; 
//  [retweetCell.imageView addSubview:spinner]; 
//  [spinner startAnimating]; 
//  [spinner release];
//  retweeting = YES;
//  [self configureCell:retweetCell atIndexPath:retweetIndexPath];
}

- (void)removeSpinnerFromRetweetCell
{
//  NSIndexPath *retweetIndexPath = [NSIndexPath indexPathForRow:kActionSectionRetweetRow inSection:kActionSection];
//  UITableViewCell *retweetCell = [self.tableView cellForRowAtIndexPath:retweetIndexPath];
//  [[retweetCell.imageView.subviews objectAtIndex:0] removeFromSuperview];
//  retweeting = NO;
//  [self configureCell:retweetCell atIndexPath:retweetIndexPath];
}

- (IBAction)retweetTweet:(id)sender
{
  SGActionSheet *retweetSheet = [[SGActionSheet alloc] initWithTitle:nil];
  [retweetSheet addButtonWithTitle:NSLocalizedString(@"Retweet", nil) block:^{
     MGTwitterEngineID tweetID = [self.tweet engineID];  
     
     NSString *identifier = @"RETWEET";
     [self.connections setObject:identifier forKey:[twitter sendRetweet:tweetID]];
     [self addSpinnerToRetweetCell];     
   }];
  
  [retweetSheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) block:^{
    // Nothing
  }];
  
  [retweetSheet showInView:self.view.window];
  [retweetSheet release];
}

- (IBAction)favoriteTweet:(id)sender
{
  BOOL favoritedValue = [self.tweet favoritedValue];
  MGTwitterEngineID tweetID = [self.tweet engineID];
  
  NSString *identifier = ((favoritedValue == NO)) ? @"FAV" : @"UNFAV";
  [self.connections setObject:identifier forKey:[twitter markUpdate:tweetID asFavorite:!favoritedValue]];
  [self.tweet setFavoritedValue:!favoritedValue];
  
  [SBActivityIndicator enable];
}

- (IBAction)showTweetActionSheet
{
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                     delegate:self 
                                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                       destructiveButtonTitle:nil 
                                            otherButtonTitles:NSLocalizedString(@"Email Tweet", nil), NSLocalizedString(@"Post Link To Tweet", nil), nil];

  SBAppDelegate *delegate = (SBAppDelegate *)[[UIApplication sharedApplication] delegate];
  [sheet showInView:delegate.window];
  [sheet release];  
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  enum PTTimelineViewActionResponseTypes {
    kEmailTweetButton   = 0,
    kPostLinkButton     = 1,
    kCancelButton       = 2,
  };
  
	switch (buttonIndex)
	{
    case kEmailTweetButton:
      [self emailTweet];
      break;
    case kPostLinkButton:
      [self postLinkToTweet];
      break;
    case kCancelButton:
      break;
    default:
      NSAssert(NO, @"Unhandled Button in SBTweetViewController's action sheet");
      break;
	}
}

- (void)emailTweet
{
  if (([MFMailComposeViewController canSendMail]))
  {
    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
    composeViewController.mailComposeDelegate = self;
    NSString *subject = [NSString stringWithFormat:@"Tweet from %@ (@%@)", self.tweet.user.name, self.tweet.user.screenName];
    [composeViewController setSubject:subject]; // Tweet from Full Name (@username)
    [composeViewController setMessageBody:[self.tweet tweetTextAsEmail] isHTML:YES];
    
    [self presentModalViewController:composeViewController animated:YES];
    [composeViewController release];
    
    
  }
  else 
  {
    UIAlertViewQuick(@"Cannot Send Email", @"Your device isn't configured to send email.", @"OK");
  }
}

- (void)postLinkToTweet
{
  if ((self.postingViewController == nil))
  {
    SBPostingViewController *newPostingViewController = [[SBPostingViewController alloc] init];
    self.postingViewController = newPostingViewController;
    [newPostingViewController release];
  }
  
  [[NSUserDefaults standardUserDefaults] setValue:[self.tweet tweetURL] forKey:kTweetInProgressText];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  UINavigationController *postingNavigationController = [[UINavigationController alloc] initWithRootViewController:self.postingViewController];
  postingNavigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  [self.navigationController presentModalViewController:postingNavigationController animated:YES];
  [postingNavigationController release];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods
// +--------------------------------------------------------------------
// | MFMailComposeViewControllerDelegate Methods
// +--------------------------------------------------------------------

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | PTTweetHeaderView Data Source Methods
// +--------------------------------------------------------------------

- (NSString *)screenNameForTweetHeaderView:(SBTweetHeaderView *)headerView
{
  if ((self.tweet.user))
  {
    return self.tweet.user.screenName;
  }
  
  return @"";
}

- (UIImage *)avatarForTweetHeaderView:(SBTweetHeaderView *)headerView
{
  if ((self.tweet.user))
  {
    return self.tweet.user.avatar;
  }
  
  return nil;
}

- (NSString *)fullNameForTweetHeaderView:(SBTweetHeaderView *)headerView
{
  if ((self.tweet.user))
  {
    return self.tweet.user.name;
  }
  
  return @"";
}

- (NSString *)locationForTweetHeaderView:(SBTweetHeaderView *)headerView
{
  if ((self.tweet.user))
  {
    return self.tweet.user.location;
  }
  
  return @"";
}

#pragma mark -
#pragma mark UIWebView Delegate Methods
// +--------------------------------------------------------------------
// | UIWebView Delegate Methods
// +--------------------------------------------------------------------

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{  
  if (navigationType == UIWebViewNavigationTypeLinkClicked) 
  {
    NSString *scheme = [[request URL] scheme];
    if (([scheme isEqualToString:@"http"]) || ([scheme isEqualToString:@"https"]))
    {
      [self showWebViewWithURLRequest:request];
    }
    else if ([scheme isEqualToString:@"x-soapbox"])
    {
      // Pass it off to SBAppDelegate to handle pushing down the navigation stack.
      [[UIApplication sharedApplication] openURL:[request URL]];
    }
    
    return NO;
  }
  
  return YES;
}

#pragma mark -
#pragma mark PTTweetContentsTableViewCell Delegate Methods
// +--------------------------------------------------------------------
// | PTTweetContentsTableViewCell Delegate Methods
// +--------------------------------------------------------------------

- (void)showWebViewWithURLRequest:(NSURLRequest *)theRequest
{
  SBBrowserViewController *browserViewController = [[SBBrowserViewController alloc] initWithNibName:NSStringFromClass([SBBrowserViewController class]) bundle:nil];
  browserViewController.linkURL = [theRequest URL];
  [self.navigationController pushViewController:browserViewController animated:YES];
  [browserViewController release];
}


#pragma mark -
#pragma mark MGTwitterEngine Delegate Methods
// +--------------------------------------------------------------------
// | MGTwitterEngine Delegate Methods
// +--------------------------------------------------------------------


- (void)connectionFinished:(NSString *)connectionIdentifier
{
  DebugLog(@"Connection finished %@", connectionIdentifier);
  
  NSString *requestType = [self.connections objectForKey:connectionIdentifier];
  if (([requestType isEqualToString:@"RETWEET"]))
  {
    [self removeSpinnerFromRetweetCell];
    [self.connections removeObjectForKey:connectionIdentifier];
  }
  
	if ([twitter numberOfConnections] == 0)
	{
	}
}

- (void)requestSucceeded:(NSString *)connectionIdentifier
{ 
  DebugLog(@"Request succeeded for connectionIdentifier = %@", connectionIdentifier);
  [SBActivityIndicator disable];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
  [SBActivityIndicator disable];
  UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [failedAlert show];
  [failedAlert release];
  
  DebugLog(@"Request failed for connectionIdentifier = %@, error = %@ (%@)", 
           connectionIdentifier, 
           [error localizedDescription], 
           [error userInfo]);
  
  NSString *requestType = [self.connections objectForKey:connectionIdentifier];
  if (([requestType isEqualToString:@"FAV"]) || ([requestType isEqualToString:@"UNFAV"]))
  {
    self.tweet.favoritedValue = (!self.tweet.favoritedValue);
//    [self.tableView reloadData];
  }
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
  if (([statuses count] == 0)) 
  {     
    return;
  }
  
  SBStatusImportOperation *operation = [[SBStatusImportOperation alloc] initWithStatuses:statuses delegate:self];  
  
  if (!(queue))
  {
    queue = [[NSOperationQueue alloc] init];
  }
  
  [queue addOperation:operation];
  [operation release];
}

#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (NSString *)favoritedStatusText
{
  if (!(self.tweet.favoritedValue))
  {
    return NSLocalizedString(@"Favorite", nil);
  }  
  else 
  {
    return NSLocalizedString(@"Unfavorite", nil);
  }
}

- (UIImage *)favoritedStatusImage
{
  if (!(self.tweet.favoritedValue))
  {
    return [UIImage imageNamed:@"favorite-button.png"]; 
  }
  else 
  {
    return [UIImage imageNamed:@"unfavorite-button.png"]; 
  }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  if ((self.tweet.tweetTypeValue != SBTweetTypePersonal))
  {    
    switch (indexPath.row)
    {
      case kActionSectionReplyRow:
        cell.imageView.image = [UIImage imageNamed:@"reply-button.png"];
        cell.textLabel.text = @"Reply";
        break;
      case kActionSectionRetweetRow:
        if ((retweeting))
        {
          cell.imageView.image = [UIImage imageNamed:@"whiteback.png"];
          cell.textLabel.text = @"Retweeting...";
          cell.textLabel.textColor = [UIColor grayColor];
        }
        else
        {
          cell.imageView.image = [UIImage imageNamed:@"retweet-button.png"];
          cell.textLabel.text = @"Retweet";
          cell.textLabel.textColor = [UIColor blackColor];
        }
        break;
      case kActionSectionFavoriteRow:
        cell.imageView.image = [self favoritedStatusImage];
        cell.textLabel.text = [self favoritedStatusText];
        break;        
      case kActionSectionGearRow:
        cell.imageView.image = [UIImage imageNamed:@"action-button.png"];
        cell.textLabel.text = @"Action";
        break;
      default:
        NSAssert(NO, @"Unhandled Button in SBTweetViewController's cellForRowAtIndexPath:");
        break;
    }  
  }
  else 
  {
    switch (indexPath.row)
    {
      case kPersonalActionSectionReplyRow:
        cell.imageView.image = [UIImage imageNamed:@"reply-button.png"];
        cell.textLabel.text = @"Reply";
        break;
      case kPersonalActionSectionGearRow:
        cell.imageView.image = [UIImage imageNamed:@"action-button.png"];
        cell.textLabel.text = @"Action";
        break;
      default:
        NSAssert(NO, @"Unhandled Button in SBTweetViewController's cellForRowAtIndexPath:");
        break;
    }      
  }
}

@end
