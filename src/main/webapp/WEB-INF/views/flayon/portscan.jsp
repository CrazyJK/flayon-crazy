<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Port Sacn</title>
<style type="text/css">
input {
	text-align: center;
}
.input-group-addon {
	border-right: 0;
}
</style>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Port Scanner</h1>
 	</div>

 	<form class="form-inline">
 	<div class="panel panel-default">
 		<div class="panel-heading">
 			<div class="input-group input-group-sm">
	 			<span class="input-group-addon">IP Address</span>
		 		<input name="ip" size="11" value="${param.ip}" placeHolder="ip address" class="form-control"/>
		 	</div>
 			<div class="input-group input-group-sm">
	 			<span class="input-group-addon">Port</span>
	 			<span class="input-group-addon">from</span>
	 		   	<input name="from" size="5" value="${param.from}" placeHolder="port" class="form-control"/>
	 			<span class="input-group-addon">to</span>
	 		    <input name="to"   size="5" value="${param.to}"   placeHolder="port" class="form-control"/>
	 		</div>
	 		<button class="btn btn-sm btn-default" style="float:right" type="submit">Scan</button>
 		</div>
 		<div class="panel-body">
	 		<textarea name="list" style="width:100%; height:100px;" placeHolder="ex. 8080, 8081, 8082" class="form-control">${param.list}</textarea>
		</div>
	</div>
 	</form>
 	
 	<div class="panel panel-default">
 		<div class="panel-heading">
			Result - <span class="result-listen">Listen ports</span>
 		</div>
 		<div class="panel-body">
 			<c:forEach items="${results}" var="result">
 				<c:if test="${result[2]}">
			 		<span class="label label-danger">${result[1]}</span>
 				</c:if>
	 		</c:forEach>
		</div>
	</div>

</div>
</body>
</html>
