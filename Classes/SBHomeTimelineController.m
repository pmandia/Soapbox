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


#import "SBHomeTimelineController.h"
#import "SBStatusImportOperation.h"
#import "CCoreDataManager.h"
#import "SBAccountManager.h"
#import "SBTwitterManager.h"

@interface SBHomeTimelineController ()
- (MGTwitterEngineID)latestID;
- (MGTwitterEngineID)earliestID;
- (void)saveLastStatusIDWithStatus:(NSDictionary *)lastStatus;
@end

@implementation SBHomeTimelineController

#pragma mark -
#pragma mark View Lifecycle
// +--------------------------------------------------------------------
// | View Lifecycle
// +--------------------------------------------------------------------

- (void)viewDidLoad 
{
  [super viewDidLoad];
  self.navigationItem.title = NSLocalizedString(@"Timeline", nil);
  
}

- (void)viewDidAppear:(BOOL)animated 
{
  [super viewDidAppear:animated];
  
  SBAccount *account = [[SBAccountManager manager] loggedInUserAccount];
  if (account.homeTimelineScrollViewLastContentOffset != nil) 
  {
    self.tableView.contentOffset = CGPointFromString(account.homeTimelineScrollViewLastContentOffset);
  }  
  
  // TODO: If the timeline hasn't been refreshed in 5 minutes, refresh it here.  
  [self fetchLatestTimeline];
}

#pragma mark -
#pragma mark Memory Management Methods
// +--------------------------------------------------------------------
// | Memory Management Methods
// +--------------------------------------------------------------------

- (void)didReceiveMemoryWarning 
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc 
{
  [super dealloc];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)refresh:(id)sender
{
  [self fetchLatestTimeline];
}


#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)fetchLatestTimeline
{
  shouldAdjustContentOffset = YES;
  [self disableRefreshButton:YES];
  [self setRefreshing:YES];
  MGTwitterEngineID latestID = [self latestID];
  [twitter getHomeTimelineSinceID:latestID startingAtPage:1 count:kMaximumTweetLoad];
}

- (void)fetchOlderTimeline
{
  shouldAdjustContentOffset = NO;
  [self showRefreshFooter:YES];
  [self setRefreshing:YES];
  MGTwitterEngineID earliestID = [self earliestID];

  [twitter getHomeTimelineSinceID:0 withMaximumID:earliestID startingAtPage:1 count:(kMaximumTweetLoad / 2)];
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods
// +--------------------------------------------------------------------
// | UIScrollView Delegate Methods
// +--------------------------------------------------------------------

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  [super scrollViewDidEndDecelerating:scrollView];
  // Detect if we are at the bottom.  If so, refresh some older tweets.
  CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
  if ((scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) && scrollView.contentSize.height > screenFrame.size.height) 
  {
    [self fetchOlderTimeline];
  }
}

#pragma mark -
#pragma mark Dynamic Accessor Methods
// +--------------------------------------------------------------------
// | Dynamic Accessor Methods
// +--------------------------------------------------------------------

- (NSFetchedResultsController *)fetchedResultsController
{
  if ((fetchedResultsController == nil))
  {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setFetchBatchSize:50];
    [fetchRequest setFetchLimit:25];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTweetEntityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];  

    [fetchRequest setPredicate:[self filtersPredicate]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];//@"HomeTimeline"];
    theFetchedResultsController.delegate = self;
    self.fetchedResultsController = theFetchedResultsController;    
    NSError *error = nil;
		if (![self.fetchedResultsController performFetch:&error]) 
    {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}    
    
    [theFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];    
  }
  
  return fetchedResultsController;
}

- (NSPredicate *)filtersPredicate
{
  if ((filtersPredicate == nil))
  {
    NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
    NSArray *filters = [[SBFilter allFiltersUsingManagedObjectContext:self.managedObjectContext] retain];    
    for (SBFilter *filter in filters)
    {     
      BOOL isSourceFilter = filter.sourceFilterValue;
      NSPredicate *filterPredicate = nil;
      if (!(isSourceFilter))
      {
        filterPredicate = [NSPredicate predicateWithFormat:@"NOT text CONTAINS[cd] %@", filter.term];
      }
      else 
      {
        filterPredicate = [NSPredicate predicateWithFormat:@"NOT createdUsingApp CONTAINS[cd] %@", filter.term];
      }
      
      [predicateArray addObject:filterPredicate];
    }
    
    NSPredicate *tweetDownloadedAsPredicate = [NSPredicate predicateWithFormat:@"downloadedAsFollower == %@", [NSNumber numberWithBool:YES]];
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObject:tweetDownloadedAsPredicate]];    
    [predicateArray addObject:andPredicate];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    self.filtersPredicate = predicate;
    [predicateArray release];
    [filters release];
  }
  
  return filtersPredicate;
}

#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (MGTwitterEngineID)latestID 
{
  SBAccount *loggedInAccount = [SBAccountManager manager].loggedInUserAccount;
  
  if ((loggedInAccount.homeTimelineLastDownloadTweetID != nil))
  {
    return [loggedInAccount.homeTimelineLastDownloadTweetID longLongValue];
  } 
  else 
  {
    return 0;
  }
}


- (MGTwitterEngineID)earliestID 
{
  if (([[self.fetchedResultsController fetchedObjects] count])) 
  {
    return [[[self.fetchedResultsController fetchedObjects] lastObject] engineID] - 1;
  } 
  else 
  {
    return 0;
  }
}

- (void)saveLastStatusIDWithStatus:(NSDictionary *)lastStatus  
{
  NSNumber *lastTweetDownloadedID = [NSNumber numberWithLongLong:[[[self.fetchedResultsController fetchedObjects] firstObject] engineID]];
  SBAccount *account = [[SBAccountManager manager] loggedInUserAccount];
  account.homeTimelineLastDownloadTweetID = lastTweetDownloadedID;
  [[SBAccountManager manager] saveAccount:account];
}
@end

