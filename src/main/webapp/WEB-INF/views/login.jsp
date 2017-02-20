<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="default.login"/></title>
<script type="text/javascript">
$(document).ready(function(){

	$("#loginModal").modal();

	if (self.innerHeight == 0) {
		var msg = $("#error").text().trim();
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
			<b>FlayOn</b> 
			<security:authorize access="isAuthenticated()">
				<security:authentication property="principal.username" />
			</security:authorize>
		</h1>
		<p><s:message code="home.favorites.wording1"/><br/>
		   <s:message code="home.favorites.wording2"/></p>
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

	<div class="text-right">
		<button class="btn btn-link" data-toggle="collapse" data-target="#webContext">.</button>
	</div>
	<div id="webContext" class="collapse">
	<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
	</div>

</div>
</body>
</html>