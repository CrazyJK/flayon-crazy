<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
<title><s:message code="default.home"/></title>
<style type="text/css">
.circle-wrapper {
	margin: 50px auto;
	width: 300px;
	height: 300px;
	border-radius: 50%;
	box-shadow: none;
	transition: all 5s;
}
.circle-wrapper:hover {
	box-shadow: 
		-150px    0   0 rgba(255,   0,   0, 0.5), 
		   0   -150px 0 rgba(252, 150,   0, 0.5), 
		 150px    0   0 rgba(0,   255,   0, 0.5), 
		   0    150px 0 rgba(0,   150, 255, 0.5),
		 106px  106px 0 rgba(255,   0,   0, 0.5),
		-106px  106px 0 rgba(252, 150,   0, 0.5), 
		-106px -106px 0 rgba(0,   255,   0, 0.5), 
		 106px -106px 0 rgba(0,   150, 255, 0.5);
}
.circle {
	background: #fff;
	border-radius: 100%;
	cursor: pointer;
	width: 300px;
	height: 300px;
	text-align: center;
	margin:0 auto;
	overflow: hidden;
	transform: translateZ(0);
	-webkit-transform: translateZ(0);
}
.circle:before, .circle:after {
	-webkit-box-sizing: border-box;
	box-sizing: border-box;
	border-radius: 100%;
	content: "";
	position: absolute;
	top: 0;
	left: 0;
	width: inherit;
	height: inherit;
	background-size: 100%;
	box-shadow: 
		inset 150px  0 0 rgba(238, 238, 238, .588), 
		inset 0  150px 0 rgba(238, 238, 238, .588), 
		inset -150px 0 0 rgba(238, 238, 238, .588), 
		inset 0 -150px 0 rgba(238, 238, 238, .588);
	transition: all 5s;
}
.circle:after {
	transform: rotate(45deg);
	-webkit-transform: rotate(45deg);
}
.circle:hover:after, .circle:hover:before {
	box-shadow: 
		inset 15px  0 0 rgba(255,   0,   0, 0.5), 
		inset 0  15px 0 rgba(252, 150,   0, 0.5), 
		inset -15px 0 0 rgba(0,   255,   0, 0.5), 
		inset 0 -15px 0 rgba(0,   150, 255, 0.5);
	background-image:none;
}
.img-circle {
	width: 100%;
}
</style>
</head>
<body>

<div class="container">
	<div class="jumbotron">
		<h1>
			<b><s:message code="jk.crazy"/></b> 
			<security:authorize access="isAuthenticated()">
				<security:authentication property="principal.username" />
			</security:authorize>
		</h1>
		<security:authorize access="isAuthenticated()">
		<div class="circle-wrapper">
			<div class="circle">
				<img class="img-circle" src="/img/kamoru_crazy_artistic.png"/>
			</div>
		</div>
		</security:authorize>
		<p>
			<span id="wording"></span>
		</p>
	</div>
</div>

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
