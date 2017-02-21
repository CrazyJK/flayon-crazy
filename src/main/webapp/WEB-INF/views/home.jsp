<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
<title><s:message code="default.home"/></title>
<style type="text/css">
body {
	background: url("img/mountain.jpg") top center no-repeat fixed;
}
.jumbotron {
	margin: 50px auto;
    padding: 10px;
	width: 650px;
    height: 250px;
    color: #f0f0f0;
    line-height: 1.40em;
    text-shadow: #000 0px 1px 0px;
    background-color: rgba(0, 0, 0, 0.85);
    box-shadow: rgba(0, 0, 0, 0.8) 0px 20px 70px;
    cursor: grab;
    /* transition: all 0.5s ease-out; */
}
.text-body {
	text-align: left;
	min-height:120px;
}
.container, footer.nav, select {
	background-color: transparent !important;
	background-image: none;
}
div.modal-content {
	background-color: rgba(0, 0 ,0 , 0.7);
    color: #eee;
    border: 1px solid #eee;
}
.modal-header, .modal-footer {
	border: 0;
}
.modal-footer {
	padding: 0;
}
input.form-control {
    background-color: transparent !important;
    color: #eee !important;
}
</style>
<script type="text/javascript">
$(document).ready(function() {
	$("#wording, h1").css({
		fontFamily: randomFont() 
	});
	$(".text-body").draggable();

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


function viewLoginForm() {
	$("#loginModal").modal();
}
</script>
</head>
<body>

<div class="container text-center">
	<div class="jumbotron">
		<h1 class="no-effect" style="height: 80px;">
			<b id="hello">FlayOn</b> 
			<security:authorize access="isAuthenticated()"><security:authentication property="principal.username"/></security:authorize>
		</h1>
		<p class="text-body">
			<span id="wording"></span>
		</p>
	</div>
</div>

	<div id="loginModal" class="modal fade">
		<div class="modal-dialog modal-sm" style="margin-top:75px;">
	
			<div class="modal-content">
				<div class="modal-header">
					<a class="close" data-dismiss="modal">&times;</a>
					<h3 class="modal-title">Ready to crazy!
					<c:if test="${null ne param.error}">
						<span id="error" class="text-danger">${sessionScope["SPRING_SECURITY_LAST_EXCEPTION"].message}</span>
					</c:if>
					</h3>
				</div>
				<div class="modal-body">
					<form method="post" class="form center-block" action="<c:url value="/login"/>">
						<div class="form-group">
							<input type="text" name="username" class="form-control" placeholder="Your name" required="required" autofocus="autofocus"/>
						</div>
						<div class="form-group">
							<input type="password" name="password" class="form-control" placeholder="Password" required="required"/>
						</div>
						<div class="checkbox">
              				<label><input type="checkbox" name="remember-me" checked="checked"/>Remember me</label>
            			</div>
						<div>
							<button class="btn btn-link btn-block" type="submit">Log in</button>
						</div>
					</form>
				</div>
	      		<div class="modal-footer">
	      			<p>Not a member? <a href="mailto:Crazy.4.JK@gmail.com">Contact me</a></p>
	      		</div>
			</div>

			<div>
				<div id="aperture"></div>
				<script type="text/javascript">
				$(function() {
					$("#aperture").aperture({
						src: "<c:url value="/img/kamoru_crazy_artistic.png"/>",
						duration: "3s",
						baseColor: "rgba(0,0,0,.5)",
						width: "200px",
					});
				});
				</script>
			</div>
			
		</div>
	</div>

</body>
</html>
