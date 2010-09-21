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


#import "SBEditableCell.h"

@implementation SBEditableCell

@synthesize textField = textField;
@synthesize label = label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegate
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
  {
    label = [[UILabel alloc] initWithFrame: CGRectZero];
		label.font = [UIFont boldSystemFontOfSize: 16.0];
		label.textColor = [UIColor darkTextColor];
		[self addSubview: label];
		
		textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:16.0];
    textField.textColor = [UIColor darkTextColor];
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.delegate = delegate;
    [self addSubview: textField];
  }
  return self;
}

- (void)layoutSubviews 
{
	[self.label sizeToFit];
	self.label.frame = CGRectMake(self.contentView.bounds.origin.x + 20, self.contentView.bounds.origin.y + 12, self.label.frame.size.width, self.label.frame.size.height);
	
  self.textField.frame = CGRectMake(self.label.frame.origin.x + self.label.frame.size.width + 8, self.contentView.bounds.origin.y, self.contentView.bounds.size.width - self.label.frame.size.width - 40, self.contentView.bounds.size.height);
}

- (void)setLabelText:(NSString *)labelText andPlaceholderText:(NSString *)placeholderText
{
	self.label.text = labelText;
	
	self.textField.placeholder = placeholderText;
	
	[self layoutSubviews];
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated {
  [super setSelected:selected animated:animated];
  
  if (selected) {
    self.textField.textColor = [UIColor whiteColor];
  } else {
    self.textField.textColor = [UIColor darkTextColor];
  }
}

- (void) dealloc {
  [textField release];
	[label release];
  [super dealloc];
}


@end