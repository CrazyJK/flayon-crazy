<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Image Tablet</title>
<link rel="stylesheet" href="${PATH}/css/app/image/slide.css"/>
<link rel="stylesheet" href="${PATH}/css/app/image/config.css"/>
<link rel="stylesheet" href="${PATH}/css/app/image/tablet.css"/>
<script src="${PATH}/js/crazy.image.timer.engine.js"></script>
<script src="${PATH}/js/crazy.image.tablet.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	tablet.init();
});
</script>
</head>
<body>
	<div class="container-fluid container-tablet">
		<div>
			<div id="leftTop">
				<div id="progressWrapper"></div>
			</div>
			<div id="leftBottom">
				<div class="configInfo">
					<code class="label label-plain   imageSource"></code>
					<code class="label label-plain    showMethod"></code>
					<code class="label label-plain  rotateDegree"></code>
					<code class="label label-plain    nextMethod"></code>
					<code class="label label-plain  playInterval"></code>
					<code class="label label-plain    hideMethod"></code>
					<code class="label label-plain displayMethod"></code>
				</div>
			</div>
			<div id="rightTop"></div>
			<div id="rightBottom"></div>
			<div id="fixedBox">
				<%@ include file="/WEB-INF/views/image/config.jspf"%>
				<span class="label label-plain displayCount">&nbsp;</span>
				<span class="label label-plain title popup-image">&nbsp;</span>
				<span class="close close-o0 delete-image">&times;</span>
			</div>
		</div>
		<div id="imageDiv"></div>
	</div>
</body>
</html>
