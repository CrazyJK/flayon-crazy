<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map.*" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
response.setHeader("error", "true");
response.setHeader("error.message", request.getAttribute("status") + " : " + request.getAttribute("error"));
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${status} : ${error}</title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/error.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
</head>
<body>

<div class="container">
    <small class="timestamp"><fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss" value="${timestamp}"/></small>
 	<div class="page-header">
 		<h1><span class="text-danger">${error}</span></h1>
 		<h3><code>${status}</code> ${path}</h3>
	</div>
	<div class="page-content">
	    <p>Error: <code>${exception}: ${message}</code></p>
	    <div>Param:
	    	<ol>
<%
	for (Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
		out.println("<li>" + entry.getKey() + " : ");
		for (String value : entry.getValue()) {
			out.println("<code>" + value + "</code>");
		}
	}
%>
	    	</ol>
	    </div>
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
