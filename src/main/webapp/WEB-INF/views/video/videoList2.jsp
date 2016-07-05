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
<script type="text/javascript">
function sort(selectedSort) {
	var reverseOrder = '${sort.name()}' == selectedSort ? ${!reverse} : true;
	location.href = "?sort=" + selectedSort + "&r=" + reverseOrder;
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
	</div>

	<div id="content_div" class="box">
		<table class="table table-condensed table-hover">
			<thead>
				<tr>
					<th>#</th>
					<c:forEach items="${sorts}" var="s">
					<th>
						<span onclick="sort('${s}')"><s:message code="video.sort.${s.desc}"/></span>
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
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${videoList}" var="video" varStatus="status">
				<tr class="nowrap">
					<td class="text-right">${status.count}</td>
					<td style="max-width: 90px;">
						<div class="nowrap">
							<a onclick="fnViewStudioDetail('${video.studio.name}')">${video.studio.name}</a>
						</div>
					</td>
					<td>
						<a onclick="fnViewVideoDetail('${video.opus}')">${video.opus}</a>
					</td>
					<td style="max-width: 180px;">
						<div class="nowrap" title="${video.title}">${video.title}</div>
					</td>
					<td style="max-width: 120px;">
						<div class="nowrap">
						<c:forEach items="${video.actressList}" var="actress">
							<a onclick="fnViewActressDetail('${actress.name}')">${actress.name}</a>
						</c:forEach>
						</div>
					</td>
					<td>${video.releaseDate}</td>
					<td>${video.videoDate}</td>
					<td class="text-right">${video.playCount}</td>
					<td class="text-right">${video.rank}</td>
					<td class="text-right">
						<fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.00G"/>
					</td>
					<td class="text-right">
						<span title="${video.scoreDesc}">${video.score}</span>
					</td>
					<td class="text-right">${video.videoCandidates.size()}</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>
</div>  
</body>
</html>
