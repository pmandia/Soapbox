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


#import "SBRootViewController.h"
#import "SBPostingViewController.h"
#import "SBHomeTimelineController.h"
#import "SBAccountManager.h"
#import "SBMentionsViewController.h"

@interface SBRootViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)showHomeTimelineWithAnimation:(BOOL)shouldAnimate;
- (void)showMentionsWithAnimation:(BOOL)shouldAnimate;
@end


@implementation SBRootViewController

@synthesize postTweetButton;
@synthesize homeViewController;
@synthesize mentionsViewController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;
  self.navigationItem.rightBarButtonItem = self.postTweetButton;  

  self.tableView.backgroundColor = DEFAULT_TABLE_BG_COLOR;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


#pragma mark -
#pragma mark Memory Management
// +--------------------------------------------------------------------
// | Memory Management
// +--------------------------------------------------------------------

- (void)didReceiveMemoryWarning 
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload 
{
  self.postTweetButton = nil;
  self.homeViewController = nil;
  self.mentionsViewController = nil;
}


- (void)dealloc 
{
  [super dealloc];
  [homeViewController release];
  [mentionsViewController release];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)post:(id)sender
{
  SBPostingViewController *postingViewController = [[SBPostingViewController alloc] init];
  postingViewController.logicalParentViewController = self;
  UINavigationController *postingNavigationController = [[UINavigationController alloc] initWithRootViewController:postingViewController];
  [self.navigationController presentModalViewController:postingNavigationController animated:YES];
  [postingViewController release];
  [postingNavigationController release];  
}

#pragma mark -
#pragma mark Table View Data Source Methods
// +--------------------------------------------------------------------
// | Table View Data Source Methods
// +--------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return NUM_ROOT_CONTROLLER_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  NSUInteger rowCount = 1;
  switch (section)
  {
    case kRootViewControllerTimelineSections:
      rowCount = NUM_ROOT_CONTROLLER_TIMELINE_SECTION_ROWS;
  }
  
  return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
  static NSString *CellIdentifier = @"Cell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }

  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}


#pragma mark -
#pragma mark Table View Delegate Methods
// +--------------------------------------------------------------------
// | Table View Delegate Methods
// +--------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  if ((indexPath.section == kRootViewControllerTimelineSections))
  {
    switch (indexPath.row)
    {
      case kRootViewTimelineSectionHomeRow:
        [self showHomeTimelineWithAnimation:YES];
        break;
      case kRootViewTimelineSectionMentionsRow:
        [self showMentionsWithAnimation:YES];
        break;
      default:
        NSAssert(NO, @"Unhandled cell in SBRootViewController's table view");
        break;              
    }
  }
}



#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{    
  switch (indexPath.row)
  {
    case kRootViewTimelineSectionHomeRow:
      cell.imageView.image = [UIImage imageNamed:@"timeline-button.png"];
      cell.textLabel.text = NSLocalizedString(@"Timeline", nil);
      break;
    case kRootViewTimelineSectionMentionsRow:
      cell.imageView.image = [UIImage imageNamed:@"mentions-button.png"];
      cell.textLabel.text = NSLocalizedString(@"Mentions", nil);
      break;
    default:
      NSAssert(NO, @"Unhandled cell in SBRootViewController's table view");
      break;      
  }
}

- (void)showHomeTimelineWithAnimation:(BOOL)shouldAnimate
{
  if ((homeViewController == nil))
  {
    SBHomeTimelineController *timelineController = [[SBHomeTimelineController alloc] initWithNibName:NSStringFromClass([SBTimelineViewController class]) bundle:nil];
    self.homeViewController = timelineController;
    [timelineController release];  
  }
  
  [self.navigationController pushViewController:self.homeViewController animated:YES];
}

- (void)showMentionsWithAnimation:(BOOL)shouldAnimate
{
  if ((mentionsViewController == nil))
  {
    SBMentionsViewController *mentionsController = [[SBMentionsViewController alloc] initWithNibName:NSStringFromClass([SBTimelineViewController class]) bundle:nil];
    self.mentionsViewController = mentionsController;
    [mentionsController release];  
  }
  
  [self.navigationController pushViewController:self.mentionsViewController animated:YES];  
}


@end

