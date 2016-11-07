<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Lightbox</title>
<link rel="stylesheet" href="/css/lightbox.css">
<style type="text/css">
</style>
<script type="text/javascript">
"use strict";

bgContinue = false;
var imagepath = '<s:url value="/image/" />';
var selectedNumber;
var selectedImgUrl;
var imageCount;
var windowWidth  = $(window).width();
var windowHeight = $(window).height();
var imageMap;
var playSlide = false;
var playInterval = 10;
var playSec = playInterval;

$(document).ready(function() {
	
	$.getJSON(imagepath + "data.json" ,function(data) {
		selectedNumber = data['selectedNumber'];
		imageCount = data['imageCount'];
		imageMap = data['imageNameMap'];
		fnRender();
	});

	$("#playInterval").val(playInterval);
	setInterval(function() {
		if (playSlide) {
			if (playSec % playInterval == 0) {
				fnRandomImage();
				playSec = playInterval;
			}
		}
		playSec--;
		if (playSec % playInterval == 0) {
			playSec = playInterval;
		}
	},	1000);

	
	$(window).bind("mousewheel DOMMouseScroll", function(e) {
		var delta = mousewheel(e);
		if (delta > 0) 
			fnPrevImage();
	    else 	
	    	fnNextImage();
	});
	$(window).bind("keyup", function(e) {
		var event = window.event || e;
		switch(event.keyCode) {
		case 32: // space
			fnRandomImage();
			break;
		case 13: // enter
			break;
		};
	});
	$(".btn-show").on('click', function() {
		fnSetOption();
		fnRandomImage();
	});
	$(".btn-play").on('click', function() {
		fnSetOption();
		fnPlayImage();		
	});
});

function fnRender() {
	for (var i=0; i<imageCount; i++) {
		var anker = $("<a>")
		.attr('href', imagepath + i)
		.attr('data-lightbox', 'lightbox-set')
		.attr('data-title', imageMap[i])
//		.html(' [' + i + '] ')
//		.html($("<img>").attr("src", imagepath + i + "/thumbnail").addClass('img-thumbnail'))
		.appendTo($('#imageset'));
	}
//	$("#imageset a:nth-child(" + selectedNumber + ")").html($("<img>").attr("src", imagepath + (selectedNumber - 1)));
}
function fnPrevImage() {
	$("a.lb-prev").click();
}
function fnNextImage() {
	$("a.lb-next").click();
}
function fnRandomImage() {
	selectedNumber = getRandomInteger(0, imageCount);
	fnShowImage();
}
function fnShowImage() {
	$("#imageset a:nth-child(" + selectedNumber + ")").click();
}
function fnSetOption() {
	var albumLabel = $("#albumLabel").val();
	var showImageNumberLabel = $("#showImageNumberLabel").is(":checked");
	var resizeDuration = parseInt($("#resizeDuration").val());
	var fadeDuration = parseInt($("#fadeDuration").val());
	var wrapAround = $("#wrapAround").is(":checked");
	lightbox.option({
		'albumLabel': albumLabel,
		'showImageNumberLabel': showImageNumberLabel,
		'resizeDuration': resizeDuration,
      	'fadeDuration': fadeDuration,
      	'wrapAround': wrapAround
    });
	playInterval = parseInt($("#playInterval").val());
}
function fnPlayImage() {
	playSlide = true;
}
</script>
</head>
<body>
	<div class="container">
		<h1>Lightbox option</h1>
		<div class="form-horizontal">
			<div class="form-group">
				<label class="control-label col-sm-2" for="albumLabel">albumLabel:</label>
				<div class="col-sm-10">
					<input class="form-control" id="albumLabel" value="Image %1 of %2" placeholder="%1 of %2"/>
				</div>
			</div>
			<div class="form-group">        
      			<div class="col-sm-offset-2 col-sm-10">
        			<div class="checkbox">
						<label class="checkbox-inline">
							<input type="checkbox" checked="checked" id="showImageNumberLabel">showImageNumberLabel
						</label>
					</div>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-sm-2" for="resizeDuration">resizeDuration:</label>
				<div class="col-sm-10">
					<input type="number" class="form-control" id="resizeDuration" value="700" placeholder="700"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-sm-2" for="fadeDuration">fadeDuration:</label>
				<div class="col-sm-10"> 
					<input type="number" class="form-control" id="fadeDuration" value="700" placeholder="700"/>
				</div>
			</div>
			<div class="form-group">        
      			<div class="col-sm-offset-2 col-sm-10">
        			<div class="checkbox">
						<label class="checkbox-inline">
							<input type="checkbox" checked="checked" id="wrapAround">wrapAround
						</label>
					</div>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-sm-2" for="playInterval">playInterval:</label>
				<div class="col-sm-10"> 
					<input type="number" class="form-control" id="playInterval" value="5" placeholder="second"/>
				</div>
			</div>
			<div class="form-group">        
      			<div class="col-sm-offset-2 col-sm-10">
					<button class="btn btn-warning btn-show">Show</button>
					<button class="btn btn-primary btn-play">Play</button>
				</div>
			</div>
		</div>

	</div>

	<div id="imageset"></div>

	<script src="/js/lightbox.js"></script>
</body>
</html>
