<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>Server Error</title>
</head>
<body>

	<div class="jumbotron">
	    <h1>${error}</h1>
	    <p>${status} ${exception}</p>
	    <p>${message}</p>
	    <div id='created'>${timestamp}</div>
	</div>

</body>
</html>
