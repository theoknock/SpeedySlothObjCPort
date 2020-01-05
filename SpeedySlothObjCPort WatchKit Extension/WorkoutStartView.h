//
//  WorkoutStartView.h
//  SpeedySlothObjCPort
//
//  Created by Xcode Developer on 1/3/20.
//  Copyright © 2020 The Life of a Demoniac. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutStartView : WKInterfaceController

@property (strong, nonatomic) HKHealthStore *healthStore;

@end

NS_ASSUME_NONNULL_END
