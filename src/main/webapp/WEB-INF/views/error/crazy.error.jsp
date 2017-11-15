<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"   uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="jk" tagdir="/WEB-INF/tags"%>
<c:set value="${exception.kind eq 'Video'}" var="isVideo"/>
<c:set value="${exception.kind eq 'Image'}" var="isImage"/>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><s:message code="error.kamoru.title" arguments="${exception.kind}"/></title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/error.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
</head>
<body>

<div class="container">
    <small class="timestamp"><fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss" value="${timestamp}"/></small>
	<header class="page-header">
		<h1><span class="text-danger">${exception.message}</span></h1>
 		<h3><code><%=response.getStatus()%></code> <%=request.getAttribute("javax.servlet.error.request_uri") %></h3>
	</header>
	
	<div class="page-content">
		<c:if test="${isVideo && !empty exception.video}">
			<div class="video-card-box">
				<c:set var="video" value="${exception.video}"/>
				<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
			</div>
		</c:if>
	
	    <p>Error : <code>${exception}</code></p>
	    
	    <c:if test="${!empty exception.cause}">
	    	<p>Cause : <code>${exception.cause}</code></p>
	    </c:if>
    	
    	<c:if test="${isImage && !empty exception.image}">
		    <p>File : <code>${exception.image.file}</code></p>
	    </c:if>
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