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

#import "SBLocationSettingsViewController.h"
#import "SBAccount.h"

enum PTLocationSettingsOptionRows
{
  kOffRow = 0,
  kManualRow,
  kAutomaticRow,
  NUM_ROWS
};

@implementation SBLocationSettingsViewController

@synthesize rowTitles;
@synthesize account;

- (void)viewDidLoad 
{
  [super viewDidLoad];

  self.tableView.backgroundColor = DEFAULT_TABLE_BG_COLOR;
  self.navigationItem.title = NSLocalizedString(@"Location Posting", nil);
  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  
  self.rowTitles = [[NSMutableArray alloc] initWithObjects:
                                  NSLocalizedString(@"Off", nil),
                                  NSLocalizedString(@"Manual", nil),
                                  NSLocalizedString(@"Automatic", nil), nil];
}


- (void)viewDidAppear:(BOOL)animated 
{
  [super viewDidAppear:animated];
  
  if (!(self.account.enabledGeoPosting))
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Posting" message:@"Location posting must be enabled via the Twitter website to attach locations to tweets.  Would you like to visit the site now?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
  }
}

- (void)viewDidUnload 
{
  self.account = nil;
  self.rowTitles = nil;
}

- (void)dealloc 
{
  [rowTitles release];
  [account release];
  [super dealloc];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  static NSInteger kOKButton = 1;
  
  if (buttonIndex == kOKButton)
	{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/account/settings/geo"]];
	}
}
     
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  return NUM_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{

  static NSString *kCellIdentifier = @"LocationCell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (cell == nil) 
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];    
  }
  
  cell.textLabel.text = [self.rowTitles objectAtIndex:indexPath.row];
  
  if ((self.account.locationPostingPreference == indexPath.row))
  {  
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    lastIndexPath = indexPath;
  }
  else 
  {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  self.account.locationPostingPreference = indexPath.row;
  
  int newRow = [indexPath row];
  int oldRow = [lastIndexPath row];
  
  if (newRow != oldRow)
  {
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;    
    lastIndexPath = indexPath;
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

