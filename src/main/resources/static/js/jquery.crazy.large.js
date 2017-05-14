(function($) {
	$.fn.largeview = function() {
		$.large.fnShowVideoSlise();

		$(window).bind("mousewheel DOMMouseScroll", function(e) {
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
		
		$("#randomViewBtn").on("click", function() {
			$.large.fnRandomVideoView();
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
			currentVideoIndex = getRandomInteger(1, totalVideoSize);
			$.large.fnShowVideoSlise();
		},
		fnVideoView: function(idx) {
			currentVideoIndex = idx;
			$.large.fnShowVideoSlise();
		},
		fnShowVideoSlise: function() {
			$("#slides > div:visible").hide();
			$("div[tabindex='" + currentVideoIndex + "']").fadeIn(600);

			$(".pagination").empty();
			$(".prevCover, .nextCover").empty();
			
			fillPagination(1);
			var startIdx = parseInt(currentVideoIndex) - 4;
			var endIdx = parseInt(currentVideoIndex) + 4;
			for (var i = startIdx; i <= endIdx; i++) {
				var previewIndex = i;
				if (previewIndex <= 0)
					previewIndex = totalVideoSize + i;
				else if (previewIndex > totalVideoSize)
					previewIndex = previewIndex - totalVideoSize;

				fillPagination(previewIndex);
				/*
				$(".pagination").append(
						$("<li>").append(
								$("<a>").attr({href: '#'}).html(previewIndex).data("previewIndex", previewIndex).on("click", function() {
									$.large.fnVideoView($(this).data("previewIndex"));
								}).css({minWidth: '50px'})
						).addClass(previewIndex == currentVideoIndex ? "active" : "")
				);
				*/
				if (currentVideoIndex == i) {
					continue;
				}
		
//				if ($(window).width() > 1390) {
					var item = $("<div class='thumb-box' style='display:inline-block; width:266px; margin:5px; cursor:pointer;'>");
					item.append($("div[tabindex='" + previewIndex + "']").html());
					item.find(".box-detail").hide();
					item.find("dl").css({height: "178px", backgroundSize: 'cover', border: 0}).addClass("box");
					item.find("dt").css({marginTop: '170px', textAlign: 'center', height: '24px'});
					item.find("dt > span").css({writingMode: 'horizontal-tb', borderRadius: '4px', padding: '5px', margin: '0'});
					item.append(
				//			$("<div>").addClass("text-center").append(
				//					$("<span>").css({display: 'inline-block', padding: '5px 14px', backgroundColor: '#fff', border: '1px solid #ddd', borderRadius: '15px', color: '#337ab7'}).html(previewIndex)	
				//			)
					).data("previewIndex", previewIndex).on("click", function() {
						$.large.fnVideoView($(this).data("previewIndex"));
					});
					if (i < currentVideoIndex) {
						item.appendTo($(".prevCover"));
					}
					else {
						item.appendTo($(".nextCover"));
					}
//				}
			}
			fillPagination(totalVideoSize);
		},
		focusVideo: function(opus) {
			var idx = $("#opus-" + opus).attr("tabindex");
			currentVideoIndex = idx;
			$.large.fnShowVideoSlise();
		}
	}

	function fillPagination(no) {
		$(".pagination").append(
				$("<li>").append(
						$("<a>").attr({href: '#'}).html(no).data("previewIndex", no).on("click", function() {
							$.large.fnVideoView($(this).data("previewIndex"));
						}).css({minWidth: '50px'})
				).addClass(no == currentVideoIndex ? "active" : "")
		);
	}
	
})(jQuery);
