//
//  NSManagedObjectContext_Extensions.h
//  Small Society
//
//  Created by Jonathan Wight on 5/27/09.
//  Copyright 2009 Small Society. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (NSManagedObjectContext_Extensions)

- (NSUInteger)countOfObjectsOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError;

- (NSArray *)fetchObjectsOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError;
- (id)fetchObjectOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate error:(NSError **)outError;

- (id)fetchObjectOfEntityForName:(NSString *)inEntityName predicate:(NSPredicate *)inPredicate createIfNotFound:(BOOL)inCreateIfNotFound wasCreated:(BOOL *)outWasCreated error:(NSError **)outError;

@end
