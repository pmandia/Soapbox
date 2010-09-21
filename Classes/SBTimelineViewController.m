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

#import "SBTimelineViewController.h"
#import "SBTweetTableViewCell.h"
#import "SBPostingViewController.h"
#import "SBTwitterManager.h"
#import "MGTwitterEngine.h"
#import "SBTimelineController.h"
#import "CCoreDataManager.h"
#import "SBAvatarDownloader.h"
#import "SBAccountManager.h"
#import "SBTweetView.h"
#import "SBSlidingAlertView.h"
#import "SBStatusImportOperation.h"
#import "SBTweetViewController.h"
#import "SBSoundEffect.h"

@interface SBTimelineViewController ()
- (void)saveScrollPosition;
@end


#define TWEET_FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define ROW_HEIGHT 60
#define MAX_ROW_HEIGHT 9999


@implementation SBTimelineViewController

@synthesize postTweetButton;
@synthesize tableHeaderView;
@synthesize loadNewerTweetsButton;
@synthesize refreshActivityIndicator;
@synthesize tableFooterView;
@synthesize footeReloadLabel;
@synthesize footerActivityIndicator;
@synthesize timelineController;
@synthesize avatarDownloadsInProgress;
@synthesize postingViewController;
@synthesize singleTweetViewController;
@synthesize refreshing;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize filtersPredicate;

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

  self.managedObjectContext = [[SBAppDelegate instance].coreDataManager.managedObjectContext retain];

  self.avatarDownloadsInProgress = [NSMutableDictionary dictionary];
  
  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  self.navigationItem.rightBarButtonItem = self.postTweetButton;

  self.tableView.backgroundColor = DEFAULT_TABLE_BG_COLOR;
  self.tableView.tableHeaderView = self.tableHeaderView;
  self.tableView.tableFooterView = self.tableFooterView;
  self.tableView.tableFooterView.hidden = YES;  
}

- (void)viewWillDisappear:(BOOL)animated
{
//  [twitter closeAllConnections];
  
  for (NSString *key in [avatarDownloadsInProgress allKeys])
  {
    SBAvatarDownloader *downloader = [avatarDownloadsInProgress objectForKey:key];
    [downloader cancelDownload];
    [avatarDownloadsInProgress removeObjectForKey:key];
  }
  
  [self saveScrollPosition];
  [super viewWillDisappear:animated];
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

  // terminate all pending download connections
  [twitter closeAllConnections];
  NSArray *allDownloads = [self.avatarDownloadsInProgress allValues];
  [allDownloads performSelector:@selector(cancelDownload)];
}

- (void)viewDidUnload 
{
  self.postTweetButton = nil;
  self.tableHeaderView = nil;
  self.loadNewerTweetsButton = nil;
  self.refreshActivityIndicator = nil;
  self.tableFooterView = nil;
  self.footeReloadLabel = nil;
  self.footerActivityIndicator = nil;
  self.timelineController = nil;
  self.postingViewController = nil;
  self.singleTweetViewController = nil;
  self.managedObjectContext = nil;
  self.fetchedResultsController = nil;
  [super viewDidUnload];
}

- (void)dealloc 
{
  [twitter closeAllConnections];
  
  [postTweetButton release];
  [tableHeaderView release];
  [loadNewerTweetsButton release]; 
  [refreshActivityIndicator release];
  [tableFooterView release];
  [footeReloadLabel release];
  [footerActivityIndicator release];
  [twitter release];
  [timelineController release];
  [avatarDownloadsInProgress release];
  [postingViewController release];
  [singleTweetViewController release];
  [queue release];
  [managedObjectContext release];
  [fetchedResultsController release];
  [filtersPredicate release];
  [super dealloc];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)refresh:(id)sender
{
  NSLog(@"Timeline View Controller refresh:");
}

- (IBAction)post:(id)sender
{
  if ((self.postingViewController == nil))
  {
    SBPostingViewController *newPostingViewController = [[SBPostingViewController alloc] init];   
    newPostingViewController.logicalParentViewController = self;
    self.postingViewController = newPostingViewController;
    [newPostingViewController release];
  }

  UINavigationController *postingNavigationController = [[UINavigationController alloc] initWithRootViewController:self.postingViewController];
  postingNavigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  [self.navigationController presentModalViewController:postingNavigationController animated:YES];
  [postingNavigationController release];
}


#pragma mark -
#pragma mark Table View Data Source Methods
// +--------------------------------------------------------------------
// | Table View Data Source Methods
// +--------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  NSInteger count = [self.fetchedResultsController.sections count];
  
  if ((count == 0))
  {
    count = 1;
  }
  
  return count;  
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  NSInteger numberOfRows = 0;
  NSInteger sectionCount = [self.fetchedResultsController.sections count];
  
  if (sectionCount > 0) {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    numberOfRows = [sectionInfo numberOfObjects];
  }
  
  
  return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
  static NSString *kCellIdentifier = @"PTTweetTableViewCell";

  SBTweetTableViewCell *tweetCell = (SBTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (tweetCell == nil) 
  {
    tweetCell = [[[SBTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
    CGRect frame = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
		tweetCell.frame = frame;
    tweetCell.selectedBackgroundView = [[[UIView alloc] initWithFrame:frame] autorelease];
  }
  
  SBTweet *selectedTweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [tweetCell setTweet:selectedTweet];
  
  UIImage *cachedAvatar = [selectedTweet.user avatar];
  
  if (!cachedAvatar)
  {
    if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
    {
      [self startAvatarDownload:selectedTweet.user forIndexPath:indexPath];
    }
  }
  
  return tweetCell;
}


#pragma mark -
#pragma mark Table View Delegate Methods
// +--------------------------------------------------------------------
// | Table View Delegate Methods
// +--------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  if ((singleTweetViewController == nil))
  {
    SBTweetViewController *tweetViewController = [[SBTweetViewController alloc] initWithNibName:NSStringFromClass([SBTweetViewController class]) bundle:nil];
    self.singleTweetViewController = tweetViewController;
    [tweetViewController release];
  }
  
  SBTweet *selectedTweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  self.singleTweetViewController.tweet = selectedTweet;
  [self.navigationController pushViewController:self.singleTweetViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  CGFloat height = 0.0f;
  height = [self cellHeightForIndexPath:indexPath];
  
  return height;
}

#pragma mark -
#pragma mark Table Cell Image Support Methods
// +--------------------------------------------------------------------
// | Table Cell Image Support Methods
// +--------------------------------------------------------------------

- (void)startAvatarDownload:(SBUser *)user forIndexPath:(NSIndexPath *)theIndexPath
{
  SBAvatarDownloader *avatarDownloader = [avatarDownloadsInProgress objectForKey:theIndexPath];
  if (avatarDownloader == nil) 
  {
    avatarDownloader = [[SBAvatarDownloader alloc] init];
    avatarDownloader.user = user;
    avatarDownloader.indexPathInTableView = theIndexPath;
    avatarDownloader.delegate = self;
    [avatarDownloadsInProgress setObject:avatarDownloader forKey:theIndexPath];
    [avatarDownloader startDownload];
    [avatarDownloader release];   
  }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
  if ([self.fetchedResultsController.fetchedObjects count] > 0)
  {
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
      SBTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
      SBUser *user = tweet.user;
      
      if (!(user.avatar)) // avoid the app icon download if the app already has an icon
      {
        [self startAvatarDownload:user forIndexPath:indexPath];
      }
    }
  }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)avatarDidLoad:(NSIndexPath *)indexPath
{
  SBAvatarDownloader *avatarDownloader = [avatarDownloadsInProgress objectForKey:indexPath];
  if (avatarDownloader != nil)
  {
    SBTweetTableViewCell *tweetCell = (SBTweetTableViewCell *)[self.tableView cellForRowAtIndexPath:avatarDownloader.indexPathInTableView];
    [tweetCell redisplay];
  }
}

#pragma mark -
#pragma mark MGTwitterEngine Delegate Methods
// +--------------------------------------------------------------------
// | MGTwitterEngine Delegate Methods
// +--------------------------------------------------------------------

- (void)connectionFinished:(NSString *)connectionIdentifier
{
  DebugLog(@"Connection finished %@", connectionIdentifier);
  
	if ([twitter numberOfConnections] == 0)
	{
    [SBSlidingAlertView currentAlertView].showNetworkActivityIndicator = NO;
    [SBSlidingAlertView hideViewAnimated:YES];
	}
  
}

- (void)requestSucceeded:(NSString *)connectionIdentifier
{ 
  DebugLog(@"Request succeeded for connectionIdentifier = %@", connectionIdentifier);  
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
  [self disableRefreshButton:NO];
  [self showRefreshFooter:NO];

  UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Timeline Fetch Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [failedAlert show];
  [failedAlert release];
  
  DebugLog(@"Request failed for connectionIdentifier = %@, error = %@ (%@)", 
        connectionIdentifier, 
        [error localizedDescription], 
        [error userInfo]);
}


- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
  if (([statuses count] == 0)) 
  { 
    [self refreshDone];
    return;
  }
  
  SBStatusImportOperation *operation = [[SBStatusImportOperation alloc] initWithStatuses:statuses delegate:self];  
  if (([NSStringFromClass([self class]) isEqualToString:@"SBMentionsViewController"]))
  {
    operation.markAllStatusesAsMentions = YES;
  }
  
  if (!(queue))
  {
    queue = [[NSOperationQueue alloc] init];
  }
  
  [queue addOperation:operation];
  [operation release];
}

- (void)mergeChanges:(NSNotification *)notification
{
  NSAssert([NSThread mainThread], @"Not on the main thread");  
  NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
  for (NSManagedObject *object in updatedObjects)
  {
    [[managedObjectContext objectWithID:[object objectID]] willAccessValueForKey:nil];
  }

  // jww: disabled for now because it still chimes even when filtered mentions are output.
//  SBSoundEffect *refresh = [[SBSoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"timeline_refresh" ofType:@"wav"]];
//  [refresh play];  
  
  [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];     
}


#pragma mark -
#pragma mark NSFetchedResultsController Delegate Methods
// +--------------------------------------------------------------------
// | NSFetchedResultsController Delegate Methods
// +--------------------------------------------------------------------

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
  // Set the content offset to what it is prior to all this inserting dance.
  contentOffsetStartPosition = self.tableView.contentOffset.y;
  
  CGFloat refreshHeight = self.tableView.tableHeaderView.frame.size.height;
  if ((contentOffsetStartPosition <= refreshHeight))
  {
    contentOffsetStartPosition += refreshHeight;
  }
  contentOffsetAppended = 0.0f;
}

- (void)updateCell:(SBTweetTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  [cell.tweetView setNeedsDisplay];
}

   
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath 
{
	UITableView *tableView = self.tableView;
	switch(type) {
		case NSFetchedResultsChangeInsert:
      contentOffsetAppended += [self cellHeightForIndexPath:newIndexPath];
      break;
			
		case NSFetchedResultsChangeDelete:
      contentOffsetAppended -= [self cellHeightForIndexPath:newIndexPath];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self updateCell:(SBTweetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
  CGFloat adjustedOffsetHeight = contentOffsetStartPosition + contentOffsetAppended;  

  if ((shouldAdjustContentOffset))
  {
    self.tableView.contentOffset = CGPointMake(0, adjustedOffsetHeight);
  }

  [self.tableView reloadData];
  [self saveScrollPosition];
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods
// +--------------------------------------------------------------------
// | UIScrollView Delegate Methods
// +--------------------------------------------------------------------

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
  if (!decelerate)
	{
    [self loadImagesForOnscreenRows];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  [self loadImagesForOnscreenRows];
}

#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (void)disableRefreshButton:(BOOL)shouldEnable
{
  if ((shouldEnable))
  {
    [self.refreshActivityIndicator startAnimating];
    [self.loadNewerTweetsButton setEnabled:NO];
    [self.loadNewerTweetsButton setTitle:@"Refreshing..." forState:UIControlStateNormal];    
    [SBActivityIndicator enable];
  }
  else
  {    
    [self.refreshActivityIndicator stopAnimating];
    [self.loadNewerTweetsButton setEnabled:YES];
    [self.loadNewerTweetsButton setTitle:@"Load Newer" forState:UIControlStateNormal];    
    [SBActivityIndicator disable];
  }
}

- (void)showRefreshFooter:(BOOL)shouldShow
{
  if ((shouldShow))
  {
    self.tableView.tableFooterView.hidden = NO;
    [self.footerActivityIndicator startAnimating];
    [SBActivityIndicator enable];
  }
  else 
  {
    
    self.tableView.tableFooterView.hidden = YES;
    [self.footerActivityIndicator stopAnimating];
    [SBActivityIndicator disable];
  }
}

- (void)saveScrollPosition
{
  // Save scroll position
  SBAccount *account = [[SBAccountManager manager] loggedInUserAccount];
  account.homeTimelineScrollViewLastContentOffset = NSStringFromCGPoint(self.tableView.contentOffset); 
  [[SBAccountManager manager] saveAccount:account];  
}

- (CGFloat)cellHeightForIndexPath:(NSIndexPath *)indexPath
{
  SBTweet *selectedTweet = (SBTweet *)[self.fetchedResultsController objectAtIndexPath:indexPath];
  CGSize size = [selectedTweet.text sizeWithFont:[UIFont systemFontOfSize:TWEET_FONT_SIZE] constrainedToSize:CGSizeMake(230, MAX_ROW_HEIGHT) lineBreakMode:UILineBreakModeWordWrap];
  
  if ((selectedTweet.tweetTypeValue == PTTweetTypeRetweet))
  {
    size.height += 76;
  }
  else 
  {
    size.height += 52;
  }
  
  CGFloat height = MAX(size.height, 75.0f);
  
  return height;
}

- (void)refreshDone
{
  [self setRefreshing:NO];
  [self disableRefreshButton:NO];
  [self showRefreshFooter:NO];
}

@end

