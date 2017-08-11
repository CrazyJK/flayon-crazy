/**
 * timer engine
 */

var timerEngine = (function($) {

	var initiated = false;
	var timerStatus = false;
	var currentSecond = 0;
	var timerInterval = 0;
	var labelText = "timer";
	var engine;
	
	var initiate = function(invokedMethod, second, progressWrapperSelector, progressStyle, text, toggleCallback) {
		console.log("timerEngine.initiate");
		timerInterval = currentSecond = second;
		labelText = text;

		if (initiated) {
			clearInterval(engine);
		}
		
		// render progress
		$(progressWrapperSelector).empty().append(
				$("<div>").addClass("progress").css(progressStyle).on("click", function() {
					toggle(toggleCallback);
				}).append(
						$("<div>").addClass("progress-bar progress-bar-info").css({width: "100%", cursor: "pointer"}).attr({
							role: "progressbar", 
							"aria-valuemin": 0,
							"aria-valuemax": 100, 
							"aria-valuenow": 100}).append(
									$("<span>").addClass("progress-label").html(labelText)
						)
				)
		);
		console.log("timerEngine.initiate", "render progress");
		
		// engine startup
		engine = setInterval(function() {
			//console.log("timerEngine engine running");
			if (timerStatus) {
				if (--currentSecond % timerInterval == 0) {
					currentSecond = timerInterval;
					if (invokedMethod)
						invokedMethod();
				}
				display(currentSecond, currentSecond + "s");
			}
		},	1000);
		console.log("timerEngine.initiate", "engine start");

		initiated = true;
	};
	
	var display = function(second, text) {
		console.log("timerEngine.display");
		$(".progress-bar").css({width: second / timerInterval * 100 + "%"}).attr({"aria-valuenow": second});
		$(".progress-label").html(text);
	};
	
	var on = function(callback) {
		console.log("timerEngine.on");
		if (!initiated) {
			console.log("timer not initiated. fitst call timerEngine.init");
			return;
		}
		timerStatus = true;
		if (callback)
			callback();
	};
	var off = function(callback) {
		console.log("timerEngine.off");
		if (!initiated) {
			console.log("timer not initiated. fitst call timerEngine.init");
			return;
		}
		timerStatus = false;
		display(timerInterval, labelText);
		if (callback)
			callback();
	};
	var toggle = function(callback) {
		console.log("timerEngine.toggle");
		if (!timerStatus)
			on();
		else
			off();
		if (callback)
			callback(timerStatus);
	};
	var setTime = function(second) {
		timerInterval = second;
		return this;
	};
	var css = function(style) {
		$(".progress").css(style);
		return this;
	};
	var setLabel = function(text) {
		labelText = text;
		$(".progress-label").html(labelText);
		return this;
	};
	
	return {
		init: initiate,
		on: on,
		off: off,
		toggle: toggle,
		css: css,
		setTime: setTime,
		setLabel: setLabel
	};

}(jQuery));

