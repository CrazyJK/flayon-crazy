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
#config-box {
	position: fixed;
	left: 0;
	bottom: 0;
	opacity: 0;
}
#config-box:hover {
	opacity: 1;
}
.table {
	margin: 0;
}
.table > tbody > tr:first-child > th,
.table > tbody > tr:first-child > td {
	border: 0;
}
.label-switch {
	cursor: pointer;
}
.active-switch {
	background-color: #5bc0de;
/* 	box-shadow: 0 0px 8px rgba(102,175,233,1),0 0 8px rgba(102,175,233,1) inset; */
}
.ui-effects-transfer { border: 2px dotted gray; }
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
		imageCount = data['imageCount'];
		imageMap = data['imageNameMap'];

		selectedNumber = parseInt(getlocalStorageItem("thumbnamils.currentImageIndex", getRandomInteger(0, imageCount)));

		resizeImage();
		if (selectedNumber > -1)
			fnViewImage(selectedNumber);
		else
			fnRandomImageView();
		$("#firstNo").html(0);
		$("#endNo").html(imageCount-1);

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
	if (effectMethod.value == 1) {
		hideEffect   = effects[getRandomInteger(0, effects.length-1)];
		hideDuration = getRandomInteger(100, 1000);
		showEffect   = effects[getRandomInteger(0, effects.length-1)];
		showDuration = getRandomInteger(100, 2000);
		$(".effectInfo").show().html("hide: " + hideEffect + "(" + hideDuration + "), show: " + showEffect + "(" + showDuration + ")");
	}
	else {
		hideEffect = "fade";
		hideDuration = 500;
		showEffect = "fade";
		showDuration = 500;
		$(".effectInfo").hide();
	}
}

function fnViewImage(current) {
	var prevNumber = selectedNumber;
	selectedNumber = current;
	selectedImgUrl = imagepath + selectedNumber;
	
	setlocalStorageItem("thumbnamils.currentImageIndex", selectedNumber);

	var hideOptions = {};
	if (hideEffect === "scale")
		hideOptions = { percent: 50 };
	else if (hideEffect === "size")
		hideOptions = { to: { width: 280, height: 185 } };
	var showOptions = {};
	if (showEffect === "scale")
		showOptions = { percent: 50 };
	else if (showEffect === "size")
		showOptions = { to: { width: 280, height: 185 } };

	$("#imageDiv").hide(hideEffect, hideOptions, hideDuration, function() {
		$("#leftNo").html(getPrevNumber());
		$("#currNo").html(selectedNumber);
		$("#rightNo").html(getNextNumber());
		$(".title").html(imageMap[selectedNumber]);
		$(this).css("background-image", "url('" + selectedImgUrl + "')").show(showEffect, showOptions, showDuration, setNextEffect);

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
			<span class="label label-info paging" onclick="fnFirstImageView();"><span id="firstNo"></span></span>
			<span class="label label-info paging" onclick="fnPrevImageView();"><i class="glyphicon glyphicon-menu-left"></i><span id="leftNo"></span></span>
			<span class="label label-info paging"><span id="currNo"></span></span>
			<span class="label label-info paging" onclick="fnNextImageView();"><span id="rightNo"></span><i class="glyphicon glyphicon-menu-right"></i></span>
			<span class="label label-info paging" onclick="fnEndImageView();"><span id="endNo"></span></span>
			<span class="label label-info title"  onclick="fnFullyImageView();"></span>
			<span class="label label-info effectInfo" title="Next effect"></span>
		
			<div class="progress" style="width: 100px; margin: 5px 0px; z-index: 18;" onclick="fnPlayImage();">
		  		<div id="timerBar" class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="10"
		  			aria-valuemin="0" aria-valuemax="10" style="width:100%"><span id="timer">Play</span></div></div>
		</div>

		<div id="imageDiv"></div>
		
		<div id="thumbnailDiv"><ul id="thumbnailUL" class="list-inline"></ul></div>
		
		<div id="config-box">
			<img src="${PATH}/img/config.png" width="20px" data-toggle="modal" data-target="#configModal"/>
		</div>
		<div id="configModal" class="modal fade" role="dialog">
			<div class="modal-dialog">

				<!-- Modal content-->
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
	</div>
</body>
</html>
