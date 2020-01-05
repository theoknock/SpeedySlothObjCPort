//
//  WorkoutSessionContext.m
//  SpeedySlothObjCPort
//
//  Created by Xcode Developer on 1/3/20.
//  Copyright © 2020 The Life of a Demoniac. All rights reserved.
//

#import "WorkoutSessionContext.h"

@implementation WorkoutSessionContext

- (instancetype)initWithHealthStore:(HKHealthStore *)healthStore workoutConfiguration:(nullable HKWorkoutConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        self.healthStore = healthStore;
        self.configuration = configuration;
    }
    return self;
}


@end
