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
#navDiv > * {
	cursor: pointer;
}
</style>
<script src="${PATH}/js/flayon.effect.aperture.js"></script>
<script src="${PATH}/js/crazy.image.timer.engine.js"></script>
<script src="${PATH}/js/crazy.image.aperture.js"></script>
</head>
<body>
<div class="container-fluid">

<div id="navDiv">
	<span class="label label-info paging paging-first"><span id="firstNo"></span></span>
	<span class="label label-info paging paging-prev" ><i class="glyphicon glyphicon-menu-left"></i><span id="leftNo"></span></span>
	<span class="label label-info paging"><span id="currNo"></span></span>
	<span class="label label-info paging paging-next" ><span id="rightNo"></span><i class="glyphicon glyphicon-menu-right"></i></span>
	<span class="label label-info paging paging-end"  ><span id="endNo"></span></span>
	<span class="label label-info" id="imageTitle"></span>
	<div id="progressWrapper"></div>
</div>

<div id="imageDiv">
	<div id="aperture"></div>
</div>

</div>
</body>
</html>
