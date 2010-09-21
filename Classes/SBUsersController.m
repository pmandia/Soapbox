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

#import "SBUsersController.h"
#import "SBTweet.h"
#import "CCoreDataManager.h"

@interface SBUsersController ()
- (NSFetchRequest *)requestUserWithScreenName:(NSString *)screenName inContext:(NSManagedObjectContext *)context;
@end

@implementation SBUsersController

@synthesize users;
@synthesize managedObjectContext;

+ (SBUsersController *)defaultController
{
  static SBUsersController *controller = nil;
  
  if (controller == nil)
    controller = [[SBUsersController alloc] init];
  return controller;
  
}

- (id)init
{
  if ((self = [super init]))
  {
    users = [[NSMutableArray alloc] init];
    managedObjectContext = [[SBAppDelegate instance].coreDataManager.managedObjectContext retain];
  }
  
  return self;
}

- (void)dealloc
{
  [users release];
  [managedObjectContext release];
  [super dealloc];  
}

- (SBUser *)newUserWithUserDictionary:(NSDictionary *)dictionary
{
  [dictionary retain];
  NSEntityDescription *entity = [NSEntityDescription entityForName:kUserEntityName inManagedObjectContext:self.managedObjectContext];
  SBUser *user = (SBUser *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
  [user parseUserContentsFromDictionary:dictionary];
  [dictionary release];
  
  return user;
}

- (SBUser *)userWithScreenName:(NSString *)screenName
{
  NSFetchRequest *request = [self requestUserWithScreenName:screenName inContext:self.managedObjectContext];
  
  NSError *error = nil;
  NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
  
  return (([results count] > 0)) ? [results objectAtIndex:0] : nil;
  
}

- (BOOL)userExistsWithScreenName:(NSString *)screenName
{
  NSManagedObjectContext *context = [SBAppDelegate instance].coreDataManager.managedObjectContext;
  NSFetchRequest *request = [self requestUserWithScreenName:screenName inContext:context];
  
  NSError *error = nil;
  NSArray *results = [context executeFetchRequest:request error:&error];
  
  return (([results count] > 0)) ? YES : NO;  
}

- (void)removeCachedUsersFromDatabase
{
  NSManagedObjectContext *context = [SBAppDelegate instance].coreDataManager.managedObjectContext;
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:kUserEntityName inManagedObjectContext:context];
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

- (NSFetchRequest *)requestUserWithScreenName:(NSString *)screenName inContext:(NSManagedObjectContext *)context
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:kUserEntityName inManagedObjectContext:context];
  [request setEntity:entity];
  [request setFetchLimit:1];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"screenName == %@", screenName];
  [request setPredicate:predicate];
  
  return [request autorelease];
}

@end
