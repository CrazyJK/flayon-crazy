<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title><s:message code="video.thumbnails"/></title>
<link rel="stylesheet" href="${PATH}/css/lightbox.css">
<style type="text/css">
body {
	overflow: hidden;
}
#content_div {
	
}
#thumbnailDiv {
    text-align: center;
}
#thumbnailUL > li {
	margin: 0 3px  3px 0;
	padding: 4px;
	width: 120px;
	height: 100px;
	background-color: transparent;
	transition: all .5s;
}
#thumbnailUL > li > a {
	width: 100%;
	height: 100%;
	text-decoration: none;
}
#thumbnailUL > li > a > div {
	width: 100%;
	height: 100%;
	background-repeat: no-repeat;
    background-size: contain;
    background-position: center center;
    background-color: rgba(255,255,255,.25);
}
.box-hover {
	transform: scale(1.5, 1.5);
	box-shadow: 0 0 9px 6px rgba(255, 0, 0, 0.5) !important;
}
input[type='range'] {
	box-shadow: rgba(255, 255, 255, 0) 0px 0px 5px 1px inset;
}
span.input-group-addon {
    background-color: transparent;
    border: 0;
    color: #337ab7 !important;
    font-weight: bold;
}
</style>
<script type="text/javascript">
bgContinue = false;
var selectedNumber;
var imageCount;
var imageMap;
var lastPage = false;
var imageSizePerPage = 50;
var displaycount = 0;

$(document).ready(function() {
	var imgWidth  = getlocalStorageItem("thumbnamils.img-width", 120);
	var imgHeight = getlocalStorageItem("thumbnamils.img-height", 100);
	$("#img-width").val(imgWidth);
	$("#img-height").val(imgHeight);
	$(".addon-width" ).html("W " + imgWidth);
	$(".addon-height").html("H " + imgHeight);

	$.getJSON("${PATH}/image/data.json" ,function(data) {
		imageCount = data['imageCount'];
		imageMap = data['imageNameMap'];
		
		selectedNumber = parseInt(getlocalStorageItem("thumbnamils.currentImageIndex", getRandomInteger(0, imageCount-1)));
		
		render();
		
		setInterval(function() {
			if (fnIsScrollBottom())
				render();
		}, 3000);
	});

	$("#content_div").scroll(function() {
		if (fnIsScrollBottom())
			render();
	});

	$("#delete").on("click", function() {
		var thisValue = $(this).data("checked");
		setlocalStorageItem("thumbnamils.close", thisValue);
		$(".close").toggleClass("hide", !thisValue);
		$(".img-title").toggleClass("hide", !thisValue);
	});
	
	$("#magnify").on("click", function() {
		setlocalStorageItem("thumbnamils.magnify", $(this).data("checked"));
	});
	var magnifyValue = getlocalStorageItem("thumbnamils.magnify", false) === 'true';
	if (magnifyValue) {
		$("#magnify").click();	
	}

	fnSetOption();
});

function fnIsScrollBottom() {
	var containerHeight    = $("#content_div").height();
	var containerScrollTop = $("#content_div").scrollTop();
	var documentHeight     = $("#thumbnailUL").height();
	var scrollMargin       = $("#thumbnailUL > li").height();
//	console.log("fnIsScrollBottom", containerHeight + ' + ' + containerScrollTop + ' = ' + (containerHeight + containerScrollTop), ' > ', documentHeight + ' - ' + scrollMargin + ' = ' + (documentHeight - scrollMargin), "lastPage=", lastPage);
	return (containerHeight + containerScrollTop > documentHeight - scrollMargin) && !lastPage;
}

function render() {
	$(".total-count").html("T " + imageCount);
	$(".current-index").html("I " + selectedNumber);
	$(".debug").html("render..." + selectedNumber).show().hide("fade", {}, 2000);
	console.log("render..." + selectedNumber);

	setlocalStorageItem("thumbnamils.currentImageIndex", selectedNumber);

	var start = selectedNumber;
	var end = start + imageSizePerPage;
	for (var i=start; i<end; i++) {
		$("ul#thumbnailUL").append(
			$("<li>").addClass("img-thumbnail").append(
				$("<a>").attr({
					'href': "${PATH}/image/" + i,
					'data-lightbox': 'lightbox-set',
					'data-title': "<a href='${PATH}/image/" + i + "' target='image-" + i + "'>" + imageMap[i] + "</a>",
					'data-index': i
				}).append(
					$("<div>").addClass("nowrap").data("src", "${PATH}/image/" + i).css({
						backgroundImage: "url('${PATH}/image/" + i + "')"
					}).append(
						$("<span>").addClass("close hide").html("&times;").on("click", function(event) {
							event.stopPropagation();
							// console.log("delete ", $(this).parent().data("src"));
							var imgSrc = $(this).parent().data("src");
							if (confirm('Delete this image\n' + imgSrc)) {
								$(this).parent().parent().parent().hide("fade", {}, 500);
								actionFrame(imgSrc, {}, "DELETE", "this image delete");
							}
							return false;
						})
					).append(
						$("<small>").addClass("img-title hide").html(imageMap[i])
					)
				)
			).hover(
				function(event) {
					if ($("#magnify").data("checked")) {
						$(this).addClass("box-hover");
					}
				}, function() {
					if ($("#magnify").data("checked")) {
						$(this).removeClass("box-hover");
					}
				}
			).css({
				width: $("#img-width").val(),
				height: $("#img-height").val()
			}).attr({
				dataIndex: i
			})
		);
		displaycount++;
		selectedNumber = i;
		if ((selectedNumber + 1) >= imageCount) {
			console.log("approached last page", i);
			selectedNumber = -1;
			break;
		}
	}
	selectedNumber++;
	$(".display-count").html("D " + displaycount);

}

function resize() {
	var imgWidth  = $("#img-width").val();
	var imgHeight = $("#img-height").val();
	$("#thumbnailUL > li").css({
		width: imgWidth,
		height: imgHeight
	});
	setlocalStorageItem("thumbnamils.img-width",  imgWidth);
	setlocalStorageItem("thumbnamils.img-height", imgHeight);
	$(".debug").html("Size : " + imgWidth + " x " + imgHeight).show().hide("fade", {}, 3000);
	$(".addon-width" ).html("W " + imgWidth);
	$(".addon-height").html("H " + imgHeight);
}
function fnSetOption() {
	lightbox.option({
		showImageNumberLabel: false,
		resizeDuration: 300,
      	fadeDuration: 300,
      	imageFadeDuration: 300,
      	randomImageEffect: true,
      	disableScrolling: true
    });
	playInterval = parseInt($("#playInterval").val());
	playMode = $('input:radio[name="playMode"]:checked').val();
	$("#timerBar").attr("aria-valuemax", playInterval);
}
</script>
</head>
<body>

	<div id="header_div" class="box form-inline">
		<label class="title">
			<s:message code="video.thumbnails"/>
		</label>
		<div class="input-group input-group-xs">
			<span class="input-group-addon addon-width">Width</span>
			<input type="range" id="img-width"  class="form-control" min="100" max="400" value="120" step="10" onchange="resize()"/>
		</div>
		<div class="input-group input-group-xs">
			<span class="input-group-addon addon-height">Height</span>
			<input type="range" id="img-height" class="form-control" min="100" max="400" value="100" step="10" onchange="resize()"/>
		</div>
		<span class="label label-primary total-count"></span>
		<span class="label label-primary display-count"></span>
		<span class="label label-primary current-index"></span>
   		<span class="label label-default" id="magnify"  role="checkbox" data-role-value="false" title="active magnify">Magnify</span>
   		<span class="label label-default" id="delete"   role="checkbox" data-role-value="false" title="active delete mode">Delete</span>
		<span class="label label-warning debug"></span>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<div id="thumbnailDiv">
			<ul id="thumbnailUL" class="list-inline">
			</ul>
		</div>
	</div>

	<script src="${PATH}/js/lightbox.js"></script>
</body>
</html>
