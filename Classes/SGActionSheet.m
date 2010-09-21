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


#import "SGActionSheet.h"


@implementation SGActionSheet

@synthesize sheet;
@synthesize blocks;


- (id)initWithTitle:(NSString *)theTitle
{
  if ((self = [super init]))
  {
    sheet = [[UIActionSheet alloc] initWithTitle:theTitle
                                      delegate:self 
                             cancelButtonTitle:nil 
                        destructiveButtonTitle:nil 
                             otherButtonTitles:nil];
    
    blocks = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)dealloc
{
  [sheet release];
  [blocks release];
  [super dealloc];
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)setCancelButtonWithTitle:(NSString *)theTitle block:(SGCompletionHandlerBlock)theBlock
{
  [self addButtonWithTitle:theTitle block:theBlock];
  sheet.cancelButtonIndex = sheet.numberOfButtons - 1;

}

- (void)addButtonWithTitle:(NSString *)theTitle block:(SGCompletionHandlerBlock)theBlock
{
  [blocks addObject:[[theBlock copy] autorelease]];
  [sheet addButtonWithTitle:theTitle]; 
}

- (void)showInView:(UIView *)theView
{
  [sheet showInView:theView];
  
  // Ensure that the we hang around until the sheet is dismissed
  [self retain];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
// +--------------------------------------------------------------------
// | UIActionSheet Delegate Methods
// +--------------------------------------------------------------------

- (void)actionSheet:(UIActionSheet *)theSheet clickedButtonAtIndex:(NSInteger)theButtonIndex 
{
  if ((theButtonIndex >= 0) && (theButtonIndex < [blocks count])) 
  {
    void (^b)() = [blocks objectAtIndex:theButtonIndex];
    b();
  }
  
  // Sheet to be dismissed, drop our self reference
  [self release];
}


@end
