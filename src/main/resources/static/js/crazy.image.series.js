/**
 *image/series module
 */

var series = (function() {
	var imageCount = 0, imageIndex = 0;
	var MARGIN_TOP = 30, MARGIN_LEFT = 100;
	var fn = {
			resize: function() {
				var $imageDiv = $("#imageDiv");					
				$imageDiv.height($(window).height() - MARGIN_TOP * 2);
				$imageDiv.children().each(function() {
					var $this = $(this);
					var position = $this.data("position");
					var calcPosition = fn.position.calc($imageDiv.width(), $imageDiv.height(), position.width, position.height, MARGIN_LEFT, MARGIN_TOP, 0.9);
					$this.css({
						width: calcPosition.width,
						height: calcPosition.height,
						top: calcPosition.top
					});
					if ($this.hasClass("img-series-left")) {
						$this.css({
							left: MARGIN_LEFT - calcPosition.width
						});
					}
					else if ($this.hasClass("img-series-center")) {
						$this.css({
							left: calcPosition.left
						});
					}
					else if ($this.hasClass("img-series-right")) {
						$this.css({
							left: $(window).width() - MARGIN_LEFT
						});
					}
				});
			},
			event: function() {	
				$("#imageDiv").navEvent(function(signal) {
					switch(signal) {
					case 39:
						fn.next();
						break;
					case 37:
						fn.prev();
						break;
					}
				});
				$(window).on("resize", fn.resize);
				$("#pathInfo").on("change", function() {
					path = $("#pathInfo option:selected").val();
				});
			},
			start: function() {
				fn.resize();

				restCall(PATH + '/rest/image/paths', {}, function(paths) {
					$.each(paths, function(idx, path) {
						$("#paths").append(
								$("<option>").attr("value", path).html(path)
						);
					});
				});
				
				restCall(PATH + '/rest/image/count', {}, function(count) {
					imageCount = count;
					fn.next();
				});
			},
			prev: function() {
				var $imageDiv = $("#imageDiv");					

				// 오른쪽을 더 멀리
				var $rightOverImage = $(".img-series-right", "#imageDiv");
				if ($rightOverImage.length > 0) {
					var position = $rightOverImage.data("position");
					$rightOverImage.removeClass("img-series-right").addClass("img-series-right-over")
					.css({
						left: $imageDiv.width() * 2
					});
				}

				// 중간을 오른쪽으로
				var $rightImage = $(".img-series-center", "#imageDiv");
				if ($rightImage.length > 0) {
					var position = $rightImage.data("position");
					$rightImage.removeClass("img-series-center").addClass("img-series-right")
					.css({
						left: $(window).width() - MARGIN_LEFT
					});
				}
				
				// 왼쪽을 중간으로
				var $centerImage = $(".img-series-left:last", "#imageDiv");
				if ($centerImage.length > 0) {
					var position = $centerImage.data("position");
					$centerImage.removeClass("img-series-left").addClass("img-series-center")
					.css({
						left: position.left
					});
					this.displayInfo($centerImage);
				}
				
				// 왼쪽 얼리있는걸 왼쪽으로
				var $leftImage = $(".img-series-left-over:last", "#imageDiv");
				if ($leftImage.length > 0) {
					var position = $leftImage.data("position");
					$leftImage.removeClass("img-series-left-over").addClass("img-series-left")
					.css({
						left: MARGIN_LEFT - position.width
					});
				}

			},
			next: function() {
				var $imageDiv = $("#imageDiv");					

				// 왼쪽을 더 멀리
				var $leftOverImage = $(".img-series-left", "#imageDiv");
				if ($leftOverImage.length > 0) {
					var position = $leftOverImage.data("position");
					$leftOverImage.removeClass("img-series-left").addClass("img-series-left-over")
					.css({
						left: (MARGIN_LEFT - position.width) * 2
					});
				}
				
				// 가운데에서 외쪽으로 밀기
				var $leftImage = $(".img-series-center", "#imageDiv");
				if ($leftImage.length > 0) {
					var position = $leftImage.data("position");
					$leftImage.removeClass("img-series-center").addClass("img-series-left")
					.css({
						left: MARGIN_LEFT - position.width
					});
				}

				// 오른쪽에서 가운데로 밀기
				var $centerImage = $(".img-series-right", "#imageDiv");
				if ($centerImage.length > 0) {
					var position = $centerImage.data("position");
					$centerImage.removeClass("img-series-right").addClass("img-series-center")
					.css({
						left: position.left
					});
					this.displayInfo($centerImage);
				}
				
				// 오른쪽 멀리서 오른쪽으로
				var $rightImage = $(".img-series-right-over:first", "#imageDiv");
				if ($rightImage.length > 0) {
					var position = $rightImage.data("position");
					$rightImage.removeClass("img-series-right-over").addClass("img-series-right")
					.css({
						left: $(window).width() - MARGIN_LEFT
					});
				}
				else { // 새 이미지
					var preloader = new Image();
					preloader.onload = function() {
						console.log("div", $imageDiv.width(), $imageDiv.height());
						var position = fn.position.calc($imageDiv.width(), $imageDiv.height(), preloader.width, preloader.height, MARGIN_LEFT, MARGIN_TOP, 0.9);
						
						var $image = $("<img>", {src: preloader.src})
						.css({
							left: $imageDiv.width() * 2, 
							top: position.top,
							width: position.width,
							height: position.height
						})
						.addClass("img-responsive img-thumbnail img-series img-series-right")
						.data("position", position)
						.data("index", imageIndex)
						.animate({
							left: $(window).width() - MARGIN_LEFT
						})
						.appendTo($imageDiv);

						restCall(PATH + '/rest/image/info/' + imageIndex, {showLoading: false}, function(info) {
							$image.data("info", info);
						});
						
						imageIndex++;
					};
					preloader.src = PATH + "/image/" + imageIndex;
				}
			},
			displayInfo: function($image) {
				var index = $image.data("index");
				var info = $image.data("info");
				$("#index").html(index);
				$("#name").html(info.name);
				$("#path").html(info.path);
				$("#length").html(formatFileSize(info.length));
				$("#modified").html(new Date(info.modified).format('yyyy-MM-dd hh:mm'));
			},
			position: {
				calc: function(divWidth, divHeight, originalWidth, originalHeight, offsetLeft, offsetTop, ratio) {
					var imgWidth  = originalWidth;
					var imgHeight = originalHeight;
					var imgLeft   = offsetLeft;
					var imgTop    = offsetTop;
					if (divHeight < imgHeight) { // 이미지 높이가 더 크면
						imgHeight = divHeight * ratio;
						imgWidth = imgHeight * originalWidth / originalHeight;
					}
					if (divWidth < imgWidth) { // 이미지 넓이가 더 크면
						imgWidth = divWidth * ratio;
						imgHeight = imgWidth * originalHeight / originalWidth;
					}
					if (divHeight > imgHeight) { // 이미지 높이가 작으면
						imgTop += (divHeight - imgHeight) / 2;
					}
					if (divWidth > imgWidth) { // 이미지 넓이가 작으면
						imgLeft += (divWidth - imgWidth) / 2;
					}
					//console.log("position", imgWidth, imgHeight, imgLeft, imgTop);
					return {
						width:  Math.floor(imgWidth),
						height: Math.floor(imgHeight),
						left:   Math.floor(imgLeft),
						top:    Math.floor(imgTop)
					};
				}
			},
	};
	
	return {
		init : function() {
			fn.event();
			fn.start();
		}
	};
	
}());