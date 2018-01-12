<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Image Series</title>
<style type="text/css">
body {
	background-color: #000;
}
.container-series {
}
#imageInfo {
	position: fixed;
	left: 0;
	bottom: 0;
	margin: 5px;
}
#imageDiv {
	margin: 30px 10px;
	text-align: center;
}
.img-series {
	position: fixed;
}
</style>
<script type="text/javascript">
bgContinue = false;
$(function() {
	series.init();
});

var series = (function() {
	var imageCount = 0;
	var MARGIN_TOP = 30, MARGIN_LEFT = 10;
	var fn = {
			init: function() {
				$("#imageDiv").height($(window).height() - MARGIN_TOP * 2);
			},
			event: function() {	
				$(window).navEvent(function(signal) {
					switch(signal) {
					case 39:
						fn.next()
						break;
					}
				});
			},
			start: function() {
				restCall(PATH + '/rest/image/count', {}, function(count) {
					imageCount = count;
					fn.next();
				});
			},
			next: function() {
				var index = getRandomInteger(0, imageCount-1);

				var preloader = new Image();
				preloader.onload = function() {
					var $imageDiv = $("#imageDiv");					
					var position = fn.position.calc($imageDiv.width(), $imageDiv.height(), preloader.width, preloader.height, MARGIN_LEFT, MARGIN_TOP, 0.9);
					
					$("<img>", {src: preloader.src})
					.addClass("img-responsive img-thumbnail img-series")
					.animate(position)
					.appendTo($imageDiv);

				};
				preloader.src = PATH + "/image/" + index;
				this.displayInfo(index);
			},
			displayInfo: function(index) {
				restCall(PATH + '/rest/image/info/' + index, {showLoading: false}, function(info) {
					$("#index").html(index);
					$("#name").html(info.name);
					$("#path").html(info.path);
					$("#length").html(formatFileSize(info.length));
					$("#modified").html(new Date(info.modified).format('yyyy-MM-dd hh:mm'));
				});
			},
			position: {
				calc: function(divWidth, divHeight, originalWidth, originalHeight, offsetLeft, offsetTop, ratio) {
					var imgWidth  = originalWidth;
					var imgHeight = originalHeight;
					var imgLeft   = offsetLeft;
					var imgTop    = offsetTop;
					if (divHeight < imgHeight) { // 이미지 높이가 더 크면
						imgHeight = divHeight * ratio;
						imgWidth = imgHeight * originalWidth / originalHeight;
					}
					if (divWidth < imgWidth) { // 이미지 넓이가 더 크면
						imgWidth = divWidth * ratio;
						imgHeight = imgWidth * originalHeight / originalWidth;
					}
					if (divHeight > imgHeight) { // 이미지 높이가 작으면
						imgTop += getRandomInteger(0, divHeight - imgHeight);
					}
					if (divWidth > imgWidth) { // 이미지 넓이가 작으면
						imgLeft += getRandomInteger(0, divWidth - imgWidth);
					}
					//console.log("position", imgWidth, imgHeight, imgLeft, imgTop);
					return {
						width:  Math.floor(imgWidth),
						height: Math.floor(imgHeight),
						left:   Math.floor(imgLeft),
						top:    Math.floor(imgTop)
					};
				}
			},
	};
	
	return {
		init : function() {
			fn.init();
			fn.event();
			fn.start();
		}
	};
	
}());
</script>
</head>
<body>
	<div class="container-fluid container-series">
		<div id="imageInfo">
			<span id="index" class="label label-black"></span>
			<span id="name" class="label label-black"></span>
			<span id="path" class="label label-black"></span>
			<span id="length" class="label label-black"></span>
			<span id="modified" class="label label-black"></span>
		</div>
		<div id="imageDiv"></div>
	</div>
</body>
</html>