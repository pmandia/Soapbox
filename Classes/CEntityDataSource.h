//
//  CEntityDataSource.h
//  Small Society
//
//  Created by Jonathan Wight on 5/5/09.
//  Copyright 2009 Small Society. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@protocol CEntityDataSource

@property (readwrite, nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (readwrite, nonatomic, retain) NSEntityDescription *entityDescription;
@property (readwrite, nonatomic, retain) NSArray *sortDescriptors;
@property (readwrite, nonatomic, retain) NSPredicate *predicate;
@property (readonly, nonatomic, retain) NSArray *items;

- (BOOL)fetch:(NSError **)outError;

@end

#pragma mark -

@interface CEntityDataSource : NSObject <CEntityDataSource> {
	NSManagedObjectContext *managedObjectContext;
	NSEntityDescription *entityDescription;
	NSArray *sortDescriptors;
	NSPredicate *predicate;
	NSArray *items;
}

@property (readwrite, nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (readwrite, nonatomic, retain) NSEntityDescription *entityDescription;
@property (readwrite, nonatomic, retain) NSPredicate *predicate;
@property (readonly, nonatomic, retain) NSArray *items;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext entityDescription:(NSEntityDescription *)inEntityDescription;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)inManagedObjectContext entityName:(NSString *)inEntityName;

- (BOOL)fetch:(NSError **)outError;

@end
