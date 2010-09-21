//
//  CEntityDataSource.m
//  Small Society
//
//  Created by Jonathan Wight on 5/5/09.
//  Copyright 2009 Small Society. All rights reserved.
//

#import "CEntityDataSource.h"

@interface CEntityDataSource ()
@property (readwrite, nonatomic, retain) NSArray *items;
@end

@implementation CEntityDataSource

@synthesize managedObjectContext;
@synthesize entityDescription;
@dynamic sortDescriptors;
@dynamic predicate;
@dynamic items;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext entityDescription:(NSEntityDescription *)inEntityDescription
{
if ((self = [self init]) != NULL)
	{
	self.managedObjectContext = inManagedObjectContext;
	self.entityDescription = inEntityDescription;
	}
return(self);
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext entityName:(NSString *)inEntityName
{
NSEntityDescription *theEntityDescription = [NSEntityDescription entityForName:inEntityName inManagedObjectContext:inManagedObjectContext];
if ((self = [self initWithManagedObjectContext:inManagedObjectContext entityDescription:theEntityDescription]) != NULL)
	{
	}
return(self);
}

- (void)dealloc
{
self.entityDescription = NULL;
self.predicate = NULL;
self.items = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSPredicate *)predicate
{
return(predicate);
}

- (void)setPredicate:(NSPredicate *)inPredicate
{
if (predicate != inPredicate)
	{
	[predicate autorelease];
	predicate = [inPredicate retain];
	//
	self.items = NULL;
    }
}

- (NSArray *)sortDescriptors
{
return(sortDescriptors);
}

- (void)setSortDescriptors:(NSArray *)inSortDescriptors
{
if (sortDescriptors != inSortDescriptors)
	{
	[sortDescriptors autorelease];
	sortDescriptors = [inSortDescriptors retain];
	//
	self.items = NULL;
    }
}

- (NSArray *)items
{
if (items == NULL)
	{
	[self fetch:NULL];
	}
return(items);
}

- (void)setItems:(NSArray *)inItems
{
if (items != inItems)
	{
	[items autorelease];
	items = [inItems retain];
    }
}

- (BOOL)fetch:(NSError **)outError
{
NSFetchRequest *theRequest = [[[NSFetchRequest alloc] init] autorelease];
[theRequest setEntity:self.entityDescription];
if (self.sortDescriptors)
	[theRequest setSortDescriptors:self.sortDescriptors];
if (self.predicate)
	[theRequest setPredicate:self.predicate];

NSArray *theArray = [self.managedObjectContext executeFetchRequest:theRequest error:outError];

self.items = theArray;

return(theArray != NULL);
}

@end
