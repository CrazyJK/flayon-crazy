<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"  uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk" tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="error.video.title" arguments="${exception.video.opus}"/></title>
<link rel="stylesheet" href="<c:url value="/css/video-main.css"   />" />
<script type="text/javascript">
bgContinue = false;
if (self.innerHeight == 0) {
	alert('<s:message code="error.video.message" arguments="${exception.video.opus},${exception.message}"/>');
}
</script>
</head>
<body>
	
	<div class="container">
		<div class="jumbotron">
			<header id="page-header">
				<h1>${exception.kind} Error ${exception.video.opus}</h1>
				<h2>${exception.message}</h2>
			</header>
		</div>
		<c:if test="${exception.kind eq 'Video'}">
			<ul>
				<c:set var="video" value="${exception.video}"/>
				<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
			</ul>
		</c:if>
	
		<c:if test="${exception.kind eq 'Video'}">
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