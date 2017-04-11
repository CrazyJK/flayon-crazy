<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Log View</title>
<style type="text/css">
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
.table {
	font-size: 12px;
}
.table-condensed > tbody > tr > td {
	padding: 2px;
}
span.input-group-addon[role='label'] {
	cursor: pointer;
}
</style>
<script type="text/javascript">
$(document).ready(function() {
	$("[role='label']").on("click", function() {
		var id = $(this).attr("data-for");
		var val = $(this).attr("data-value");
		console.log("label click", id, val);
		$("#" + id).val(val);
	}); 
});
</script>
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
			<form class="form-inline">
				<div class="input-group input-group-sm">
	 				<span class="input-group-addon">Log path</span>
				  	<input type="text" id="logpath" name="logpath" size="30" value="${param.logpath}" placeHolder="log file full path" class="form-control"/>
				</div>
				<div class="input-group input-group-sm">
				 	<input type="text" id="delimeter" name="delimeter" size="7" value="${param.delimeter}" placeHolder="delimeter" class="form-control"/>
	 				<span class="input-group-addon">Delimeter</span>
					<input type="text" id="deliMax" name="deliMax" size="2" value="${param.deliMax}" placeHolder="max" class="form-control"/>
				</div>
				<div class="input-group input-group-sm">
	 				<span class="input-group-addon">Keywords</span>
					<input type="text" id="search" name="search" size="15" value="${param.search}" placeHolder="ex. http, error" class="form-control"/>
				</div>
				<div class="input-group input-group-sm">
	 				<span class="input-group-addon" role="label" data-for="oper" data-value="0">AND</span>
					<input type="range" id="oper" name="oper" min="0" max="1" value="${param.oper}" style="width:50px;" class="form-control">
	 				<span class="input-group-addon" role="label" data-for="oper" data-value="1">OR</span>
				</div>
				<button class="btn btn-sm btn-default" type="submit" style="float:right">View</button>
			</form>
		</div>
 		<div class="panel-body">
			<table class="table table-bordered table-condensed table-striped">
				<tbody>
					<c:forEach items="${lines}" var="line" varStatus="lineStatus">
					<tr>
						<c:forEach items="${line}" var="str" varStatus="status">
							<c:if test="${status.first}">
								<td class="log-no">${str}</td>
							</c:if>
							<c:if test="${!status.first}">
								<td class="log-text" colspan="${colspan}"><c:out value="${str}" escapeXml="false"/></td>
							</c:if>
						</c:forEach>
					</tr>
					</c:forEach>
				</tbody>
			</table>
			<div class="error-msg">${msg}</div>
		</div>		
	</div>

</div>
</body>
</html>