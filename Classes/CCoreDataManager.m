//
//  CCoreDataManager.m
//  TouchCode
//
//  Created by Jonathan Wight on 3/3/07.
//  Copyright 2007 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CCoreDataManager.h"

#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@interface CCoreDataManager ()
@property (readwrite, retain) NSURL *modelURL;
@property (readwrite, retain) NSURL *persistentStoreURL;
@property (readwrite, retain) NSString *storeType;
@property (readwrite, retain) NSDictionary *storeOptions;

+ (NSURL *)modelURLForName:(NSString *)inName;
+ (NSURL *)persistentStoreURLForName:(NSString *)inName storeType:(NSString *)inStoreType forceReplace:(BOOL)inForceReplace;
+ (NSString *)applicationSupportFolder;
- (NSString *)threadStorageKey;
@end

#pragma mark -

@implementation CCoreDataManager

@synthesize modelURL;
@synthesize persistentStoreURL;
@synthesize storeType;
@synthesize storeOptions;

@dynamic persistentStoreCoordinator;
@dynamic managedObjectModel;
@dynamic managedObjectContext;

@synthesize delegate;

- (id)initWithModelUrl:(NSURL *)inModelUrl persistentStoreUrl:(NSURL *)inPersistentStoreUrl storeType:(NSString *)inStoreType storeOptions:(NSDictionary *)inStoreOptions
{
NSAssert(inModelUrl != NULL, @"inModelURL should not be NULL.");
NSAssert(inPersistentStoreUrl != NULL, @"inPersistentStoreURL should not be NULL.");

if ((self = [super init]) != NULL)
	{
	#if TARGET_OS_IPHONE == 1
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
	#else
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
	#endif

	self.modelURL = inModelUrl;
	self.persistentStoreURL = inPersistentStoreUrl;
	self.storeType = inStoreType ? inStoreType : NSSQLiteStoreType;
	self.storeOptions = inStoreOptions;
	}
return(self);
}

- (id)initWithModelUrl:(NSURL *)inModelUrl persistentStoreName:(NSString *)inPersistentName forceReplace:(BOOL)inForceReplace storeType:(NSString *)inStoreType storeOptions:(NSDictionary *)inStoreOptions;
{
NSURL *thePersistentStoreURL = [[self class] persistentStoreURLForName:inPersistentName storeType:inStoreType forceReplace:inForceReplace];
NSAssert(thePersistentStoreURL != NULL, @"thePersistentStoreURL should not be NULL.");

if ((self = [self initWithModelUrl:inModelUrl persistentStoreUrl:thePersistentStoreURL storeType:inStoreType storeOptions:inStoreOptions]) != NULL)
	{
	
	}
return(self);
}

- (id)initWithModelName:(NSString *)inModelName persistentStoreName:(NSString *)inPersistentName forceReplace:(BOOL)inForceReplace storeType:(NSString *)inStoreType storeOptions:(NSDictionary *)inStoreOptions;
{
NSURL *theModelURL = [[self class] modelURLForName:inModelName];
NSAssert(theModelURL != NULL, @"theModelURL should not be NULL.");
NSURL *thePersistentStoreURL = [[self class] persistentStoreURLForName:inPersistentName storeType:inStoreType forceReplace:inForceReplace];
NSAssert(thePersistentStoreURL != NULL, @"thePersistentStoreURL should not be NULL.");

if ((self = [self initWithModelUrl:theModelURL persistentStoreUrl:thePersistentStoreURL storeType:inStoreType storeOptions:inStoreOptions]) != NULL)
	{
	
	}
return(self);
}

- (id)initWithName:(NSString *)inName forceReplace:(BOOL)inForceReplace storeType:(NSString *)inStoreType storeOptions:(NSDictionary *)inStoreOptions;
{
NSURL *theModelURL = [[self class] modelURLForName:inName];
NSAssert(theModelURL != NULL, @"theModelURL should not be NULL.");
NSURL *thePersistentStoreURL = [[self class] persistentStoreURLForName:inName storeType:inStoreType forceReplace:inForceReplace];
NSAssert(thePersistentStoreURL != NULL, @"thePersistentStoreURL should not be NULL.");

if ((self = [self initWithModelUrl:theModelURL persistentStoreUrl:thePersistentStoreURL storeType:inStoreType storeOptions:inStoreOptions]) != NULL)
	{
	
	}
return(self);
}

- (void)dealloc
{
#if TARGET_OS_IPHONE == 1
[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
#else
[[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillTerminateNotification object:[NSApplication sharedApplication]];
#endif

[self save];

self.modelURL = NULL;
self.persistentStoreURL = NULL;
self.storeType = NULL;
self.storeOptions = NULL;

[persistentStoreCoordinator release];
persistentStoreCoordinator = NULL;
[managedObjectModel release];
managedObjectModel = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSManagedObjectModel *)managedObjectModel
{
@synchronized(@"CCoreDataManager.managedObjectModel")
	{
	if (managedObjectModel == NULL)
		{
		managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
		}
	}
return(managedObjectModel);
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
@synchronized(@"CCoreDataManager.persistentStoreCoordinator")
	{
	if (persistentStoreCoordinator == NULL)
		{
		NSError *theError = NULL;
		NSManagedObjectModel *theManagedObjectModel = self.managedObjectModel;
		if (theManagedObjectModel == NULL)
			return(NULL);
		NSPersistentStoreCoordinator *thePersistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:theManagedObjectModel] autorelease];
		NSPersistentStore *thePersistentStore = [thePersistentStoreCoordinator addPersistentStoreWithType:self.storeType configuration:NULL URL:self.persistentStoreURL options:self.storeOptions error:&theError];
        if (thePersistentStore == NULL)
			{
			[self presentError:theError];
			}
		
		persistentStoreCoordinator = [thePersistentStoreCoordinator retain];
		}
	}
return(persistentStoreCoordinator);
}

- (NSManagedObjectContext *)managedObjectContext
{
NSString *theThreadStorageKey = [self threadStorageKey];

NSManagedObjectContext *theManagedObjectContext = [[[NSThread currentThread] threadDictionary] objectForKey:theThreadStorageKey];
if (theManagedObjectContext == NULL)
	{
	theManagedObjectContext = [[self newManagedObjectContext] autorelease];
	if (theManagedObjectContext == NULL)
		return(NULL);
	[[[NSThread currentThread] threadDictionary] setObject:theManagedObjectContext forKey:theThreadStorageKey];
	}
return(theManagedObjectContext);
}

#pragma mark -

- (NSManagedObjectContext *)newManagedObjectContext
{
NSPersistentStoreCoordinator *thePersistentStoreCoordinator = self.persistentStoreCoordinator;
if (thePersistentStoreCoordinator == NULL)
	return(NULL);
NSManagedObjectContext *theManagedObjectContext = [[NSManagedObjectContext alloc] init];
[theManagedObjectContext setPersistentStoreCoordinator:thePersistentStoreCoordinator];

[self.delegate coreDataManager:self didCreateNewManagedObjectContext:theManagedObjectContext];

return(theManagedObjectContext);
}

- (BOOL)migrate:(NSError **)outError;
{
NSAssert(persistentStoreCoordinator == NULL, @"Cannot migrate persistent store with it already open.");

NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

NSPersistentStoreCoordinator *thePersistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel] autorelease];

NSDictionary *theOptions = [NSDictionary dictionaryWithObjectsAndKeys:
	[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, 
	NULL];
    persistentStoreCoordinator = [thePersistentStoreCoordinator retain];
NSError *theError = NULL;
[thePersistentStoreCoordinator addPersistentStoreWithType:self.storeType configuration:NULL URL:self.persistentStoreURL options:theOptions error:&theError];
    
if (theError)
	[theError retain];

[thePool release];

if (theError)
	[theError autorelease];

if (outError)
	*outError = theError;
    
return(theError == NULL);
}

- (BOOL)save:(NSError **)outError;
{
BOOL theResult = NO;

[self.managedObjectContext lock];

#if TARGET_OS_IPHONE == 0
[self.managedObjectContext commitEditing];
#endif

if ([self.managedObjectContext hasChanges] == NO)
	theResult = YES;
else
	{
	[self.managedObjectContext processPendingChanges];
	theResult = [self.managedObjectContext save:outError];
	}

[self.managedObjectContext unlock];

return(theResult);
}

- (void)save
{
NSError *theError = NULL;
if ([self save:&theError] == NO)
	{
	[self presentError:theError];
	}
}

#pragma mark -

- (void)presentError:(NSError *)inError
{
#if TARGET_OS_IPHONE == 1
fprintf(stderr, "ERROR: %s (%s)\n", [[inError description] UTF8String], [[inError.userInfo description] UTF8String]);
#else
[[NSApplication sharedApplication] presentError:inError];
#endif
}

- (void)applicationWillTerminate:(NSNotification *)inNotification
{
#pragma unused (inNotification)

[self save];
}

#pragma mark -

+ (NSURL *)modelURLForName:(NSString *)inName
{
NSString *theModelPath = [[NSBundle mainBundle] pathForResource:inName ofType:@"mom"];
if (theModelPath == NULL)
	theModelPath = [[NSBundle mainBundle] pathForResource:inName ofType:@"momd"];
NSURL *theModelURL = [NSURL fileURLWithPath:theModelPath];
return(theModelURL);
}

+ (NSURL *)persistentStoreURLForName:(NSString *)inName storeType:(NSString *)inStoreType forceReplace:(BOOL)inForceReplace
{
inStoreType = inStoreType ? inStoreType : NSSQLiteStoreType;

NSString *thePathExtension = NULL;
if ([inStoreType isEqualToString:NSSQLiteStoreType])
	thePathExtension = @"sqlite";
else if ([inStoreType isEqualToString:NSBinaryStoreType])
	thePathExtension = @"db";

NSString *theStorePath = [[self applicationSupportFolder] stringByAppendingPathComponent:[inName stringByAppendingPathExtension:thePathExtension]];

if (inForceReplace == YES)
	{
	NSError *theError = NULL;
	if ([[NSFileManager defaultManager] fileExistsAtPath:theStorePath] == YES)
		{
		[[NSFileManager defaultManager] removeItemAtPath:theStorePath error:&theError];
		}
	}
	
if ([[NSFileManager defaultManager] fileExistsAtPath:theStorePath] == NO)
	{
	NSError *theError = NULL;
	NSString *theSourceFile = [[NSBundle mainBundle] pathForResource:inName ofType:thePathExtension];
	if ([[NSFileManager defaultManager] fileExistsAtPath:theSourceFile] == YES)
		{
		BOOL theResult = [[NSFileManager defaultManager] copyItemAtPath:theSourceFile toPath:theStorePath error:&theError];
		if (theResult == NO)
			{
			[self release];
			self = NULL;
			return(self);
			}
		}
	}

NSURL *thePersistentStoreURL = [NSURL fileURLWithPath:theStorePath];

return(thePersistentStoreURL);
}

+ (NSString *)applicationSupportFolder
{
NSArray *thePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
NSString *theApplicationSupportFolder = ([thePaths count] > 0) ? [thePaths lastObject] : NSTemporaryDirectory();

if ([[NSFileManager defaultManager] fileExistsAtPath:theApplicationSupportFolder] == NO)
	{
	NSError *theError = NULL;
	if ([[NSFileManager defaultManager] createDirectoryAtPath:theApplicationSupportFolder withIntermediateDirectories:YES attributes:NULL error:&theError] == NO)
		return(NULL);
	}

return(theApplicationSupportFolder);
}

- (NSString *)threadStorageKey
{
NSString *theKey = [NSString stringWithFormat:@"%@:%p", NSStringFromClass([self class]), self];
return(theKey);
}

@end
