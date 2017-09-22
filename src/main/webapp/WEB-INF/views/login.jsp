<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="default.login"/></title>
<link rel="stylesheet" href="<c:url value="/css/crazy-common.css"/>">
<script type="text/javascript">
$(document).ready(function() {
	$("#loginBtn").hide();
	self.innerHeight == 0 && ${not empty param.error} && alert($("#error").text());
	$("input[name='username']").on("change keyup click", function() {
		$("#name").html($(this).val());
	});
});
</script>
</head>
<body>
<div class="container">

	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header text-center">
		        <h1>
		            <b>FlayOn</b> Login 
		        </h1>
				<h3 class="modal-title">
				    Welcome <span id="name" class="text-primary"></span>
				</h3>
		        <c:if test="${null ne param.error}">
		            <h3 id="error" class="text-danger title-effect">
		                ${sessionScope["SPRING_SECURITY_LAST_EXCEPTION"].message}
		                마지막 한 번의 기회다.
		            </h3>
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
                        <p class="float-right">Not a member? <a href="mailto:Crazy.4.JK@gmail.com">Contact me</a></p>
             			<label><input type="checkbox" name="remember-me" checked="checked"/>Remember me</label>
           			</div>
					<div>
						<button class="btn btn-white btn-block" type="submit">Log in</button>
					</div>
				</form>
			</div>
      		<div class="modal-footer">
	            <div class="text-center">
	                <s:message code="home.favorites.wording1"/>
	                <br/>
	                <s:message code="home.favorites.wording2"/>
	            </div>
      		</div>
		</div>
	</div>

	<div style="position: fixed; right:0; bottom:0;">
		<button class="btn btn-link" data-toggle="collapse" data-target="#webContext">.</button>
	</div>
	<div id="webContext" class="collapse">
	   <%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
	</div>

</div>
</body>
</html>