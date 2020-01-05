//
//  WorkoutSession.m
//  SpeedySlothObjCPort
//
//  Created by Xcode Developer on 1/3/20.
//  Copyright © 2020 The Life of a Demoniac. All rights reserved.
//

#import "WorkoutSession.h"
#import "WorkoutSessionContext.h"

@interface WorkoutSession ()

@end

@implementation WorkoutSession

// MARK: - State Control

- (void)pauseWorkout
{
    [self.session pause];
}

- (void)resumeWorkout
{
    [self.session resume];
}

- (void)endWorkout
{
    /// Update the timer based on the state we are in.
    /// - Tag: SaveWorkout
    [self.session end];
    [self.builder endCollectionWithEndDate:[NSDate date] completion:^(BOOL success, NSError * _Nullable error) {
        [self.builder finishWorkoutWithCompletion:^(HKWorkout * _Nullable workout, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissController];
            });
        }];
    }];
}


- (void)setupMenuItemsForWorkoutSessionState:(HKWorkoutSessionState)state
{
    [self clearAllMenuItems];
    
    if (state == HKWorkoutSessionStateRunning)
    {
        [self addMenuItemWithItemIcon:WKMenuItemIconPause title:@"Pause" action:@selector(pauseWorkoutAction)];
    } else if (state == HKWorkoutSessionStatePaused) {
        [self addMenuItemWithItemIcon:WKMenuItemIconResume title:@"Resume" action:@selector(resumeWorkoutAction)];
    }
    
    [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"End" action:@selector(endWorkoutAction)];
}

- (void)setupWorkoutSessionInterface:(WorkoutSessionContext *)context
{
    if (!context)
    {
        return;
    } else {
        self.healthStore = context.healthStore;
        self.configuration = context.configuration;
        
        [self setupMenuItemsForWorkoutSessionState:HKWorkoutSessionStateRunning];
    }
}

- (void)setDurationTimerDate:(HKWorkoutSessionState)sessionState
{
    /// Obtain the elapsed time from the workout builder.
    /// - Tag: ObtainElapsedTime
    NSDate *timerDate = [NSDate dateWithTimeInterval:[self.builder elapsedTime] sinceDate:[NSDate date]];
    
    // Dispatch to main, because we are updating the interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timer setDate:timerDate];
    });
    
    // Dispatch to main, because we are updating the interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        /// Update the timer based on the state we are in.
        /// - Tag: UpdateTimer
        (sessionState == HKWorkoutSessionStateRunning) ? [self.timer start] : [self.timer stop];
    });
}

// Track elapsed time.
- (void)workoutBuilderDidCollectEvent:(HKLiveWorkoutBuilder *)workoutBuilder
{
    // Retrieve the workout event.
    switch ([[workoutBuilder workoutEvents] lastObject].type) {
        case HKWorkoutEventTypePause:
            [self setDurationTimerDate:HKWorkoutSessionStatePaused];
            break;
            
        case HKWorkoutEventTypeResume:
            [self setDurationTimerDate:HKWorkoutSessionStateRunning];
            break;
            
        default:
            break;
    }
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self setupWorkoutSessionInterface:context];
    
    // Create the session and obtain the workout builder.
    /// - Tag: CreateWorkout
    @try {
        self.session = [[HKWorkoutSession alloc] initWithHealthStore:self.healthStore configuration:self.configuration error:(NSError *__autoreleasing  _Nullable * _Nullable)nil];
        self.builder = [self.session associatedWorkoutBuilder];
    } @catch (NSException *exception) {
        [self dismissController];
    } @finally {
        
    }
    
    // Setup session and builder.
    self.session.delegate = self;
    self.builder.delegate = self;
    
    /// Set the workout builder's data source.
    /// - Tag: SetDataSource
    self.builder.dataSource = [[HKLiveWorkoutDataSource alloc] initWithHealthStore:self.healthStore workoutConfiguration:self.configuration];
    
    // Start the workout session and begin data collection.
    /// - Tag: StartSession
    [self.session startActivityWithDate:[NSDate date]];
    [self.builder beginCollectionWithStartDate:[NSDate date] completion:^(BOOL success, NSError * _Nullable error) {
        [self setDurationTimerDate:HKWorkoutSessionStateRunning];
    }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

// MARK: - Update the interface

/// Retreive the WKInterfaceLabel object for the quantity types we are observing.
- (WKInterfaceLabel *)labelForQuantityType:(HKQuantityType *)type
{
    if (type == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate])
    {
        return self.heartRateLabel;
    } else if (type == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned])
    {
        return self.activeCaloriesLabel;
    } else if (type == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning])
    {
        return self.distanceLabel;
    } else {
        return nil;
    }
}

/// Update the WKInterfaceLabels with new data.
- (void)updateLabel:(WKInterfaceLabel *)label withStatistics:(HKStatistics *)statistics
{
    // Make sure we got non `nil` parameters.
    if (!label || !statistics)
    {
        return;
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (statistics.quantityType == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate])
            {
                HKUnit *heartRateUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
                double value = [[statistics mostRecentQuantity] doubleValueForUnit:heartRateUnit];
                double roundedValue = (double)(round(1.0 * value) / 1.0);
                [label setText:[NSString stringWithFormat:@"%.2f BPM", roundedValue]];
            } else if (statistics.quantityType == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned])
            {
                HKUnit *energyUnit = [HKUnit kilocalorieUnit];
                double value = [[statistics sumQuantity] doubleValueForUnit:energyUnit];
                double roundedValue = (double)(round(1.0 * value) / 1.0);
                [label setText:[NSString stringWithFormat:@"%f cal", roundedValue]];
            } else if (statistics.quantityType == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning])
            {
                HKUnit *meterUnit = [HKUnit meterUnit];
                double value = [[statistics sumQuantity] doubleValueForUnit:meterUnit];
                double roundedValue = (double)(round(1.0 * value) / 1.0);
                [label setText:[NSString stringWithFormat:@"%f m", roundedValue]];
            }
        });
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
- (void)workoutBuilder:(HKLiveWorkoutBuilder *)workoutBuilder didCollectDataOfTypes:(NSSet<HKSampleType *> *)collectedTypes
{
    for (HKSampleType *type in collectedTypes)
    {
        if (![type isKindOfClass:[HKQuantityType class]])
        {
            return;
        } else {
            /// - Tag: GetStatistics
            HKQuantityType *quantityType = (HKQuantityType *)type;
            HKStatistics *statistics = [workoutBuilder statisticsForType:quantityType];
            WKInterfaceLabel *label = [self labelForQuantityType:quantityType];
            [self updateLabel:label withStatistics:statistics];
        }
    }
}

// MARK: - HKWorkoutSessionDelegate
- (void)workoutSession:(HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(NSDate *)date
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupMenuItemsForWorkoutSessionState:toState];
    });
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error
{
    // No error handling in this sample project.
}

@end
