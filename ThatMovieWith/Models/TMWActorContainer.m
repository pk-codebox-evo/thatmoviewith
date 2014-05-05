//
//  TMWAllActors.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWActorContainer.h"

@implementation TMWActorContainer

NSMutableArray *mutableActorContainer;

static TMWActorContainer *actorContainer;

// Singleton for accessing the same instance in multiple view controllers
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        actorContainer = [[TMWActorContainer alloc] init];
    }
}

+ (TMWActorContainer *)actorContainer
{
    [self initialize];
    return actorContainer;
}

- (void)removeActorObject:(TMWActor *)actorObject
{
    if (mutableActorContainer) {
        [mutableActorContainer removeObject:actorObject];
    }
    
}

- (void)addActorObject:(TMWActor *)actorObject
{
    if (!mutableActorContainer) {
        mutableActorContainer = [[NSMutableArray alloc] init];
    }
    [mutableActorContainer addObject:actorObject];
}

- (void)removeAllActorObjects
{
    if (mutableActorContainer) {
        [mutableActorContainer removeAllObjects];
    }
}

# pragma mark Getter Methods

- (NSArray *)allActorObjects
{
    return [NSArray arrayWithArray:mutableActorContainer];
}

- (NSArray *)sameMoviesNames
{
    NSMutableArray *mutableActorsMovies = [[NSMutableArray alloc] init];
    for (TMWActor *actor in mutableActorContainer) {
        if (actor.movies) {
            [mutableActorsMovies addObject:actor.movies];
        }
    }
    
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    for (NSArray *individualActorMovies in [mutableActorsMovies valueForKey:@"original_title"]) {
        if ([intersection count] != 0) {
            [intersection intersectSet:[NSSet setWithArray:individualActorMovies]];
        }
        else {
            [intersection addObjectsFromArray:individualActorMovies];
        }
    }
    return [[intersection set] allObjects];
}

- (NSArray *)sameMoviesIDs
{
    NSMutableArray *mutableActorsMovies = [[NSMutableArray alloc] init];
    for (TMWActor *actor in mutableActorContainer) {
        if (actor.movies) {
            [mutableActorsMovies addObject:actor.movies];
    
        }
    }
    
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    for (NSArray *individualActorMovies in [mutableActorsMovies valueForKey:@"id"]) {
        
        if ([intersection count] != 0) {
            [intersection intersectSet:[NSSet setWithArray:individualActorMovies]];
        }
        else {
            [intersection addObjectsFromArray:individualActorMovies];
        }
    }
    return [[intersection set] allObjects];
    
}

- (NSArray *)sameMoviesPosterUrlEndings
{
    NSMutableArray *mutableActorsMovies = [[NSMutableArray alloc] init];
    for (TMWActor *actor in mutableActorContainer) {
        if (actor.movies) {
            [mutableActorsMovies addObject:actor.movies];
            
        }
    }
    
    
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    for (NSArray *individualActorMovies in [mutableActorsMovies valueForKey:@"poster_path"]) {
        
        NSMutableArray *mutableIndividualActorMovies = [[NSMutableArray alloc] initWithArray:individualActorMovies];
        
        if ([intersection count] != 0) {
            [intersection intersectSet:[NSSet setWithArray:individualActorMovies]];
        }
        else {
            
            // Replace the null instances in the array with an int
            // because sets will consider every null value as 1 value
            NSUInteger i = 0;
            for (NSString *posterPath in individualActorMovies)
            {
                if (posterPath == (id)[NSNull null]) {
                    [mutableIndividualActorMovies replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:i]];
                }
                i++;
            }
            
            [intersection addObjectsFromArray:mutableIndividualActorMovies];
        }
    }
    return [[intersection set] allObjects];
}

@end