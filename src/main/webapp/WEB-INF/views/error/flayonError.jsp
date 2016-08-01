<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%
Exception exception = (Exception) request.getAttribute("exception");
response.setHeader("error", "true");
response.setHeader("error.message", exception.getMessage());
if (exception.getCause() != null)
	response.setHeader("error.cause", exception.getCause().toString());
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>FlayOn Error</title>
<script type="text/javascript">
bgContinue = false;
</script>
</head>
<body>
<div class="container">

 	<div class="page-header">
	    <h1>${exception.message}</h1>
	</div>
    <pre>${exception.cause}</pre>

	<div class="text-right">
		<button class="btn btn-info" data-toggle="collapse" data-target="#webContext">view Web Attribute</button>
	</div>
	<div id="webContext" class="collapse">
	<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
	</div>
	
</div>
</body>
</html>
