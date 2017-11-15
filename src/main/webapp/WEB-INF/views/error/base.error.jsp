<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Base Error</title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/error.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
</head>
<body>

<div class="container">
   	<small class="timestamp"><fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss" value="${timestamp}"/></small>
 	<div class="page-header">
	    <h1><span class="text-danger">${exception.message}</span></h1>
 		<h3><code><%=response.getStatus()%></code> <%=request.getAttribute("javax.servlet.error.request_uri") %></h3>
	</div>
	<div class="page-content">
	    <p>Error : <code>${exception}</code></p>
	    <c:if test="${!empty exception.cause}">
	    <p>Cause : <code>${exception.cause}</code></p>
	    </c:if>
	</div>
</div>

<div class="container">
	<div class="text-right">
		<button class="btn btn-link" data-toggle="collapse" data-target=".webAttribute">Web Attributes</button>
	</div>
	<div class="webAttribute collapse">
		<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
	</div>
</div>

</body>
</html>
