<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Aperture</title>
<style type="text/css">
body, .label-info, .progress, .paging, .img-circle {
	transition: background .5s ease, background-image .5s ease;
}
</style>
<script src="${PATH}/js/flayon.effect.aperture.js"></script>
<script src="${PATH}/js/crazy.image.aperture.js"></script>
</head>
<body>
	<div class="container-fluid">
		<div>
			<div id="leftTop">
				<div id="progressWrapper"></div>
				<div id="pagingArea" class="text-center">
					<span class="label label-primary paging paging-first"><span id="firstNo">0</span></span>
					<span class="label label-primary paging"><span id="currNo"></span></span>
					<span class="label label-primary paging paging-end"  ><span id="endNo"></span></span>
				</div>		
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
				<span class="label label-plain" id="imageTitle"></span>
			</div>
		</div>
		<div id="imageDiv">
			<div id="aperture"></div>
		</div>
	</div>
</body>
</html>
