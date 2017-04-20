/**
 * for videoMain.jsp jk view
 */
$(window).ready(function() {

	// scroll
	$("#content_div").scroll(setCover);

	$(window).on("mousedown", function(event) {
		switch (event.which) {
		case 1: // left click
			break;
		case 2: // middle click
			fnRandomPlay();
			break;
		case 3: // right click
			break;
		}
	});

	var width = getLocalStorageItem(VIDEOMAIN_JK_COVER_WIDTH, 800);
	rangeCover.value = width;
	changeCover(width);
	
	randomView();

	$(".jk-video-wrapper").removeClass("hide");
});

function randomView() {
	var selectedNumber = getRandomInteger(0, opusArray.length-1);
	var selectedOpus = opusArray[selectedNumber];
	//console.log("randomView", selectedOpus);
	location.href = "#opus-" + selectedOpus;
}

function setCover() {
	$(".jk-video-cover.lazy-load").each(function() {
		var top = $(this).offset().top;
		var from = 0 - parseInt(rangeCover.value);
		var to = $("#content_div").height();
		console.log("margin", from, to);
		if (from < top && top < to) {
			$(this).css("background-image", "url(" + $(this).attr("data-src") + ")").removeClass("lazy-load").addClass("lazy-loaded");
		 	console.log("set background-image as", $(this).attr("data-src"));
		}
	});
	console.log(".jk-video-cover.lazy-load length", $(".jk-video-cover.lazy-load").length);
	if ($(".jk-video-cover.lazy-load").length == 0) {
		$("#content_div").off("scroll");
		console.log("off scroll event");
	}
}

function changeCover(val) {
	var width = parseInt(val);
	var height = parseInt(val*0.6725);
	console.log("changeCover", width, height);
	$(".jk-video-inner").css({width: width});
	$(".jk-video-cover").css({height: height, backgroundSize: (width+10) + "px " + (height+10) + "px"});
	$(".jk-video-title").css({fontSize: (width > 500 ? '24px' : "18px"), maxHeight: height-10});
	$(".jk-video-detail").toggle(width > 500);
	
	setLocalStorageItem(VIDEOMAIN_JK_COVER_WIDTH, width);
	
	if ($(".jk-video-cover.lazy-load").length > 0) {
		setCover();
	}
}