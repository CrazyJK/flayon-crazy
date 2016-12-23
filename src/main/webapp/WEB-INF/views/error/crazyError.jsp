<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"  uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk" tagdir="/WEB-INF/tags"%>

<!DOCTYPE html>
<html>
<head>
<title><s:message code="error.kamoru.title" arguments="${exception.kind}"/></title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/bootstrap-crazy.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
<script type="text/javascript">
bgContinue = false;
if (self.innerHeight == 0)
	alert('<s:message code="error.kamoru.message" arguments="${exception.kind},${exception.message}"/>');
</script>
</head>
<body>

	<div class="container">
		<div class="jumbotron">
			<header id="page-header">
				<h1>${exception.kind} Error</h1>
				<h2>${exception.message}</h2>
			</header>
		</div>

		<div class="error-detail">
			<div class="text-right">
				<button class="btn btn-link" data-toggle="collapse" data-target="#webContext">view Web Attribute</button>
			</div>
			<div id="webContext" class="collapse">
				<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
			</div>
		</div>
	</div>

</body>
</html>