<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title><s:message code="image.image-viewer"/></title>
<style type="text/css">
body, #navDiv, #imageDiv, #thumbnailDiv, .img-thumbnail, .active {
	overflow: hidden;
}
#navDiv {
	position:absolute; 
	left:0px; 
	top:0px; 
	margin:5px 5px 0px 5px; 
	text-align: center;
}
#imageDiv {
	text-align:center;
	margin-top: 30px;
	background-size:contain; 
	background-repeat:no-repeat; 
	background-position:center center;
}
#thumbnailDiv {
	position:absolute; 
	bottom:0px; 
	height:105px; 
	width:100%; 
	margin:10px 5px 0px 0px; 
	text-align:center; 
	overflow:hidden;
}
.img-thumbnail {
	width:120px; 
	height:100px;
	margin: 3px;
	background-size: cover; 
	background-repeat:no-repeat; 
	background-position:center center;
}
.active {
	opacity:1;
    border-color: #66afe9;
    outline: 0;
    -webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
    box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);	
}
body, .label-info, .progress, .paging {
	transition: background .5s ease, background-image .5s ease;
}
.effectInfo {
	position: fixed;
	bottom: 0;
	right: 0;
}
</style>
<script type="text/javascript">
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
var effects = ["blind", "bounce", "clip", "drop", "explode", "fade", "fold", "highlight", "puff", "pulsate", "scale", "shake", "size", "slide"];
var hideEffect;
var hideDuration;
var showEffect;
var showDuration;

$(document).ready(function() {
	
	setNextEffect();
	
	$.getJSON(imagepath + "data.json" ,function(data) {
		selectedNumber = data['selectedNumber'];
		imageCount = data['imageCount'];
		imageMap = data['imageNameMap'];
		
		resizeImage();
		if (selectedNumber > -1)
			fnViewImage(selectedNumber);
		else
			fnRandomImageView();
		$("#firstNo").html(0);
		$("#endNo").html(imageCount-1);

		setInterval(function() {
			toggleSlideView();
			//resizeImage();
			if (playSlide) {
				if (playSec % playInterval == 0) {
					fnRandomImageView();
					playSec = playInterval;
				}
				showTimer(playSec);
				//console.log("timer ", playSec);
			}
			playSec--;
			if (playSec % playInterval == 0) {
				playSec = playInterval;
			}
		},	1000);
	});
	
	$(window).bind("mousewheel DOMMouseScroll", function(e) {
		var delta = mousewheel(e);
		if (delta > 0) 
			fnPrevImageView(); //alert("마우스 휠 위로~");
	    else 	
			fnNextImageView(); //alert("마우스 휠 아래로~");
	});
	$(window).bind("keyup", function(e) {
		var event = window.event || e;
		//alert(event.keyCode);
		switch(event.keyCode) {
		case 37: // left
		case 40: // down
			fnPrevImageView(); break;
		case 39: // right
		case 38: // up
			fnNextImageView(); break;
		case 32: // space
			fnRandomImageView();
		case 13: // enter
			break;
		}
	});
	$("#imageDiv").bind("click", function(event){
		switch (event.which) {
		case 1: // left click
			fnNextImageView();
			break;
		case 2: // middle click
			fnRandomImageView();
			break;
		case 3: // right click
			break;
		}
		event.stopImmediatePropagation();
		event.preventDefault();
		event.stopPropagation();
	});
	$(window).bind("resize", resizeImage);
	
});

function toggleSlideView() {
	if (playSlide) {
		$("#thumbnailDiv").css('height', '5px').hide();
		$("body").css("background", "#000");
		$(".label-info").css("background", "#000");
		$("#timerBar").css("background", "#000");
		$(".progress").css("background-image", "linear-gradient(to bottom,#403a3a 0,#2f2626 100%)");
		$(".paging").hide();
	}
	else {
		$("#thumbnailDiv").css('height', '105px').show();
		$("body").css("background", "#fff");
		$(".label-info").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
		$("#timerBar").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
		$(".progress").css("background-image", "linear-gradient(to bottom,#ebebeb 0,#f5f5f5 100%)");
		$(".paging").show();
	}
	$("#imageDiv").height(windowHeight - $("#thumbnailDiv").outerHeight() - 35);
}

function resizeSecondDiv() {
	resizeImage();
}

function resizeImage() {
	windowHeight = $(window).height();
	$("#imageDiv").height(windowHeight - $("#thumbnailDiv").outerHeight() - 35);
	if (!playSlide) {
		//console.log("resizeImage");				
		fnDisplayThumbnail();
	}
}

function setNextEffect() {
	hideEffect   = effects[Math.floor(Math.random() * effects.length)];
	hideDuration = Math.floor(Math.random() * 1000);
	showEffect   = effects[Math.floor(Math.random() * effects.length)];
	showDuration = Math.floor(Math.random() * 2000);
	$(".effectInfo").html("hide: " + hideEffect + "(" + hideDuration + "), show: " + showEffect + "(" + showDuration + ")");
}

function fnViewImage(current) {
	var prevNumber = selectedNumber;
	selectedNumber = current;
	selectedImgUrl = imagepath + selectedNumber;
	
	$("#imageDiv").hide(hideEffect, [], hideDuration, function() {
		$(this).css("background-image", "url('" + selectedImgUrl + "')").show(showEffect, [], showDuration, setNextEffect);
	});
	if (!playSlide) {
		fnDisplayThumbnail();
	}
/* 
	var imageDiv = $("#imageDiv");
	if (playSlide) {
		var rNoP = Math.floor(Math.random() * 3);
		var iNoP = Math.floor(Math.random() * 1000);
		var rNoN = Math.floor(Math.random() * 3);
		var iNoN = Math.floor(Math.random() * 1000);

		switch (rNoP) { // hide prev image
		case 0:
			imageDiv.fadeOut(iNoP, function() {
				$(this).css("background-image", "url('" + selectedImgUrl + "')");
			});
			break;
		case 1:
			imageDiv.hide(iNoP, function() {
				$(this).css("background-image", "url('" + selectedImgUrl + "')");
			});
			break;
		case 2:
			imageDiv.slideUp(iNoP, function() {
				$(this).css("background-image", "url('" + selectedImgUrl + "')");
			});
			break;
		}
		switch (rNoN) { // show next image
		case 0:
			imageDiv.fadeIn(iNoN);
			break;
		case 1:
			imageDiv.slideDown(iNoN);
			break;
		case 2:
			imageDiv.show(iNoN);
			break;
		}
	}
	else {
		if (prevNumber - selectedNumber < 0) { // move forward
			imageDiv.hide(300, function() {
				$(this).css("background-image", "url('" + selectedImgUrl + "')");
			});
			imageDiv.fadeIn("slow");
		}
		else { // move backward
			imageDiv.fadeOut(300, function() {
				$(this).css("background-image", "url('" + selectedImgUrl + "')");
			});
			imageDiv.show(300);
		}
		fnDisplayThumbnail();
	}
 */		

	$("#leftNo").html(getPrevNumber());
	$("#currNo").html(selectedNumber);
	$("#rightNo").html(getNextNumber());
	$(".title").html(imageMap[selectedNumber]);
}
function fnFullyImageView() {
	popupImage(selectedImgUrl);
}
function getPrevNumber() {
	return selectedNumber == 0 ? imageCount - 1 : selectedNumber - 1;
}
function getNextNumber() {
	return selectedNumber == imageCount -1 ? 0 : selectedNumber + 1;
}
function fnFirstImageView() {
	fnViewImage(0);
}
function fnPrevImageView() {
	fnViewImage(getPrevNumber());
}
function fnNextImageView() {
	fnViewImage(getNextNumber());
}
function fnEndImageView() {
	fnViewImage(imageCount-1);
}
function fnRandomImageView() {
	fnViewImage(Math.floor(Math.random() * imageCount));
}
function fnDisplayThumbnail() {
	var windowWidth = $(window).width();
	var thumbnailRange = parseInt(windowWidth / (200 * 2));
	$("#thumbnailUL").empty();
	for (var current = selectedNumber - thumbnailRange; current <= selectedNumber + thumbnailRange; current++) {
		var thumbNo = current;
		if (thumbNo < 0 )
			thumbNo = imageCount + thumbNo;
		if (thumbNo >= imageCount)
			thumbNo = thumbNo - imageCount;
		$("<li>").append(
			$("<div>").addClass("img-thumbnail " + (thumbNo == selectedNumber ? "active" : "")).css("background-image", "url('" + imagepath + thumbNo + "')").data("imgNo", thumbNo).on("click", function() {
				fnViewImage($(this).data("imgNo"));
			})
		).appendTo($("ul#thumbnailUL"));
	}
}
function fnPlayImage() {
	if (playSlide) {
		playSlide = false;
		showTimer(playInterval);
		fnDisplayThumbnail();
		$("#timer").html("Random Play");
	}
	else {
		playSlide = true;
	}
}
function showTimer(sec) {
	$("#timer").html(sec + "s");
	$("#timerBar").attr("aria-valuenow", sec);
	$("#timerBar").css("width", sec*10 + "%");
}
</script>
</head>
<body>
<div class="container-fluid">

<div id="navDiv">
	<span class="label label-info paging" onclick="fnFirstImageView();"><span id="firstNo"></span></span>
	<span class="label label-info paging" onclick="fnPrevImageView();"><i class="glyphicon glyphicon-menu-left"></i><span id="leftNo"></span></span>
	<span class="label label-info paging"><span id="currNo"></span></span>
	<span class="label label-info paging" onclick="fnNextImageView();"><span id="rightNo"></span><i class="glyphicon glyphicon-menu-right"></i></span>
	<span class="label label-info paging" onclick="fnEndImageView();"><span id="endNo"></span></span>
	<span class="label label-info title"  onclick="fnFullyImageView();"></span>
	<span class="label label-info effectInfo" title="Next effect"></span>

	<div class="progress" style="width: 100px; margin: 5px 0px; z-index: 18;" onclick="fnPlayImage();">
  		<div id="timerBar" class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="10"
  			aria-valuemin="0" aria-valuemax="10" style="width:100%"><span id="timer">Random Play</span></div></div>
</div>

<div id="imageDiv"></div>

<div id="thumbnailDiv"><ul id="thumbnailUL" class="list-inline"></ul></div>

</div>
</body>
</html>
