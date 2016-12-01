<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Port Sacn</title>
<style type="text/css">
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
input {
	/* background-color:rgba(0,0,0,0); */
	/* border:0; */
	text-align: center;
}
label {
	margin-right: 15px;
}
</style>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Port Scanner</h1>
 	</div>

 	<form>
 	<div class="panel panel-default">
 		<div class="panel-heading">
	 		IP Address <input name="ip" size="11" value="${ip}" placeHolder="ip address"/>
	 		 Port from <input name="ports" size="5" value="${ports}" placeHolder="port"/>
	 		        to <input name="porte" size="5" value="${porte}" placeHolder="port"/>
	 		<button class="btn btn-sm btn-default" style="float:right" type="submit">Scan</button>
 		</div>
 		<div class="panel-body">
	 		<textarea name="portArr" style="width:100%; height:100px;" placeHolder="ex. 8080, 8081, 8082">${portArr}</textarea>
		</div>
	</div>
 	</form>
 	
 	<div class="panel panel-default">
 		<div class="panel-heading">
			Result - <span class="result-listen">LISTEN</span>
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
