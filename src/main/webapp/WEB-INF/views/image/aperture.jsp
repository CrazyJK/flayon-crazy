<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Aperture</title>
<style type="text/css">
body, .label-info, .progress, .paging {
	transition: background .5s ease, background-image .5s ease;
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

$(document).ready(function(){
	
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
 {
	
}

function toggleSlideView() {
	if (playSlide) {
		$(".circle").css({'background-color': '#000'});
		$("body").css("background", "#000");
		$("#deco_nav").css("background", "#000");
		$(".label-info").css("background", "#000");
		$("#timerBar").css("background", "#000");
		$(".progress").css("background-image", "linear-gradient(to bottom,#403a3a 0,#2f2626 100%)");
		$(".paging").hide();
	}
	else {
		$(".circle").css({'background-color': '#fff'});
		$("body").css("background", "#fff");
		$("#deco_nav").css("background", "rgba(255,255,255,.8)");
		$(".label-info").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
		$("#timerBar").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
		$(".progress").css("background-image", "linear-gradient(to bottom,#ebebeb 0,#f5f5f5 100%)");
		$(".paging").show();
	}
}

function resizeImage() {
	windowHeight = $(window).height();
	calcDivHeight = windowHeight - 80;
	calcDivWidth  = $(window).width();
	$("#imageDiv").height(calcDivHeight);
	
	$("#aperture").aperture({
		outerMargin: "30px auto",
		width: (calcDivWidth - 50) + "px",
		height: (calcDivHeight - 50) + "px",
		outerRadius: "0",		// circle outer radius
		baseColor: randomColor(0.5), //"rgba(238, 238, 238, .9)", // default color
		innerCirclePadding: "15px"
	});

}

function fnViewImage(current) {
	resizeImage();
	var prevNumber = selectedNumber;
	selectedNumber = current;
	selectedImgUrl = imagepath + selectedNumber;

	$("#aperture img").attr("src", selectedImgUrl);

	$("#leftNo").html(getPrevNumber());
	$("#currNo").html(selectedNumber);
	$("#rightNo").html(getNextNumber());
	$("#imageTitle").html(imageMap[selectedNumber]);
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
function fnPlayImage() {
	if (playSlide) {
		playSlide = false;
		showTimer(playInterval);
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
	<span class="label label-info" id="imageTitle" onclick="fnFullyImageView();"></span>

	<div class="progress" style="width: 100px; margin: 5px 0px; z-index: 18;" onclick="fnPlayImage();">
  		<div id="timerBar" class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="10"
  			aria-valuemin="0" aria-valuemax="10" style="width:100%"><span id="timer">Random Play</span></div></div>
</div>

<div id="imageDiv">
	<div id="aperture"></div>
</div>

</div>
</body>
</html>
