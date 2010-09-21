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


#import "SBTweetContentsTableViewCell.h"
#import "SBUserViewController.h"
#import "SBTweetViewController.h"

@implementation SBTweetContentsTableViewCell

@synthesize tweetView;
@synthesize cellHeight;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) 
  {
    cellHeight = 162.0f;
    
    CGRect tweetViewFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    tweetView = [[[UIWebView alloc] initWithFrame:CGRectInset(tweetViewFrame, 5, 5)] retain];
    tweetView.delegate = self;
    tweetView.backgroundColor = [UIColor whiteColor];
    tweetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:tweetView];
  }
  
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
  [super setSelected:selected animated:animated];
}

- (void)dealloc 
{
  [tweetView release];
  [super dealloc];
}

#pragma mark -
#pragma mark UIWebView Delegate Methods
// +--------------------------------------------------------------------
// | UIWebView Delegate Methods
// +--------------------------------------------------------------------

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{  
  if (navigationType == UIWebViewNavigationTypeLinkClicked) 
  {
    NSString *scheme = [[request URL] scheme];
    if (([scheme isEqualToString:@"http"]) || ([scheme isEqualToString:@"https"]))
    {
      [self.delegate showWebViewWithURLRequest:request];
    }
    else if ([scheme isEqualToString:@"x-soapbox"])
    {
      // Pass it off to SBAppDelegate to handle pushing down the navigation stack.
      [[UIApplication sharedApplication] openURL:[request URL]];
    }
    
    return NO;
  }
  
  return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)sender 
{
  CGFloat newHeight = [[tweetView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] floatValue];
  self.cellHeight = newHeight;
}

@end
