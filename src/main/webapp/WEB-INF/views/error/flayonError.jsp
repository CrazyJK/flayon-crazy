<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>FlayOn Error</title>
</head>
<body>

	<div class="jumbotron">
	    <h1>FlayOn Error</h1>
	    <code>${exception.cause}</code>
	    <p>${exception.message}</p>
	</div>

</body>
</html>
