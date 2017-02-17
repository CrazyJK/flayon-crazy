<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<html>
<head>
<title><s:message code="default.home"/></title>
<link rel="stylesheet" href="<c:url value="/css/typed.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/aperture.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/neon.css"/>"/>
<style type="text/css">
body {
 	font-family: 'clipregular';
	background-image: url("${PATH}/img/neon-bg.png");
	background-position: center top;	
	background-repeat: repeat;
/*	background-size: contain; */
 	background-size: 950px 341px;
 	overflow: hidden;
}
.jumbotron {
	background-color: transparent;
	margin: 10px;
	padding: 0;
}
.title-panel {
	padding-top: 20px;
}
#front-wrapper {
	margin: 25px auto;
	height: 419px;
}
#front {
	background-position: center center;
	background-repeat: no-repeat;
	background-size: cover;
	width: 625px;
	height: 419px;
	margin: 25px auto;
	padding: 0;
	border-radius: 10px;
	cursor: cell;
	transform: scale(1, 1);
	opacity: .4;
	transition: all 1s ease 0s;
}
#front:hover {
	transform: scale(1.1, 1.1);
	opacity: 1;
}
.typed-panel {
	font-size: x-large;
}
#favicon-crazy, #favicon-video {
	position: absolute;
	cursor: move;
	bottom: 5px;
	width: 128px;
	transition: border-radius 3s ease 0s;
}
#favicon-crazy {
	left: 5px;
} 
#favicon-video {
	right: 5px;
}
</style>
<script type="text/javascript" src="<c:url value="/js/jquery.crazy.aperture.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/typed.js" />"></script>
<script type="text/javascript">
bgContinue = false;
var timingProperties = ["linear", "ease", "ease-in", "ease-out", "ease-in-out"];

$(document).ready(function() {
	
	backgroundEffect();
	
	neonEffect();

	frontEffect();
	
	typedEffect();
	
	imageballEffect();
	
	faviconEffect();
	
	draggableEffect();
});

/**
 * random background-color
 */
function backgroundEffect() {
	setInterval(function() {
		$("body").css("background-color", randomColor(1));
	}, 1000 * getRandomInteger(10, 60));
}

/**
 * neon sign
 */
function neonEffect() {
	// change inverse
	$("ul.nav, #lang").removeClass("navbar-default").addClass("navbar-inverse");
	$("ul.nav > li > a, ul.dropdown-menu > li > a").css({color: "#eee"});
	$("ul.dropdown-menu").css("background-color", "rgba(0, 0, 0, 0.5)");
	$("ul.nav > li").removeClass("active");
	
	// neon effect
	$("ul.nav > li > a, ul.dropdown-menu > li > a, .neon").each(function() {
		$(this).addClass("blink-" + getRandomInteger(1, 10));
	});
}

var opusList;
/**
 * front image
 */
function frontEffect() {
	$("#front").css({
		"background-image": "url('${PATH}/img/favicon-crazy-" + getRandomInteger(0, 4) + ".png')"
	}).bind("click", function() {
		var opus = $(this).data("opus");
		if (opus && opus != "") {
			fnViewVideoDetail(opus);
		}
	});
	$.getJSON("${PATH}/video/opus.json" ,function(data) {
		opusList = data['opus'];
		
		setInterval(function() {
			var bool = getRandomBoolean();
			var opusIndex = getRandomInteger(0, opusList.length);
			$("#front").css({
				backgroundImage: (bool ? "url('${PATH}/image/random?_t=" + new Date().getTime() + "')"  : "url('${PATH}/video/" + opusList[opusIndex] + "/cover/title')"),
				backgroundSize: (bool ? "contain" : "cover"),
				backgroundColor: randomColor("." + getRandomInteger(20, 50)),
				borderTopLeftRadius:     getRandomInteger(10, 30) + "%",
			    borderTopRightRadius:    getRandomInteger(10, 30) + "%",
			    borderBottomRightRadius: getRandomInteger(10, 30) + "%",
			    borderBottomLeftRadius:  getRandomInteger(10, 30) + "%"
			}).data("opus", (bool ? "" : opusList[opusIndex]));
		}, 1000 * getRandomInteger(3, 30));
	});
}

/**
 * wording typed
 */
function typedEffect() {
	typed("#wording1", $("#wording-data-1").html());
}
function typed(selector, message, callbackStart) {
	$(selector).typed({
	    strings: [message],
	    //stringsElement: $('#wordings'),
	    typeSpeed: getRandomInteger(10, 50),
	    backDelay: 500,
	    loop: false,
	    contentType: 'html', // or text
	    // defaults to false for infinite loop
	    loopCount: false,
	    callback: function() {
	    	$(selector).next(".typed-cursor").hide();
			if (callbackStart) {
				// startImageBall();
			}
			else {
				typed("#wording2", $("#wording-data-2").html(), true);
			}
	    }
	});	
}

/**
 * image ball aperture
 */
function imageballEffect() {
	setInterval(function() {
		aperture($("#aperture-O1"), "${PATH}/image/random");
	}, 1000 * getRandomInteger(10, 30));
 	setInterval(function() {
		aperture($("#aperture-O2"), "${PATH}/image/random");
	}, 1000 * getRandomInteger(10, 30));
	setInterval(function() {
		aperture($("#aperture-O3"), "${PATH}/image/random");
	}, 1000 * getRandomInteger(10, 30));
}
var minSize = 100;
var maxSize = 300;
function aperture($obj, imgSrc) {
	var position = imageballPosition();
	var left  = position[0];
	var top   = position[1];
	var scale = "." + getRandomInteger(3, 9);
//	console.log("aperture", left, top, scale);
	
	$obj.css({
		position: "absolute", /* relative, absolute */ 
		left: left + "px",
		top:  top  + "px", 
		transform: "scale(" + scale + ", " + scale + ")"
	}).on("click", function() {
		$(this).css({
			transform: "scale(1.5, 1.5)"
		});
	}).aperture({
		src: imgSrc + "?_t=" + new Date().getTime(),
		baseColor: randomColor("." + getRandomInteger(10, 50)),
		outerMargin: "0 auto",
		timing: timingProperties[getRandomInteger(1, 5)],
		width: maxSize + "px"
	});
}
function imageballPosition() {
	var offset = 50;
	var left  = getRandomInteger(1, $(window).innerWidth()  - maxSize);
	var top   = getRandomInteger(1, $(window).innerHeight() - maxSize);
	var sX    = $("#front").offset().left - offset;
	var eX    = sX + $("#front").width() + offset*2;
	var sY    = $("#front").offset().top - offset;
	var eY    = sY + $("#front").height() + offset*2;
	var _left = left + (maxSize /2);
	var _top  = top  + (maxSize /2);
	if (sX < _left && _left < eX && sY < _top && _top < eY) {
		return imageballPosition();
	}
	/* 
	$("<div>").css({
		position: "absolute",
		left: sX,
		top: sY,
		width: eX - sX,
		height: eY - sY,
		"background-color": randomColor(.5),
		"z-index": -1
	}).appendTo($("body"));
	 */
//	console.log(sX + " < " + _left + " < " + eX + " : " + sY + " < " + _top + " < " + eY);
	return [left, top];
}

/**
 *  favicon
 */
function faviconEffect() {
	setInterval(function() {
		$( "#favicon-crazy").css({
			"border-top-left-radius":     getRandomInteger(10, 50) + "%",
		    "border-top-right-radius":    getRandomInteger(10, 50) + "%",
		    "border-bottom-right-radius": getRandomInteger(10, 50) + "%",
		    "border-bottom-left-radius":  getRandomInteger(10, 50) + "%"
		}).attr({
			"src": "${PATH}/img/favicon-crazy-" + getRandomInteger(0, 4) + ".png"
		});
	}, 1000 * getRandomInteger(10, 30));
	setInterval(function() {
		$( "#favicon-video").css({
			"border-top-left-radius":     getRandomInteger(10, 50) + "%",
		    "border-top-right-radius":    getRandomInteger(10, 50) + "%",
		    "border-bottom-right-radius": getRandomInteger(10, 50) + "%",
		    "border-bottom-left-radius":  getRandomInteger(10, 50) + "%"
		}).attr({
			"src": "${PATH}/img/favicon-video-" + getRandomInteger(0, 1) + ".png"
		});
	}, 1000 * getRandomInteger(10, 30));
}

/**
 * draggable by jquery-ui
 */
function draggableEffect() {
	$("#favicon-crazy").draggable();
	$("#favicon-video").draggable();
	$("#aperture-O1").draggable();
	$("#aperture-O2").draggable();
	$("#aperture-O3").draggable();	
}
</script>
</head>
<body>

<div class="container text-center">
	<div class="jumbotron title-panel">
		<h1>
			<b class="neon">FlayOn</b>
			<b class="neon">Video</b>
		</h1>
	</div>
	<div id="front-wrapper">
		<div class="jumbotron" id="front"></div>
	</div>
	<div class="jumbotron typed-panel">
		<p>
			<span id="wording1" class='neon'></span>
		</p>
		<p>
			<span id="wording2" class='neon'></span>
		</p>
	</div>
</div>

<div class="hide">
	<p id="wording-data-1"><s:message code="home.favorites.wording1"/></p>
	<p id="wording-data-2"><s:message code="home.favorites.wording2"/></p>
</div>

<div id="aperture-O1" class="aperture neon"></div>
<div id="aperture-O2" class="aperture neon"></div>
<div id="aperture-O3" class="aperture neon"></div>

<img id="favicon-crazy"/>
<img id="favicon-video"/>

</body>
</html>
