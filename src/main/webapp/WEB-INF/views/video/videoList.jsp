<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<c:set var="ONE_GB" value="${1024*1024*1024}"/>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title><s:message code="video.video"/> <s:message code="video.list"/></title>
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
<div class="container-fluid" role="main">
	<div id="header_div" class="box form-inline">
		<label for="search">
			<s:message code="video.total"/> <s:message code="video.video"/> <span class="badge">${fn:length(videoList)}</span>
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
		<table id="list" class="table table-condensed table-hover table-bordered">
			<thead>
				<tr>
					<th>#</th>
					<c:forEach items="${sorts}" var="s">
					<th title="<s:message code="video.sort.${s.desc}"/>"><s:message code="video.sort.short.${s.desc}"/></th>
					</c:forEach>
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${videoList}" var="video" varStatus="status">
				<tr class="nowrap">
					<td class="number">${status.count}</td>
					<td style="max-width: 90px;">
						<div class="nowrap">
							<a onclick="fnViewStudioDetail('${video.studio.name}')">${video.studio.name}</a>
						</div>
					</td>
					<td>
						<a onclick="fnViewVideoDetail('${video.opus}')">${video.opus}</a>
					</td>
					<td style="max-width: 150px;">
						<div class="nowrap" title="${video.title}">${video.title}</div>
					</td>
					<td style="max-width: 100px;">
						<div class="nowrap">
						<c:forEach items="${video.actressList}" var="actress">
							<a onclick="fnViewActressDetail('${actress.name}')">${actress.name}</a>
						</c:forEach>
						</div>
					</td>
					<td>${video.releaseDate}</td>
					<td>${video.videoDate}</td>
					<td class="number">${video.playCount}</td>
					<td class="number">${video.rank}</td>
					<td class="number">
						<fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.00G"/>
					</td>
					<td class="number">
						<span title="${video.scoreDesc}">${video.score}</span>
					</td>
					<td class="number">${video.videoCandidates.size()}</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>
</div>  
</body>
</html>
