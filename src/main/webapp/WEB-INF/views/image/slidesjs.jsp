<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="image.image-viewer"/> by SlidesJS</title>
<style type="text/css">
.slides {
	width:100%;
	margin:50px 0 0 0;
	text-align: center;
}
.slidesjs-container {
	margin-bottom: 10px;
}
.slidesjs-control {
}
.slidesjs-slide {
	border-radius: 10px;
}

.slidesjs-navigation {
	font-size: 15px;
	background-color:rgba(255, 255, 255, 0.5); 
	color:black; 
	text-shadow:1px 1px 1px white; 
	padding:0px 5px 0px 5px;
	border:1px solid orange; 
	border-radius: 5px;
	text-decoration:none;
}
.slidesjs-navigation:hover {
	text-decoration:none;
}
.slidesjs-previous {
	display: none;
	float:left;
}
.slidesjs-next {
	display: none;
	float:right;
}
.slidesjs-play,
.slidesjs-stop {
	position: absolute;
	top: 0;
	left: 0;
	margin: 10px;
	z-index: 18;
}

ul.slidesjs-pagination {
	position: fixed;
	top:0;
	text-shadow: 1px 1px 1px red;
	margin: 10px;
	padding-left: 50px;
}
li.slidesjs-pagination-item {
	display:inline-block;
}
li.slidesjs-pagination-item:first-child {
	margin-right: 10px;
}
li.slidesjs-pagination-item:last-child {
	margin-left: 10px;
}
li.slidesjs-pagination-item a {
	background-color:rgba(255, 255, 255, 0.5); 
	text-shadow:1px 1px 1px white; 
	padding:0px 5px 0px 5px;
	border:1px solid orange;
	border-radius: 5px;
	text-decoration:none;
	margin: 3px;
	color:black;
	width: 30px;
	font-size: 12px;
}
li.slidesjs-pagination-item a.active {
	padding: 5px;
	margin: 3px;
	text-decoration:none;
	color:#7d8ee2;
}
li.slidesjs-pagination-item a:hover {
	text-shadow:1px 1px 1px #7d8ee2;
}
.bg-image {
	height: 300px; 
	background-position: center center; 
	background-size: contain; 
	background-repeat: no-repeat;
}
#debug {
position: absolute;
    top: 0;
    left: 20px;
    margin: 0;
    padding: 0;
    z-index: 99;
}
</style>
<script src="http://slidesjs.com/examples/standard/js/jquery.slides.min.js"></script>
<script type="text/javascript">
var imagepath = '<s:url value="/image/" />';
var selectedNumber;
var selectedImgUrl;
var imageCount;
var windowWidth  = $(window).width();
var windowHeight = $(window).height();
var navHeight = 80;

$(document).ready(function(){
	$(function() {
		
		$.getJSON(imagepath + "data.json" ,function(data) {
			selectedNumber = data['selectedNumber'];
			imageCount = data['imageCount'];
			//imageMap = data['imageNameMap'];

			for (var i=0; i<imageCount; i++) {
				var imageDiv = $("<div>").addClass("bg-image").height(windowHeight - navHeight); //.css({"background-image": "url(" + imagepath + i + ")", "display": "none"});
				$('#slides').append(imageDiv);
			}
			
			$('#slides').slidesjs({
				start: selectedNumber == -1 ? getRandomInteger(0, imageCount) : selectedNumber,
				    width: windowWidth,
				    height: windowHeight - navHeight,
			    navigation: {active: true},
			    /* pagination: false, */
			    play: {active: true, interval:5000, auto: false},
			    callback: {
			    	loaded: function(number) {
				    		//debug("loaded callback : " + number);	 
			    		rePagination();
			    	},
			    	start: function(number) {
				    		//debug("start callback : " + number);	        
			    		rePagination();
			    	},
			    	complete: function(number) {
				    		//debug("complete callback : " + number);
			    	}
			    }
			});

			$(".slidesjs-control").bind("click", function(e){
				var event = window.event || e;
				console.log(event.type + " - " + event.button + ", keyValue=" + event.keyCode);
				event.stopImmediatePropagation();
				event.preventDefault();
				event.stopPropagation();
				if (event.button == 0) {
					$(".slidesjs-next").click();
				};
			});
			
		});
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
				$(".slidesjs-previous").click(); //alert("마우스 휠 위로~");
		    else 	
		    	$(".slidesjs-next").click(); //alert("마우스 휠 아래로~");
		}
	});
	$(window).bind("keyup", function(e) {
		var event = window.event || e;
		//alert(event.keyCode);
		switch(event.keyCode) {
		case 37: // left
		case 40: // down
			$(".slidesjs-previous").click(); break;
		case 39: // right
		case 38: // up
			$(".slidesjs-next").click(); break;
		case 32: // space
			fnRandomImageView(); break;
		case 13: // enter
			break;
		};
	});
	$(window).bind("resize", resizeImage);

});
function resizeImage() {
	windowHeight = $(window).height();
	$(".bg-image").height(windowHeight - navHeight);
	$('#slides').height(windowHeight - navHeight);
	$('.slidesjs-container').height(windowHeight - navHeight);
	
	rePagination();
}
function fnRandomImageView() {
	selectedNumber = getRandomInteger(0, imageCount);
	$("a[data-slidesjs-item='" + selectedNumber + "']").click();
}
function rePagination() {
    var index = parseInt($(".active").attr("data-slidesjs-item"));
    //debug(index);
	
    if (false) {
    	var img = $("<img>").attr("src", imagepath + index);
        $("div[slidesjs-index='" + index + "']").empty();
        $("div[slidesjs-index='" + index + "']").append(img);
    }
    else {
	    $("div[slidesjs-index='" + index + "']").css({"background-image": "url(" + imagepath + index + ")"});
    }
    
    $(".slidesjs-pagination-item").each(function() {
    	var itemIdx = parseInt($(this).children().attr("data-slidesjs-item"));
    	if (itemIdx > index + 2 || itemIdx < index - 2) {
    		$(this).hide();
    	}
    	else {
    		$(this).show();
    	}
    });
}
function debug(msg) {
	$("#debug").html(msg);
}

</script>
</head>
<body>
<div class="container-fluid">

<div id="slides" class="slides">
</div>

<div id="slidesNav"></div>
<div id="debug"></div>

</div>
</body>
</html>