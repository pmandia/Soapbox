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


#import "SBTimelineController.h"
#import "SBTweet.h"
#import "CCoreDataManager.h"
#import "SBUsersController.h"

@interface SBTimelineController ()
- (NSFetchRequest *)requestTweetWithID:(NSNumber *)tweetID inContext:(NSManagedObjectContext *)context;
@end

@implementation SBTimelineController

@synthesize usersController;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;

- (id)init
{
  if ((self = [super init]))
  {
    managedObjectContext = [[SBAppDelegate instance].coreDataManager.managedObjectContext retain];
    usersController = [[SBUsersController alloc] init];
    usersController.managedObjectContext = managedObjectContext;
  }
  
  return self;
}

- (void)dealloc
{
  [usersController release];
  [managedObjectContext release];
  [fetchedResultsController release];

  [super dealloc];  
}

- (SBTweet *)newTweetWithStatusDictionary:(NSDictionary *)dictionary
{
  [dictionary retain];
  NSDictionary *userDictionary = [dictionary objectForKey:@"user"];
  
  NSDictionary *retweetDictionary = [dictionary objectForKey:@"retweeted_status"];
  if ((retweetDictionary != nil))
  {
    userDictionary = [retweetDictionary objectForKey:@"user"];
  }
  
  SBUser *user = [self.usersController userWithScreenName:[userDictionary valueForKey:@"screen_name"]];
  if (user == nil)
  {
    user = [self.usersController newUserWithUserDictionary:userDictionary];
  }
    
  NSEntityDescription *entity = [[[SBAppDelegate instance].coreDataManager.managedObjectModel entitiesByName] objectForKey:kTweetEntityName];
  SBTweet *tweet = (SBTweet *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
  tweet.user = user;  
    
  [tweet parseTweetContentsFromDictionary:dictionary];      

  [dictionary release];                   
  return tweet;  
}

- (SBTweet *)tweetWithID:(NSNumber *)tweetID
{
  NSFetchRequest *request = [self requestTweetWithID:tweetID inContext:self.managedObjectContext];
  
  NSError *error = nil;
  NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
  
  return (([results count] > 0)) ? [results objectAtIndex:0] : nil;
}


- (BOOL)hasTweetWithID:(NSNumber *)tweetID
{
  NSManagedObjectContext *context = [SBAppDelegate instance].coreDataManager.managedObjectContext;
  NSFetchRequest *request = [self requestTweetWithID:tweetID inContext:context];
  
  NSError *error = nil;
  NSArray *results = [context executeFetchRequest:request error:&error];
 
  return (([results count] > 0)) ? YES : NO;
}

- (void)removeCachedTweetsFromDatabase
{
  NSManagedObjectContext *context = [SBAppDelegate instance].coreDataManager.managedObjectContext;
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:kTweetEntityName inManagedObjectContext:context];
  [request setEntity:entity];

  NSError *error;
  NSArray *items = [context executeFetchRequest:request error:&error];
  [request release];
  
  
  for (NSManagedObject *managedObject in items) 
  {
    [context deleteObject:managedObject];
    DebugLog(@"%@ object deleted", entity);
  }
  
  if (![context save:&error]) 
  {
    DebugLog(@"Error deleting %@ - error:%@", entity, error);
  }
}

- (void)saveTweet:(SBTweet *)tweet
{
  DebugLog(@"Save A Tweet To The Local Cache");
}

- (void)removeTweet:(SBTweet *)tweet
{
  DebugLog(@"Remove A Tweet From The Local Cache");
}


- (NSFetchRequest *)requestTweetWithID:(NSNumber *)tweetID inContext:(NSManagedObjectContext *)context
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:kTweetEntityName inManagedObjectContext:context];
  [request setEntity:entity];
  [request setFetchLimit:1];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tweetID == %@", tweetID];
  [request setPredicate:predicate];
  
  return [request autorelease];
}


#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (NSFetchedResultsController *)fetchedResultsController
{
  if ((fetchedResultsController == nil))
  {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setFetchBatchSize:50];
    [fetchRequest setFetchLimit:50];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTweetEntityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];  
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"UserTimeline"];
    self.fetchedResultsController = theFetchedResultsController;    
    
    [theFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];    
  }
  
  return fetchedResultsController;
}

@end
