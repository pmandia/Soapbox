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


#import "SBAuthenticationViewController.h"
#import "SBEditableCell.h"
#import "MGTwitterEngine.h"
#import "SBAccountManager.h"

@interface SBAuthenticationViewController ()
- (NSString *)userNameFieldValue;
- (NSString *)passwordFieldValue;
@end

const NSString *kNewAccountAuthenticationDataKey = @"newAccount";

@implementation SBAuthenticationViewController

@synthesize cancelButton;
@synthesize saveButton;
@synthesize tableFooterView;
@synthesize activityIndicator;
@synthesize promptLabel;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
  [super viewDidLoad];  
  
  twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
  
  [twitter setConsumerKey:kOAuthConsumerKey secret:kOAuthConsumerSecret];
    
  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  self.navigationItem.prompt = NSLocalizedString(@"Enter your Twitter account information", nil);
  self.navigationItem.title = NSLocalizedString(@"Add Account", nil);
  self.navigationItem.leftBarButtonItem = self.cancelButton;
  self.navigationItem.rightBarButtonItem = self.saveButton;
  
  self.tableView.backgroundColor = DEFAULT_TABLE_BG_COLOR;
  self.tableView.tableFooterView = self.tableFooterView;
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Select the first row
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kUserNameField inSection:0];
  [self.tableView selectRowAtIndexPath:firstRow animated:NO scrollPosition:UITableViewScrollPositionNone]; 
  SBEditableCell *userNameCell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  [userNameCell.textField becomeFirstResponder];
  [self.tableView reloadData];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
  self.cancelButton = nil;
  self.saveButton = nil;
  self.tableFooterView = nil;
  self.activityIndicator = nil;
  self.promptLabel = nil;
}


- (void)dealloc 
{
  [twitter closeAllConnections];
  
  [cancelButton release];
  [saveButton release]; 
  [tableFooterView release];
  [activityIndicator release];
  [promptLabel release];
  [twitter release]; 
  [super dealloc];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)cancel:(id)sender
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
  [twitter closeAllConnections];
}

- (BOOL)loginFieldsAreValid
{
  NSString *username = [self userNameFieldValue];
	NSString *password = [self passwordFieldValue];  
  BOOL isValid = (([username length] > 0) && ([password length] > 0)) ? YES : NO;
  
  return isValid;
}

- (IBAction)save:(id)sender
{
  NSString *username = [self userNameFieldValue];
	NSString *password = [self passwordFieldValue];
  
  if (([password length] == 0))
  {
    UIAlertViewQuick(@"Unable to login", @"Please enter a password.", @"OK");
    return;
  }
	
	DebugLog(@"About to request an xAuth token exchange for username: ]%@[ password: ]%@[.", username, password);

  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [self.activityIndicator startAnimating];

  // send the request to twitter to get our OAuth account info
  [twitter getXAuthAccessTokenForUsername:username password:password];
  
  // our delegate method will get called back when the authorization finishes.
  
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (NSString *)userNameFieldValue
{
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kUserNameField inSection:0];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  return cell.textField.text;
}

- (NSString *)passwordFieldValue
{
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kPasswordField inSection:0];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  return cell.textField.text;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  return NUM_AUTHENTICATION_SECTIONS;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *CellIdentifier = @"SGEditableCell";
    
  SBEditableCell *cell = (SBEditableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[[SBEditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier delegate:self] autorelease];
    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  }

  if (indexPath.row == kUserNameField)
  {
    cell.textField.returnKeyType = UIReturnKeyNext;
    cell.textField.tag = kUserNameField;
    [cell setLabelText:@"Username" andPlaceholderText:@"justin"];
  }
  else
  {
    cell.textField.tag = kPasswordField;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.secureTextEntry = YES;
    [cell setLabelText:@"Password" andPlaceholderText:@"Required"];
  }

  return cell;
}

#pragma mark -
#pragma mark UITextField Delegate Methods
// +--------------------------------------------------------------------
// | UITextField Delegate Methods
// +--------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  NSIndexPath *passwordRow = [NSIndexPath indexPathForRow:kPasswordField inSection:0];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:passwordRow]; 
    
  if ((textField.tag == kUserNameField))
  {
    [cell.textField becomeFirstResponder];    
  }
  else if ((textField.tag == kPasswordField))
  {
    [cell.textField resignFirstResponder];    
  }
  
  return YES;
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate Methods
// +--------------------------------------------------------------------
// | MGTwitterEngineDelegate Methods
// +--------------------------------------------------------------------

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
  DebugLog(@"Request succeeded for connectionIdentifier = %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
  UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [failedAlert show];
  [failedAlert release];
  
  DebugLog(@"Request failed for connectionIdentifier = %@, error = %@ (%@)", 
           connectionIdentifier, 
           [error localizedDescription], 
           [error userInfo]);
}

- (void)connectionFinished:(NSString *)connectionIdentifier
{
  DebugLog(@"Connection finished %@", connectionIdentifier);
  
	if ([twitter numberOfConnections] == 0)
	{
    //		[UIApplication terminate:self];
	}
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier;
{
  SBAccount *account = [[SBAccountManager manager] loggedInUserAccount];
  if ((userInfo != nil))
  {
    NSDictionary *userDictionary = [userInfo objectAtIndex:0];
    account.twitterID = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"id"] integerValue]];
    account.fullName = [userDictionary objectForKey:@"name"];
    account.enabledGeoPosting = [[userDictionary objectForKey:@"geo_enabled"] boolValue];
    account.isProtected = [[userDictionary objectForKey:@"protected"] boolValue];
    
    if ((account.enabledGeoPosting == NO))
    {
      account.locationPostingPreference = SBAccountLocationOff;
    }
    
    [[SBAccountManager manager] saveAccount:account];
  }
  
  // Notify app of account change  
  [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kLoggedInAccountDidChange
                                                      object:account
                                                    userInfo:nil];
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [self.activityIndicator stopAnimating];  
  [self.navigationController dismissModalViewControllerAnimated:YES];  
}

// Gets called after the OAuth login works.. 
- (void)accessTokenReceived:(OAToken *)token forRequest:(NSString *)connectionIdentifier
{
  [twitter setAccessToken:token];
  
  BOOL accountExists = [[SBAccountManager manager] hasAccountWithUsername:[self userNameFieldValue]];
  SBAccount *account = nil;
  
  // Create the new account
  if (!(accountExists))
  {
    account = [[SBAccount alloc] initWithUserName:[self userNameFieldValue]];
  }
  else 
  {    
    account = [[SBAccountManager manager] accountByUsername:[self userNameFieldValue]];
    [account retain];
  }
  
  account.secret = token.secret; 
  account.key = token.key;
  
  [[SBAccountManager manager] saveAccount:account];
  
  // Set as the currently active account.
  [[SBAccountManager manager] login:account];  
  
  [twitter getUserInformationFor:[self userNameFieldValue]];
  [account release];
}

@end

