<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="image.image-viewer"/> by SlidesJS</title>
<link rel="stylesheet" href="${PATH}/css/app/image/slidesjs.css"/>
<script src="${PATH}/js/jquery.slides.js"></script>
<script src="${PATH}/js/crazy.image.slidesjs.js"></script>
</head>
<body>
	<div class="container-fluid">
		<div>
			<div id="leftTop">
				<div id="progressWrapper"></div>
			</div>
			<div id="leftBottom">
				<div class="configInfo">
					<code class="label label-plain   imageSource"></code>
					<code class="label label-plain    nextMethod"></code>
					<code class="label label-plain  playInterval"></code>
				</div>
			</div>
			<div id="rightTop"></div>
			<div id="rightBottom"></div>
			<div id="fixedBox">
				<%@ include file="/WEB-INF/views/image/config.jspf"%>
				<span class="label label-plain page-no"></span>
				<span class="label label-plain title popup-image"></span>
			</div>
		</div>
		<div id="container-slidesjs"></div>
	</div>
</body>
</html>