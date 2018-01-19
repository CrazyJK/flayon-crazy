<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Image Series</title>
<link rel="stylesheet" href="${PATH}/css/app/image/config.css"/>
<style type="text/css">
body {
	background-color: #000;
}
.container-series {
}
#imageDiv {
	margin: 30px 100px;
	text-align: center;
}
.img-series {
	position: fixed;
}
.img-series-left-over {
}
.img-series-left {
	filter: grayscale(100%);
	cursor: e-resize;
	/* opacity: 0.6; */
}
.img-series-center {
	box-shadow: 0 0 10px 5px rgba(255, 255, 255, 0.5);
}
.img-series-right {
	filter: grayscale(100%);
	cursor: w-resize;
	opacity: 0.6;
}
.img-series-right-over {
	left: calc(100% * 2) !important;
}
select.label-black {
	border: 0;
}
.progress-bar {
	background: #000;
	color: #fff;
}
</style>
<script src="${PATH}/js/crazy.image.series.js"></script>
<script src="${PATH}/js/crazy.image.timer.engine.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	series.init();
});
</script>
</head>
<body>
	<div class="container-fluid container-series">
		<div id="leftTop">
			<div id="progressWrapper"></div>
		</div>
		<div id="leftBottom">
			<span id="playInterval" class="label label-black"></span>
			<select id="paths" class="label label-black"></select>
			<span id="path" class="label label-black hide"></span>
			<span id="name" class="label label-black"></span>
			<span id="index" class="label label-black"></span>
			<span id="length" class="label label-black"></span>
			<span id="modified" class="label label-black"></span>
		</div>
		<div id="rightBottom">
		</div>
		<div id="imageDiv"></div>
	</div>
</body>
</html>