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

#import "SBAccountManager.h"
#import "SBTwitterManager.h"
#import "SBAccount.h"

@interface SBAccountManager ()
- (void)loadSavedAccounts;
@end

@implementation SBAccountManager

@synthesize loggedInUserAccount;
@synthesize accountOrder;

+ (SBAccountManager *)manager
{
  static SBAccountManager *manager = nil;
  
  if (manager == nil)
    manager = [[SBAccountManager alloc] init];
  return manager;
  
}

- (id)init
{
  if ((self = [super init]))
  {
    accounts = [[NSMutableDictionary alloc] init];
    accountOrder = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:kAccountListingOrder]];
    loggedInUserAccount = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
    [self loadSavedAccounts];
    
  }
  
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
  [self clearLoggedObject];
  [accounts release];
  [accountOrder release];
  [super dealloc];  
}

- (void)saveAccount:(SBAccount *)account
{
  if (account == nil) return;
  
  BOOL accountExists = [self hasAccountWithUsername:account.screenName];

  if ((!accountExists))
  {
    // Store the secret and key from OAuth in keychain.
    NSError *error = nil;
    NSString *username = account.screenName;
    NSString *tokenString = account.secret;
    
    if ([SFHFKeychainUtils storeUsername:username andPassword:tokenString forServiceName:kSourceName updateExisting:YES error:&error] == NO)
    {
      if (error)
      {
        UIAlertViewQuick([error localizedFailureReason], [error localizedDescription], @"OK");
      }
    }
    else
    {
      DebugLog(@"Cached token in keychain for user %@", username);  
    }

    [accountOrder addObject:account.screenName];
  }
  
  [accounts setObject:account forKey:account.screenName];
  [self saveToUserDefaults];
}

- (void)saveToUserDefaults
{
  NSMutableDictionary *accountsDictionary = [[NSMutableDictionary alloc] init];
  for (NSString *key in [accounts allKeys])
  {
    SBAccount *account = (SBAccount *)[accounts objectForKey:key];
    [accountsDictionary setObject:[account serializeAsDictionary] forKey:account.screenName];
  }
    
  [[NSUserDefaults standardUserDefaults] setObject:accountsDictionary forKey:kUserAccounts];
  [[NSUserDefaults standardUserDefaults] setObject:self.accountOrder forKey:kAccountListingOrder];  
  [[NSUserDefaults standardUserDefaults] synchronize];

  [accountsDictionary release];
}

- (void)removeSecretFromKeychainForAccount:(SBAccount *)account  
{
  // Remove their credential from Keychain
  NSError *err = nil;
  
  // choosing not to check for the return codes here, checking for an NSError returned seems fine, as
  // we are just displaying it
  [SFHFKeychainUtils deleteItemForUsername:account.screenName andServiceName:kSourceName error:&err];
  [SFHFKeychainUtils deleteItemForUsername:account.bitlyUserName andServiceName:kBitlyService error:&err];
  
  if (err)
  {
    UIAlertViewQuick([err localizedFailureReason], [err localizedDescription], @"OK");
  }

}
- (void)removePersistentStoreForAccount:(SBAccount *)account  
{
  // Remove the persistent store
  NSString *persistentStoreName = [NSString stringWithFormat:@"%@.sqlite", account.twitterID];  
  NSArray *thePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
  NSString *theApplicationSupportFolder = ([thePaths count] > 0) ? [thePaths lastObject] : NSTemporaryDirectory();
  NSString *theStorePath = [theApplicationSupportFolder stringByAppendingPathComponent:persistentStoreName];

  NSError *err = NULL;
  if ([[NSFileManager defaultManager] fileExistsAtPath:theStorePath] == YES)
  {
    [[NSFileManager defaultManager] removeItemAtPath:theStorePath error:&err];
    
    if (err)
    {
      UIAlertViewQuick([err localizedFailureReason], [err localizedDescription], @"OK");
    }
  }
}

- (void)unsetLoggedInAccountFromAccount:(SBAccount *)account  
{
  // If they are the logged in user, change it to nil.
  BOOL isloggedInUser = [account.screenName isEqualToString:self.loggedInUserAccount.screenName];
  
  if ((isloggedInUser))
  {
    // Get another user account.
    BOOL success = NO;
    for (NSString *key in [accounts allKeys])
    {
      if (!([key isEqualToString:account.screenName]))
      {
        [[NSUserDefaults standardUserDefaults] setValue:key forKey:kLoggedInAccountName];
        success = YES;
      }
    }    
    
    if ((!success))
    {
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoggedInAccountName];
    }
  }
}
- (void)removeAccount:(SBAccount *)account
{
  if (account == nil) return;
  
  BOOL accountExists = [self hasAccountWithUsername:account.screenName];

  if ((accountExists))
  {
    [self removeSecretFromKeychainForAccount:account];
    [self removePersistentStoreForAccount:account];
    [self unsetLoggedInAccountFromAccount:account];


    [accounts removeObjectForKey:account.screenName];
    
    NSUInteger index = 0;
    for (NSString *key in self.accountOrder)
    {
      if (([key isEqualToString:account.screenName]))
      {
        [self.accountOrder removeObjectAtIndex:index];
        break;
      }           
      index++;
    }
    
    [self saveToUserDefaults];
  }
}

- (SBAccount *)accountByUsername:(NSString *)username
{
  if (accounts == nil) return nil;
  
  SBAccount *account = [accounts objectForKey:username];
  if (account == nil) return nil;
  
  return account;
}

- (BOOL)hasAccountWithUsername:(NSString *)username
{
  return (!([self accountByUsername:username] == nil));
}

- (void)login:(SBAccount *)account
{
  if (!account) return;
  
  NSString *currentAccount = account.screenName;

  // Fetch their credential from Keychain
  NSError *err = nil;
	NSString *accessTokenString = [SFHFKeychainUtils getPasswordForUsername:currentAccount andServiceName:kSourceName error:&err];
  account.secret = accessTokenString;
  DebugLog(@"Successfully fetched access token: %@", accessTokenString);
  
  if (err)
  {
    UIAlertViewQuick([err localizedFailureReason], [err localizedDescription], @"OK");
  }

  [self updateLoggedInAccount:account];
  DebugLog(@"Logged in as %@", self.loggedInUserAccount.screenName);
}

- (void)clearLoggedObject
{
  if ((self.loggedInUserAccount))
  {
    [loggedInUserAccount release];
  }
}

- (BOOL)isValidLoggedUser
{
  return (!(self.loggedInUserAccount == nil));
}

- (void)updateLoggedInAccount:(SBAccount *)account
{
  [self clearLoggedObject];

  self.loggedInUserAccount = [account retain];
  
  twitter = [[[SBTwitterManager manager] createTwitterEngineForUserAccount:self.loggedInUserAccount delegate:self] retain];
  [twitter getUserInformationFor:self.loggedInUserAccount.screenName];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  [[NSUserDefaults standardUserDefaults] setObject:account.screenName forKey:kLoggedInAccountName];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)numberOfAccounts
{
  return [accounts count];
}

- (NSArray *)allAccounts
{
  NSMutableArray *accountsArray = [[NSMutableArray alloc] init];

  for (NSString *key in self.accountOrder)
  {
    SBAccount *account = (SBAccount *)[[accounts objectForKey:key] retain];
    [accountsArray addObject:account];
    [account release];
  }
  
  return [accountsArray autorelease];
}

#pragma mark -
#pragma mark NSNotification Methods
// +--------------------------------------------------------------------
// | NSNotification Methods
// +--------------------------------------------------------------------

- (void)applicationWillTerminate:(NSNotification *)inNotification
{
  [self saveToUserDefaults];
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
  DebugLog(@"Request succeeded for connectionIdentifier = %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
  DebugLog(@"Failed to update account information failed for connectionIdentifier = %@, error = %@ (%@)", 
           connectionIdentifier, 
           [error localizedDescription], 
           [error userInfo]);
}

- (void)connectionFinished:(NSString *)connectionIdentifier
{
  DebugLog(@"Connection finished %@", connectionIdentifier);
  
	if ([twitter numberOfConnections] == 0)
	{
    [twitter release];
	}
}
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier;
{
  if ((userInfo != nil))
  {
    NSDictionary *userDictionary = [userInfo objectAtIndex:0];
    self.loggedInUserAccount.twitterID = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"id"] integerValue]];
    self.loggedInUserAccount.fullName = [userDictionary objectForKey:@"name"];
    self.loggedInUserAccount.enabledGeoPosting = [[userDictionary objectForKey:@"geo_enabled"] boolValue];
    self.loggedInUserAccount.isProtected = [[userDictionary objectForKey:@"protected"] boolValue];
  }
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (void)loadSavedAccounts
{
  NSDictionary *allAccounts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserAccounts];
  
  for (NSString *key in [allAccounts allKeys])
  {
    NSDictionary *thisAccount = [allAccounts objectForKey:key];
    
    SBAccount *account = [[SBAccount alloc] initWithUserDictionary:thisAccount];
    [accounts setObject:account forKey:account.screenName];    
    [account release];
  }  
  
  NSString *lastAccountUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kLoggedInAccountName];  
  SBAccount *lastAccount = [self accountByUsername:lastAccountUsername];
  [self login:lastAccount];
}
@end
