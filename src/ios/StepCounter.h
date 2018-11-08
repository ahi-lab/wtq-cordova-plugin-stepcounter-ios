//
//  StepCounter.h
//
//  Created by Johannes Dwiartanto on 12/8/14.
//
//

#import <Cordova/CDVPlugin.h>
#import "CoreMotion/CMStepCounter.h"

@interface StepCounter : CDVPlugin

@property(nonatomic, strong) CMStepCounter * stepCounter;

//checks if device has step counter support
- (void) isSupported:(CDVInvokedUrlCommand*)command;

//start live update
- (void) startLiveUpdate:(CDVInvokedUrlCommand *)command;

//stop live update
- (void) stopLiveUpdate:(CDVInvokedUrlCommand *)command;

//get data based on from and to arguments (in milliseconds)
- (void) getData:(CDVInvokedUrlCommand *)command;

@end
