<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Thumbnails</title>
<style type="text/css">
#content_div {
	
}
#thumbnailDiv {
    text-align: center;
}
#thumbnailUL > li {
	margin: 0 3px;
	padding: 4px;
	width: 120px;
	height: 100px;
	transition: all .5s;
}
#thumbnailUL > li > div {
	width: 100%;
	height: 100%;
	background-repeat: no-repeat;
    background-size: contain;
    background-position: center center;
    background-color: rgba(255,255,255,.5);
}
.box-hover {
	transform: scale(1.5, 1.5);
	box-shadow: 0 0 9px 6px rgba(255, 0, 0, 0.5) !important;
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
	
	$("input[type='range']").css({
		boxShadow: "rgba(255, 255, 255, 0.5) 0px 0px 5px 1px inset"	
	});
	
	$("#img-width").val(getlocalStorageItem("thumbnamils.img-width", 120));
	$("#img-height").val(getlocalStorageItem("thumbnamils.img-height", 100));
	
	$.getJSON("${PATH}/image/data.json" ,function(data) {
		imageCount = data['imageCount'];
		imageMap = data['imageNameMap'];
		
		selectedNumber = parseInt(getlocalStorageItem("thumbnamils.currentImageIndex", getRandomInteger(0, imageCount)));
		
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
	});
	
	$("#magnify").on("click", function() {
		setlocalStorageItem("thumbnamils.magnify", $(this).data("checked"));
	});
	var magnifyValue = getlocalStorageItem("thumbnamils.magnify", false) === 'true';
	if (magnifyValue) {
		$("#magnify").click();	
	}
	
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
				$("<div>").data("src", "${PATH}/image/" + i).css(
					{
						backgroundImage: "url('${PATH}/image/" + i + "')"
					}
				).on("click", function() {
					// console.log("image click");
					popupImage($(this).data("src"));
				}).append(
					$("<span>").addClass("close hide").html("&times;").on("click", function(event) {
						event.stopPropagation();
						// console.log("delete ", $(this).parent().data("src"));
						var imgSrc = $(this).parent().data("src");
						if (confirm('Delete this image\n' + imgSrc)) {
							$(this).parent().parent().hide("fade", {}, 500);
							actionFrame(imgSrc, {}, "DELETE", "this image delete");
						}
					})
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
			})
		);
		displaycount++;
		selectedNumber = i;
		if ((selectedNumber + 1) === imageCount) {
			console.log("approached last page");
			selectedNumber = 0;
			render();
		}
	}
	selectedNumber++;
	$(".display-count").html("D " + displaycount);

}

function resize() {
	$("#thumbnailUL > li").css({
		width: $("#img-width").val(),
		height: $("#img-height").val()
	});

	setlocalStorageItem("thumbnamils.img-width",  $("#img-width").val());
	setlocalStorageItem("thumbnamils.img-height", $("#img-height").val());
	
}

</script>
</head>
<body>

	<div id="header_div" class="box form-inline">

		<span class="label label-info">Width</span>
		<input type="range" id="img-width"  class="form-control input-sm input-range" min="100" max="400" value="120" onmouseup="resize()"/>
		<span class="label label-info">Height</span>
		<input type="range" id="img-height" class="form-control input-sm input-range" min="100" max="400" value="100" onmouseup="resize()"/>
	
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

</body>
</html>
