<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"   tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.actress"/> <s:message code="video.list"/></title>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript">
var table, resizeSecondDiv = function() {
	table.draw();
};
$(document).ready(function() {
	$("#viewBtn").on("click", function() {
		loading(true);
		location.href = location.pathname + "?i=" + $("#instance").is(":checked") + "&a=" + $("#archive").is(":checked");
	});
    table = $('#list').DataTable({
    	scrollY:        (calculatedDivHeight - 70),
        scrollCollapse: true,
        paging:         false,
        searching: false,
        processing: true,
        info: false,
        order: [[2, 'desc']],
        "fnDrawCallback": function( oSettings ) {
        	$("#actress-list").css({visibility: 'visible'}).addClass("w3-animate-opacity");
        }
    });
});
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search" class="title">
			<s:message code="video.actress"/> <span class="badge">${fn:length(actressList)}</span>
		</label>
		<input type="search" name="search" id="search" class="form-control input-sm" placeHolder="<s:message code="video.search"/>" onkeyup="searchContent(this.value)"/>
		
		<label>
			<input type="checkbox" id="instance" name="i" value="${instance}" ${instance ? 'checked=\"checked\"' : ''} class="sr-only"/>
			<span class="label" id="checkbox-instance">Instance</span>
		</label>
		<label>
			<input type="checkbox" id="archive" name="a" value="${archive}" ${archive ? 'checked=\"checked\"' : ''} class="sr-only"/>
			<span class="label" id="checkbox-archive">Archive</span>
		</label>
		
		<button class="btn btn-xs btn-default" id="viewBtn">View</button>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<div id="actress-list" style="visibility:hidden;">
			<table id="list" class="table table-condensed table-hover">
				<thead>
					<tr>
						<th style="max-width: 20px;">#</th>
						<c:forEach items="${sorts}" var="s">
						<th style="max-width: 50px;" title="<s:message code="actress.sort.${s}"/>"><s:message code="actress.sort.short.${s}"/></th>
						</c:forEach>
						<th style="max-width: 50px;">Age</th>
						<th>Video</th>
					</tr>
				</thead>
				<c:forEach items="${actressList}" var="actress" varStatus="status">
				<tr class="nowrap">
					<td class="number">${status.count}</td>
					<td><a onclick="fnViewActressDetail('${actress.name}')">${actress.name}</a></td>
					<td class="text-center">${actress.favorite ? '★' : ''}</td>
					<td>${actress.birth}</td>
					<td>${actress.bodySize}</td>
					<td class="number">${actress.height}</td>
					<td class="number">${actress.debut}</td>
					<td class="number">${fn:length(actress.videoList)}</td> 
					<td class="number">${actress.score}</td>
					<td class="number">${actress.age}</td>
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

</div>
</body>
</html>
