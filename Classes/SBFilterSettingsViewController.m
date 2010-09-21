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

#import "SBFilterSettingsViewController.h"
#import "SBFilterDetailViewController.h"
#import "SBFilterAddViewController.h"
#import "CCoreDataManager.h"

@interface SBFilterSettingsViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)imageForFilterType:(BOOL)isSourceFilter;
@end

@implementation SBFilterSettingsViewController

@synthesize addButton;
@synthesize account;
@synthesize fetchedResultsController;

#pragma mark -
#pragma mark View Lifecycle
// +--------------------------------------------------------------------
// | View Lifecycle
// +--------------------------------------------------------------------

- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  self.navigationItem.title = NSLocalizedString(@"Filters", nil);
  self.navigationItem.rightBarButtonItem = self.addButton;
  
  self.fetchedResultsController.delegate = self;
  
  NSError *error = nil;
	if ((![self.fetchedResultsController performFetch:&error])) 
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", nil)
                                                    message:[NSString stringWithFormat:@"Error was: %@.", [error localizedDescription]]
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
	}  
}


#pragma mark -
#pragma mark Memory Management Methods
// +--------------------------------------------------------------------
// | Memory Management Methods
// +--------------------------------------------------------------------

- (void)didReceiveMemoryWarning 
{
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
  self.addButton = nil;
  self.fetchedResultsController = nil;
}


- (void)dealloc 
{
  [addButton release];
  [account release];
  [fetchedResultsController release];
  [super dealloc];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)addFilter:(id)sender
{
  SBFilterAddViewController *addViewController = [[SBFilterAddViewController alloc] initWithNibName:NSStringFromClass([SBFilterAddViewController class]) bundle:nil];
  addViewController.delegate = self;

  NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
	SBFilter *newFilter = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
  addViewController.filter = newFilter;

  NSError *error;
  if (![context save:&error])
  {
    NSLog(@"Error saving entity: %@", [error localizedDescription]);
  }
  
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addViewController];
  [self presentModalViewController:navigationController animated:YES];
  
  [navigationController release];  
  [addViewController release];
}


- (void)showFilter:(SBFilter *)filter animated:(BOOL)animated 
{
  // Create a detail view controller, set the recipe, then push it.
  SBFilterDetailViewController *detailViewController = [[SBFilterDetailViewController alloc] initWithNibName:NSStringFromClass([SBFilterDetailViewController class]) bundle:nil];
  detailViewController.filter = filter;
  
  [self.navigationController pushViewController:detailViewController animated:animated];
  [detailViewController release];
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
  static NSString *CellIdentifier = @"Cell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) 
  {
    // Delete the managed object for the given index path
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error;
		if (![context save:&error]) 
    {
      UIAlertViewQuick(@"Cannot Delete", [error localizedDescription], @"OK");
		}
	}   
}


#pragma mark -
#pragma mark Table View Delegate Methods
// +--------------------------------------------------------------------
// | Table View Delegate Methods
// +--------------------------------------------------------------------


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  SBFilter *filter = (SBFilter *)[self.fetchedResultsController objectAtIndexPath:indexPath];
  [self showFilter:filter animated:YES];
}


#pragma mark -
#pragma mark NSFetchedResultsController Delegate Methods
// +--------------------------------------------------------------------
// | NSFetchedResultsController Delegate Methods
// +--------------------------------------------------------------------

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
//{
//  [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//	UITableView *tableView = self.tableView;
//	
//	switch(type) {
//		case NSFetchedResultsChangeInsert:
//			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//			
//		case NSFetchedResultsChangeDelete:
//			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//			
//		case NSFetchedResultsChangeUpdate:
//			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//			break;
//			
//		case NSFetchedResultsChangeMove:
//			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//			// Reloading the section inserts a new row and ensures that titles are updated appropriately.
//			[tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
//			break;
//	}
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
//  [self.tableView endUpdates];
  [self.tableView reloadData];
}

#pragma mark -
#pragma mark PTFilterAddViewDelegate Methods
// +--------------------------------------------------------------------
// | PTFilterAddViewDelegate Methods
// +--------------------------------------------------------------------

// Stubbed out a bit early, but I suppose we can do something someday if the filter exists
- (void)filterAddViewController:(SBFilterAddViewController *)filterAddViewController didAddFilter:(SBFilter *)filter;
{
  [self dismissModalViewControllerAnimated:YES];  
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
    NSManagedObjectContext *context = [SBAppDelegate instance].coreDataManager.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setFetchBatchSize:50];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kFilterEntityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];  
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"term" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"UserTimeline"];
    self.fetchedResultsController = theFetchedResultsController;    
    
    [theFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];    
  }
  
  return fetchedResultsController;
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
  // Configure the cell
  SBFilter *selectedFilter = [self.fetchedResultsController objectAtIndexPath:indexPath];  
  cell.textLabel.text = selectedFilter.term;
  
  UIImage *image = [self imageForFilterType:selectedFilter.sourceFilterValue];  
  cell.imageView.image = image;
}

- (UIImage *)imageForFilterType:(BOOL)isSourceFilter
{
  UIImage *image = ((isSourceFilter)) ? [UIImage imageNamed:@"source-filter.png"] : [UIImage imageNamed:@"word-filter.png"];
  return image;
}

@end

