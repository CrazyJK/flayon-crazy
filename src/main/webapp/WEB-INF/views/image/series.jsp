<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Image Series</title>
<style type="text/css">
body {
	background-color: #000;
}
.container-series {
}
#pathInfo {
	position: fixed;
	left: 0;
	top: 0;
	padding: 3px;	
}
#imageInfo {
	position: fixed;
	left: 0;
	bottom: 0;
	margin: 5px;
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
}
.img-series-center {
	filter: grayscale(0);
}
.img-series-right {
	filter: grayscale(100%);
}
.img-series-right-over {
	left: calc(100% * 2) !important;
	filter: grayscale(100%);
} 
</style>
<script src="${PATH}/js/crazy.image.series.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	series.init();
});
</script>
</head>
<body>
	<div class="container-fluid container-series">
		<div id="pathInfo">
			<select id="paths" class="label-black"></select>
		</div>
		<div id="imageInfo">
			<span id="path" class="label label-black"></span>
			<span id="name" class="label label-black"></span>
			<span id="index" class="label label-black"></span>
			<span id="length" class="label label-black"></span>
			<span id="modified" class="label label-black"></span>
		</div>
		<div id="imageDiv"></div>
	</div>
</body>
</html>