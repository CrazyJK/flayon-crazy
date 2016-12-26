<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>RequestMapping List</title>
<style type="text/css">
table {
	font-size:0.8em;
}
thead > tr {
	background-color:rgba(255,165,0,.5);
}
tbody > tr:hover {
	background-color:rgba(255,165,0,.25);
}
td {
	font-family: "나눔고딕코딩";
}
.link:hover {
	color:orange; 
	text-decoration:none; 
	text-shadow:1px 1px 1px black;
}
</style>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript">
$(document).ready(function() {
    $('#list').DataTable({
    	scrollY:        '60vh',
        scrollCollapse: true,
        paging:         false
    });
});
</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Request Mapping List</h1>
 	</div>

	<table id="list" class="table table-condensed">
		<thead>
			<tr>
				<th class="text-center">No</th>
				<th>Method</th>
				<th>Pattern</th>
				<th class="text-right">Class</th>
				<th>Method</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${mappingList}" var="mapping" varStatus="mappingStat">
			<tr>
				<td align="center">${mappingStat.count}</td>
				<td align="center">${mapping.reqMethod}</td>
				<td align="left"  ><a href="${mapping.reqPattern}" class="link" target="_blank">${mapping.reqPattern}</a></td>
				<td align="right" >${mapping.beanType}</td>
				<td align="left"  >${mapping.beanMethod}</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>

</div>
</body>
</html>
