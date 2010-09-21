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


enum SBRootViewControllerSections {
  kRootViewControllerTimelineSections = 0,
  NUM_ROOT_CONTROLLER_SECTIONS
};

enum SBRootViewControllerTimelineSectionRows {
  kRootViewTimelineSectionHomeRow = 0,
  kRootViewTimelineSectionMentionsRow,
  NUM_ROOT_CONTROLLER_TIMELINE_SECTION_ROWS
};

@class CCoreDataManager;
@class SBMentionsViewController;
@class SBHomeTimelineController;

@interface SBRootViewController : UITableViewController <NSFetchedResultsControllerDelegate> 
{
@private
  UIBarButtonItem *postTweetButton;
  
  SBHomeTimelineController *homeViewController;
  SBMentionsViewController *mentionsViewController;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *postTweetButton;
@property (nonatomic, retain) SBHomeTimelineController *homeViewController;
@property (nonatomic, retain) SBMentionsViewController *mentionsViewController;

- (IBAction)post:(id)sender;

@end
