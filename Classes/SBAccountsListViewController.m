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


#import "SBAccountsListViewController.h"
#import "SBAuthenticationViewController.h"
#import "SBAccountSettingsViewController.h"
#import "CCoreDataManager.h"
#import "SBAccountManager.h"
#import "SBRootViewController.h"

@implementation SBAccountsListViewController

@synthesize addAccountButton;
@synthesize authenticationController;
@synthesize rootViewController;
@synthesize settingsViewController;

#pragma mark -
#pragma mark Memory Management
// +--------------------------------------------------------------------
// | Memory Management
// +--------------------------------------------------------------------

- (void)dealloc 
{
  [addAccountButton release];
  [authenticationController release];
  [rootViewController release];
  [accountManager release];
  [settingsViewController release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning 
{
  [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad 
{
  [super viewDidLoad];

  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  self.navigationItem.title = NSLocalizedString(@"Accounts", nil);
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  self.navigationItem.rightBarButtonItem = self.addAccountButton;
  
  accountManager = [SBAccountManager manager];
}

- (void)viewDidUnload 
{
  self.addAccountButton = nil;
  self.rootViewController = nil;
  self.authenticationController = nil;
}


- (void)viewWillAppear:(BOOL)animated 
{
  [super viewWillAppear:animated];
  
  [self.tableView reloadData];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)add:(id)sender
{
  SBAuthenticationViewController *viewController = [[SBAuthenticationViewController alloc] initWithNibName:NSStringFromClass([SBAuthenticationViewController class]) bundle:nil];
  self.authenticationController = viewController;
  [viewController release];
  
  UINavigationController *newAccountNavigationController = [[UINavigationController alloc] initWithRootViewController:self.authenticationController];
  [self.navigationController presentModalViewController:newAccountNavigationController animated:YES];
  [newAccountNavigationController release];    
}

#pragma mark -
#pragma mark Table View Methods
// +--------------------------------------------------------------------
// | Table View Methods
// +--------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView 
{
  NSUInteger count = 1;
  return count;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)theSection
{
  NSUInteger count = 0;
  
  count = [accountManager numberOfAccounts];
  
  return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath {   
  static NSString *kAccountsTableCellIdentifier = @"kAccountsTableCellIdentifier";

  UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:kAccountsTableCellIdentifier];
  if (cell == nil) 
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAccountsTableCellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
  }

  SBAccount *currentAccount = [[accountManager allAccounts] objectAtIndex:theIndexPath.row];
  cell.imageView.image = [UIImage imageNamed:@"twitter-button.png"];
  cell.textLabel.text = [currentAccount valueForKey:@"screenName"];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  if (self.rootViewController != nil)
  {
    self.rootViewController = nil;
  }

  SBRootViewController *newTimelineController = [[SBRootViewController alloc] initWithNibName:NSStringFromClass([SBRootViewController class]) bundle:nil];
  self.rootViewController = newTimelineController;
  [newTimelineController release];
  
  SBAccount *account = [[accountManager allAccounts] objectAtIndex:indexPath.row];
  [[SBAccountManager manager] login:account];
  
  
  // Notify app of account change 
  [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInAccountDidChange
                                                      object:account
                                                    userInfo:nil];
  
  [self.navigationController pushViewController:self.rootViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
  if ((self.settingsViewController == nil))
  {
    SBAccountSettingsViewController *newSettingsController = [[SBAccountSettingsViewController alloc] initWithNibName:NSStringFromClass([SBAccountSettingsViewController class]) bundle:nil];
    self.settingsViewController = newSettingsController;
    [newSettingsController release];
  }
  
  SBAccount *account = [[accountManager allAccounts] objectAtIndex:indexPath.row];
  self.settingsViewController.account = [account retain];
  [self.navigationController pushViewController:self.settingsViewController animated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) 
  {
    SBAccount *account = [[accountManager allAccounts] objectAtIndex:indexPath.row];
    [accountManager removeAccount:account];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
  NSIndexPath *indexPath = proposedDestinationIndexPath;
  if ((proposedDestinationIndexPath.row >= [accountManager numberOfAccounts])) 
  {
    indexPath = [NSIndexPath indexPathForRow:[accountManager numberOfAccounts] - 1 inSection:0];
  }
  
  return indexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
  DebugLog(@"move from:%d to:%d", fromIndexPath.row, toIndexPath.row);
  
  SBAccount *account = [[accountManager allAccounts] objectAtIndex:fromIndexPath.row];
  if (fromIndexPath.row > toIndexPath.row) 
  {
    [accountManager.accountOrder insertObject:account.screenName atIndex:toIndexPath.row];
    [accountManager.accountOrder removeObjectAtIndex:(fromIndexPath.row + 1)];
  }
  else if (fromIndexPath.row < toIndexPath.row) 
  {
    [accountManager.accountOrder insertObject:account.screenName atIndex:(toIndexPath.row + 1)];    
    [accountManager.accountOrder removeObjectAtIndex:(fromIndexPath.row)];
  }
  
  [accountManager saveToUserDefaults];
}
@end

