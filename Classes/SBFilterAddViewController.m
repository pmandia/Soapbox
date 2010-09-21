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

#import "SBFilterAddViewController.h"
#import "SBEditableCell.h"

enum FilterDetailRows
{
  kFilterTermRow = 0,
  kFilterSourceRow,
  NUM_FILTER_DETAIL_ROWS
};

@implementation SBFilterAddViewController

@synthesize tableFooterView;
@synthesize saveButton;
@synthesize cancelButton;
@synthesize filter;
@synthesize delegate;

#pragma mark -
#pragma mark View Lifecycle
// +--------------------------------------------------------------------
// | View Lifecycle
// +--------------------------------------------------------------------

- (void)viewDidLoad 
{
  [super viewDidLoad];

  self.tableView.backgroundColor = DEFAULT_TABLE_BG_COLOR;
  self.tableView.tableFooterView = self.tableFooterView;
  
  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  self.navigationItem.title = self.filter.term;
  self.navigationItem.leftBarButtonItem = self.cancelButton;
  self.navigationItem.rightBarButtonItem = self.saveButton;
}

- (void)viewWillAppear:(BOOL)animated 
{
  [super viewWillAppear:animated];
  // Select the first row
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kFilterTermRow inSection:0];
  [self.tableView selectRowAtIndexPath:firstRow animated:NO scrollPosition:UITableViewScrollPositionNone]; 
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  [cell.textField becomeFirstResponder];
  [self.tableView reloadData];
}

#pragma mark -
#pragma mark Memory Management
// +--------------------------------------------------------------------
// | Memory Management
// +--------------------------------------------------------------------

- (void)didReceiveMemoryWarning 
{
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
  self.tableFooterView = nil;
  self.saveButton = nil;
  self.cancelButton = nil;
}


- (void)dealloc 
{
  [tableFooterView release];
  [saveButton release];
  [cancelButton release];
  [filter release];
  [super dealloc];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)save:(id)sender
{
  self.filter.term = [self filterTermField];  
  if (([self.filter.term length] == 0))
  {
    UIAlertViewQuick(@"Save Error", @"The filter term cannot be blank.", @"OK");
    return;
  }
  
	NSError *error = nil;
	if (![filter.managedObjectContext save:&error]) 
  {
    UIAlertViewQuick(@"Failed to save", [NSString stringWithFormat:@"Error = %@", [error localizedDescription]], @"OK");
	}		
  
	[self.delegate filterAddViewController:self didAddFilter:self.filter];
}

- (IBAction)cancel:(id)sender
{
  [filter.managedObjectContext deleteObject:filter];
  
	NSError *error = nil;
	if (![filter.managedObjectContext save:&error]) 
  {
    UIAlertViewQuick(@"Failed to save", [NSString stringWithFormat:@"Error = %@", [error localizedDescription]], @"OK");
	}		
  
  [self.delegate filterAddViewController:self didAddFilter:nil];
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)setFilterTermField:(NSString *)theTerm
{
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kFilterTermRow inSection:0];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  cell.textField.text = theTerm;
}

- (NSString *)filterTermField
{
  NSIndexPath *firstRow = [NSIndexPath indexPathForRow:kFilterTermRow inSection:0];
  SBEditableCell *cell = (SBEditableCell *)[self.tableView cellForRowAtIndexPath:firstRow]; 
  return cell.textField.text;
}

#pragma mark -
#pragma mark Table View Data Source Methods
// +--------------------------------------------------------------------
// | Table View Data Source Methods
// +--------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  // Return the number of sections.
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  return NUM_FILTER_DETAIL_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  if ((indexPath.row == kFilterTermRow))
  {
    static NSString *kURLShorteningCell = @"SGEditableCell";
    
    SBEditableCell *cell = (SBEditableCell *)[tableView dequeueReusableCellWithIdentifier:kURLShorteningCell];
    if (cell == nil) 
    {
      cell = [[[SBEditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kURLShorteningCell delegate:self] autorelease];
      cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
      cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    
    [cell setLabelText:@"Term" andPlaceholderText:@"Bieber"];
    [self setFilterTermField:self.filter.term];
    
    return cell;    
  }
  
  if ((indexPath.row == kFilterSourceRow))
  {
    static NSString *kSwitchCell = @"SwitchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSwitchCell];
    if (cell == nil) 
    {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSwitchCell] autorelease];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;      
    }
    
    cell.textLabel.text = NSLocalizedString(@"Source Filter", nil);
    
    UISwitch *switchView = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
    [switchView addTarget:self action:@selector(toggleSourceFilter:) forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
    switchView.on = self.filter.sourceFilterValue;
    
    [cell addSubview:switchView];
    cell.accessoryView = switchView;
    
    return cell;
  }
  
  return nil;
}

- (void)toggleSourceFilter:(id)sender
{
  if ((sender) && ([sender respondsToSelector:@selector(isOn)]))
  {    
    [self.filter setSourceFilterValue:[sender isOn]];  
  }
}
@end

