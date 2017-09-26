;(function($) {

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
			currentVideoIndex = getRandomVideoIndex(); //getRandomInteger(1, totalVideoSize);
			$.large.fnShowVideoSlise();
		},
		fnVideoView: function(idx) {
			currentVideoIndex = idx;
			$.large.fnShowVideoSlise();
		},
		fnShowVideoSlise: function() {
			// show slide
			$("#slides > div:visible").hide();
			$("div[tabindex='" + currentVideoIndex + "']").fadeIn(300);

			// render prevView
			var prevViewWidth  = Math.floor(($("#content_div").width() - 800 ) / 2);
			var prevViewHeight = $(window).height() - 200;
			var prevViewColumn = Math.floor(prevViewWidth / 270);
			var prevViewRow    = Math.floor(prevViewHeight / 200);
			var prevViewSize   = prevViewColumn * prevViewRow;
			var prevViewStartIndex = parseInt(currentVideoIndex) - prevViewSize;
			var prevViewEndIndex   = parseInt(currentVideoIndex) + prevViewSize;
			
			$(".pagination, .prevCover, .nextCover").empty();
			fillPagination(1);
			var halfIndex = (prevViewEndIndex - prevViewStartIndex) / 2;
			var count = 0;
			for (var i = prevViewStartIndex; i <= prevViewEndIndex; i++) {
				var previewIndex = i;
				if (previewIndex <= 0)
					previewIndex = totalVideoSize + i;
				else if (previewIndex > totalVideoSize)
					previewIndex = previewIndex - totalVideoSize;

				fillPagination(previewIndex);

				if (currentVideoIndex == i) {
					continue;
				}
				
				var item = $("<div>");
				item.append($("div[tabindex='" + previewIndex + "']").html())
					.addClass("thumb-box")
					.attr("data-thumb-box-index", previewIndex)
					.css({display: "inline-block", width: "266px", margin: "5px", cursor: "pointer", transition: "all .3s"})
					.data("previewIndex", previewIndex)
					.on("click", function() {
						$.large.fnVideoView($(this).data("previewIndex"));
					});

				item.find("dl").css({height: "178px", backgroundSize: 'cover', border: 0}).addClass("box");
				item.find("dt").css({marginTop: '170px', textAlign: 'center', height: '24px'});
				item.find("dt > span").css({writingMode: 'horizontal-tb', borderRadius: '4px', padding: '5px', margin: '0'});
				item.find(".box-detail").remove();

				if (count++ < halfIndex)
					item.appendTo($(".prevCover"));
				else
					item.appendTo($(".nextCover"));
			}
			fillPagination(totalVideoSize);
		
			console.log("prevViewWidth", prevViewWidth, "prevViewHeight", prevViewHeight, 
					"prevViewColumn", prevViewColumn, "prevViewRow", prevViewRow, "prevViewSize", 
					prevViewSize, "prevViewStartIndex", prevViewStartIndex, "prevViewEndIndex", prevViewEndIndex, "currentVideoIndex", currentVideoIndex
			);
			
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
