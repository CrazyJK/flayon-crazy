<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<html>
<head>
<title><s:message code="default.home"/></title>
</head>
<body>

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

</body>
</html>
