//
//  WorkoutStartView.m
//  SpeedySlothObjCPort
//
//  Created by Xcode Developer on 1/3/20.
//  Copyright © 2020 The Life of a Demoniac. All rights reserved.
//

#import "WorkoutStartView.h"
#import "WorkoutSessionContext.h"

@interface WorkoutStartView ()

@end

@implementation WorkoutStartView

@synthesize healthStore = _healthStore;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (HKHealthStore *)healthStore
{
    HKHealthStore *hs = self->_healthStore;
    if (!hs)
    {
        hs = [HKHealthStore new];
        self->_healthStore = hs;
    }
    
    return hs;
}

- (void)didAppear
{
    [super didAppear];
    
    /// Requesting authorization.
    /// - Tag: RequestAuthorization
    // The quantity type to write to the health store.
    NSSet *typesToShare = [NSSet setWithArray:@[[HKQuantityType workoutType]]];
    
    // The quantity types to read from the health store.
    NSSet *typesToRead = [NSSet setWithArray:@[[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                                               [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                                               [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning]]];

    // Request authorization for those quantity types.
    [self.healthStore requestAuthorizationToShareTypes:typesToShare readTypes:typesToRead completion:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier
{
    if ([segueIdentifier isEqualToString:@"startWorkout"])
    {
        HKWorkoutConfiguration *configuration = [HKWorkoutConfiguration new];
        [configuration setActivityType:HKWorkoutActivityTypeRunning];
        [configuration setLocationType:HKWorkoutSessionLocationTypeOutdoor];
        
        return [[WorkoutSessionContext alloc] initWithHealthStore:self.healthStore workoutConfiguration:configuration];
    }
    
    return nil;
}

@end



