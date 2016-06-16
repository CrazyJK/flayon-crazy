<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Port Sacn</title>
<style type="text/css">
#postScan-container {
}
.result-li {
	display: inline-block;
	border:1px solid orange;
	font-size: 9pt;
	color: gray;
	border-radius: 5px;
	padding:2px;
}
.result-listen {
	color: red;
}
.result-close {
	display: none;
}
input, textarea {
	/* background-color:rgba(0,0,0,0); */
	border:0;
}
label {
	margin-right: 15px;
}
</style>
</head>
<body>
<div class="container" role="main" data-layout-fragment="content">

	<div class="page-header">
		<h1>Port Scanner</h1>
 	</div>
 	

 	<form>
 	<div class="panel panel-info">
 		<div class="panel-heading">
	 		<h3 class="panel-title">
		 		<label>IP Address
		 			<input name="ip" size="11" value="${ip}" placeHolder="ip address"/></label>
		 		<label>Port from
		 			<input name="ports" size="5" value="${ports}" placeHolder="port"/></label>
		 		<label>to
		 			<input name="porte" size="5" value="${porte}" placeHolder="port"/></label>
		 		<button class="btn btn-sm btn-success" style="float:right" type="submit">Scan</button>
	 		</h3>
 		</div>
 		<div class="panel-body">
	 		<textarea name="portArr" style="width:100%; height:100px;" placeHolder="ex. 8080, 8081, 8082">${portArr}</textarea>
		</div>
	</div>
 	</form>
 	
 	<div class="panel panel-info">
 		<div class="panel-heading">
			<h3 class="panel-title">Result - <span class="result-listen">LISTEN</span></h3>
 		</div>
 		<div class="panel-body">
 			<c:forEach items="${results}" var="result">
	 		<span class="result-li ${result[2] ? 'result-listen' : 'result-close'}">${result[1]}</span>
	 		</c:forEach>
		</div>
	</div>

</div>
</body>
</html>
