<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"     tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.studio"/> <s:message code="video.list"/></title>
<script type="text/javascript">
function sort(selectedSort) {
	var reverseOrder = '${sort.name()}' == selectedSort ? ${!reverse} : true;
	location.href = "?sort=" + selectedSort + "&r=" + reverseOrder;
}
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search">
			<s:message code="video.total"/> <s:message code="video.studio"/> <span class="badge">${fn:length(studioList)}</span>
		</label>
		<input type="search" name="search" id="search" class="form-control input-sm" placeHolder="<s:message code="video.search"/>" onkeyup="searchContent(this.value)"/>
	</div>
	
	<div id="content_div" class="box">
		<table class="table table-condensed table-hover table-bordered">
			<thead>
				<tr>
					<th>#</th>
					<c:forEach items="${sorts}" var="s">
					<th>
						<span onclick="sort('${s}')"><s:message code="studio.sort.${s}"/></span>
						<c:if test="${s eq sort}">
							<c:if test="${!reverse}">
							<span class="glyphicon glyphicon-chevron-up"></span>
							</c:if>
							<c:if test="${reverse}">
							<span class="glyphicon glyphicon-chevron-down"></span>
							</c:if>
						</c:if>
					</th>
					</c:forEach>
					<th>Video</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${studioList}" var="studio" varStatus="status">
				<tr class="nowrap">
					<td class="text-right">${status.count}</td>
					<td><a onclick="fnViewStudioDetail('${studio.name}')">${studio.name}</a></td>
					<td><a href="<s:url value="${studio.homepage}" />" target="_blank">${studio.homepage}</a></td>
					<td>${studio.company}</td>
					<td class="text-right">${fn:length(studio.videoList)}</td>
					<td class="text-right">${studio.score}</td>
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
