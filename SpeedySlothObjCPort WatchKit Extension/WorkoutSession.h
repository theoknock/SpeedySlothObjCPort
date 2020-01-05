//
//  WorkoutSession.h
//  SpeedySlothObjCPort
//
//  Created by Xcode Developer on 1/3/20.
//  Copyright © 2020 The Life of a Demoniac. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutSession : WKInterfaceController <HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate>

@property (weak, nonatomic) IBOutlet WKInterfaceTimer *timer;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *activeCaloriesLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *distanceLabel;

@property (strong, nonatomic) HKWorkoutConfiguration *configuration;
@property (strong, nonatomic) HKHealthStore *healthStore;
@property (strong, nonatomic) HKWorkoutSession *session;
@property (strong, nonatomic) HKLiveWorkoutBuilder *builder;

@end

NS_ASSUME_NONNULL_END
