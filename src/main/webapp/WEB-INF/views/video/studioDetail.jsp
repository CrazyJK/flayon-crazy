<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>${studio.name}</title>
<link rel="stylesheet" href="<c:url value="/css/videoMain.css"/>"/>
<script type="text/javascript">
bgContinue = false;
function fnRenameTo() {
	var actressForm = document.forms['studioForm'];
	actressForm.action = "<s:url value="/video/studio/${studio.name}/renameTo/"/>" + $("#newName").val();
	actressForm.submit();
}

function fnPutStudioInfo() {
	var actressForm = document.forms['studioForm'];
	actressForm.action = "<s:url value="/video/studio/${studio.name}"/>";
	actressForm.submit();
	if (opener) {
		if (opener.location.href.indexOf("video/studio") > -1) 
			opener.location.reload();
	}
}
</script>
</head>
<body>
<div class="container">

<form id="studioForm" method="post" role="form" class="form-horizontal">
	<input type="hidden" name="_method" id="hiddenHttpMethod" value="put"/>

	<div class="form-group">
		<div class="col-sm-11">
			<input class="form-control" type="text" name="newname" value="${studio.name}" id="newName" />
		</div>
		<div class="col-sm-1">
			<span class="label label-info">Score ${studio.score}</span>
		</div>
	</div>
	<div class="form-group">
		<div class="col-sm-6">
			<input class="form-control input-sm" id="homepage" name="homepage" value="${studio.homepage}" placeholder="Homepage"/>
		</div>
		<div class="col-sm-5">
			<input class="form-control input-sm" id="company" name="company" value="${studio.company}" placeholder="Company"/>
		</div>
		<div class="col-sm-1">
			<span class="btn btn-default btn-sm" onclick="fnPutStudioInfo()">Save</span>
		</div>
	</div>
	<div class="form-group">
		<span class="label label-info">Actress <i class="badge">${fn:length(studio.actressList)}</i></span>
	</div>
	<div class="form-group" style="padding-left:60px;">
		<c:forEach items="${studio.actressList}" var="actress">
			<span class="label label-primary" onclick="fnViewActressDetail('${actress.name}')">
					${actress.name} <i class="badge">${fn:length(actress.videoList)}</i>, Score ${actress.score}</span>
		</c:forEach>
	</div>
	<div class="form-group">
		<span class="label label-info">Video <i class="badge">${fn:length(studio.videoList)}</i></span>
	</div>
	<div class="form-group box" style="padding-left:60px;">
		<ul class="list-inline">
			<c:forEach items="${studio.videoList}" var="video">
				<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
			</c:forEach>
		</ul>
	</div>
</form>

</div>
</body>
</html>
