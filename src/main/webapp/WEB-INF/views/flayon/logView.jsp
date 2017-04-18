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
	font-size: 14px;
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
.row {
	margin: 3px 0;
}
.col-sm-1, .col-sm-2, .col-sm-3, .col-sm-6, .col-sm-9 {
	padding: 0 5px;
}  
</style>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript">
$(document).ready(function() {
	$("[role='label']").on("click", function() {
		var id = $(this).attr("data-for");
		var val = $(this).attr("data-value");
		console.log("label click", id, val);
		$("#" + id).val(val);
	});
	
	var lineSize = ${lines.size()};
	if (lineSize < 1000) {
		var windowHeight = $(window).innerHeight();
		var tableHeight = windowHeight - 400;
	    $('.table').DataTable({
	    	scrollY:        tableHeight + 'px',
	        scrollCollapse: true,
	        paging:         false,
	        searching:      false,
	        info:           false
	    });
	}

});
</script>
</head>
<body>
<div class="container">
	<div class="page-header">
		<h1>Log Viewer...<span class="badge">${lines.size()}</span><span class="error-msg float-right">${msg}</span></h1>
 	</div>
</div> 	
<div class="container-fluid">
 	<div class="panel panel-default">
 		<div class="panel-heading">
			<div class="container">
			<form>
				<div class="row">
					<div class="col-sm-9">
						<div class="input-group input-group-sm">
			 				<span class="input-group-addon">Log path</span>
						  	<input type="text" id="logpath" name="logpath" size="30" value="${param.logpath}" placeHolder="log file full path" class="form-control"/>
						</div>
					</div>
					<div class="col-sm-3">
						<div class="input-group input-group-sm col-sm-9">
			 				<span class="input-group-addon">Charset</span>
						  	<input type="text" id="charset" name="charset" size="6"  value="${param.charset}" placeHolder="charset" class="form-control"/>
						</div>
					</div>
				</div>
				<div class="row">
					<div class="col-sm-3">
						<div class="input-group input-group-sm">
						 	<input type="text" id="delimeter" name="delimeter" size="4" value="${param.delimeter}" placeHolder="delimeter" class="form-control"/>
			 				<span class="input-group-addon" style="border-right:none; border-left:none;">Delimeter</span>
							<input type="number" id="deliMax" name="deliMax" size="1" value="${param.deliMax}" placeHolder="max" class="form-control" style="width:60px;"/>
						</div>
					</div>
					<div class="col-sm-6">
						<div class="input-group input-group-sm">
			 				<span class="input-group-addon">Keywords</span>
							<input type="text" id="search" name="search" size="15" value="${param.search}" placeHolder="ex. http, error" class="form-control"/>
						</div>
					</div>
					<div class="col-sm-2">
						<div class="input-group input-group-sm">
			 				<span class="input-group-addon" role="label" data-for="oper" data-value="0">AND</span>
							<input type="range" id="oper" name="oper" min="0" max="1" value="${param.oper}" class="form-control">
			 				<span class="input-group-addon" role="label" data-for="oper" data-value="1">OR</span>
						</div>
					</div>
					<div class="col-sm-1">
						<button class="btn btn-sm btn-default" type="submit" style="float:right">View</button>
					</div>
				</div>
			</form>
			</div>
		</div>
 		<div class="panel-body" style="padding:5px;">
			<table class="table table-bordered table-condensed table-striped">
				<thead class="bg-info">
					<tr>
						<th>line</th>
						<c:forEach var="x" begin="1" end="${tdCount}">
						<th>Col-${x}</th>
						</c:forEach>
					</tr>
				</thead>
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
		</div>		
	</div>

</div>
</body>
</html>