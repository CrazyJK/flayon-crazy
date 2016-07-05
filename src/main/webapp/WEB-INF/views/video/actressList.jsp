<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"     tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.actress"/> <s:message code="video.list"/></title>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript">
var table;
$(document).ready(function() {
    table = $('#list').DataTable({
    	scrollY:        (calculatedDivHeight - 70),
        scrollCollapse: true,
        paging:         false,
        searching: false,
        processing: true,
        info: false,
        order: [[7, 'desc']]
    });
});

function resizeSecondDiv() {
	table.draw();
}
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search">
			<s:message code="video.total"/> <s:message code="video.actress"/> <span class="badge">${fn:length(actressList)}</span>
		</label>
		<input type="search" name="search" id="search" class="form-control input-sm" placeHolder="<s:message code="video.search"/>" onkeyup="searchContent(this.value)"/>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<table id="list" class="table table-condensed table-hover table-bordered">
			<thead>
				<tr>
					<th>#</th>
					<c:forEach items="${sorts}" var="s">
					<th title="<s:message code="actress.sort.${s}"/>"><s:message code="actress.sort.short.${s}"/></th>
					</c:forEach>
					<th>Age</th>
					<th>Video</th>
				</tr>
			</thead>
			<c:forEach items="${actressList}" var="actress" varStatus="status">
			<tr class="nowrap">
				<td class="text-right">${status.count}</td>
				<td><a onclick="fnViewActressDetail('${actress.name}')">${actress.name}</a></td>
				<td class="text-center">${actress.favorite ? '★' : ''}</td>
				<td>${actress.birth}</td>
				<td>${actress.bodySize}</td>
				<td class="text-right">${actress.height}</td>
				<td class="text-right">${actress.debut}</td>
				<td class="text-right">${fn:length(actress.videoList)}</td> 
				<td class="text-right">${actress.score}</td>
				<td class="text-right">${actress.age}</td>
				<td style="max-width:150px;">
					<div class="nowrap">
						<c:forEach items="${actress.videoList}" var="video">
						<jk:video video="${video}" view="opus"/>
						</c:forEach>
					</div>
				</td>
			</tr>
			</c:forEach>
		</table>
	</div>

</div>
</body>
</html>
