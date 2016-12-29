<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="image.image-viewer"/> by SlidesJS</title>
<style type="text/css">
.slides {
	/* width:100%; */
	margin:30px 0 0 0;
	text-align: center;
}
.slidesjs-container {
}
.slidesjs-control {
}
.slidesjs-slide {
}

.slidesjs-navigation {
    display: inline;
    padding: .2em .6em .3em;
    font-size: 75%;
    font-weight: 700;
    line-height: 1;
    color: #fff;
    text-align: center;
    white-space: nowrap;
    vertical-align: baseline;
    border-radius: .25em;	
	background-color: #5bc0de;
	
}
.slidesjs-navigation:hover, li.slidesjs-pagination-item a:hover, #imageTitle:hover {
	text-decoration:none;
}
.slidesjs-previous, .slidesjs-next {
	display: none;
}
.slidesjs-play, .slidesjs-stop {
	position: absolute;
	top: 0;
	left: 0;
	padding: 5px;
	margin: 7px;
	z-index: 18;
}
ul.slidesjs-pagination {
	position: absolute; 
	left:0px; 
	top:0px; 
	margin:7px 5px 0px 5px; 
	text-align: center;
	/* padding: 0; */
}
li.slidesjs-pagination-item {
	display:inline-block;
	margin:0 3px;
}
li.slidesjs-pagination-item:first-child, li.slidesjs-pagination-item:last-child {
}
li.slidesjs-pagination-item a {
	position: relative;
	float: left;
    padding: .2em .6em .3em;
    font-size: 95%;
    font-weight: 700;
    line-height: 1;
    /* width: 30px; */
    color: #fff;
    text-align: center;
    white-space: nowrap;
    vertical-align: baseline;
    border-radius: .25em;	
	background-color: #5bc0de;
}
li.slidesjs-pagination-item a.active {
    /* padding: .2em 1.2em .3em; */
	text-decoration:none;
	color: black;
}

.bg-image {
	background-position: center center; 
	background-size: contain; 
	background-repeat: no-repeat;
}
#imageTitle {
	position: absolute;
	top: 25px;
	left: 0px;
	padding: 5px;
	margin: 7px;
	z-index: 18;
}
</style>
<script src="/js/jquery.slides.min.js"></script>
<script type="text/javascript">
bgContinue = false;
var imagepath = '<s:url value="/image/" />';
var selectedNumber;
var selectedImgUrl;
var imageCount;
var windowWidth  = $(window).width();
var windowHeight = $(window).height();
var topOffset = 30;
var margin = 10;
var imageMap;
var isPlay = false;
var prevPlay = false;

$(document).ready(function(){
	$(function() {
		
		$.getJSON(imagepath + "data.json" ,function(data) {
			selectedNumber = data['selectedNumber'];
			imageCount = data['imageCount'];
			imageMap = data['imageNameMap'];

			for (var i=0; i<imageCount; i++) {
				var imageDiv = $("<div>").addClass("bg-image").height(windowHeight - topOffset - margin);
				$('#slides').append(imageDiv);
			}
			
			$('#slides').slidesjs({
				start: selectedNumber == -1 ? getRandomInteger(0, imageCount) : selectedNumber,
				width: windowWidth,
				height: windowHeight - topOffset,
			    navigation: {active: true},
			    /* pagination: false, */
			    play: {active: true, interval:5000, auto: false},
			    callback: {
			    	loaded: function(number) {
			    		rePagination();
			    	},
			    	start: function(number) {
			    		rePagination();
			    	},
			    	complete: function(number) {
			    		toggleSlideView();
			    	}
			    }
			});

			$(".slidesjs-control").bind("click", function(event){
				event.stopImmediatePropagation();
				event.preventDefault();
				event.stopPropagation();
				switch (event.which) {
				case 1: // left click
					$(".slidesjs-next").click();
					break;
				case 2: // middle click
					$(".slidesjs-previous").click();
					break;
				case 3: // right click
					break;
				}
			});

			$(".slidesjs-play").on('click', function() {
				isPlay = true;
				toggleSlideView();
			});
			$(".slidesjs-stop").on('click', function() {
				isPlay = false;
				toggleSlideView();
			});

		});
	});

	$(window).bind("mousewheel DOMMouseScroll", function(e) {
		var delta = mousewheel(e);
		if (delta > 0) 
			$(".slidesjs-previous").click();
	    else 	
	    	$(".slidesjs-next").click();
	});
	$(window).bind("keyup", function(e) {
		var event = window.event || e;
		//alert(event.keyCode);
		switch(event.keyCode) {
		case 37: // left
		case 40: // down
			$(".slidesjs-previous").click(); break;
		case 39: // right
		case 38: // up
			$(".slidesjs-next").click(); break;
		case 32: // space
			fnRandomImageView(); break;
		case 13: // enter
			break;
		};
	});
	
	$(window).bind("resize", resizeImage);

});
function resizeImage() {
	windowHeight = $(window).height();
	$('#slides').height(windowHeight - topOffset);
	$(".bg-image").height(windowHeight - topOffset - margin);
	$('.slidesjs-container').height(windowHeight - topOffset);
	
	rePagination();
}
function fnRandomImageView() {
	selectedNumber = getRandomInteger(0, imageCount);
	selectedImgUrl = imagepath + selectedNumber;
	$("a[data-slidesjs-item='" + selectedNumber + "']").click();
}
function rePagination() {
    var index = parseInt($(".slidesjs-pagination-item>.active").attr("data-slidesjs-item"));
	selectedImgUrl = imagepath + index;
    $("#imageTitle").html(imageMap[index]);

    if (false) {
    	var img = $("<img>").attr("src", selectedImgUrl);
        $("div[slidesjs-index='" + index + "']").empty();
        $("div[slidesjs-index='" + index + "']").append(img);
    }
    else {
	    $("div[slidesjs-index='" + index + "']").css({"background-image": "url(" + selectedImgUrl + ")"});
    }
    
    $(".slidesjs-pagination-item").each(function() {
    	var itemIdx = parseInt($(this).children().attr("data-slidesjs-item"));
    	if (itemIdx > index + 2 || itemIdx < index - 2) {
    		$(this).hide();
    	}
    	else {
    		$(this).show();
    	}
    });
}
function fnFullyImageView() {
	popupImage(selectedImgUrl);
}
function toggleSlideView() {
	var displayValue = $(".slidesjs-play").css("display");
	// console.log(".slidesjs-play", displayValue);
	isPlay = displayValue == 'none' ? true : false;	
	if (prevPlay != isPlay) {
		// console.log('toggleSlideView', isPlay);
		if (isPlay) {
			$(".slidesjs-pagination").hide();
			$(".slidesjs-navigation").css("background-color", "#000");
			$("#thumbnailDiv").css('height', '5px').hide();
			$("body").css("background", "#000");
//			$("#deco_nav").css("background", "#000");
			$(".label-info").css("background", "#000");
			$("#timerBar").css("background", "#000");
			$(".progress").css("background-image", "linear-gradient(to bottom,#403a3a 0,#2f2626 100%)");
			$(".paging").hide();
			$("#imageTitle").hide();
		}
		else {
			$(".slidesjs-pagination").show();
			$(".slidesjs-navigation").css("background-color", "#5bc0de");
			$("#thumbnailDiv").css('height', '105px').show();
			$("body").css("background", "#fff");
//			$("#deco_nav").css("background", "rgba(255,255,255,.8)");
			$(".label-info").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
			$("#timerBar").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
			$(".progress").css("background-image", "linear-gradient(to bottom,#ebebeb 0,#f5f5f5 100%)");
			$(".paging").show();
			$("#imageTitle").show();
		}
	}
	prevPlay = isPlay;
}

</script>
</head>
<body>
<div class="container-fluid">

	<div id="slides" class="slides"></div>
	
	<span class="label label-info" id="imageTitle" onclick="fnFullyImageView();"></span>
	
</div>
</body>
</html>