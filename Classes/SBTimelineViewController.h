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
#import "MGTwitterEngine.h"
#import "SBAvatarDownloader.h"

@class SBTimelineController;
@class SBTweetTableViewCell;
@class SBPostingViewController;
@class SBTweetViewController;

@interface SBTimelineViewController : UITableViewController <UIScrollViewDelegate, UIActionSheetDelegate, SBAvatarDownloaderDelegate, NSFetchedResultsControllerDelegate>
{
  MGTwitterEngine *twitter;

  BOOL shouldAdjustContentOffset;
  NSFetchedResultsController *fetchedResultsController;
  NSPredicate *filtersPredicate;

@private
  UIBarButtonItem *postTweetButton;

  // Table Header View
  // TODO: Factor this out to its own UIView.
  UIView *tableHeaderView;
  UIButton *loadNewerTweetsButton;
  UIActivityIndicatorView *refreshActivityIndicator;
  
  // Table Footer View
  // TODO: Factor this out to its own UIView
  UIView *tableFooterView;
  UILabel *footeReloadLabel;
  UIActivityIndicatorView *footerActivityIndicator;
  
  SBTimelineController *timelineController;
  NSMutableDictionary *avatarDownloadsInProgress;
  
  SBPostingViewController *postingViewController;
  SBTweetViewController *singleTweetViewController;
  
  CGFloat contentOffsetStartPosition;
  CGFloat contentOffsetAppended;
  
  BOOL refreshing;
  NSOperationQueue *queue;
  
  NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *postTweetButton;
@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *refreshActivityIndicator;
@property (nonatomic, retain) IBOutlet UIButton *loadNewerTweetsButton;
@property (nonatomic, retain) IBOutlet UIView *tableFooterView;
@property (nonatomic, retain) IBOutlet UILabel *footeReloadLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *footerActivityIndicator;
@property (nonatomic, retain) SBTimelineController *timelineController;
@property (nonatomic, retain) NSMutableDictionary *avatarDownloadsInProgress;
@property (nonatomic, retain) SBPostingViewController *postingViewController;
@property (nonatomic, retain) SBTweetViewController *singleTweetViewController;
@property (assign, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSPredicate *filtersPredicate;

- (IBAction)post:(id)sender;
- (IBAction)refresh:(id)sender;

- (void)refreshDone;
- (void)avatarDidLoad:(NSIndexPath *)indexPath;
- (void)startAvatarDownload:(SBUser *)user forIndexPath:(NSIndexPath *)theIndexPath;
- (CGFloat)cellHeightForIndexPath:(NSIndexPath *)indexPath;
- (void)disableRefreshButton:(BOOL)shouldEnable;
- (void)showRefreshFooter:(BOOL)shouldShow;
@end
