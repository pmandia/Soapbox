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


#import "SBAddressBookViewController.h"
#import "SBAvatarDownloader.h"
#import "SBAppDelegate.h"
#import "CCoreDataManager.h"
#import "SBUser.h"

@interface SBAddressBookViewController ()
- (void)loadImagesForOnscreenRows;
@end

@implementation SBAddressBookViewController

@synthesize cancelButton;
@synthesize avatarDownloadsInProgress;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;

#pragma mark -
#pragma mark View Life Cycle
// +--------------------------------------------------------------------
// | View Life Cycle
// +--------------------------------------------------------------------

- (void)viewDidLoad 
{
  [super viewDidLoad];
  self.managedObjectContext = [[SBAppDelegate instance].coreDataManager.managedObjectContext retain];
  self.avatarDownloadsInProgress = [NSMutableDictionary dictionary];

  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  self.navigationItem.leftBarButtonItem = self.cancelButton;
  self.navigationItem.title = NSLocalizedString(@"Address Book", nil);
  
  NSError *error = nil;
	if ((![self.fetchedResultsController performFetch:&error])) 
  {
		DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		  
}

- (void)viewDidAppear:(BOOL)animated 
{
  [super viewDidAppear:animated];
  [self loadImagesForOnscreenRows];
}

- (void)dealloc 
{
  [cancelButton release];
  [avatarDownloadsInProgress release];
  [fetchedResultsController release];
  [managedObjectContext release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning 
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // terminate all pending download connections
  NSArray *allDownloads = [self.avatarDownloadsInProgress allValues];
  [allDownloads performSelector:@selector(cancelDownload)];
}

- (void)viewDidUnload 
{
  self.cancelButton = nil;
  self.fetchedResultsController = nil;
  self.managedObjectContext = nil;
  self.avatarDownloadsInProgress = nil;
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)cancel:(id)sender
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table View Methods
// +--------------------------------------------------------------------
// | Table View Methods
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
  NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
  for (id section in [self.fetchedResultsController sections])
  {    
    [sectionTitles addObject:[section name]];
  }
  
  return [sectionTitles autorelease];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
  return [[[self.fetchedResultsController sections] objectAtIndex:section] name];  
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
  UIImage *avatar = [user avatar];
  
  cell.imageView.image = ((avatar != nil)) ? avatar : [UIImage imageNamed:@"Placeholder.png"];
  cell.textLabel.text = user.screenName;
  cell.detailTextLabel.text = [user name];  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
  static NSString *CellIdentifier = @"AddressBookCell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
  
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
  NSString *username = [NSString stringWithFormat:@"@%@ ", [user valueForKey:@"screenName"]];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:PTSelectedUserFromAddressBook object:username];
  
  [self.navigationController dismissModalViewControllerAnimated:YES];
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
#pragma mark Table cell image support

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
      SBUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
      
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:avatarDownloader.indexPathInTableView];
//    [cell redisplay];
    [self configureCell:cell atIndexPath:avatarDownloader.indexPathInTableView];

  }
}

#pragma mark -
#pragma mark Accessor Methods
// +--------------------------------------------------------------------
// | Accessor Methods
// +--------------------------------------------------------------------

- (NSFetchedResultsController *)fetchedResultsController
{
  if ((fetchedResultsController == nil))
  {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kUserEntityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];  
    
    NSSortDescriptor *screenNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"screenName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:screenNameDescriptor, fullNameDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"screenNameInitial" cacheName:@"UserAddressBook"];
    theFetchedResultsController.delegate = self;
    self.fetchedResultsController = theFetchedResultsController;    
    
    [theFetchedResultsController release];
    [fetchRequest release];
    [screenNameDescriptor release];
    [fullNameDescriptor release];
    [sortDescriptors release];    
  }
  
  return fetchedResultsController;
}

@end

