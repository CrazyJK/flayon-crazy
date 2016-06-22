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
	/* border-bottom: 1px solid lightblue; */
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
	/* background-color:rgba(0,0,0,0); */
	border:0;
}
</style>
</head>
<body>
<div class="container-fluid">

	<div class="page-header">
		<h1>Log Viewer</h1>
 	</div>
 	
 	<div class="panel panel-info">
 		<div class="panel-heading">
			<form>
	 		<h3 class="panel-title">
				<label>Log path
					<input type="text" id="logpath" name="logpath" size="30" value="${logpath}" placeHolder="log file full path"/>
				</label>
				<label>Delimeter
					<input type="text" id="delimeter" name="delimeter" size="2" value="${delimeter}" placeHolder="delimeter"/>
				</label>
				<label>Keywords
					<input type="text" id="search" name="search" size="15" value="${search}" placeHolder="ex. http, error"/>
				</label>
				<label>and
					<input type="radio" name="searchOper" value="and" ${searchOper == 'and' ? 'checked' : ''}/>
				</label>
				<label>or
					<input type="radio" name="searchOper" value="or" ${searchOper == 'or' ? 'checked' : ''}/>
				</label>
				<button class="btn btn-sm btn-success" type="submit" style="float:right">View</button>
			</h3>
			</form>
		</div>
 		<div class="panel-body">
			<div class="error-msg">${msg}</div>
			<table class="table table-bordered">
				<c:forEach items="${lines}" var="line" varStatus="lineStatus">
				<tr>
					<td class="log-td log-no" style="padding:3px;">${lineStat.count}</td>
					<c:forEach items="${line}" var="str">
					<td class="log-td log-text" style="padding:3px;" colspan="${colspan}"><c:out value="${str}"/></td>
					</c:forEach>
				</tr>
				</c:forEach>
			</table>
		</div>		
	</div>

</div>
</body>
</html>