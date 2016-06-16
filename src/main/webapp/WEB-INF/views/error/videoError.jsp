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
if (self.innerHeight == 0) {
	alert('<s:message code="error.video.message" arguments="${exception.video.opus},${exception.message}"/>');
}
</script>
</head>
<body>

	<header id="error-header">
		<h1><s:message code="error.video.header" arguments="${exception.video.opus}"/></h1>
		<h2><s:message code="error.video.message" arguments="${exception.video.opus},${exception.message}"/></h2>
		<ul>
			<c:set var="video" value="${exception.video}"/>
			<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
		</ul>
	</header>
	<article id="error-article">
		<jk:error/>
	</article>

</body>
</html>