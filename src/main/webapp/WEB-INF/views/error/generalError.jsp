<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="s"   uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>General Error</title>
<script type="text/javascript">
bgContinue = false;
</script>
</head>
<body>
<div class="container">

 	<div class="page-header">
 		<h1>Opps.. Sorry!
	    	<small style="float:right"><fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss" value="${timestamp}"/></small>
 		</h1>
	</div>
	<p>${exception.message}</p>
    <code>
    	${exception.cause}
    </code>

	<div class="text-right">
		<button class="btn btn-link" data-toggle="collapse" data-target="#webContext">view Web Attribute</button>
	</div>
	<div id="webContext" class="collapse">
	<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
	</div>
	
</div>
</body>
</html>
