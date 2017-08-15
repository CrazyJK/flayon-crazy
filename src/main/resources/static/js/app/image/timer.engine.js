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
		$(".progress").remove();
		$(progressWrapperSelector).append(
				$("<div>").addClass("progress").css(progressStyle).on("click", function() {
					toggle(toggleCallback);
				}).append(
						$("<div>", {style: "width: 100%; cursor: pointer;", "class": "progress-bar progress-bar-primary", 
							role: "progressbar", "aria-valuemin": 1, "aria-valuemax": timerInterval, "aria-valuenow": timerInterval}).append(
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
		initiated = true;

		console.log("timerEngine.initiate", "engine start");
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
		currentSecond = timerInterval;
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
		console.log("timerEngine.setTime", second);
		timerInterval = second;
		return this;
	};
	var css = function(style) {
		console.log("timerEngine.css", style);
		$(".progress").css(style);
		return this;
	};
	var setLabel = function(text) {
		console.log("timerEngine.setLabel", text);
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

