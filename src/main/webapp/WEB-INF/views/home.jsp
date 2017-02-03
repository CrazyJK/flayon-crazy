<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
<title><s:message code="default.home"/></title>
<security:authorize access="isAuthenticated()">
<style type="text/css">
body {
	font-family: 'clipregular';
	background-image: url("/img/neon-bg.png");
	background-position: center 50px;	
	background-repeat: repeat;
	background-size: contain;
}
#front {
/*	background-image: url('/img/kamoru_crazy_artistic_t.png'); */ 
 	background-image: url('/img/favicon-crazy.png');
	background-position: center top;
	background-repeat: no-repeat;
/*	background-size: contain; */
 	background-size: 625px 469px;
	min-height: 500px;
}
.aperture {
	z-index: 1;
	display:inline-block;
	transition: all 1.5s ease;
}
.jumbotron {
	background-color: transparent;
/* 	z-index: 588; */
}
</style>
<script type="text/javascript">
$(document).ready(function() {
	// background-color random
	setInterval(function() {
		$("body").css("background-color", randomColor(1));
	}, 1000 * getRandomInteger(10, 60));
	
	// change inverse
	$(".nav, #lang").removeClass("navbar-default").addClass("navbar-inverse");
	$("ul.dropdown-menu").css("background-color", "rgba(0, 0, 0, 0.5)");
	
	// neon effect
	var styles = {color: "#eee", fontWeight: "bold"};
	$("li a, #hello, #user, #wording, #typed, .navbar-header a, select").each(function() {
		$(this).addClass("blink-" + getRandomInteger(1, 10)).css(styles);
	});

});

function startImageBall() {
	setInterval(function() {
		aperture($("#aperture-O1"), "/image/random");
	}, 1000 * getRandomInteger(3, 10));
	setInterval(function() {
		aperture($("#aperture-O2"), "/image/random");
	}, 1000 * getRandomInteger(3, 10));
	setInterval(function() {
		aperture($("#aperture-O3"), "/image/random");
	}, 1000 * getRandomInteger(3, 10));
}

function aperture($obj, imgSrc) {
	var windowWidth = $(window).innerWidth();
	var windowHeight = $(window).innerHeight();
	var _left = getRandomInteger(1, windowWidth - 200);
	var _top = getRandomInteger(200, windowHeight - 200);
	var _width = getRandomInteger(50, 200);
	// console.log(_left, _top, _width);
	$obj.css({
		position: "absolute", /* relative, absolute */ 
		left: _left + "px",
		top: _top + "px"
	}).aperture({
		src: imgSrc + "?_t=" + new Date().getTime(),
		baseColor: randomColor(.25), //"rgba(0,0,0,0)",
		outerMargin: "0 auto",
		timing: "ease-in-out",
		width: _width + "px",
		/* duration: "5s" */
	});
}
</script>
</security:authorize>
</head>
<body>

<div class="container text-center" id="front">
	<div class="jumbotron" style="display: inline-block;">
		<h1>
			<b id="hello">FlayOn</b> 
			<security:authorize access="isAuthenticated()">
				<span id="user"><security:authentication property="principal.username" /></span>
			</security:authorize>
		</h1>
	</div>
	<div class="jumbotron text-left" style="margin-top:200px;">
		<p>
			<span id="wording"></span>
		</p>
	</div>
</div>

<div id="aperture-O1" class="aperture"></div>
<div id="aperture-O2" class="aperture"></div>
<div id="aperture-O3" class="aperture"></div>

<script type="text/javascript">
$("#wording").typed({
    strings: ["<s:message code="home.favorites.wording1"/><br/><s:message code="home.favorites.wording2"/>"],
    //stringsElement: $('#wordings'),
    typeSpeed: 50,
    backDelay: 500,
    loop: false,
    contentType: 'html', // or text
    // defaults to false for infinite loop
    loopCount: false,
    callback: function(){
    	$("#wording").next(".typed-cursor").hide();
    	startImageBall();
    }
});
</script>

</body>
</html>
