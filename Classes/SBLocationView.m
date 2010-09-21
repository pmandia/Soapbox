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

#import "SBLocationView.h"

#define LOCATION_STRING_OFFSET 30.f
#define VERTICAL_OFFSET 3.0f
static CGFloat kLocationFontSize = 13.0f;

@implementation SBLocationView

@synthesize locationString;

- (id)initWithFrame:(CGRect)theFrame 
{
  if (self = [super initWithFrame:theFrame]) 
  {
    self.backgroundColor = [UIColor colorWithRed:0.898 green:0.949 blue:1.000 alpha:1.000];
    pinImage = [UIImage imageNamed:@"geopin.png"];
  }
  
  return self;
}
- (CGRect)backgroundRectForBounds:(CGRect)theBounds
{
  CGRect backgroundRect = theBounds;
  backgroundRect.origin.y = CGRectGetMaxY(theBounds);
  return backgroundRect;
}

  
- (void)drawLocationBackground
{
  CGRect backgroundRect = [self backgroundRectForBounds:self.bounds];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  UIColor *bgColor = [UIColor colorWithRed:0.898 green:0.949 blue:1.000 alpha:1.000];
  CGContextSetFillColorWithColor(context, bgColor.CGColor);
  CGContextFillRect(context, backgroundRect);
  CGContextRestoreGState(context);
}

- (void)drawPinImage
{
  CGRect backgroundRect = [self backgroundRectForBounds:self.bounds];
  CGFloat boundsX = backgroundRect.origin.x;
  CGPoint imagePoint = CGPointMake(boundsX + 10.0f, VERTICAL_OFFSET);
  [pinImage drawAtPoint:imagePoint];
}

- (void)drawLocationString
{
  UIFont *systemFont = [UIFont systemFontOfSize:kLocationFontSize];
  CGRect backgroundRect = [self backgroundRectForBounds:self.bounds];
  CGFloat boundsX = backgroundRect.origin.x;
  CGFloat actualFontSize;
  
  [[UIColor blackColor] set];
  CGFloat width = self.frame.size.width - LOCATION_STRING_OFFSET;
  [self.locationString sizeWithFont:systemFont minFontSize:kLocationFontSize actualFontSize:&actualFontSize forWidth:width lineBreakMode:UILineBreakModeTailTruncation];

  CGPoint stringPoint = CGPointMake(boundsX + 30.0f, VERTICAL_OFFSET);
  [self.locationString drawAtPoint:stringPoint forWidth:width withFont:systemFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
  
}

- (void)drawRect:(CGRect)rect 
{
  [self drawLocationBackground];
  [self drawPinImage];
  [self drawLocationString];
}


- (void)dealloc 
{
  [locationString release];
  [pinImage release];
  [super dealloc];
}

- (void)setLocationString:(NSString *)newString
{
  if ((locationString != newString))
  {
    [locationString release];
    locationString = [newString copy];
  }
  
  [self setNeedsDisplay];
}


@end