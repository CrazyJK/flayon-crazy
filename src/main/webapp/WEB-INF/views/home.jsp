<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
<title><s:message code="default.home"/></title>
</head>
<body>

<div class="container text-center" style="margin-top: 50px;">
	<div class="jumbotron" style="display: inline-block;">
		<h1>
			<b id="hello">FlayOn</b> 
			<security:authorize access="isAuthenticated()">
				<span id="user"><security:authentication property="principal.username"/></span>
			</security:authorize>
		</h1>
	</div>
	<div class="jumbotron text-left">
		<p>
			<span id="wording"></span>
		</p>
	</div>
	<div>
		<div id="aperture"/>
		<script type="text/javascript">
		$(function() {
			$("#aperture").aperture({
				src:"/img/kamoru_crazy_artistic.png",
				duration: "3s",
				baseColor: "rgba(255, 255, 255, .9)",
				width: "200px",
			});
		});
		</script>
	</div>
</div>

<script type="text/javascript">
$(function() {
	$("#wording").typed({
	    strings: ["<s:message code="home.favorites.wording1"/><br/><s:message code="home.favorites.wording2"/>"],
	    //stringsElement: $('#wordings'),
	    typeSpeed: 50,
	    backDelay: 500,
	    loop: false,
	    contentType: 'html', // or text
	    // defaults to false for infinite loop
	    loopCount: false,
	    callback: function() {
	    	$("#wording").next(".typed-cursor").hide();
	    }
	});
});
</script>

</body>
</html>
