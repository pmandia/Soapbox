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


#import "SBBrowserViewController.h"
#import "SBActivityButton.h"

@interface SBBrowserViewController ()
- (void)setupToolbar;
- (void)showActivityButton:(BOOL)shouldShow;
@end

@implementation SBBrowserViewController

@synthesize webView;
@synthesize backButton;
@synthesize forwardButton;
@synthesize refreshButton;
@synthesize spinnerButton;
@synthesize actionButton;
@synthesize linkURL;


#pragma mark -
#pragma mark View Lifecycle
// +--------------------------------------------------------------------
// | View Lifecycle
// +--------------------------------------------------------------------

- (void)viewDidLoad 
{
  [super viewDidLoad];  
  self.navigationController.navigationBar.tintColor = DEFAULT_TINT_COLOR;  
  self.navigationController.toolbar.tintColor = DEFAULT_TINT_COLOR;
  
  [self setupToolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.webView loadRequest:[NSURLRequest requestWithURL:linkURL]];
  [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  if (([self.webView isLoading]))
  {
    [self.webView stopLoading];
  }
  
  [self.navigationController setToolbarHidden:YES animated:NO];
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

  if ([self.webView isLoading])
  {
    [self.webView stopLoading];
  }
}

- (void)viewDidUnload 
{
  [super viewDidUnload];
  self.webView = nil;
  self.backButton = nil;
  self.forwardButton = nil;
  self.refreshButton = nil;
  self.spinnerButton = nil;
  self.actionButton = nil;
}


- (void)dealloc 
{
  [webView release];
  [backButton release];
  [forwardButton release];
  [refreshButton release];
  [spinnerButton release];
  [actionButton release];  
  [linkURL release];
  [super dealloc];
}

#pragma mark -
#pragma mark IBAction Methods
// +--------------------------------------------------------------------
// | IBAction Methods
// +--------------------------------------------------------------------

- (IBAction)back:(id)sender
{
  [self.webView goBack];
}

- (IBAction)forward:(id)sender
{
  [self.webView goForward];
}

- (IBAction)reload:(id)sender
{
  [self.webView reload];
}

- (IBAction)showActionSheet:(id)sender
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[self.linkURL absoluteString]
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Open in Safari", nil), nil];
  
  SBAppDelegate *delegate = (SBAppDelegate *)[[UIApplication sharedApplication] delegate];
  [actionSheet showInView:delegate.window];
  [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{  
  enum PTTimelineViewActionResponseTypes {
    kOpenInSafariButton = 0,
    kCancelButton       = 1,
  };
  
	switch (buttonIndex)
	{
    case kOpenInSafariButton:
      [[UIApplication sharedApplication] openURL:self.linkURL];
      break;
    case kCancelButton:
      break;
    default:
      NSAssert(NO, @"Unhandled Button in PTBrowserViewController's action sheet");
      break;
	}
}


#pragma mark -
#pragma mark UIWebView Delegate Methods
// +--------------------------------------------------------------------
// | UIWebView Delegate Methods
// +--------------------------------------------------------------------

- (void)webViewDidStartLoad:(UIWebView *)theWebView 
{
  [self showActivityButton:YES];
  [SBActivityIndicator enable];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView 
{

  [self.backButton setEnabled:[theWebView canGoBack]];
  [self.forwardButton setEnabled:[theWebView canGoForward]];
  self.navigationItem.title = [theWebView stringByEvaluatingJavaScriptFromString:@"document.title"]; 
  self.linkURL = [theWebView.request URL];
  
  [self showActivityButton:NO];
  [SBActivityIndicator disable];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error 
{
  [SBActivityIndicator disable];
  if (error.code == NSURLErrorCancelled) return; // this is Error -999
  if (error != NULL) 
  {
    UIAlertViewQuick([error localizedDescription], [error localizedFailureReason], @"OK");
  }
}

#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (UIBarButtonItem *)createFixedWidthButtonItem
{
  UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  button.width = 20.00;
  
  return [button autorelease];
}

- (UIBarButtonItem *)createFlexibleWidthButtonItem
{
  return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
}

- (void)setupToolbar
{
  SBActivityButton *activityIndicator = [[SBActivityButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
  self.spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];    
  [activityIndicator release];    
  
  NSMutableArray *items = [NSMutableArray array];
  [items addObject:self.backButton];
  [items addObject:[self createFixedWidthButtonItem]];  
  [items addObject:self.forwardButton];
  
  [items addObject:[self createFlexibleWidthButtonItem]];
  
  [items addObject:self.refreshButton];
  [items addObject:[self createFixedWidthButtonItem]];  
  [items addObject:self.actionButton];

  [self setToolbarItems:items animated:YES];
}

- (void)showActivityButton:(BOOL)shouldShow
{
  NSMutableArray *items = [[NSMutableArray arrayWithArray:self.toolbarItems] retain];
  if ((shouldShow))
  {
    [items replaceObjectAtIndex:4 withObject:self.spinnerButton];
    [(SBActivityButton *)self.spinnerButton.customView startAnimating];
  }
  else 
  {
    [items replaceObjectAtIndex:4 withObject:self.refreshButton];
  
    [(SBActivityButton *)self.spinnerButton.customView stopAnimating];
  }
  
  [self setToolbarItems:items animated:NO];
  [items release];
}
@end
