(function($) {
	$.fn.largeview = function() {
		$.large.fnShowVideoSlise();

		$(this).bind("mousewheel DOMMouseScroll", function(e) {
			var delta = mousewheel(e);
			if (delta > 0) 
				$.large.fnPrevVideoView();
		    else 	
		    	$.large.fnNextVideoView();
		});
		
		$(window).bind("keyup", function(e) {
			var event = window.event || e;
			switch(event.keyCode) {
			case 37: // left
			case 40: // down
				$.large.fnPrevVideoView(); break;
			case 39: // right
			case 38: // up
				$.large.fnNextVideoView(); break;
//			case 32: // space
			case 34: // PageDown key
				$.large.fnRandomVideoView(); break;
			case 13: // enter
				break;
			}
		});
		return this;
	};

	$.large = {
		fnPrevVideoView: function() {
			if (currentVideoIndex == 1)
				currentVideoIndex = totalVideoSize + 1;
			currentVideoIndex--;
			$.large.fnShowVideoSlise();
		},
		fnNextVideoView: function() {
			if (currentVideoIndex == totalVideoSize)
				currentVideoIndex = 0;
			currentVideoIndex++;
			$.large.fnShowVideoSlise();
		},
		fnRandomVideoView: function() {
			currentVideoIndex = getRandomInteger(0, totalVideoSize);
			$.large.fnShowVideoSlise();
		},
		fnShowVideoSlise: function() {
			$("#slides > div:visible").hide();
			$("div[tabindex='" + currentVideoIndex + "']").fadeIn();
			$("#slideNumber").html(currentVideoIndex + " / " + totalVideoSize);
			
			$("#video_slide_bar").empty();
			var startIdx = parseInt(currentVideoIndex) - 1;
			var endIdx = parseInt(currentVideoIndex) + 1;
			for (var i=startIdx; i<=endIdx; i++) {
				var previewIndex = i;
				if (previewIndex == 0)
					previewIndex = totalVideoSize;
				else if (previewIndex == totalVideoSize + 1)
					previewIndex = 1;
				
				var item = $("<div class='video-box' style='display:inline-block;'>");
				item.append($("div[tabindex='" + previewIndex + "']").html());
				item.children("dl").removeClass("video-slide-bg").addClass("video-box-bg");
				$("#video_slide_bar").append(item);
			}
		},
		focusVideo: function(opus) {
			var idx = $("#opus-" + opus).attr("tabindex");
			currentVideoIndex = idx;
			$.large.fnShowVideoSlise();
		}
	}

})(jQuery);
