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
/* 
    $('#list').DataTable({
    	scrollY:        '60vh',
        scrollCollapse: true,
        paging:         false
    });
 */

	$("#size").on("keyup", function(e) {
		var event = window.event || e;
		if (event.keyCode == 13) {
			go(${pageImpl.number});
		}
	});
});
function go(page) {
	var size = $("#size").val();
	var remoteAddr = $("#remoteAddr").val();
	var requestURI = $("#requestURI").val();
	this.location.href = "?size=" + size + "&page=" + page + "&sort=id,desc&requestURI=" + requestURI + "&remoteAddr=" + remoteAddr;
}
</script>
</head>
<body>
<div class="container">
	<div class="page-header">
		<h1>Access Log Viewer
			<small class="badge">${pageImpl.totalElements}</small>
			<c:if test="${!useAccesslogRepository}">
				<span class="label label-danger" style="float:right;">No repository</span>
			</c:if>
		</h1>
 	</div>
</div>
<div class="container-fluid">
	<ul class="pager">
	    <c:if test="${!pageImpl.first}">
	    <li class="previous">
	        <a href="?page=${pageImpl.number-1}">&larr; Prev Page</a>
	    </li>
	    </c:if>
	    <c:if test="${!pageImpl.last}">
	    <li class="next">
	        <a href="?page=${pageImpl.number+1}">Next Page &rarr;</a>
	    </li>
	    </c:if>
	</ul>


	<table id="list" class="table table-condensed">
		<thead>
			<tr>
				<th class="text-center">No</th>
				<th>Date</th>
				<th>RemoteAddr</th>
				<th>User</th>
				<th>Method</th>
				<th>RequestURI</th>
				<!-- <th style="text-align:right">ContentType</th> -->
				<th style="text-align:right">Elapsed</th>
				<th>HandlerInfo</th>
				<th>ExceptionInfo</th>
				<!-- <th>ModelAndViewInfo</th> -->
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${pageImpl.content}" var="accessLog" varStatus="accessLogStat">
			<tr>
				<td align="center">${accessLogStat.count}</td>
				<td align="left"  ><fmt:formatDate pattern="yy-MM-dd hh:mm:ss" value="${accessLog.accessDate}" /></td>
				<td align="left"  >${accessLog.remoteAddr}</td>
				<td align="left"  >${accessLog.user.name}</td>
				<td align="left"  >${accessLog.method}</td>
				<td align="left"  >${accessLog.requestURI}</td>
				<%-- <td align="right" >${accessLog.contentType}</td> --%>
				<td align="right" ><fmt:formatNumber type="number" pattern="#,##0 ms" value="${accessLog.elapsedTime}" /></td>
				<%-- <td align="center" title="${accessLog.handlerInfo}" data-toggle="popover" data-placement="left" data-content="${accessLog.exceptionInfo} ${accessLog.modelAndViewInfo}">Popover</td> --%>
				<td align="left"  >${fn:replace(accessLog.handlerInfo, 'org.springframework.web.servlet.mvc.', '')}</td>
				<td align="left"  ><c:out value="${accessLog.exceptionInfo}"></c:out></td>
				<%-- <td align="left"  >${accessLog.modelAndViewInfo}</td> --%>
			</tr>
			</c:forEach>
			<tr>
				<td></td>
				<td></td>
				<td><input id="remoteAddr" name="remoteAddr" placeholder="remoteAddr" value="${param.remoteAddr}"/></td>
				<td></td>
				<td></td>
				<td><input id="requestURI" name="requestURI" placeholder="requestURI" value="${param.requestURI}"/></td>
				<td></td>
				<td></td>
				<td></td>
			</tr>
		</tbody>
	</table>

	<div class="text-center">
		<ul class="pagination">
			<c:forEach var="i" begin="0" end="${pageImpl.totalPages-1}" step="1">
				<c:if test="${i == 0 or i == pageImpl.totalPages-1 or (pageImpl.number - i < 5 and i - pageImpl.number < 5)}">
				  	<li class="${i eq pageImpl.number ? 'active' : ''}"><a href="javascript:go(${i})">${i == 0 ? 'First ' : ''}${i == pageImpl.totalPages-1 ? 'Last ' : ''}${i+1}</a></li>
				</c:if>
			</c:forEach>
		</ul>
		<div style="float: right;">
		    
		    
			<input id="size" size="2" placeholder="Line size" title="Line size" value="${pageImpl.size}" class="text-center"/>
		</div>
	</div>

	<code>
		totalElements: ${pageImpl.totalElements},
		totalPages: ${pageImpl.totalPages},
		first: ${pageImpl.first},
		last: ${pageImpl.last},
		number: ${pageImpl.number},
		size: ${pageImpl.size},
		numberOfElements: ${pageImpl.numberOfElements}
	</code>

</div>
</body>
</html>