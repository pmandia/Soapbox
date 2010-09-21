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


#import "SBAccountSettingsViewController.h"
#import "SBLocationSettingsViewController.h"
#import "SBFilterSettingsViewController.h"
#import "SBAccount.h"
#import "SBEditableCell.h"
#import "SBAccountManager.h"

enum PTAccountSettingsSections 
{
  kLocationSection = 0,
  kURLShorteningSection,
  kFilteringSection,
  NUM_SECTIONS
};

enum LocationSection
{
  kLocationSectionPostingPreference = 0,
  NUM_LOCATION_SECTION_ROWS
};

enum URLShorteningSection 
{
  kURLShorteningSectionUserNameRow = 0,
  kURLShorteningSectionApiKeyRow,
  NUM_URL_SHORTENING_SECTION_ROWS
};

enum FilteringSection
{
  kFilteringSectionFilters = 0,
  NUM_FILTERS_SECTION_ROWS
};

@implementation SBAccountSettingsViewController

@synthesize tableFooterView;
@synthesize account;

#pragma mark -
#pragma mark View Lifecycle
// +--------------------------------------------------------------------
// | View Lifecycle
// +--------------------------------------------------------------------


- (void)viewDidLoad 
{
  [super viewDidLoad];

  self.tableView.tableFooterView = self.tableFooterView;
  self.tableView.backgroundColor = DEFAULT_TABLE_BG_COLOR;

  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  self.navigationItem.title = self.account.screenName;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self setBitlyUsernameField:self.account.bitlyUserName];
  [self setBitlyApiKeyField:self.account.bitlyApiKey];
  
  [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [[SBAccountManager manager] saveAccount:self.account];
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

  // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc 
{
  [tableFooterView release];
  [account release];
  [super dealloc];
}

- (void)viewDidUnload 
{
  self.tableFooterView = nil;
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

//
// Really all this does is delete the user account's SQLite database so it can be regenerated. 
//
- (void)removePersistentStore 
{
  // twitterID.sqlite
  NSString *persistentStoreName = [NSString stringWithFormat:@"%@.sqlite", self.account.twitterID];  
  NSArray *thePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
  NSString *theApplicationSupportFolder = ([thePaths count] > 0) ? [thePaths lastObject] : NSTemporaryDirectory();
  NSString *theStorePath = [theApplicationSupportFolder stringByAppendingPathComponent:persistentStoreName];
  
  NSError *theError = NULL;
  if ([[NSFileManager defaultManager] fileExistsAtPath:theStorePath] == YES)
  {
    [[NSFileManager defaultManager] removeItemAtPath:theStorePath error:&theError];
  }
  
  NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"The locally cached tweets and filters for the account '%@' have been removed.", nil), self.account.screenName];
  UIAlertViewQuick(NSLocalizedString(@"Cache cleared", nil), alertMessage, NSLocalizedString(@"OK", nil));

}

- (IBAction)resetAccount:(id)sender
{
  // Alert the user asking if they really want to do it
  // If so, expunge!
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Clear All Cached Tweets and Filters?", nil)
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                             destructiveButtonTitle:NSLocalizedString(@"Reset Account", nil) 
                                                  otherButtonTitles:nil];
  
  SBAppDelegate *delegate = (SBAppDelegate *)[[UIApplication sharedApplication] delegate];
  [actionSheet showInView:delegate.window];
  [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	static NSInteger kClearCacheButton = 0;
	if (buttonIndex == kClearCacheButton)
	{
    [self removePersistentStore];    
	}
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)setBitlyUsernameField:(NSString *)theUsename
{
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kURLShorteningSectionUserNameRow inSection:kURLShorteningSection];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  cell.textField.text = theUsename;
  
}
- (NSString *)bitlyUsernameField
{
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kURLShorteningSectionUserNameRow inSection:kURLShorteningSection];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  return cell.textField.text;
}

- (void)setBitlyApiKeyField:(NSString *)theApiKey
{
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kURLShorteningSectionApiKeyRow inSection:kURLShorteningSection];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  cell.textField.text = theApiKey; 
}

- (NSString *)bitlyApiKeyField
{
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kURLShorteningSectionApiKeyRow inSection:kURLShorteningSection];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  return cell.textField.text;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  self.account.bitlyUserName = [self bitlyUsernameField];
  self.account.bitlyApiKey = [self bitlyApiKeyField];
}

#pragma mark -
#pragma mark Table View Methods
// +--------------------------------------------------------------------
// | Table View Methods
// +--------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return NUM_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  switch (section)
  {
    case kURLShorteningSection:
      return NUM_URL_SHORTENING_SECTION_ROWS;
    case kLocationSection:
      return NUM_LOCATION_SECTION_ROWS;
    case kFilteringSection:
      return NUM_FILTERS_SECTION_ROWS;
    default:
      return 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{

  if ((indexPath.section == kLocationSection))
  {
    static NSString *kFilteringCell = @"LocationCell";
    
    UITableViewCell *filteringCell = [tableView dequeueReusableCellWithIdentifier:kFilteringCell];
    if ((filteringCell == nil))
    {
      filteringCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kFilteringCell] autorelease];
      filteringCell.textLabel.text = NSLocalizedString(@"Location Posting", nil);
    }
    filteringCell.detailTextLabel.text = [self.account locationPostingPreferenceTitle];

    return filteringCell;
  }
  
  if ((indexPath.section == kURLShorteningSection))
  {
    static NSString *kURLShorteningCell = @"SGEditableCell";
    
    SBEditableCell *cell = (SBEditableCell *)[tableView dequeueReusableCellWithIdentifier:kURLShorteningCell];
    if (cell == nil) 
    {
      cell = [[[SBEditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kURLShorteningCell delegate:self] autorelease];
      cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
      cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    
    if (indexPath.row == kURLShorteningSectionUserNameRow)
    {
      [cell setLabelText:@"Username" andPlaceholderText:@"Optional"];
    }
    else
    {
      cell.textField.keyboardType = UIKeyboardTypeAlphabet;
      [cell setLabelText:@"API Key" andPlaceholderText:@"Optional"];
    }
    
    return cell;    
  }
  
  if ((indexPath.section == kFilteringSection))
  {
    static NSString *kFilteringCell = @"FilteringCell";
    
    UITableViewCell *filteringCell = [tableView dequeueReusableCellWithIdentifier:kFilteringCell];
    if ((filteringCell == nil))
    {
      filteringCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFilteringCell] autorelease];
      filteringCell.textLabel.text = NSLocalizedString(@"Filters", nil);
      filteringCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return filteringCell;    
  }
  
  return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
  switch (section)
  {
    case kLocationSection:
      return NSLocalizedString(@"Location Posting", nil);
    case kURLShorteningSection:
      return NSLocalizedString(@"URL Shortening (bit.ly)", nil);
    case kFilteringSection:
      return NSLocalizedString(@"Filtering", nil);
    default:
      return @"";
  }
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  if ((indexPath.section == kLocationSection))
  {
    SBLocationSettingsViewController *locationSettingsViewController = [[SBLocationSettingsViewController alloc] initWithNibName:NSStringFromClass([SBLocationSettingsViewController class]) bundle:nil];
    locationSettingsViewController.account = [account retain];
    [self.navigationController pushViewController:locationSettingsViewController animated:YES];
    [locationSettingsViewController release];    
  }
  
  if ((indexPath.section == kFilteringSection))    
  {
    SBFilterSettingsViewController *filteringViewController = [[SBFilterSettingsViewController alloc] initWithNibName:NSStringFromClass([SBFilterSettingsViewController class]) bundle:nil];
    filteringViewController.account = [account retain];
    [self.navigationController pushViewController:filteringViewController animated:YES];
    [filteringViewController release];        
  }
}


@end

