<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>${tag.name}</title>
<link rel="stylesheet" href="<c:url value="/css/videoMain.css"/>"/>
<script type="text/javascript">
//bgContinue = false;
function fnSaveTagInfo() {
	var tagForm = document.forms['tagForm'];
	tagForm.submit();
	if (opener) {
		if (opener.location.href.indexOf("video/briefing") > -1) {
			opener.location.href = opener.location.origin + opener.location.pathname + "?tab=tags";
		}
	}
}
</script>
</head>
<body>
<div class="container">

<form id="tagForm" method="post" role="form" class="form-horizontal">
	<input type="hidden" name="_method" id="hiddenHttpMethod" value="post"/>
	<input type="hidden" name="id" value="${tag.id}"/>
	<div class="form-group">
		<div class="col-sm-5">
			<input class="form-control" type="text" name="name" value="${tag.name}" placeholder="Tag name"/>
		</div>
		<div class="col-sm-6">
			<input class="form-control" type="text" name="description" value="${tag.description}" placeholder="Description"/>
		</div>
		<div class="col-sm-1">
			<span class="btn btn-default" onclick="fnSaveTagInfo()">Save</span>
		</div>
	</div>
	<div class="form-group">
		<span class="label label-info">Video <i class="badge">${fn:length(tag.videoList)}</i></span>
	</div>
	<div class="form-group box" style="padding-left: 60px;">
		<ul class="list-inline">
			<c:forEach items="${tag.videoList}" var="video">
				<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
			</c:forEach>
		</ul>
	</div>
</form>

</div>
</body>
</html>
