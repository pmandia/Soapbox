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


#import "SBTweetHeaderView.h"

#define WRAPPER_VIEW_PADDING 10.0  

@implementation SBTweetHeaderView

@synthesize fullNameLabel;
@synthesize screenNameLabel;
@synthesize locationLabel;
@synthesize avatarImageView;
@synthesize dataSource;

- (CGRect)wrapperRectForBounds:(CGRect)theBounds
{
  CGRect wrapperRect = CGRectMake(0.0f, WRAPPER_VIEW_PADDING, theBounds.size.width - WRAPPER_VIEW_PADDING, theBounds.size.height - (WRAPPER_VIEW_PADDING * 2));  
  return wrapperRect;
}

- (void)drawBackgroundWrapper
{    
  UIColor *wrapperViewColor = [UIColor whiteColor];
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGContextSetShadowWithColor(context, CGSizeMake(1.0f, 1.5f), 2.0f, [[UIColor blackColor] colorWithAlphaComponent:0.75].CGColor);
  CGContextSetFillColorWithColor(context, wrapperViewColor.CGColor);
  CGContextFillRect(context, wrapperRect);
  CGContextRestoreGState(context);
}


- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  // Draw background wrapper
  [self drawBackgroundWrapper];
  
  if (([dataSource respondsToSelector:@selector(avatarForTweetHeaderView:)]))
  {
    self.avatarImageView.image = [self.dataSource avatarForTweetHeaderView:self];    
  }
  
  if (([dataSource respondsToSelector:@selector(fullNameForTweetHeaderView:)]))
  {
    self.fullNameLabel.text = [self.dataSource fullNameForTweetHeaderView:self];
  }
  
  if (([dataSource respondsToSelector:@selector(screenNameForTweetHeaderView:)]))
  {
    self.screenNameLabel.text = [self.dataSource screenNameForTweetHeaderView:self];
  }
  
  if (([dataSource respondsToSelector:@selector(locationForTweetHeaderView:)]))
  {
    self.locationLabel.text = [self.dataSource locationForTweetHeaderView:self];
  }
}

- (void)dealloc 
{
  [fullNameLabel release];
  [screenNameLabel release];
  [locationLabel release];
  [avatarImageView release];
  [super dealloc];
}


@end
