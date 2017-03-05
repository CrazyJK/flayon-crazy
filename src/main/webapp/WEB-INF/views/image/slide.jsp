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
body, .label-info, .progress, .paging {
	transition: background .5s ease, background-image .5s ease;
}
#navDiv {
	position: fixed;
	left: 0; 
	top: 0; 
	margin: 5px 5px 0px 5px; 
	z-index: 2000;
}
.progress {
	width: 100px; 
	margin: 0; 
}
.progress-bar {
	width:100%
}
#imageDiv {
	margin-top: 30px;
	background-size: contain; 
	background-repeat: no-repeat; 
	background-position: center center;
}
#thumbnailDiv {
	position: fixed; 
	bottom: 0; 
	width: 100%; 
	text-align: center; 
}
#thumbnailUL {
	margin: 0;
}
#thumbnailUL li:first-child, #thumbnailUL li:last-child {
	visibility: hidden;
}  
.img-thumbnail {
	width: 120px; 
	height: 100px;
	margin: 3px;
	background-size: cover; 
	background-repeat: no-repeat; 
	background-position: center center;
}
.active {
	opacity: 1;
    border-color: #66afe9;
    outline: 0;
    box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);	
}
#effectInfo-box {
	position: fixed;
	right: 0;
	bottom: 0;
	margin: 1px;
}
#config-box {
	position: fixed;
	left: 0;
	bottom: 0;
	margin: 1px;
	cursor: pointer;
	opacity: 0;
}
#config-box:hover {
	opacity: 1;
}
.table {
	margin: 0;
}
.table > tbody > tr:first-child > th, .table > tbody > tr:first-child > td {
	border: 0;
}
.label-switch {
	cursor: pointer;
}
.active-switch {
	background-color: #5bc0de;
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
var hideEffect, hideDuration, hideOptions;
var showEffect, showDuration, showOptions;

$(document).ready(function() {
	
	$.getJSON(imagepath + "data.json" ,function(data) {
		imageCount = data['imageCount'];
		imageMap = data['imageNameMap'];

		$("#firstNo").html(0);
		$("#endNo").html(imageCount-1);
		selectedNumber = parseInt(getlocalStorageItem("thumbnamils.currentImageIndex", getRandomInteger(0, imageCount)));

		resizeImage();
		setNextEffect();
		if (selectedNumber > -1)
			fnViewImage(selectedNumber);
		else
			fnRandomImageView();

		setInterval(function() {
			if (playSlide) {
				if (--playSec % playInterval == 0) {
					if (playMode.value == 1) {
						fnRandomImageView();
					}
					else { 
						fnNextImageView();
					}
					playSec = playInterval;
				}
				showTimer(playSec);
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
		$("body").css("background", "#000");
		$("#thumbnailDiv").css('height', '5px').hide();
		$(".progress").css("background-image", "linear-gradient(to bottom,#403a3a 0,#2f2626 100%)");
		$(".progress-bar").css("background", "#000");
		$(".label-info").css("background", "#000");
		$(".paging").hide();
	}
	else {
		$("body").css("background", "#fff");
		$("#thumbnailDiv").css('height', '105px').show('fade', {}, 1000);
		$(".progress").css("background-image", "linear-gradient(to bottom,#ebebeb 0,#f5f5f5 100%)");
		$(".progress-bar").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
		$(".label-info").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
		$(".paging").show();
	}
	$("#imageDiv").height(windowHeight - $("#thumbnailDiv").outerHeight() - 35);
}

function resizeSecondDiv() {
	resizeImage();
}

function resizeImage() {
	windowHeight = $(window).height();
	if (!playSlide) {
		fnDisplayThumbnail();
	}
	$("#imageDiv").height(windowHeight - $("#thumbnailDiv").outerHeight() - 35);
}

function setNextEffect() {
	if (effectMethod.value == 1) {
		hideEffect   = effects[getRandomInteger(0, effects.length-1)];
		hideDuration = getRandomInteger(100, 1000);
		if (hideEffect === "scale")
			hideOptions = { percent: getRandomInteger(10, 50) };
		else if (hideEffect === "size")
			hideOptions = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
		else
			hideOptions = {};
		showEffect   = effects[getRandomInteger(0, effects.length-1)];
		showDuration = getRandomInteger(100, 2000);
		if (showEffect === "scale")
			showOptions = { percent: getRandomInteger(10, 50) };
		else if (showEffect === "size")
			showOptions = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
		else
			showOptions = {};

		$(".effectInfo").show().html(hideEffect + "(" + hideDuration + ") ▷ " + showEffect + "(" + showDuration + ")");
	}
	else {
		hideEffect = "fade";
		hideDuration = 500;
		hideOptions = {};
		showEffect = "fade";
		showDuration = 500;
		showOptions = {};
		$(".effectInfo").hide();
	}
}

function fnViewImage(current) {
	selectedNumber = current;
	selectedImgUrl = imagepath + selectedNumber;
	
	setlocalStorageItem("thumbnamils.currentImageIndex", selectedNumber);

	$("#imageDiv").hide(hideEffect, hideOptions, hideDuration, function() {
		$("#leftNo").html(getPrevNumber());
		$("#currNo").html(selectedNumber);
		$("#rightNo").html(getNextNumber());
		$(".title").html(imageMap[selectedNumber]);
		$(this).css({
			backgroundImage: "url('" + selectedImgUrl + "')"
		}).show(showEffect, showOptions, showDuration, setNextEffect);

		if (!playSlide) {
			fnDisplayThumbnail();
		}	
	});
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
	windowWidth = $(window).width();
	var thumbnailRange = parseInt(windowWidth / (150 * 2));
	$("#thumbnailUL").empty();
	for (var current = selectedNumber - thumbnailRange; current <= selectedNumber + thumbnailRange; current++) {
		var thumbNo = current;
		if (thumbNo < 0 )
			thumbNo = imageCount + thumbNo;
		if (thumbNo >= imageCount)
			thumbNo = thumbNo - imageCount;
		$("<li>").append(
			$("<div>")
				.addClass("img-thumbnail" + (thumbNo == selectedNumber ? " active" : ""))
				.css({backgroundImage: "url('" + imagepath + thumbNo + "')"})
				.data("imgNo", thumbNo)
				.on("click", function() {
					fnViewImage($(this).data("imgNo"));
				})
		).appendTo($("ul#thumbnailUL"));
	}
}
function fnPlayImage() {
	playSlide = !playSlide;
	if (playSlide) { // start
		playSec = playInterval;
	}
	else { // stop
		showTimer(playInterval, "Play");
		fnDisplayThumbnail();
	}
	toggleSlideView();
}
function showTimer(sec, text) {
	if (text)
		$("#timer").html(text);
	else
		$("#timer").html(sec + "s");
	$("#timerBar").attr("aria-valuenow", sec).css("width", sec/playInterval*100 + "%");
}
</script>
</head>
<body>
	<div class="container-fluid">
		<div id="navDiv">
			<div class="progress" onclick="fnPlayImage();">
		  		<div id="timerBar" class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="10" aria-valuemin="0" aria-valuemax="10">
		  			<span id="timer">Play</span>
		  		</div>
		  	</div>
		  	<div>
				<span class="label label-info title"  onclick="fnFullyImageView();"></span>
		  	</div>
		</div>

		<div id="imageDiv"></div>

		<div id="thumbnailDiv"><ul id="thumbnailUL" class="list-inline"></ul></div>
		
		<div id="config-box">
			<img src="${PATH}/img/config.png" width="20px" data-toggle="modal" data-target="#configModal"/>
		</div>
		<div id="effectInfo-box">
			<span class="label label-info effectInfo" title="Next effect"></span>
		</div>
		
	</div>

	<div class="hide">
		<span class="label label-info paging" onclick="fnFirstImageView();"><span id="firstNo"></span></span>
		<span class="label label-info paging" onclick="fnPrevImageView();"><i class="glyphicon glyphicon-menu-left"></i><span id="leftNo"></span></span>
		<span class="label label-info paging"><span id="currNo"></span></span>
		<span class="label label-info paging" onclick="fnNextImageView();"><span id="rightNo"></span><i class="glyphicon glyphicon-menu-right"></i></span>
		<span class="label label-info paging" onclick="fnEndImageView();"><span id="endNo"></span></span>
	</div>
	
	<div id="configModal" class="modal fade" role="dialog">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<h4 class="modal-title">Configuration</h4>
				</div>
				<div class="modal-body">
					<table class="table">
						<tr>
							<th>Effect</th>
							<td>
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="effectMethod">Fadein</span>
								<input type="range" role="switch" id="effectMethod" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="effectMethod">Random</span>
							</td>
						</tr>
						<tr>
							<th>Play mode</th>
							<td>
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="playMode">Sequencial</span>
								<input type="range" role="switch" id="playMode" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="playMode">Random</span>
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
						Effect   <span class="label label-info effectMethod"></span> 
						Play     <span class="label label-info playMode"></span>
						Interval <span class="label label-info interval"></span>
						<button class="btn btn-plain btn-sm float-right" onclick="shuffle()">Shuffle</button>
					</div>
				</div>
			</div>
			<script type="text/javascript">
			$("[data-role='switch']").on('click', function() {
				var target = $(this).attr("data-target");
				var value  = $(this).attr("data-value");
				var text   = $(this).text();
				$("#" + target).val(value);
				$("." + target).html(text);
				$("[data-target='" + target + "']").removeClass("active-switch");
				$(this).addClass("active-switch");
			});
			$("input[type='range'][role='switch']").on('click', function() {
				var value = $(this).val();
				var target = $(this).attr("id");
				$("[data-target='" + target + "'][data-value='" + value + "']").click();
			});
			$("#interval").on('click', function() {
				$(".interval").html($(this).val());
				playInterval = $(this).val();
				$("#timerBar").attr({
					"aria-valuemax": playInterval 
				});
			});
			function shuffleOnce() {
				$("[data-target='effectMethod'][data-value='" + getRandomInteger(0, 1) + "']").click();
				$("[data-target='playMode'][data-value='" + getRandomInteger(0, 1) + "']").click();
				$("#interval").val(getRandomInteger(5, 20)).click();
			}
			function shuffle() {
				var count = 0;
				var maxShuffle = getRandomInteger(3, 9);
			 	showSnackbar("shuffle start", 1000);
				var shuffler = setInterval(function() {
					shuffleOnce();
					if (++count > maxShuffle) {
					 	clearInterval(shuffler);
					 	showSnackbar("shuffle completed. try " + maxShuffle, 1000);
					}
				}, 500);
			}
			shuffleOnce();
			</script>
		</div>
	</div>

</body>
</html>
