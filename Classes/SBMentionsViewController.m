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

#import "SBMentionsViewController.h"
#import "SBTimelineViewController.h"
#import "SBAccountManager.h"
#import "SBTweetTableViewCell.h"
#import "CCoreDataManager.h"

@interface SBMentionsViewController ()
- (MGTwitterEngineID)latestID;
- (MGTwitterEngineID)earliestID;
- (void)saveLastStatusIDWithStatus:(NSDictionary *)lastStatus;
@end


@implementation SBMentionsViewController

#pragma mark -
#pragma mark View Lifecycle
// +--------------------------------------------------------------------
// | View Lifecycle
// +--------------------------------------------------------------------

- (void)viewDidLoad 
{
  [super viewDidLoad];

  self.navigationItem.title = NSLocalizedString(@"Mentions", nil);
  self.managedObjectContext = [[SBAppDelegate instance].coreDataManager.managedObjectContext retain];  
}

- (void)viewDidAppear:(BOOL)animated 
{
  [super viewDidAppear:animated];

  
  NSError *error = nil;
	if ((![self.fetchedResultsController performFetch:&error])) 
  {
		DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}   
  
  SBAccount *account = [[SBAccountManager manager] loggedInUserAccount];
  if (account.mentionsTimelineScrollViewLastContentOffset != nil) 
  {
    self.tableView.contentOffset = CGPointFromString(account.mentionsTimelineScrollViewLastContentOffset);
  }    
  
  // TODO: If the timeline hasn't been refreshed in 5 minutes, refresh it here.  
  [self fetchLatestMentions];
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
  [self fetchLatestMentions];
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)fetchLatestMentions
{
  shouldAdjustContentOffset = YES;
  [self disableRefreshButton:YES];
  [self setRefreshing:YES];
  MGTwitterEngineID latestID = [self latestID];
  [twitter getRepliesSinceID:latestID startingAtPage:1 count:kMaximumTweetLoad];
}


- (void)fetchOlderMentions
{
  shouldAdjustContentOffset = NO;
  [self showRefreshFooter:YES];
  [self setRefreshing:YES];
  MGTwitterEngineID earliestID = [self earliestID];
  [twitter getRepliesSinceID:0 withMaximumID:earliestID startingAtPage:1 count:kMaximumTweetLoad];
}

#pragma mark -
#pragma mark Table View Delegate Methods
// +--------------------------------------------------------------------
// | Table View Delegate Methods
// +--------------------------------------------------------------------

#pragma mark -
#pragma mark NSFetchedResultsController Delegate Methods
// +--------------------------------------------------------------------
// | NSFetchedResultsController Delegate Methods
// +--------------------------------------------------------------------

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath 
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{ 
  [self.tableView reloadData];
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
    [self fetchOlderMentions];
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
    [fetchRequest setFetchBatchSize:25];
    [fetchRequest setFetchLimit:25];
    [fetchRequest setPredicate:[self filtersPredicate]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTweetEntityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];  
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"MentionsTimeline"];
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
    // Build an array of predicates to filter with, then combine into one AND predicate
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
    
    NSPredicate *tweetTypeAndDownloadPredicate = [NSPredicate predicateWithFormat:@"tweetType == %@ && downloadedAsMention == %@", [NSNumber numberWithInteger:SBTweetTypeMention], [NSNumber numberWithBool:YES]];
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObject:tweetTypeAndDownloadPredicate]];    
    [predicateArray addObject:andPredicate];    
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    
    self.filtersPredicate = predicate;
    [filters release];
    [predicateArray release];
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
  
  if ((loggedInAccount.mentionsTimelineLastDownloadTweetID != nil))
  {
    return [loggedInAccount.mentionsTimelineLastDownloadTweetID longLongValue];
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
  account.mentionsTimelineLastDownloadTweetID = lastTweetDownloadedID;
  [[SBAccountManager manager] saveAccount:account];
}



@end

