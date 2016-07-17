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
	background-image: url("/img/neon-bg.jpg");
	background-position: top left;	
	font-family: 'clipregular';
}
.aperture {
	z-index: 1;
	display:inline-block;
}
.jumbotron {
	background-color: rgba(0,0,0,.8);
	z-index: 588;
}
</style>
<script type="text/javascript">
var windowWidth = $(window).innerWidth();
var windowHeight = $(window).innerHeight();

$(document).ready(function() {
	// change inverse
	$(".nav, #lang").removeClass("navbar-default").addClass("navbar-inverse");
	
	// neon effect
	var styles = {color: "#eee", fontWeight: "bold"};
	$("li a, #hello, #user, #wording, #typed, .navbar-header a, select").each(function() {
		$(this).addClass("blink-" + getRandomInteger(1, 10)).css(styles);
	});

	// aperture
	setInterval(function() {
		aperture($("#aperture-O1"), "/image/random");
	}, 1000 * getRandomInteger(3, 10));
	setInterval(function() {
		aperture($("#aperture-O2"), "/image/random");
	}, 1000 * getRandomInteger(3, 10));
	setInterval(function() {
		aperture($("#aperture-O3"), "/image/random");
	}, 1000 * getRandomInteger(3, 10));

});
function aperture($obj, imgSrc) {
	var _width = getRandomInteger(1, windowWidth - 180);
	var _height = getRandomInteger(500, windowHeight - 200);
	var _aWidth = getRandomInteger(20, 200);
	console.log(_width, _height, _aWidth);
	$obj.css({
		position: "absolute", /* relative */ 
		left: _width + "px",
		top: _height + "px"
	}).aperture({
		src: imgSrc,
		baseColor: "rgba(0,0,0,.8)",
		outerMargin: "0 auto",
		timing: "ease-in-out",
		width: _aWidth + "px"
		/* duration: "5s" */
	});
	
}
</script>
</security:authorize>
</head>
<body>

<div class="container text-center">
	<div class="jumbotron" style="display: inline-block;">
		<h1>
			<b id="hello"><s:message code="jk.crazy"/></b> 
			<security:authorize access="isAuthenticated()">
				<span id="user"><security:authentication property="principal.username" /></span>
			</security:authorize>
		</h1>
	</div>
	<div class="jumbotron text-left">
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
    }
});
</script>


</body>
</html>
