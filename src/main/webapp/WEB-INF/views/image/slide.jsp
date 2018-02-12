<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title><s:message code="image.image-viewer"/></title>
<link rel="stylesheet" href="${PATH}/css/app/image/slide.css"/>
<script src="${PATH}/js/crazy.image.slide.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	slide.init();
});
</script>
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
					<code class="label label-plain    showMethod"></code>
					<code class="label label-plain    nextMethod"></code>
					<code class="label label-plain  playInterval"></code>
				</div>
			</div>
			<div id="rightTop"></div>
			<div id="rightBottom">
			  	<div id="pagingArea" class="text-center">
					<span class="label label-primary paging paging-first">0</span>
					<span class="label label-primary paging paging-curr">0</span>
					<span class="label label-primary paging paging-end">0</span>
			  	</div>
			</div>
			<div id="fixedBox">
				<%@ include file="/WEB-INF/views/image/config.jspf"%>
				<span class="label label-plain title popup-image">&nbsp;</span>
				<span class="close close-o0 delete-image">&times;</span>
			</div>
		</div>
		<div id="imageDiv" class="text-center"></div>
		<div id="thumbnailDiv">
			<ul id="thumbnailUL" class="list-inline"></ul>
		</div>
	</div>
</body>
</html>
