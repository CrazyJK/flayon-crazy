<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"  uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="error.image.title" arguments="${exception.image.name}"/></title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/bootstrap-crazy.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
<script type="text/javascript">
bgContinue = false;
if (self.innerHeight == 0)
	alert('<s:message code="error.image.message" arguments="${exception.image.name},${exception.message}"/>');
</script>
</head>
<body>

	<div class="container">
		<div class="jumbotron">
			<c:if test="${exception.kind eq 'Image'}">
			<img src="<c:url value="/image/${exception.image.idx}"/>" class="img-thumbnail" style="height:150px; float:right;"/>
			</c:if>
			<header id="page-header">
				<h1>${exception.kind} ${exception.image.idx}</h1>
				<h2>${exception.message}</h2>
			</header>
		</div>
		
		<c:if test="${exception.kind eq 'Image'}">
		<div class="error-detail">
			
			<div class="text-right">
				<button class="btn btn-link" data-toggle="collapse" data-target="#webContext">view Web Attribute</button>
			</div>
			<div id="webContext" class="collapse">
				<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
			</div>
		</div>
		</c:if>
	</div>

</body>
</html>