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


#import "SBCharacterCountView.h"

static NSInteger kMaximumCharacterCount = 140;

@implementation SBCharacterCountView

@synthesize label;

- (void)awakeFromNib
{
  CGRect frame = self.bounds;
  self.backgroundColor = [UIColor clearColor];
  NSString *characterCount = [NSString stringWithFormat:@"%ld", kMaximumCharacterCount];
  self.label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
  self.label.opaque = NO;
  self.label.textAlignment = UITextAlignmentRight;
  self.label.text = characterCount;
  self.label.font = [UIFont boldSystemFontOfSize:20.0f];
  self.label.textColor = [UIColor whiteColor];
  self.label.backgroundColor = [UIColor clearColor];
  self.label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.35];
  self.label.shadowOffset = CGSizeMake(0, -1.0);
}
- (void)drawRect:(CGRect)rect 
{
  self.label.text = [NSString stringWithFormat:@"%ld", kMaximumCharacterCount];
  [self addSubview:self.label];
}

- (void)dealloc 
{
  [label release]; self.label = nil;
  [super dealloc];
}


@end
