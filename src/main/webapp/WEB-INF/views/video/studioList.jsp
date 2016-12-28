<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"     tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.studio"/> <s:message code="video.list"/></title>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/videoMain.js"/>"></script>
<script type="text/javascript">
var table;
$(document).ready(function() {
    table = $('#list').DataTable({
    	scrollY:        (calculatedDivHeight - 70),
        scrollCollapse: true,
        paging:         false,
        searching: false,
        processing: true,
        info: false
    });
});

function resizeSecondDiv() {
	table.draw();
}
function view() {
	loading(true);
	location.href = location.pathname + "?i=" + $("#instance").is(":checked") + "&a=" + $("#archive").is(":checked");
}
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search" class="title">
			<s:message code="video.total"/> <s:message code="video.studio"/> <span class="badge">${fn:length(studioList)}</span>
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
		
		<button class="btn btn-xs btn-default" onclick="view()">View</button>

	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<table id="list" class="table table-condensed table-hover">
			<thead>
				<tr>
					<th>#</th>
					<c:forEach items="${sorts}" var="s">
					<th title="<s:message code="studio.sort.${s}"/>"><s:message code="studio.sort.short.${s}"/></th>
					</c:forEach>
					<th>Video</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${studioList}" var="studio" varStatus="status">
				<tr class="nowrap">
					<td class="number">${status.count}</td>
					<td><a onclick="fnViewStudioDetail('${studio.name}')">${studio.name}</a></td>
					<td><a href="<s:url value="${studio.homepage}" />" target="_blank">${studio.homepage}</a></td>
					<td>${studio.company}</td>
					<td class="number">${fn:length(studio.videoList)}</td>
					<td class="number">${studio.score}</td>
					<td style="max-width:150px;">
						<div class="nowrap">
							<c:forEach items="${studio.videoList}" var="video">
							<jk:video video="${video}" view="opus"/>
							</c:forEach>
						</div>
					</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>

</div>
</body>
</html>
