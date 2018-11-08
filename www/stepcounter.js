/*
 * Johannes Dwiartanto
 * (c) Leotech Pte Ltd., 2014
 *
 * JavaScript Cordova bridge CMStepCounter
 */

var exec = require("cordova/exec");
var StepCounter = {
	
	//check if device has step counter support
	isSupported: function(callback) {
		return exec(callback, function(error){callback(false);}, "StepCounter", "isSupported", []);
	},

	//start live update
	startLiveUpdate: function(callback) {
		return exec(callback, function(error){callback(false);}, "StepCounter", "startLiveUpdate", []);
	},
	
	//stop live update
	stopLiveUpdate: function(callback) {
		return exec(callback, function(error){callback(false);}, "StepCounter", "stopLiveUpdate", []);
	},
	
	//get data
	getData: function(from, to, callback) {
		from = from ? from : new Date().getTime();
		to = to ? to : new Date().getTime();
		return exec(callback, function(error){callback(false);}, "StepCounter", "getData", [from, to]);
	}
};

module.exports = StepCounter;
