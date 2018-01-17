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
	filter: grayscale(100%);
}
.img-series-left {
	filter: grayscale(100%);
	cursor: e-resize;
}
.img-series-center {
	filter: grayscale(0);
}
.img-series-right {
	filter: grayscale(100%);
	cursor: w-resize;
}
.img-series-right-over {
	left: calc(100% * 2) !important;
	filter: grayscale(100%);
}
select.label-black {
	border: 0;
}
input[type=text].label-black {
	border: 0;
	width: 30px;
	text-align: right;
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
			<span id="path" class="label label-black"></span>
			<span id="name" class="label label-black"></span>
			<span id="index" class="label label-black"></span>
			<span id="length" class="label label-black"></span>
			<span id="modified" class="label label-black"></span>
		</div>
		<div id="rightBottom">
			<span id="playInterval" class="label-black"></span>
			<select id="paths" class="label-black"></select>
		</div>
		<div id="imageDiv"></div>
	</div>
</body>
</html>