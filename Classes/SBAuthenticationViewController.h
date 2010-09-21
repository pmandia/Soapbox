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


#import <UIKit/UIKit.h>
#import "SBTwitterManager.h"
#import "MGTwitterEngine.h"
#import "MGTwitterEngineDelegate.h"

enum PTAuthenticationViewControllerSegments
{
  kUserNameField = 0,
  kPasswordField,
  NUM_AUTHENTICATION_SECTIONS
};

@interface SBAuthenticationViewController : UITableViewController <MGTwitterEngineDelegate>
{
@private
  UIBarButtonItem *cancelButton;
  UIBarButtonItem *saveButton;
  
  // Table Footer View
  UIView *tableFooterView;
  UIActivityIndicatorView *activityIndicator;
  UILabel *promptLabel;
  
  MGTwitterEngine *twitter;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic, retain) IBOutlet UIView *tableFooterView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *promptLabel;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

- (NSString *)userNameFieldValue;
- (NSString *)passwordFieldValue;
@end
