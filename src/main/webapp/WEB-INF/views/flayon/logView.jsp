<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Log View</title>
<style type="text/css">
.log-td {
	font-size: 9pt;
	padding:3px;
}
.log-no {
	width: 15px;
	color: blue;
	text-align: right;
}
.log-text {
	/* white-space:nowrap; */
}
em {
	color: red;
	font-style: normal;
}
.error-msg {
	color: red;
}
input, textarea {
	border:0;
}
</style>
</head>
<body>
<div class="container">
	<div class="page-header">
		<h1>Log Viewer...<span class="badge">${lines.size()}</span></h1>
 	</div>
</div> 	
<div class="container-fluid">
 	<div class="panel panel-default">
 		<div class="panel-heading">
			<form>
				Log path  <input type="text" id="logpath" name="logpath" size="30" value="${logpath}" placeHolder="log file full path"/>
				Delimeter <input type="text" id="delimeter" name="delimeter" size="7" value="${delimeter}" placeHolder="delimeter"/>
						  <input type="text" id="deliMax" name="deliMax" size="2" value="${deliMax}" placeHolder="max"/>
				Keywords  <input type="text" id="search" name="search" size="15" value="${search}" placeHolder="ex. http, error"/>
				<input type="radio" name="searchOper" value="and" ${searchOper == 'and' ? 'checked' : ''}/>AND
				<input type="radio" name="searchOper" value="or" ${searchOper == 'or' ? 'checked' : ''}/>OR
				<button class="btn btn-sm btn-default" type="submit" style="float:right">View</button>
			</form>
		</div>
 		<div class="panel-body">
			<div class="error-msg">${msg}</div>
			<table class="table table-bordered">
				<tbody>
					<c:forEach items="${lines}" var="line" varStatus="lineStatus">
					<tr>
						<td class="log-td log-no">${lineStatus.count}</td>
						<c:forEach items="${line}" var="str">
						<td class="log-td log-text" colspan="${colspan}"><c:out value="${str}" escapeXml="false"/></td>
						</c:forEach>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</div>		
	</div>

</div>
</body>
</html>