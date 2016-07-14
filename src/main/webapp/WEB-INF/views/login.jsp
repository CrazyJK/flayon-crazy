<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="default.login"/></title>
<style type="text/css">
#sign-in {
	margin:20px 20px 20px;
	background-color: rgba(241, 241, 241, .75); 
	border:1px solid #e5e5e5;
	border-radius:10px;
	padding:20px 25px; 
	width:300px;
	float:right;
}
</style>
<script type="text/javascript">
$(document).ready(function(){

	if (self.innerHeight == 0) {
		var msg = $("#loginMsg").text().trim();
		if (msg != '')
			alert(msg);
	}
});
</script>
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
		<p><s:message code="home.favorites.wording1"/></p>
		<p><s:message code="home.favorites.wording2"/></p>
	</div>
	
	<div id="aperture"></div>
	<script type="text/javascript">
	$("#aperture").aperture({
		src:"/img/kamoru_crazy_artistic.png",
		duration: "3s",
		baseColor: "rgba(255, 255, 255, .9)",
		width: "200px",
	});
	</script>

	<div id="loginModal" class="modal fade">
		<div class="modal-dialog modal-sm" style="margin-top:75px;">
		
			<div class="modal-content">
				<div class="modal-header">
					<a class="close" data-dismiss="modal">&times;</a>
					<h3 class="modal-title">Ready to crazy!</h3>
					<c:if test="${param.error}">
						<span id="loginMsg" class="alert-success">
				    		${sessionScope["SPRING_SECURITY_LAST_EXCEPTION"].message}
				    		${LAST_REQUEST_METHOD} ${authException}
				    	</span>
					</c:if>
				</div>
				<div class="modal-body">
					<form method="post" class="form center-block">
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
							<button class="btn btn-primary btn-block" type="submit">Log in</button>
						</div>
					</form>
				</div>
	      		<div class="modal-footer">
	      			<p>Not a member? <a href="mailto:Crazy.4.JK@gmail.com">Contact me</a></p>
	      		</div>
			</div>
			
		</div>
	</div>
	<script>
	$(document).ready(function(){
		$("#loginModal").modal();
	});
	</script>

</div>
</body>
</html>