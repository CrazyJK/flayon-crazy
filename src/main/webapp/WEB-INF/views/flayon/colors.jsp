<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Standard colors</title>
<style type="text/css">
#colors {
	margin: 10px;
}
.colordvcon {
	display: inline-block;
	margin: 3px 1px;
	text-align: center;
	font-family: Courier,monospace;
	padding: 6px;
	width: 132px;
	border-radius: 5px;
	-webkit-border-radius: 5px;
}
.colordva {
	height: 120px;
	width: 120px;
	border-radius: 5px;
	-webkit-border-radius: 5px;
}
</style>
</head>
<body>
<div class="container" role="main" data-layout-fragment="content">

	<div class="page-header">
		<h1>Color Palette</h1>
 	</div>
 	
 	<div class="panel panel-info">
 		<div class="panel-heading">
	 		<h3 class="panel-title">If you want to see custom color, input parameter by <a href="?c=rgba(123,123,123,0.5)">?c=rgba(123,123,123,0.5)</a></h3>
	 	</div>
		<div class="panel-body" id="colors">
			<c:forEach items="aqua, black, blue, fuchsia, gray, green, lime, maroon, navy, olive, orange, purple, red, silver, teal, white, yellow" var="color">
			<div class="colordvcon">
				<div class="colordva" style="background-color: ${color}"></div>
				<code>${color}</code>
			</div>
			</c:forEach>
			<c:if test="${param.c != ''}">
			<div class="colordvcon">
				<div class="colordva" style="background-color: ${param.c}"></div>
				<code>${param.c}</code>
			</div>
			</c:if>
		</div>
 		<div class="panel-heading">
			Find more color <a href="http://www.color-hex.com/" target="_blank">www.color-hex.com</a>
		</div>
	</div>

</div>
</body>
</html>