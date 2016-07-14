(function($) {
	$.fn.aperture = function(options) {

		var $circleWrapper = $(this);
		var cssId = "#" + $circleWrapper.attr("id");

		// determine default options 
		if (!options.width && !options.height) { // both not set
			options.width = $circleWrapper.outerHeight() + "px";
		}
		if (!options.width && options.height) { // width not set
			options.width = options.height;
		}
		if (options.width && !options.height) { // height not set 
			options.height = options.width;
		}
		if (!options.outerRadius) { // outRadius not net
			options.outerRadius = pixelDivide(options.width, 2);
		}
		if (!options.outerMargin) { // outerMargin not set
			options.outerMargin = pixelDivide(options.width, 10) + " auto";
		}
		if (!options.innerCirclePadding) { // innerCirclePadding not set
			options.innerCirclePadding = pixelDivide(options.width, 20);
		}
		var opts = $.extend({}, $.fn.aperture.defaults, options); // extend options
		
		var _radius = parsePixel(opts.outerRadius);
		// outer diagonal radius
		var outerDiagonalRadius = parseInt(Math.sqrt(_radius * _radius / 2)) + "px";
		// inner radius
		var innerRadius = pixelDivide(opts.width, 2);

		//console.log(opts, "outerDiagonalRadius: " + outerDiagonalRadius, "innerRadius: " + innerRadius);
		
		$circleWrapper.addClass("circle-wrapper").empty();
		var circle = $("<div>").addClass("circle");
		var image = $("<img>").addClass("img-circle").attr("src", opts.src);
		image.appendTo(circle);
		circle.appendTo($circleWrapper);
		
		// set css
		var _style = "<style>" + 
				cssId+".circle-wrapper, "+cssId+" div.circle:before, "+cssId+" div.circle:after {" +
					"transition: all " + opts.duration + " " + opts.timing + " " + opts.delay + ";" +
				"}" +
				""+cssId+".circle-wrapper {" +
					"width: "  + opts.width + ";" +
					"height: " + opts.height + ";" +
					"margin:"  + opts.outerMargin + ";" +
				"}" +
				""+cssId+".circle-wrapper:hover {" +
					"box-shadow: " +
						"-" + opts.outerRadius    + " 0"                        + " 0 " + opts.color1 + "," +
						"0"                       + " -" + opts.outerRadius     + " 0 " + opts.color2 + "," +
						"" + opts.outerRadius     + " 0"                        + " 0 " + opts.color3 + "," +
						"0 "                             + opts.outerRadius     + " 0 " + opts.color4 + "," +
						""  + outerDiagonalRadius + " "  + outerDiagonalRadius  + " 0 " + opts.color1 + "," +
						"-" + outerDiagonalRadius + " "  + outerDiagonalRadius  + " 0 " + opts.color2 + "," +
						"-" + outerDiagonalRadius + " -" + outerDiagonalRadius  + " 0 " + opts.color3 + "," +
						""  + outerDiagonalRadius + " -" + outerDiagonalRadius  + " 0 " + opts.color4 + ";" +
				"}" +
				""+cssId+" div.circle {" +
						"width: " + opts.width + ";" +
						"height: " + opts.height + ";" +
						"line-height: " + opts.height + ";" +
				"}" +
				""+cssId+" div.circle:before, "+cssId+" div.circle:after {" +
					"box-shadow: " +
						"inset " + innerRadius + "  0 0 " + opts.baseColor + "," +
						"inset 0  " + innerRadius + " 0 " + opts.baseColor + "," +
						"inset -" + innerRadius + " 0 0 " + opts.baseColor + "," +
						"inset 0 -" + innerRadius + " 0 " + opts.baseColor + ";" +
				"}" +
				""+cssId+" div.circle:hover:after, "+cssId+" div.circle:hover:before {" +
					"box-shadow: " +
						"inset " + opts.innerCirclePadding + "  0 0 " + opts.color1 + "," +
						"inset 0  " + opts.innerCirclePadding + " 0 " + opts.color2 + "," +
						"inset -" + opts.innerCirclePadding + " 0 0 " + opts.color3 + "," +
						"inset 0 -" + opts.innerCirclePadding + " 0 " + opts.color4 + ";" +
				"}" +
			"</style>";
		$(_style).appendTo("head");
		if (opts.width != opts.height) {
			var _style2 = "<style>" +
							cssId+".circle-wrapper, " + cssId+" div.circle, " + cssId+" div.circle:before, "+cssId+" div.circle:after {" +
									"border-radius: 25%;" +
							"}" +
							cssId+" div.circle:after {" +
									"transform: none;" +
									"-webkit-transform: none;" +
							"}" +
					"</style>";
			$(_style2).appendTo("head");
		}
		
	};

	/*
	 * default options
	 */
	$.fn.aperture.defaults = {
		duration: "1s", 	// transition-duration
		timing: "ease", 	// transition-timing-function
		delay: "0s",		// transition-delay
		width: "300px",		// circle width
		height: "300px",	// circle height
		outerRadius: "150px",		// circle outer radius
		outerMargin: "50px auto",	// circle outer margin
		baseColor: "rgba(255, 255, 255, .9)", // default color
		color1: "rgba(255,   0,   0, .5)",	// 1st circle color
		color2: "rgba(252, 150,   0, .5)",	// 2nd circle color
		color3: "rgba(0,   255,   0, .5)", // 3th circle color
		color4: "rgba(0,   150, 255, .5)", // 4th circle color
		innerCirclePadding: "15px"	// inner circle padding 
	};

	/*
	 * 25px -> (int)20
	 */
	function parsePixel(expStr) {
		return parseInt(expStr.substring(0, expStr.length-2));
	}
	
	/*
	 * 50px, 2 -> 50/2 = 25px
	 */
	function pixelDivide(pixel, divide) {
		var _num = parsePixel(pixel);
		return parseInt(_num / divide) + "px";
	}
})(jQuery);
