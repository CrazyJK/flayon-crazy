<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>RequestMapping List</title>
<style type="text/css">
td, td a {
	font-family: "나눔고딕코딩";
	font-size: 11px;
}
.link:hover {
	color:orange; 
	text-decoration:none; 
	text-shadow:1px 1px 1px black;
}
.beanType::after {
	content: ' .';
	color : #a94442;
}
.beanMethod::before {
}

th:hover {
	color: red;
}
</style>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript">
$(document).ready(function() {
	var windowHeight = $(window).innerHeight();
	var tableHeight = windowHeight - 200;
	console.log(windowHeight, tableHeight);
	
	$(window).resize(function() {
		$(".dataTables_scrollBody").css("max-height", $(window).innerHeight() - 200);
	});

    $('#list').DataTable({
    	scrollY:        tableHeight + 'px',
        scrollCollapse: true,
        paging:         false,
        searching:      false,
        info:           false
    });
});
</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Request Mapping List ... <span class="badge">${mappingList.size()}</span></h1>
 	</div>

	<table id="list" class="table table-condensed table-hover">
		<thead class="bg-primary">
			<tr>
				<th class="text-center">No</th>
				<th class="text-center">Method</th>
				<th>Pattern</th>
				<th class="text-right">Controller</th>
				<th>Method</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${mappingList}" var="mapping" varStatus="mappingStat">
			<tr>
				<td class="text-center">${mappingStat.count}</td>
				<td class="text-center">${mapping.reqMethod}</td>
				<td><a href="${mapping.reqPattern}" class="link" target="_blank">${mapping.reqPattern}</a></td>
				<td class="text-right beanType">${mapping.beanType}</td>
				<td class="beanMethod">${mapping.beanMethod}</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>

</div>
</body>
</html>
