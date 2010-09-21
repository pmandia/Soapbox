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

#import "SBStatusImportOperation.h"
#import "SBTimelineViewController.h"
#import "CCoreDataManager.h"
#import "SBModelObjects.h"

@implementation SBStatusImportOperation

@synthesize statuses;
@synthesize delegate;
@synthesize markAllStatusesAsMentions;
@synthesize hasExistingCachedTweet;

- (id)initWithStatuses:(NSArray *)theStatuses delegate:(id)theDelegate;
{
  if ((self = [super init]))
  {
    self.statuses = theStatuses;
    self.delegate = theDelegate;
    self.hasExistingCachedTweet = NO;
  }
  
  return self;
}

- (void)main
{
  NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
  [moc setPersistentStoreCoordinator:[SBAppDelegate instance].coreDataManager.persistentStoreCoordinator];
  [moc setUndoManager:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(contextDidSave:)
                                               name:NSManagedObjectContextDidSaveNotification
                                             object:moc];

  for (NSDictionary *statusDict in self.statuses)
  {
    NSNumber *tweetID = [NSNumber numberWithLongLong:[[statusDict valueForKey:@"id"] longLongValue]];
    SBTweet *tweet = [SBTweet tweetWithID:tweetID usingManagedObjectContext:moc];

    if (!(tweet))
    {   
      SBTweet *tweet = nil;
      
      NSDictionary *retweetDictionary = [statusDict objectForKey:@"retweeted_status"];
      NSDictionary *userDictionary = ((retweetDictionary != nil)) ? [retweetDictionary objectForKey:@"user"] : [statusDict objectForKey:@"user"];
      
      NSString *screenName = [userDictionary objectForKey:@"screen_name"];
      SBUser *user = [SBUser userWithScreenName:screenName usingManagedObjectContext:moc];
      if (user == nil)
      {
        NSEntityDescription *entity = [NSEntityDescription entityForName:kUserEntityName inManagedObjectContext:moc];
        user = (SBUser *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
        [user parseUserContentsFromDictionary:userDictionary];        
      }      
      
      tweet = [NSEntityDescription insertNewObjectForEntityForName:kTweetEntityName inManagedObjectContext:moc];                
      tweet.user = user;
      if ((self.markAllStatusesAsMentions)) 
      { 
        tweet.downloadedAsFollowerValue = (([tweet.user followingValue])) ? YES : NO;
        tweet.downloadedAsMentionValue = YES;
      }
      
      [tweet parseTweetContentsFromDictionary:statusDict];
    }
    else 
    {
      if ((self.markAllStatusesAsMentions)) 
      { 
        tweet.downloadedAsMentionValue = YES;
      }
      
      [tweet markDirty];
    }
  }
  
  NSError *error = nil;

  if (![moc save:&error]) 
  {
    UIAlertViewQuick(@"Failed to save", [NSString stringWithFormat:@"Error = %@", [error localizedDescription]], @"OK");
    NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if(detailedErrors != nil && [detailedErrors count] > 0) {
      for(NSError* detailedError in detailedErrors) {
        NSLog(@"  DetailedError: %@", [detailedError userInfo]);
      }
    }
    
  }

  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSManagedObjectContextDidSaveNotification
                                                object:moc];
  
  [moc release], moc = nil;
  [statuses release], statuses = nil;
  
  if (([self.delegate respondsToSelector:@selector(refreshDone)]))
  {
    [self.delegate refreshDone];
  }
}

-(void)contextDidSave:(NSNotification *)notification
{
  if (([self.delegate respondsToSelector:@selector(mergeChanges:)])) 
  {
    DebugLog(@"Sending off mergeChanges to main thread");
    [self.delegate performSelectorOnMainThread:@selector(mergeChanges:) withObject:notification waitUntilDone:YES];
  }
  
  if (([self.delegate respondsToSelector:@selector(saveLastStatusIDWithStatus:)]))
  {
    DebugLog(@"Sending saving last Status ID to main thread");
    [self.delegate performSelectorOnMainThread:@selector(saveLastStatusIDWithStatus:) withObject:[self.statuses firstObject] waitUntilDone:YES];
  }
}

@end
