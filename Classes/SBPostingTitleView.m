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


#import "SBPostingTitleView.h"
#import "SBAccountManager.h"

static CGFloat kTitleFontSize = 16.0f;

@implementation SBPostingTitleView

@synthesize titleLabel;
@synthesize accountLabel;

- (id)initWithFrame:(CGRect)frame 
{
  if ((self = [super initWithFrame:frame])) 
  {
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 200, 19)];
    self.titleLabel.opaque = NO;
    self.titleLabel.tag = 0;
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.text = NSLocalizedString(@"New Tweet", nil);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.35];
    self.titleLabel.shadowOffset = CGSizeMake(0, -1.0);    
    
    SBAccountManager *accountManager = [SBAccountManager manager];
    self.accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 200, 18)];
    self.accountLabel.opaque = NO;
    self.accountLabel.tag = 1;
    self.accountLabel.textAlignment = UITextAlignmentCenter;
    self.accountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"from %@", nil), [accountManager loggedInUserAccount].screenName];
    self.accountLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.accountLabel.textColor = [UIColor whiteColor];
    self.accountLabel.backgroundColor = [UIColor clearColor];
    self.accountLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.35];
    self.accountLabel.shadowOffset = CGSizeMake(0, -1.0);        
  }
  
  return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
  [self addSubview:self.titleLabel];
  [self addSubview:self.accountLabel];
}

- (void)dealloc 
{
  [titleLabel release]; self.titleLabel = nil;
  [accountLabel release]; self.accountLabel = nil;
  [super dealloc];
}


@end
