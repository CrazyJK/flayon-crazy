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
	color: #fff;
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
/* 	display:inline-block; */
	display: none;
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
/*#imageTitle {
 	position: absolute;
	top: 25px;
	left: 0px; 
	padding: 5px;
	margin: 7px;
	z-index: 18;
}*/
.label-switch, #imageTitle {
	cursor: pointer;
	padding: 4px;
}
.active-switch {
	background-color: #5bc0de;
}
#config-box {
	position: fixed;
	left: 40px;
	top: 0;
	margin: 5px;
	cursor: pointer;
	opacity: 0;
}
#config-box:hover {
	opacity: 1;
}
</style>
<script src="${PATH}/js/jquery.slides.min.js"></script>
<script type="text/javascript">
bgContinue = false;
var SLIDESJS_SOUUCE_MODE   = "slidesjs.souuce.mode";
var SLIDESJS_PLAY_INTERVAL = "slidesjs.play.interval";
var imagepath = '<s:url value="/image/" />';
var selectedNumber;
var selectedItemUrl;
var imageCount;
var imageMap;
var coverCount;
var coverMap;
var windowWidth  = $(window).width();
var windowHeight = $(window).height();
var topOffset = 30;
var margin = 5;
var isPlay = false;
var prevPlay = false;

$(document).ready(function(){
	$(function() {
		
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

	$("[data-role='switch']").on('click', function() {
		var target = $(this).attr("data-target");
		var value  = $(this).attr("data-value");
		var text   = $(this).text();
		$("#" + target).val(value);
		$("." + target).html(text);
		$("[data-target='" + target + "']").removeClass("active-switch");
		$(this).addClass("active-switch");
		buildSlidesJS();
	});
	$("input[type='range'][role='switch']").on('click', function() {
		var value = $(this).val();
		var target = $(this).attr("id");
		$("[data-target='" + target + "'][data-value='" + value + "']").click();
	});
	$("#interval").on('click', function() {
		$(".interval").html($(this).val());
		setLocalStorageItem(SLIDESJS_PLAY_INTERVAL, $(this).val());
	});

	requestData();
	shuffleOnce();

});

function requestData() {
	console.log("requestData start");
	$.ajax({
		type: 'GET',
		url: imagepath + "data.json",
		async: false
	}).done(function(data, textStatus, jqXHR) {
		coverCount = data['coverCount'];
		coverMap   = data['coverNameMap'];
		imageCount = data['imageCount'];
		imageMap   = data['imageNameMap'];
		console.log("requestData done");
	});
	console.log("requestData end");
}

function buildSlidesJS() {
	var itemCount = 0;
	if (sourceMode.value == 0) { // image
		itemCount = imageCount;
		selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(0, imageCount)));
	}
	else {
		itemCount = coverCount;
		selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, getRandomInteger(0, coverCount)));
	}
	console.log("call buildSlidesJS mode", sourceMode.value, "selectedNumber", selectedNumber);
	showSnackbar(sourceMode.value == 0 ? "Image mode" : "Cover mode");
	setLocalStorageItem(SLIDESJS_SOUUCE_MODE, sourceMode.value);

	$('#container-slidesjs').empty().append(
			$("<div>").attr({id: "slides"}).addClass("slides")	
	);
	
	for (var i=0; i<itemCount; i++) {
		var imageDiv = $("<div>").addClass("bg-image").height(windowHeight - topOffset - margin);
		$('#slides').append(imageDiv);
	}
	
	$('#slides').slidesjs({
		start: selectedNumber + 1,
		width: windowWidth,
		height: windowHeight - topOffset,
	    navigation: {active: true},
	    play: {active: true, interval: interval.value * 1000, auto: false},
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
}

function resizeImage() {
	windowHeight = $(window).height();
	$('#slides').height(windowHeight - topOffset);
	$(".bg-image").height(windowHeight - topOffset - margin);
	$('.slidesjs-container').height(windowHeight - topOffset);
	
	rePagination();
}
function fnRandomImageView() {
	if (sourceMode.value == 0) { // image
		selectedNumber = getRandomInteger(0, imageCount);
		selectedItemUrl = "${PATH}/image/" + selectedNumber;
	}
	else {
		selectedNumber = getRandomInteger(0, countCount);
		selectedItemUrl = "${PATH}/video/" + coverMap[selectedNumber] + "/cover";
	}
	
	$("a[data-slidesjs-item='" + selectedNumber + "']").click();
}
function rePagination() {
	selectedNumber = parseInt($(".slidesjs-pagination-item>.active").attr("data-slidesjs-item"));
    if (sourceMode.value == 0) { // image
		selectedItemUrl = "${PATH}/image/" + selectedNumber;
		selectedItemTitle = imageMap[selectedNumber];
		setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, selectedNumber);
    }
    else {
		selectedItemUrl = "${PATH}/video/" + coverMap[selectedNumber] + "/cover";
		selectedItemTitle = coverMap[selectedNumber];
		setLocalStorageItem(THUMBNAMILS_COVER_INDEX, selectedNumber);
    }
	console.log("rePagination", selectedNumber, selectedItemUrl, selectedItemTitle);

    $("#imageTitle").html(selectedItemTitle);
    $("div[slidesjs-index='" + selectedNumber + "']").css({"background-image": "url(" + selectedItemUrl + ")"});

    /*    
    $(".slidesjs-pagination-item").each(function() {
    	var itemIdx = parseInt($(this).children().attr("data-slidesjs-item"));
    	if (itemIdx > index + 3 || itemIdx < index - 3) {
    		$(this).hide();
    	}
    	else {
    		$(this).show();
    	}
    });
	*/    
}
function fnFullyImageView() {
	if (sourceMode.value == 0) { // image
		popupImage(selectedItemUrl);
	}
	else {
		fnVideoDetail(coverMap[selectedNumber]);
	}
}
function toggleSlideView() {
	var displayValue = $(".slidesjs-play").css("display");
	isPlay = displayValue == 'none' ? true : false;	
	if (prevPlay != isPlay) {
		if (isPlay) {
			$(".slidesjs-pagination").hide();
			$(".slidesjs-navigation").css("background-color", "#000");
			$("body").css("background", "#000");
			$("#switch-wrapper").hide();
		}
		else {
			$(".slidesjs-pagination").show();
			$(".slidesjs-navigation").css("background-color", "#5bc0de");
			$("body").css("background", "#fff");
			$("#switch-wrapper").show();
		}
	}
	prevPlay = isPlay;
}

function shuffleOnce() {
	var slidesjsSouuceMode   = getLocalStorageItem(SLIDESJS_SOUUCE_MODE,   getRandomInteger(0, 1));
	var slidesjsPlayInterval = getLocalStorageItem(SLIDESJS_PLAY_INTERVAL, getRandomInteger(5, 20));
	$("[data-target='sourceMode'][data-value='" + slidesjsSouuceMode + "']").click();
	$("#interval").val(slidesjsPlayInterval).click();
}
</script>
</head>
<body>
<div class="container-fluid">

	<div id="container-slidesjs"></div>
	
	<div id="config-box">
		<img src="${PATH}/img/config.png" width="20px" data-toggle="modal" data-target="#configModal"/>
	</div>

	<div id="configModal" class="modal fade" role="dialog">
		<div class="modal-dialog modal-sm">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<h4 class="modal-title">Configuration</h4>
				</div>
				<div class="modal-body">
					<table class="table">
						<tr>
							<th>Source Mode</th>
							<td class="text-center">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="sourceMode">Image</span>
								<input type="range" role="switch" id="sourceMode" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="sourceMode">Cover</span>
							</td>
						</tr>
						<tr>
							<th>Play interval</th>
							<td><input type="range" id="interval" value="10" min="5" max="20"/></td>
						</tr>
					</table>
				</div>
				<div class="modal-footer">
					<div class="text-center">
						Source   <span class="label label-info sourceMode"></span> 
						Interval <span class="label label-info interval"></span>
					</div>
				</div>
			</div>
		</div>
	</div>

</div>
</body>
</html>