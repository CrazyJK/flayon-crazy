<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
<title><s:message code="default.home"/></title>
<style type="text/css">
body {
 	background: transparent url("<c:url value="/img/mountain.jpg"/>") no-repeat fixed top center;
 	transition: background .5s linear;
 	overflow: hidden;
}
div.container, footer.nav, select {
	background-color: transparent !important;
	background-image: none;
}
div.jumbotron {
	background: url("<c:url value="/img/chalk-bg.png"/>") repeat center top;
	background-size: cover;
	margin: 15px auto;
    padding: 10px;
	width: 650px;
	min-height: 250px;
    color: #f0f0f0;
    line-height: 1.40em;
    text-shadow: #000 0px 1px 0px;
    box-shadow: rgba(0, 0, 0, 0.8) 0px 20px 70px;
    transition: height 0.5s cubic-bezier(0.6, -0.28, 0.74, 0.05);
}
div.jumbotron h1 {
	height: 80px;
}
p.text-body {
	text-align: left;
	line-height: 27px;
}
div.modal-dialog {
	width: 650px;
    height: 250px;
    margin-top: 360px;
}
div.modal-content {
/*     background: transparent url("<c:url value="/img/chalk-bg.png"/>") repeat center top;
	background-size: cover; */
 	background-color: rgba(0, 0 ,0 , 0);
    color: #eee;
}
div.modal-header, div.modal-footer {
	border: 0;
}
div.modal-body {
	padding: 0 15px;
}
div.modal-body table.table {
	margin: 0;
}
div.modal-body .checkbox {
	margin-top: 0;
}
div.modal-footer {
	padding: 0;
}
form input.form-control {
    background-color: transparent !important;
    color: #eee !important;
}
form .checkbox span {
	float: right;
}
form .input-group {
	margin-bottom: 15px;
}
form .input-group-addon {
	background-color: transparent;
    color: #fff;
}
div.modal-content .btn-link, div.modal-content a {
	color: #eee;
}
div.modal-content .btn-link:hover, div.modal-content a:hover {
	color: #eee;
	text-decoration: none;
}
</style>
</head>
<body>

	<div class="container text-center">
		<div class="jumbotron">
			<h1 class="no-effect">
				<b id="hello"></b>
				<span id="name"></span>
			</h1>
			<p class="text-body">
				<span id="wording"></span>
			</p>
		</div>
	</div>

	<div id="loginModal" class="modal fade">
		<div class="modal-dialog modal-sm">
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
					<table class="table">
						<tr>
							<td>
								<div id="aperture"></div>
							</td>
							<td>
								<form method="post" class="form center-block" action="<c:url value="/login"/>">
									<div class="input-group">
      									<span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
										<input type="text" name="username" class="form-control" placeholder="Your name" required="required" autofocus="autofocus"/>
									</div>
									<div class="input-group">
      									<span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
										<input type="password" name="password" class="form-control" placeholder="Password" required="required"/>
									</div>
									<div class="checkbox">
										<span>Not a member? <a href="mailto:Crazy.4.JK@gmail.com">Contact me</a></span>
			              				<label><input type="checkbox" name="remember-me" checked="checked"/>Remember me</label>
			            			</div>
									<div>
										<button class="btn btn-link btn-block" type="submit">Log in</button>
									</div>
								</form>
							</td>
						</tr>
					</table>
				</div>
	      		<div class="modal-footer"></div>
			</div>
		</div>
	</div>

<script type="text/javascript">
$(document).ready(function() {
	
	$("h1").css({fontFamily: randomFont()}).hide();
	$("#wording").css({fontFamily: randomFont()});
	$(".jumbotron").draggable();

	setTimeout(function(){
		
		$("#hello").html("FlayOn");
		<security:authorize access="isAuthenticated()">
		$("#name").html('<security:authentication property="principal.username"/>');
		</security:authorize>
		$("h1").show('scale');
		
		$("#wording").typed({
		    strings: ["<s:message code="home.favorites.wording1"/><br/><s:message code="home.favorites.wording2"/>"],
		    //stringsElement: $('#wordings'),
		    typeSpeed: getRandomInteger(10, 50),
		    backDelay: 500,
		    loop: false,
		    contentType: 'html', // or text
		    // defaults to false for infinite loop
		    loopCount: false,
		    callback: function() {
		    	$("#wording").next(".typed-cursor").hide();
		    }
		});

	}, 1000);

});

function viewLoginForm() {
	$("#aperture").aperture({
		src: "<c:url value="/img/kamoru_crazy_artistic_t.png"/>",
		duration: "3s",
		baseColor: "rgba(0,0,0,0.1)",
		color: "rgba(0,0,0,0.5)",
		backgroundColor: "transparent",
		width: "150px",
	});
	$("#loginModal").modal();
}
</script>
</body>
</html>
