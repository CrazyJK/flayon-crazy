<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Lightbox</title>
<link rel="stylesheet" href="${PATH}/css/lightbox.css">
<style type="text/css">
body {
	overflow: hidden;
}
.progress {
	position: fixed;
	top: 0px;
	left: 0px;
	width: 100px;
	margin: 5px;
	z-index: 2000;
	float: right;
	background-image: linear-gradient(to bottom,#403a3a 0,#2f2626 100%);
}
#timerBar {
	background: #000;
}
.form-control {
	border: 0;
    box-shadow: none;
    min-height: 40px;
}
.form-group:not(:last-child) {
	border-bottom: 1px dashed #ddd;
    padding-bottom: 5px;
}
.control-label {
	text-transform: capitalize;
}
</style>
<script type="text/javascript">
"use strict";

bgContinue = false;
var imagepath = '<s:url value="/image/"/>';
var selectedNumber;
var selectedImgUrl;
var imageCount;
var windowWidth  = $(window).width();
var windowHeight = $(window).height();
var imageMap;
var playSlide = false;
var playInterval = 10;
var playSec = playInterval;
var playMode = 'R';

$(document).ready(function() {
	
	$.getJSON(imagepath + "data.json" ,function(data) {
		imageCount = data['imageCount'];
		imageMap = data['imageNameMap'];
		
		selectedNumber = parseInt(getlocalStorageItem("thumbnamils.currentImageIndex", getRandomInteger(0, imageCount-1))) + 1;

		$(".imageCount").html(imageCount);
		
		fnRender();
		fnSetOption();
		fnCurrImage();
	});

	$("#playInterval").val(playInterval); // set default
	
	setInterval(function() {
		if (playSlide) {
			if (playSec % playInterval == 0) {
				if (playMode === 'r') {
					fnRandomImage();
				}
				else {
			    	fnNextImage();
				}
				playSec = playInterval;
			}
			showTimer(playSec);
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
	
	$("#albumLabel, #showDataLabel, #showImageNumberLabel, #resizeDuration, #fadeDuration, #imageFadeDuration, #wrapAround, #playInterval, #positionFromTop, input:radio[name='playMode']").on("change", function() {
		console.log("change", $(this));
		fnSetOption();
	});
});

function fnRender() {
	var imageset = $('#imageset');
	for (var i=0; i<imageCount; i++) {
		$("<a>").attr({
			'href': imagepath + i,
			'data-lightbox': 'lightbox-set',
			'data-title': "<a href='" + imagepath + i + "' target='image-" + i + "'>" + imageMap[i] + "</a>",
			"data-index": i
		}).appendTo(imageset);
	}
}
function fnPrevImage() {
	$("a.lb-prev").click();
}
function fnNextImage() {
	$("a.lb-next").click();
}
function fnCurrImage() {
	$("#imageset a:nth-child(" + selectedNumber + ")").click();
}
function fnRandomImage() {
	selectedNumber = getRandomInteger(0, imageCount-1);
	fnCurrImage();
}
function fnPlayImage() {
	if (playSlide) { // stop
		playSlide = false;
		showTimer(playInterval);
		$("#timer").html("Play");
	}
	else { // start
		playSlide = true;
	}
}
function showTimer(sec) {
	$("#timer").html(sec + "s");
	$("#timerBar").attr("aria-valuenow", sec);
	$("#timerBar").css("width", sec/playInterval*100 + "%");
}
function fnSetOption() {
	var albumLabel           = $("#albumLabel").val();
	var showDataLabel        = $("#showDataLabel").is(":checked");
	var showImageNumberLabel = $("#showImageNumberLabel").is(":checked");
	var resizeDuration       = parseInt($("#resizeDuration").val());
	var fadeDuration         = parseInt($("#fadeDuration").val());
	var imageFadeDuration	 = parseInt($("#imageFadeDuration").val());
	var wrapAround           = $("#wrapAround").is(":checked");
	var positionFromTop      = parseInt($("#positionFromTop").val());
	lightbox.option({
		'albumLabel': albumLabel,
		'showDataLabel': showDataLabel,
		'showImageNumberLabel': showImageNumberLabel,
		'resizeDuration': resizeDuration,
      	'fadeDuration': fadeDuration,
      	'imageFadeDuration': imageFadeDuration,
      	'wrapAround': wrapAround,
      	'positionFromTop': positionFromTop,
      	'sanitizeTitle': false
    });
	playInterval = parseInt($("#playInterval").val());
	playMode = $('input:radio[name="playMode"]:checked').val();
	$("#timerBar").attr("aria-valuemax", playInterval);

}
</script>
</head>
<body>
	<div class="container">
		<div class="page-header">
			<h1>Lightbox
				<small class="badge imageCount"></small>
			</h1>
		</div>
	
		<div class="form-horizontal box">
			<h1 class="text-center">Options</h1>
			<div class="form-group">
				<label class="control-label col-xs-6" for="albumLabel">albumLabel:</label>
				<div class="col-xs-6">
					<input class="form-control" id="albumLabel" value="Image %1 of %2" placeholder="%1 of %2"/>
				</div>
			</div>
			<div class="form-group">        
				<label class="control-label col-xs-6" for="showDataLabel">showDataLabel:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="showDataLabel">showDataLabel</label>
				</div>
			</div>
			<div class="form-group">        
				<label class="control-label col-xs-6" for="showImageNumberLabel">showImageNumberLabel:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="showImageNumberLabel">showImageNumberLabel</label>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="resizeDuration">resizeDuration:</label>
				<div class="col-xs-6">
					<input type="number" class="form-control" id="resizeDuration" value="700" placeholder="700"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="fadeDuration">fadeDuration:</label>
				<div class="col-xs-6"> 
					<input type="number" class="form-control" id="fadeDuration" value="600" placeholder="600"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="imageFadeDuration">imageFadeDuration:</label>
				<div class="col-xs-6"> 
					<input type="number" class="form-control" id="imageFadeDuration" value="600" placeholder="600"/>
				</div>
			</div>
			<div class="form-group"> 
				<label class="control-label col-xs-6" for="wrapAround">wrapAround:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="wrapAround">wrapAround</label>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="playInterval">playInterval:</label>
				<div class="col-xs-6"> 
					<input type="number" class="form-control" id="playInterval" value="5" placeholder="second"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="positionFromTop">positionFromTop:</label>
				<div class="col-xs-6"> 
					<input type="number" class="form-control" id="positionFromTop" value="30" placeholder="px"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6">playMode</label>
				<div class="col-xs-6">
					<label class="radio-inline"><input type="radio" name="playMode" value="r" checked="checked">Random</label>
					<label class="radio-inline"><input type="radio" name="playMode" value="s">Sequential</label>
				</div>
			</div>
			<div class="form-group">
      			<div class="col-xs-12">
					<button class="btn btn-default btn-block btn-lg" onclick="fnCurrImage()">View</button>
				</div>
			</div>
		</div>
	</div>

	
	<div class="progress" onclick="fnPlayImage();">
  		<div id="timerBar" class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="10"
  			aria-valuemin="0" aria-valuemax="10" style="width:100%"><span id="timer">Play</span></div></div>


	<div id="imageset"></div>

	<script src="${PATH}/js/lightbox.js"></script>
</body>
</html>
