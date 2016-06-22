<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title><s:message code="image.image-viewer"/></title>
<style type="text/css">
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
</style>
<script type="text/javascript">
var imagepath = '<s:url value="/image/" />';
var selectedNumber;
var selectedImgUrl;
var imageCount;
var windowWidth  = $(window).width();
var windowHeight = $(window).height();
var imageMap;

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

	});
	
	$(window).bind("mousewheel DOMMouseScroll", function(e) {
		var delta = 0;
		var event = window.event || e;
		if (event.wheelDelta) {
			delta = event.wheelDelta/120;
			if (window.opera) delta = -delta;
		} 
		else if (event.detail)  
			delta = -event.detail/3;
		else
			delta = parseInt(event.originalEvent.wheelDelta || -event.originalEvent.detail);
		if (delta) {
			if (delta > 0) 
				fnPrevImageView(); //alert("마우스 휠 위로~");
		    else 	
				fnNextImageView(); //alert("마우스 휠 아래로~");
		}
		//alert("event=" + event + " delta=" + delta);
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
	$("#imageDiv").bind("click", function(e){
		var event = window.event || e;
		//alert(event.type + " - " + event.button + ", keyValue=" + event.keyCode);
		event.stopImmediatePropagation();
		event.preventDefault();
		event.stopPropagation();
		if(event.button == 0) {
			fnNextImageView();
		} 
	});
	$(window).bind("resize", resizeImage);
	
});

function resizeImage() {
	windowHeight = $(window).height();
	$("#imageDiv").height(windowHeight - $("#thumbnailDiv").outerHeight() - 35);
	fnDisplayThumbnail();
}

function fnViewImage(current) {
	var prevNumber = selectedNumber;
	selectedNumber = current;
	selectedImgUrl = imagepath + selectedNumber;

	if (prevNumber - selectedNumber < 0) { // move forward
		$("#imageDiv").hide("slow", function() {
			$(this).css("background-image", "url('" + selectedImgUrl + "')");
		});
//		$("#imageDiv").slideUp("slow", function() {
//			$(this).css("background-image", "url('" + selectedImgUrl + "')");
//		});
//		$("#imageDiv").slideDown("slow");
		$("#imageDiv").fadeIn("slow");
	}
	else { // move backward
		$("#imageDiv").fadeOut("slow", function() {
			$(this).css("background-image", "url('" + selectedImgUrl + "')");
		});
		$("#imageDiv").show("slow");
	}

	$("#leftNo").html(getPrevNumber());
	$("#currNo").html(selectedNumber);
	$("#rightNo").html(getNextNumber());
	$("#imageTitle").html(imageMap[selectedNumber]);
	fnDisplayThumbnail();
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
	var thumbnailRange = parseInt(parseInt($(window).width() / 200) / 2);
	$("#thumbnailUL").empty();
	for (var current = selectedNumber - thumbnailRange; current <= selectedNumber + thumbnailRange; current++) {
		var thumbNo = current;
		if (thumbNo < 0 )
			thumbNo = imageCount + thumbNo;
		if (thumbNo >= imageCount)
			thumbNo = thumbNo - imageCount;
		var li = $("<li>");
		var div = $("<div class='img-thumbnail " + (thumbNo == selectedNumber ? "active" : "") + "' onclick='fnViewImage("+thumbNo+")'>");
		div.css("background-image", "url('" + imagepath + thumbNo + "" + "')");
		li.append(div);
		$("#thumbnailUL").append(li);
	}
}
</script>
</head>
<body>
<div class="container-fluid">

<div id="navDiv">
	<span class="label label-info" onclick="fnFirstImageView();"><span id="firstNo"></span></span>
	<span class="label label-info" onclick="fnPrevImageView();"><i class="glyphicon glyphicon-menu-left"></i><span id="leftNo"></span></span>
	<span class="label label-info"><span id="currNo"></span></span>
	<span class="label label-info" onclick="fnNextImageView();"><span id="rightNo"></span><i class="glyphicon glyphicon-menu-right"></i></span>
	<span class="label label-info" onclick="fnEndImageView();"><span id="endNo"></span></span>
	&nbsp;
	<span class="label label-info" id="imageTitle" onclick="fnFullyImageView();"></span>
</div>
<div id="imageDiv"></div>
<div id="thumbnailDiv"><ul id="thumbnailUL" class="list-inline"></ul></div>

</div>
</body>
</html>
