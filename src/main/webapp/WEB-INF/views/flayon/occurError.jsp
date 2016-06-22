<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
		<h1>Occur Error
			<small>
				<a class="text-danger" target="errorFrame" href="?k=default">default</a>
				<a class="text-danger" target="errorFrame" href="?k=falyon">falyon</a>
			</small>
		</h1>
	</div>

	<iframe name="errorFrame" style="width:100%; height:500px;" class="box-frame"></iframe>
	
</div>
</body>
</html>