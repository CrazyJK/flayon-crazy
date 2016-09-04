<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Access Log</title>
<style type="text/css">
table {
	font-size: 0.8em;
}
tbody > tr:hover {
	background-color: rgba(255,165,0,.25);
}
th {
	background-color: rgba(255,165,0,.5);
}
td {
	font-family: "나눔고딕코딩";
}
* [onclick] {
	cursor:pointer;
}
* [onclick]:hover {
	color:orange; 
	text-decoration:none; 
	text-shadow:1px 1px 1px black;
}
.selected {
	color: blue;
}
.row {
    margin-right: -20px;
    margin-left: -20px;
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
<div class="container-fluid">

	<div class="page-header">
		<h1>Access Log Viewer</h1>
 	</div>

	<table id="list" class="table table-condensed">
		<thead>
			<tr>
				<th class="text-center">No</th>
				<th>Date</th>
				<th>RemoteAddr</th>
				<th>Method</th>
				<th>RequestURI</th>
				<th>ContentType</th>
				<th>ElapsedTime</th>
				<th>HandlerInfo</th>
				<th>ExceptionInfo</th>
				<th>ModelAndViewInfo</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${accessLogList}" var="accessLog" varStatus="accessLogStat">
			<tr>
				<td align="center">${accessLogStat.count}</td>
				<td align="left"  ><fmt:formatDate pattern="yy-MM-dd hh:mm:ss" value="${accessLog.accessDate}" /></td>
				<td align="left"  >${accessLog.remoteAddr}</td>
				<td align="left"  >${accessLog.method}</td>
				<td align="left"  >${accessLog.requestURI}</td>
				<td align="right" >${accessLog.contentType}</td>
				<td align="right" ><fmt:formatNumber type="number" pattern="#,##0 ms" value="${accessLog.elapsedTime}" /></td>
				<%-- <td align="center" title="${accessLog.handlerInfo}" data-toggle="popover" data-placement="left" data-content="${accessLog.exceptionInfo} ${accessLog.modelAndViewInfo}">Popover</td> --%>
				<td align="left"  >${fn:replace(accessLog.handlerInfo, 'org.springframework.web.servlet.mvc.', '')}</td>
				<td align="left"  >${accessLog.exceptionInfo}</td>
				<td align="left"  >${accessLog.modelAndViewInfo}</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>

</div>
</body>
</html>