<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<html>
<head>
<title><s:message code="default.home"/></title>
<link rel="stylesheet" href="${PATH}/css/typed.css"/>
<link rel="stylesheet" href="${PATH}/css/aperture.css"/>
<link rel="stylesheet" href="${PATH}/css/neon.css"/>
<style type="text/css">
body {
 	font-family: 'clipregular';
	background-image: url("${PATH}/img/bg/neon-bg.png");
	background-position: center top;	
	background-repeat: repeat;
 	background-size: 950px 341px;
 	overflow: hidden;
}
.jumbotron {
	background-color: transparent;
	margin: 10px;
	padding: 0;
}
.title-panel {
	padding: 10px !important;
	margin: 20px auto 0 !important;
	width: 500px;
	background-size: cover; */
    border-radius: 10px !important;
}
.border-shadow {
	box-shadow: rgba(249, 0, 0, 0.8) 0px 0px 70px, rgba(249, 0, 0, 0.8) 0px 0px 70px inset;
}
#front-wrapper {
	margin-top: 20px;
}
#front {
	height: 419px;
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
	position: fixed;
    bottom: 0;
    width: 100%;
    left: 0;
    padding: 5px 140px !important;
    margin: 0;
}
#favicon-crazy {
	left: 5px;
} 
#favicon-video {
	right: 5px;
}
.favicon {
	position: absolute;
	cursor: move;
	bottom: 5px;
	width: 128px;
	transition: border-radius 3s ease 0s;
}
.favicon:hover {
	box-shadow: 0 3px 6px rgba(0,0,0,.15), 0 3px 9px rgba(0,0,0,.19);
}
h1 > b.neon {
	text-shadow: rgba(38, 90, 136, 0.5) 3px 3px 10px;
    color: rgb(238, 238, 238);
}
p > span.neon {
	text-shadow: rgba(38, 90, 136, 0.8) 3px 3px 0;
    color: rgb(238, 238, 238);
}
.ui-draggable-dragging {
	box-shadow: 
		-3px -3px 3px 3px rgba(255, 0, 0, 0.25), 
		 3px -3px 3px 3px rgba(0, 255, 0, 0.25), 
		 3px  3px 3px 3px rgba(0, 0, 255, 0.25), 
		-3px  3px 3px 3px rgba(255, 255, 0, 0.25);
	transition: top 0s, left 0s !important;
}
.aperture {
    transition: box-shadow 1s ease-out 0s, transform 1s !important;
}
</style>
<script type="text/javascript" src="${PATH}/js/flayon.effect.aperture.js"></script>
<script type="text/javascript" src="${PATH}/js/flayon.effect.typed.js"></script>
<script type="text/javascript">
bgContinue = false;
var frontApp = (function() {

	var opusList,
	/**
	 * random background-color
	 */
	backgroundEffect = function() {
		setInterval(function() {
			$("body").randomBG(1);
		}, 1000 * getRandomInteger(10, 60));
	},
	/**
	 * neon sign
	 */
	neonEffect = function() {
		if (themeSwitch === 'normal') {
			$("ul.nav > li").removeClass("active");
			$(".neon").css({color: '#eee'}).each(function() { 
				$(this).addClass("blink-" + getRandomInteger(1, 10));
			});
		}
		if (themeSwitch === 'plain') {
			$(".neon").removeClass('blink-1 blink-2 blink-3 blink-4 blink-5 blink-6 blink-7 blink-8 blink-9 blink-10');
		}
	},
	/**
	 * front image
	 */
	frontEffect = function() {
		$("#front").attr({
			src: '${PATH}/img/flayon/favicon-crazy-' + getRandomInteger(0, 4) + '.png'
		}).on("click", function() {
			var opus = $(this).data("opus");
			if (opus && opus !== "") {
				fnVideoDetail(opus);
			}
		});
		restCall(PATH + '/rest/video/opus', {}, function(data) {
			opusList = data;
			setInterval(function() {
				var bool = getRandomBoolean();
				var opusIndex = getRandomInteger(0, opusList.length-1);
				$("#front").hide("fade", {}, 2000, function() {
					$(this).attr({
						src: (bool ? "${PATH}/image/random?_t=" + new Date().getTime()  : "${PATH}/cover/video/" + opusList[opusIndex])
					}).data("opus", (bool ? "" : opusList[opusIndex])).show("fade", {}, 1000, function() {
						$(this).css({
							borderRadius: getRandomInteger(10, 30) + "% " + getRandomInteger(10, 30) + "% " + getRandomInteger(10, 30) + "% " + getRandomInteger(10, 30) + "%",
							transition: "transform " + getRandomInteger(1, 3) + "s cubic-bezier(0.6, -0.28, 0.74, 0.05), opacity 1s, border-radius 3s",
							transform: "rotateZ(" + getRandomInteger(-15, 15) + "deg)"
						});
					});
				});
			}, 1000 * getRandomInteger(3, 30));
		});
	},
	/**
	 * wording typed
	 */
	typedEffect = function() {
		var typed = function(selector, message, callbackStart) {
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
		}; 
		typed("#wording1", $("#wording-data-1").html());
	},
	/**
	 * image ball aperture
	 */
	imageballEffect = function() {
		var minSize = 100, maxSize = 300;
		var	aperture = function($obj, imgSrc) {
			var TIMING_PROPERTIES = ["linear", "ease", "ease-in", "ease-out", "ease-in-out"];
			var calcCount = 0;
			var	imageballPosition = function() {
				var offset = 50;
				var left  = getRandomInteger(1, $(window).innerWidth()  - maxSize);
				var top   = getRandomInteger(1, $(window).innerHeight() - maxSize);
				var sX    = $("#front").offset().left - offset;
				var eX    = sX + $("#front").width() + offset*2;
				var sY    = $("#front").offset().top - offset;
				var eY    = sY + $("#front").height() + offset*2;
				var _left = left + (maxSize /2);
				var _top  = top  + (maxSize /2);
				if (++calcCount < 10) {
					if (sX < _left && _left < eX && sY < _top && _top < eY) {
						return imageballPosition();
					}
				}
				return [left, top];
			};
			var position = imageballPosition();
			var left  = position[0];
			var top   = position[1];
			var scale = "." + getRandomInteger(3, 9);
			console.log("aperture", left, top, scale);
				
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
				baseColor1: getRandomColor("." + getRandomInteger(10, 50)),
				baseColor2: getRandomColor("." + getRandomInteger(10, 50)),
				baseColor3: getRandomColor("." + getRandomInteger(10, 50)),
				baseColor4: getRandomColor("." + getRandomInteger(10, 50)),
				backgroundColor: getRandomColor("." + getRandomInteger(10, 50)),
				outerMargin: "0 auto",
				outerRadius: "0",
				timing: TIMING_PROPERTIES[getRandomInteger(1, 5)],
				width: maxSize + "px"
			});
		};
		
		setInterval(function() {aperture($("#aperture-O1"), "${PATH}/image/random")}, 1000 * getRandomInteger(10, 30));
	 	setInterval(function() {aperture($("#aperture-O2"), "${PATH}/image/random")}, 1000 * getRandomInteger(10, 30));
		setInterval(function() {aperture($("#aperture-O3"), "${PATH}/image/random")}, 1000 * getRandomInteger(10, 30));
	},
	/**
	 *  favicon
	 */
	faviconEffect = function() {
		setInterval(function() {
			$( "#favicon-crazy").css({
				"border-top-left-radius":     getRandomInteger(10, 50) + "%",
			    "border-top-right-radius":    getRandomInteger(10, 50) + "%",
			    "border-bottom-right-radius": getRandomInteger(10, 50) + "%",
			    "border-bottom-left-radius":  getRandomInteger(10, 50) + "%"
			}).attr({
				"src": "${PATH}/img/flayon/favicon-crazy-" + getRandomInteger(0, 4) + ".png"
			});
		}, 1000 * getRandomInteger(10, 30));
		setInterval(function() {
			$( "#favicon-video").css({
				"border-top-left-radius":     getRandomInteger(10, 50) + "%",
			    "border-top-right-radius":    getRandomInteger(10, 50) + "%",
			    "border-bottom-right-radius": getRandomInteger(10, 50) + "%",
			    "border-bottom-left-radius":  getRandomInteger(10, 50) + "%"
			}).attr({
				"src": "${PATH}/img/flayon/favicon-video-" + getRandomInteger(0, 1) + ".png"
			});
		}, 1000 * getRandomInteger(10, 30));
	},
	/**
	 * draggable by jquery-ui
	 */
	draggableEffect = function() {
		$("#favicon-crazy").draggable();
		$("#favicon-video").draggable();
		$("#aperture-O1").draggable();
		$("#aperture-O2").draggable();
		$("#aperture-O3").draggable();	
	},
	/**
	 * nav Background button hide
	 */
	navBackBtnHide = function() {
		$("#backMenu").parent().hide();
	};
	
	return {init: function() {
		  navBackBtnHide();
		backgroundEffect();
		      neonEffect();
		     frontEffect();
		     typedEffect();
		 imageballEffect();
		   faviconEffect();
		 draggableEffect();
	}};
}());

$(document).ready(function() {
	frontApp.init();	
});
</script>
</head>
<body>

<div class="container-fluid text-center">
	<div class="jumbotron title-panel">
		<h1>
			<b class="neon">FlayOn</b>
			<b class="neon">Video</b>
		</h1>
	</div>
	<div id="front-wrapper">
		<img id="front" class="border-shadow"/>
	</div>
	<div class="jumbotron typed-panel">
		<p>
			<span id="wording1" class="neon"></span>
		</p>
		<p>
			<span id="wording2" class="neon"></span>
		</p>
		<div class="hide">
			<p id="wording-data-1"><s:message code="home.favorites.wording1"/></p>
			<p id="wording-data-2"><s:message code="home.favorites.wording2"/></p>
		</div>
	</div>
</div>

<div class="aperture-wrap">
	<div id="aperture-O1" class="aperture neon border-shadow"></div>
	<div id="aperture-O2" class="aperture neon border-shadow"></div>
	<div id="aperture-O3" class="aperture neon border-shadow"></div>
</div>

<div class="favicon-wrap">
	<img id="favicon-crazy" class="favicon neon border-shadow"/>
	<img id="favicon-video" class="favicon neon border-shadow"/>
</div>

</body>
</html>
