/**
 * for videoMain.jsp jk view
 */
var firstChangeCoverSize = true,
	opusList = new Array(),
	makeOpusList = function () {
		$(".jk-video").each(function() {
			opusList.push($(this).attr("id"));
		});
	},
	changeCoverSize = function() {
		var width = parseInt(rangeCover.value),
			height = parseInt(width * 0.6725),
			isLarge = width > 500;
		
		$(".jk-video").css({padding: (isLarge ? "10px" : "5px")});
		$(".jk-video-inner").css({width: width});
		$(".jk-video-cover").css({height: height});
		$(".jk-video-title").css({fontSize: (isLarge ? '24px' : "18px"), maxHeight: height-10});
		$(".jk-video-detail").toggle(isLarge);
		
		setLocalStorageItem(VIDEOMAIN_JK_COVER_WIDTH, width);
		rangeCover.title = width + " x " + height;
		console.log("changeCoverSize", "width", width, "height", height);
		
		if ($(".jk-video-cover.lazy-load").length > 0)
			if (firstChangeCoverSize)
				firstChangeCoverSize = false;
			else
				loadCoverImage();
	},
	randomView = function() {
		location.href = "#" + opusList[getRandomVideoIndex() - 1];
		/*
		var selectedNumber = getRandomVideoIndex() - 1; // getRandomInteger(0, opusList.length-1);
		var selectedOpus = opusList[selectedNumber];
		location.href = "#" + selectedOpus;
		console.log("randomView", selectedOpus); */
	},
	loadCoverImage = function() {
		var from = 0 - parseInt(rangeCover.value),
			to   = $("#content_div").height() + 100;
		//console.log("loadCoverImage", "from", from, "to", to);
	
		$(".jk-video-cover.lazy-load").each(function() {
			var top  = $(this).offset().top;
			if (from < top && top < to) {
				var imgUrl = $(this).attr("data-src");
				$(this).css("background-image", "url(" + imgUrl + ")").removeClass("lazy-load").addClass("lazy-loaded");
			 	console.log("load cover image", imgUrl);
			}
		});
		if ($(".jk-video-cover.lazy-load").length == 0) {
			$("#content_div").off("scroll");
			console.log("all cover image loadeed. #content_div scroll event off");
		}
	};

$(window).ready(function() {

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

	makeOpusList();
		
	$("#rangeCover").on("change", changeCoverSize).val(width).trigger("change");
	$("#randomViewBtn").on("click", randomView).trigger("click");
	$("#content_div").on('scroll', loadCoverImage).trigger("scroll");

});
