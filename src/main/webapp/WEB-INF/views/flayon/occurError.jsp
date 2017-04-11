<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<c:url value="/video/throwError" var="throwError"/>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>occur Error</title>
<style type="text/css">
.box-frame {
	background-clip: padding-box;
	border: 1px solid #999;
	border: 1px solid rgba(0,0,0,.2);
	border-radius: 6px;
	outline: 0;
	-webkit-box-shadow: 0 3px 9px rgba(0,0,0,.5);
	box-shadow: 0 3px 9px rgba(0,0,0,.5);
	margin: 10px;
	padding: 10px;
}
</style>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Occur Error</h1>
	</div>

	<div class="text-center">
		<div class="btn-group btn-group-sm">
			<a class="btn btn-default" target="errorFrame" href="/UnknownPage">general</a>
		</div>
		<div class="btn-group btn-group-sm">
			<a class="btn btn-default" target="errorFrame" href="?k=default">default</a>
			<a class="btn btn-default" target="errorFrame" href="?k=falyon">falyon</a>
		</div>
		<div class="btn-group btn-group-sm">
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=crazy">crazy</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=video">video</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=videonotfound">videoNotFound</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=studionotfound">studioNotFound</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=actressnotfound">actressNotFound</a>
		</div>
		<div class="btn-group btn-group-sm">
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=image">image</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=imagenotfound">imageNotFound</a>
		</div>
	</div>

	<iframe name="errorFrame" style="width:100%; height:500px;" class="box-frame"></iframe>
	
</div>
</body>
</html>