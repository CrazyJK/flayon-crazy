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
			<a class="btn btn-default" target="errorFrame" href="/UnknownPage">404</a>
		</div>
		<div class="btn-group btn-group-sm">
			<a class="btn btn-default" target="errorFrame" href="?k=error">error</a>
			<a class="btn btn-default" target="errorFrame" href="?k=runtime">runtime</a>
		</div>
		<div class="btn-group btn-group-sm">
			<a class="btn btn-default" target="errorFrame" href="?k=base1">base1</a>
			<a class="btn btn-default" target="errorFrame" href="?k=base2">base2</a>
		</div>
		<div class="btn-group btn-group-sm">
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=Crazy">crazy</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=Video">video</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=Image">image</a>
		</div>
		<div class="btn-group btn-group-sm">
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=VideoNotFound">videoNotFound</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=StudioNotFound">studioNotFound</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=ActressNotFound">actressNotFound</a>
			<a class="btn btn-default" target="errorFrame" href="${throwError}?k=ImageNotFound">imageNotFound</a>
		</div>
	</div>

	<iframe name="errorFrame" style="width:100%; height:500px;" class="box-frame"></iframe>
	
</div>
</body>
</html>