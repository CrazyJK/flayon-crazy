<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"  uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk" tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="error.image.title" arguments="${exception.image.name}"/></title>
<script type="text/javascript">
bgContinue = false;
if (self.innerHeight == 0)
	alert('<s:message code="error.image.message" arguments="${exception.image.name},${exception.message}"/>');
</script>
</head>
<body>

	<div class="container">
		<div class="jumbotron">
			<header id="page-header">
				<h1>${exception.kind} Error ${exception.image.idx}</h1>
				<h2>${exception.message}</h2>
			</header>
		</div>
		<c:if test="${exception.kind eq 'Image'}">
			<img src="<c:url value="/image/${exception.image.idx}"/>" width="400px"/>
		</c:if>

		<c:if test="${exception.kind eq 'Image'}">
			<div class="text-right">
				<button class="btn btn-info" data-toggle="collapse" data-target="#webContext">view Web Attribute</button>
			</div>
			<div id="webContext" class="collapse">
			<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    
			</div>
<%-- 		
			<article id="error-article">
				<jk:error/>
			</article>
 --%>
		</c:if>

	</div>

</body>
</html>