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
}
input[type='range'] {
	box-shadow: rgba(255, 255, 255, 0) 0px 0px 5px 1px inset;
}
span.input-group-addon {
    background-color: transparent;
    border: 0;
    color: #fff !important;
    font-weight: bold;
	text-shadow: 0px 0px 5px #0c0c0c;
}
.img-title {
	color: #fff;
	text-shadow: 0px 0px 5px #0c0c0c;
}
</style>
<script type="text/javascript">
bgContinue = false;
var storageItemIndexName;
var storageItemWidthName;
var storageItemHeightName;
var currentIndex = 0;
var itemCount = 0;
var itemMap;
var imageCount = 0;
var imageMap;
var coverCount = 0;
var coverMap;
var lastPage = false;
var imageSizePerPage = 50;
var displaycount = 0;
var mode;
var url = '${PATH}/image/data.json';
var param;
var scrollBottomChecker;

$(document).ready(function() {

	mode = getLocalStorageItem(THUMBNAMILS_MODE, "image");
	$("input:radio[name='mode'][value='" + mode + "']").attr("checked", true).parent().addClass("active");
	
	$("input:radio[name='mode']").on('change', fnToggleBtnMode);
	fnToggleBtnMode();

	$("#content_div").scroll(function() {
		if (fnIsScrollBottom())
			render();
	});

	$("#delete").on("click", function() {
		var thisValue = $(this).data("checked");
		setLocalStorageItem(THUMBNAMILS_BTN_DELETE, thisValue);
		if (mode === 'image') {
			$(".close").toggleClass("hide", !thisValue);
			$(".img-title").toggleClass("hide", !thisValue);
		}
	});
	if (getLocalStorageItem(THUMBNAMILS_BTN_DELETE, false) === 'true') {
		$("#delete").click();	
	}

	$("#magnify").on("click", function() {
		setLocalStorageItem(THUMBNAMILS_BTN_MAGNIFY, $(this).data("checked"));
	});
	if (getLocalStorageItem(THUMBNAMILS_BTN_MAGNIFY, false) === 'true') {
		$("#magnify").click();	
	}

	fnSetOption();
});

function fnToggleBtnMode() {
	mode = $("input:radio[name='mode']:checked").val();
	console.log("fnToggleBtnMode mode", mode);
	
	if (mode === 'cover') {
		param =  "m=c";
		storageItemIndexName  = THUMBNAMILS_COVER_INDEX;
		storageItemWidthName  = THUMBNAMILS_COVER_WIDTH;
		storageItemHeightName = THUMBNAMILS_COVER_HEIGHT;
		if (coverCount == 0) 
			requestData();
		itemCount = coverCount;
		itemMap   = coverMap;
	}
	else {
		param = "";
		storageItemIndexName  = THUMBNAMILS_IMAGE_INDEX;
		storageItemWidthName  = THUMBNAMILS_IMAGE_WIDTH;
		storageItemHeightName = THUMBNAMILS_IMAGE_HEIGHT;
		if (imageCount == 0)
			requestData();
		itemCount = imageCount;
		itemMap   = imageMap;
	}
	
	currentIndex  = parseInt(getLocalStorageItem(storageItemIndexName, getRandomInteger(0, itemCount-1)));
	var imgWidth  = getLocalStorageItem(storageItemWidthName, 100);
	var imgHeight = getLocalStorageItem(storageItemHeightName, 100);
	
	$("#img-width").val(imgWidth);
	$("#img-height").val(imgHeight);
	$(".addon-width" ).html("W " + imgWidth);
	$(".addon-height").html("H " + imgHeight);

	$("ul#thumbnailUL").empty();
	displaycount = 0;
	render();

	clearInterval(scrollBottomChecker);
	scrollBottomChecker = setInterval(function() {
		if (fnIsScrollBottom())
			render();
	}, 3000);

	setLocalStorageItem(THUMBNAMILS_MODE, mode);
}

function requestData() {
	console.log("requestData start");
	$.ajax({
		type: 'GET',
		url: url,
		data: param,
		async: false
	}).done(function(data, textStatus, jqXHR) {
		itemCount = data['imageCount'];
		itemMap   = data['imageNameMap'];
		if (mode === 'cover') {
			coverCount = itemCount;
			coverMap   = itemMap;
		}
		else {
			imageCount = itemCount;
			imageMap   = itemMap;
		}
		console.log("requestData done");
	});
	console.log("requestData end");
}

function fnIsScrollBottom() {
	var containerHeight    = $("#content_div").height();
	var containerScrollTop = $("#content_div").scrollTop();
	var documentHeight     = $("#thumbnailUL").height();
	var scrollMargin       = $("#thumbnailUL > li").height();
//	console.log("fnIsScrollBottom", containerHeight + ' + ' + containerScrollTop + ' = ' + (containerHeight + containerScrollTop), ' > ', documentHeight + ' - ' + scrollMargin + ' = ' + (documentHeight - scrollMargin), "lastPage=", lastPage);
	return (containerHeight + containerScrollTop > documentHeight - scrollMargin) && !lastPage;
}

function render() {
	$(".total-count").html("T " + itemCount);
	$(".current-index").html("I " + currentIndex);
	$(".debug").html("render..." + currentIndex).show().hide("fade", {}, 2000);
	console.log("render..." + currentIndex);

	setLocalStorageItem(storageItemIndexName, currentIndex);
	
	var showDelete = ($("#delete").data("checked") && mode === 'image') ? "" : "hide";
	
	var start = currentIndex;
	var end = start + imageSizePerPage;
	for (var i=start; i<end; i++) {

		var imgSrc = mode === 'cover' ? "${PATH}/video/" + itemMap[i] + "/cover" : "${PATH}/image/" + i;
		var imgTitle = mode === 'cover' 
				? '<a onclick="fnVideoDetail(\'' + itemMap[i] + '\')" href="#">' + itemMap[i] + '</a>'
				: '<a href="${PATH}/image/' + i + '" target="image-' + i + '">' + itemMap[i] + '</a>';
			
		$("ul#thumbnailUL").append(
			$("<li>").addClass("img-thumbnail").append(
				$("<a>").attr({
					'href': imgSrc,
					'data-lightbox': 'lightbox-set',
					'data-title': imgTitle,
					'data-index': i,
					'data-type': mode
				}).append(
					$("<div>").addClass("nowrap").data("src", imgSrc).css({
						backgroundImage: "url('" + imgSrc + "')"
					}).append(
						$("<span>").addClass("close " + showDelete).html("&times;").on("click", function(event) {
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
						$("<small>").addClass("img-title " + showDelete).html(itemMap[i])
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
		currentIndex = i;
		if ((currentIndex + 1) >= itemCount) {
			console.log("approached last page", i);
			currentIndex = -1;
			break;
		}
	}
	currentIndex++;
	$(".display-count").html("D " + displaycount);

}

function resize() {
	var imgWidth  = $("#img-width").val();
	var imgHeight = $("#img-height").val();
	$("#thumbnailUL > li").css({
		width: imgWidth,
		height: imgHeight
	});
	$(".debug").html("Size : " + imgWidth + " x " + imgHeight).show().hide("fade", {}, 3000);
	$(".addon-width" ).html("W " + imgWidth);
	$(".addon-height").html("H " + imgHeight);
	
	setLocalStorageItem(storageItemWidthName,  imgWidth);
	setLocalStorageItem(storageItemHeightName, imgHeight);
}
function fnSetOption() {
	lightbox.option({
		showImageNumberLabel: false,
		resizeDuration: 300,
      	fadeDuration: 300,
      	imageFadeDuration: 300,
      	randomImageEffect: false,
      	disableScrolling: true
    });
}
</script>
</head>
<body>

	<div id="header_div" class="box form-inline">
		<label class="title">
			<s:message code="video.thumbnails"/>
		</label>
		
		<div class="btn-group btn-group-xs btn-mode" data-toggle="buttons">
			<a class="btn btn-default" data-toggle="tab" data-target="#imageTab"><input type="radio" name="mode" value="image">Image</a>
			<a class="btn btn-default" data-toggle="tab" data-target="#coverTab"><input type="radio" name="mode" value="cover">Cover</a>
		</div>
		
		
		<div class="input-group input-group-xs">
			<span class="input-group-addon addon-width">Width</span>
			<input type="range" id="img-width"  class="form-control" min="100" max="800" value="120" step="50" onchange="resize()"/>
		</div>
		<div class="input-group input-group-xs">
			<span class="input-group-addon addon-height">Height</span>
			<input type="range" id="img-height" class="form-control" min="100" max="800" value="100" step="50" onchange="resize()"/>
		</div>
		<span class="label label-primary total-count"   title="Total"></span>
		<span class="label label-primary display-count" title="Display"></span>
		<span class="label label-primary current-index" title="Index"></span>
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
