<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Standard colors</title>
<style type="text/css">
#colors {
	padding: 10px;
}
.colordvcon {
	display: inline-block;
	margin: 3px 1px;
	text-align: center;
	padding: 5px;
	border-radius: 5px;
}
.colordva {
	height: 100px;
	width: 100px;
	border-radius: 5px;
	margin-bottom: 5px;
	box-shadow: 0 2px 2px 0 rgba(0,0,0,0.16),0 0 0 1px rgba(0,0,0,0.08);
	transition: all .5s ease;
}
.colordva:hover {
    box-shadow: 0 3px 8px 0 rgba(0,0,0,0.2),0 0 0 1px rgba(0,0,0,0.08);
    transform: scale(1.1, 1.1);
}
</style>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Color Palette</h1>
 	</div>
 	
 	<div class="panel panel-default">
 		<div class="panel-heading">
	 		<h3 class="panel-title">If you want to see custom color, add parameter like <a href="?c=rgba(123,123,123,0.5)">?c=rgba(123,123,123,0.5)</a></h3>
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