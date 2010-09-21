//
//  NSManagedObjectContext_Extensions.m
//  Small Society
//
//  Created by Jonathan Wight on 5/27/09.
//  Copyright 2009 Small Society. All rights reserved.
//

#import "NSManagedObjectContext_Extensions.h"

@implementation NSManagedObjectContext (NSManagedObjectContext_Extensions)

- (NSUInteger)countOfObjectsOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError
{
NSEntityDescription *theEntityDescription = [NSEntityDescription entityForName:inEntityName inManagedObjectContext:self];
NSFetchRequest *theFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
[theFetchRequest setEntity:theEntityDescription];
if (inPredicate)
	[theFetchRequest setPredicate:inPredicate];
NSUInteger theCount = [self countForFetchRequest:theFetchRequest error:outError];
return(theCount);
}

- (NSArray *)fetchObjectsOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError
{
NSEntityDescription *theEntityDescription = [NSEntityDescription entityForName:inEntityName inManagedObjectContext:self];
NSFetchRequest *theFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
[theFetchRequest setEntity:theEntityDescription];
if (inPredicate)
	[theFetchRequest setPredicate:inPredicate];
NSArray *theObjects = [self executeFetchRequest:theFetchRequest error:outError];
return(theObjects);
}

- (id)fetchObjectOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError;
{
id theObject = [self fetchObjectOfEntityForName:inEntityName predicate:inPredicate createIfNotFound:NO wasCreated:NULL error:outError];
return(theObject);
}

- (id)fetchObjectOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate createIfNotFound:(BOOL)inCreateIfNotFound wasCreated:(BOOL *)outWasCreated error:(NSError **)outError
{
id theObject = NULL;
NSArray *theObjects = [self fetchObjectsOfEntityForName:inEntityName predicate:inPredicate error:outError];
BOOL theWasCreatedFlag = NO;
if (theObjects)
	{
	const NSUInteger theCount = theObjects.count;
	if (theCount == 0)
		{
		if (inCreateIfNotFound == YES)
			{
			theObject = [NSEntityDescription insertNewObjectForEntityForName:inEntityName inManagedObjectContext:self];
			if (theObject)
				theWasCreatedFlag = YES;
			}
		}
	else if (theCount == 1)
		{
		theObject = [theObjects lastObject];
		}
	else
		{
		if (outError)
			{
			NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"Expected 1 object (of type %@) but got %d instead (%@).", inEntityName, theObjects.count, inPredicate], NSLocalizedDescriptionKey,
				NULL];
			
			*outError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:theUserInfo];
			}
		}
	}
if (theObject && outWasCreated)
	*outWasCreated = theWasCreatedFlag;
	
return(theObject);
}

@end
