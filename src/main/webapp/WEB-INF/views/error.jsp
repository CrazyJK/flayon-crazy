<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
String exception = (String) request.getAttribute("exception");
String message = (String) request.getAttribute("message");
response.setHeader("error", "true");
response.setHeader("error.message", message);
response.setHeader("error.cause", exception);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>Server Error</title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap-theme.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
</head>
<body>
<div class="container">

 	<div class="page-header">
	    <h1>${error}
	    	<small style="float:right"><fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss" value="${timestamp}"/></small>
	    </h1>
  	</div>
  	
    <p>${status} : ${exception}</p>
    <pre>${message}</pre>

	<div class="text-right">
		<button class="btn btn-info" data-toggle="collapse" data-target="#webContext">view Web Attribute</button>
	</div>
	<div id="webContext" class="collapse">
	<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
	</div>
	
</div>
</body>
</html>
