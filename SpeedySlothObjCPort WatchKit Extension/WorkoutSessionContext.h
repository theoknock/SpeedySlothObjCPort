//
//  WorkoutSessionContext.h
//  SpeedySlothObjCPort
//
//  Created by Xcode Developer on 1/3/20.
//  Copyright © 2020 The Life of a Demoniac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutSessionContext : NSObject

- (instancetype)initWithHealthStore:(HKHealthStore *)healthStore workoutConfiguration:(nullable HKWorkoutConfiguration *)configuration;

@property (strong, nonatomic) HKWorkoutConfiguration *configuration;
@property (assign, nonatomic) HKHealthStore *healthStore;

@end

NS_ASSUME_NONNULL_END
