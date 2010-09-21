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


#import "SBSlidingAlertView.h"

static CGFloat kSpinnerPadding = 10.0f;
static CGFloat kMessagePadding = 15.0f;
static CGFloat kHeightDivisor = 20.0f;

@implementation SBSlidingAlertView

@synthesize showNetworkActivityIndicator;
@synthesize showActivitySpinner;
@synthesize animationDelay;

static SBSlidingAlertView *sAlertView = nil;

+ (SBSlidingAlertView *)currentAlertView
{
  return sAlertView;
}

+ (SBSlidingAlertView *)alertViewForView:(UIView *)addToView withMessage:(NSString *)messageText backgroundColor:(UIColor *)color;
{
  return [[self alloc] initForView:addToView withMessage:messageText backgroundColor:color withDelay:0.0f spinning:YES];
}

+ (SBSlidingAlertView *)alertViewForView:(UIView *)addToView withMessage:(NSString *)messageText backgroundColor:(UIColor *)color withDelay:(CGFloat)delay spinning:(BOOL)shouldSpin;
{
  return [[self alloc] initForView:addToView withMessage:messageText backgroundColor:color withDelay:delay spinning:shouldSpin];
}

- (SBSlidingAlertView *)initForView:(UIView *)addToView withMessage:(NSString *)labelText backgroundColor:(UIColor *)color withDelay:(CGFloat)delay spinning:(BOOL)shouldSpin;
{
  if ((self = [super initWithFrame:CGRectZero]))
  {
    // Immediately remove any existing alert view:
    if (sAlertView)
    {
      [[self class] removeView];
    }
    
    // Remember the new view (it is already retained):
    sAlertView = self;

    self.showActivitySpinner = shouldSpin;
    self.opaque = NO;
    self.backgroundView.backgroundColor = color;
    self.messageLabel.text = labelText;
    self.animationDelay = delay;

    [addToView addSubview:self];
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.messageLabel];
    
    if ((self.showActivitySpinner))
    {
      [self.backgroundView addSubview:self.activitySpinner];    
    }
    
    [self layoutIfNeeded];
    
    [self show];
  }
	
  return self;
}


- (void)dealloc 
{  
  [backgroundView release];
  [messageLabel release];
  [backgroundColor release];
  [activitySpinner release];
  [super dealloc];
  
  sAlertView = nil;
}

+ (void)removeView;
{
  if (!sAlertView)
    return;
  
  if (sAlertView.showNetworkActivityIndicator)
  {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }
  
  [sAlertView removeFromSuperview];
  
  // Remove the global reference:
  [sAlertView release];
  sAlertView = nil;
}

+ (void)hideViewAnimated:(BOOL)animated
{
  if (!sAlertView)
    return;
  
  if (animated)
  {
    [sAlertView animateRemove];
  }
  else
  {
    [[self class] removeView];
  }
  
}

- (CGRect)enclosingFrame;
{
  CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
  return CGRectMake(0, CGRectGetMaxY(screenFrame), screenFrame.size.width, roundf(screenFrame.size.height / kHeightDivisor));
}


- (UIView *)backgroundView
{  
  if (!backgroundView)
  {
    backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    backgroundView.opaque = NO;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  }
  
  return backgroundView;  
}

- (UIActivityIndicatorView *)activitySpinner
{
  if (!activitySpinner)
  {
    activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activitySpinner startAnimating];
  }
  
  return activitySpinner;
}


- (UILabel *)messageLabel
{
  if (!(messageLabel))
  {
    messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.font = [UIFont systemFontOfSize:13];
    messageLabel.textAlignment = UITextAlignmentLeft;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.backgroundColor = [UIColor clearColor];
  }
  
  return messageLabel;
}

- (void)layoutSubviews
{
  self.frame = [self enclosingFrame];
  // If we're animating a transform, don't lay out now, as can't use the frame property when transforming:
  if (!CGAffineTransformIsIdentity(self.backgroundView.transform))
    return;
  
  CGRect backgroundFrame = CGRectZero;
  backgroundFrame.size.width = self.frame.size.width;
  backgroundFrame.size.height = self.frame.size.height;
  backgroundFrame.origin.x = floor(0.5 * (self.frame.size.width - backgroundFrame.size.width));
  backgroundFrame.origin.y = floor(0.5 * (self.frame.size.height - backgroundFrame.size.height));
  self.backgroundView.frame = backgroundFrame;
    
  CGRect spinnerFrame = self.activitySpinner.frame;
  spinnerFrame.origin.x += kSpinnerPadding;
  spinnerFrame.origin.y = floor(0.75 * (backgroundFrame.size.height - spinnerFrame.size.height)) + 2.0f;
  spinnerFrame.size.width = floor(spinnerFrame.size.height * 0.75);
  spinnerFrame.size.height = floor(spinnerFrame.size.height * 0.75);
  self.activitySpinner.frame = spinnerFrame;

  CGRect messageFrame = self.messageLabel.frame;
  messageFrame.origin.x = self.activitySpinner.frame.size.width + kMessagePadding;
	messageFrame.origin.y = floor(0.5 * (self.frame.size.height - backgroundFrame.size.height));
  messageFrame.size.width = self.frame.size.width - kMessagePadding;
  messageFrame.size.height = self.frame.size.height;
  self.messageLabel.frame = messageFrame;
}

- (void)setShowNetworkActivityIndicator:(BOOL)shouldShowNetworkActivityIndicator;
{
  showNetworkActivityIndicator = shouldShowNetworkActivityIndicator;
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = shouldShowNetworkActivityIndicator;
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------


- (void)show
{
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.55];
  self.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height * -1));
  [UIView commitAnimations];
  
  if ((self.animationDelay > 0))
  {
    [self performSelector:@selector(animateRemove) withObject:nil afterDelay:self.animationDelay];
  }
}

- (void)animateRemove
{
  if (self.showNetworkActivityIndicator)
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  
  // Slide the view down off screen
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.55];
  
  self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
  
  // To autorelease the Msg, define stop selector
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
  
  [UIView commitAnimations];
}

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context 
{
  [[self class] removeView];
}
@end
