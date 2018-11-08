//
//  StepCounter.m
//
//  Created by Johannes Dwiartanto on 12/8/14.
//
//

#import "StepCounter.h"

@implementation StepCounter

- (void) isSupported:(CDVInvokedUrlCommand*)command {
	NSLog(@"check is supported");
    //properties
    NSDictionary * props = @{@"supported":[NSNumber numberWithBool:[CMStepCounter isStepCountingAvailable]]};
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:props];
    [result setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) startLiveUpdate:(CDVInvokedUrlCommand*)command {
		NSLog(@"start live update");
		
		NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterFullStyle];
		[dateFormatter setTimeStyle:NSDateFormatterFullStyle];
		
		dispatch_queue_t q = dispatch_queue_create("LiveUpdateQueue", 0);
		dispatch_async(q, ^{
				
				if ([CMStepCounter isStepCountingAvailable]) {
						//start
						NSOperationQueue *queue = [NSOperationQueue new];
						queue.name = @"Steps";
						
						if(self.stepCounter == nil) {
								self.stepCounter = [[CMStepCounter alloc] init];
						}
						[self.stepCounter startStepCountingUpdatesToQueue:queue
                                                                 updateOn:1
                                                              withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                                                  if (!error) {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          //timestamp string
                                                                          NSString * timestampStr = [dateFormatter stringFromDate:timestamp];
																															
                                                                          //properties
                                                                          NSDictionary * props = @{@"numberOfSteps":[NSNumber numberWithInteger:numberOfSteps], @"timestamp":timestampStr};
																															
                                                                          //result
                                                                          CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:props];
                                                                          [result setKeepCallback:[NSNumber numberWithBool:YES]];
                                                                          [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                                                      });
                                                                  }
                                                                  else {
                                                                      NSLog(@"error startStepCountingUpdatesToQueue:updateOn");
                                                                  }
                                                              }];
				}
				else {
						CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:nil];
						[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
				}
		});
}

- (void) stopLiveUpdate:(CDVInvokedUrlCommand*)command {
		NSLog(@"stop live update");
		
		[self.stepCounter stopStepCountingUpdates];
}

- (void) getData:(CDVInvokedUrlCommand*)command {
		NSLog(@"get data");
		
		long long fromMillis = [[command argumentAtIndex:0 withDefault:@"0"] longLongValue];
		long long toMillis = [[command argumentAtIndex:1 withDefault:@"0"] longLongValue];
		
		NSDate *from = [NSDate date];
		NSDate *to = [NSDate date];
		
		if(fromMillis > 0) {
				from = [NSDate dateWithTimeIntervalSince1970:fromMillis/1000];
		}
		
		if(toMillis > 0) {
				to = [NSDate dateWithTimeIntervalSince1970:toMillis/1000];
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
		NSLog(@"From date is %@",[formatter stringFromDate:from]);
		NSLog(@"To date is %@",[formatter stringFromDate:to]);
		
		dispatch_queue_t q = dispatch_queue_create("StepsQueryQueue", 0);
		dispatch_async(q, ^{
				if ([CMStepCounter isStepCountingAvailable]) {

						//query
						NSOperationQueue *queue = [NSOperationQueue new];
						queue.name = @"Steps Query";
						
						if(self.stepCounter == nil) {
								self.stepCounter = [[CMStepCounter alloc] init];
						}
						[self.stepCounter queryStepCountStartingFrom:from
                                                                  to:to
                                                             toQueue:queue
                                                         withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                                             NSLog(@"Steps: %ld", numberOfSteps);
                                                             if (!error) {                                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                    //properties
                                                                    NSDictionary * props = @{@"numberOfSteps":[NSNumber numberWithInteger:numberOfSteps]};
																							 
                                                                    //result
                                                                    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:props];
                                                                    [result setKeepCallback:[NSNumber numberWithBool:YES]];
                                                                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
																 });
                                                            }
                                                            else {
                                                                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:nil];
                                                                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                                                NSLog(@"error queryStepCountStartingFrom:to");
                                                            }
                                                         }];
				}
				else {
						CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:nil];
						[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
				}
		});
}

- (void) dealloc {
		[self stopLiveUpdate:nil];
}

@end
