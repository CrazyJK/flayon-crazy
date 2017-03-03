<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
Integer status = (Integer)request.getAttribute("status");
String error   = (String) request.getAttribute("error");
response.setHeader("error", "true");
response.setHeader("error.message", status + " : " + error);
response.setHeader("error.cause", "");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Server Error</title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap-theme.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
</head>
<body>

	<div class="container">
	 	<div class="page-header">
	 		<h1>${status} : ${error}
		    	<small style="float:right"><fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss" value="${timestamp}"/></small>
	 		</h1>
		</div>
		<p>
	    	<code><c:out value="${message}" escapeXml="true"/></code>
	    </p>
	    <c:if test="${!empty requestScope['javax.servlet.error.exception']}}">
		<pre><c:out value="${requestScope['javax.servlet.error.exception']}" escapeXml="true"/></pre>
	    </c:if>
	
		<c:if test="${status ne 404}">
		<div class="container text-right">
			<button class="btn btn-link" data-toggle="collapse" data-target="#webContext">view Web Attribute</button>
		</div>
		<div id="webContext" class="container-fluid collapse">
			<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
		</div>
		</c:if>
	</div>

</body>
</html>
