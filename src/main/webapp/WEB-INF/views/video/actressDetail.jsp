<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"      uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"	tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title>${actress.name}</title>
<link rel="stylesheet" href="<c:url value="/css/videoMain.css"/>"/>
<script type="text/javascript">
bgContinue = false;
$(document).ready(function(){
	
});

/**
 * @deprecated
 */
function fnRenameTo() {
	var actressForm = document.forms['actressForm'];
	actressForm.action = "<s:url value="/video/actress/${actress.name}/renameTo/"/>" + $("#newName").val();
	actressForm.submit();
}

function fnSaveActressInfo() {
	loading(true, "Saving...");
	var actressForm = document.forms['actressForm'];
	actressForm.action = "<s:url value="/video/actress/${actress.name}"/>";
	actressForm.submit();
	if (opener) {
		if (opener.location.href.indexOf("video/actress") > -1) 
			opener.location.reload();
	}
}
function toogleFavorite(dom) {
	var favorite = $("#favorite").val() == 'true';
	$("#favoriteTEXT").html(favorite ? '☆' : '★');
	$("#favorite").val(!favorite);
	if (opener) {
		// TODO 메인의 배우 정보 업데이트 해야함
	}
}
</script>
</head>
<body>
<div class="container">

<form id="actressForm" method="post" role="form" class="form-horizontal">
	<input type="hidden" name="_method" id="hiddenHttpMethod" value="post"/>
	<input type="hidden" name="name" value="${actress.name}"/>
	<input type="hidden" name="favorite" id="favorite" value="${actress.favorite}"/>

	<div class="form-group">
		<div class="col-sm-2 text-right">
			<span id="favoriteTEXT" onclick="toogleFavorite()" class="text-danger lead">${actress.favorite ? '★' : '☆'}</span>
		</div>
		<div class="col-sm-4">
			<input class="form-control" type="text" name="newname"   value="${actress.name}"      id="newName" />
		</div>
		<div class="col-sm-4">
			<input class="form-control" type="text" name="localname" value="${actress.localName}" placeholder="local name"/>
		</div>
		<div class="col-sm-1">
			<img src="<c:url value="/img/magnify${status.count%2}.png"/>" width="12px" title="<s:message code="video.find-info.actress"/>"
				onclick="popup('<c:url value="${urlSearchActress}"/>${actress.reverseName}', 'infoActress', 800, 600)"/>
		</div>
		<div class="col-sm-1">
			<span class="label label-info">Score ${actress.score}</span>
		</div>		
	</div>
	<div class="form-group">
		<div class="col-sm-3">
			<input class="form-control input-sm" type="text" name="birth"    value="${actress.birth}"    placeholder="Birth"/>
		</div>
		<div class="col-sm-3">
			<input class="form-control input-sm" type="text" name="bodySize" value="${actress.bodySize}" placeholder="Body size"/>
		</div>
		<div class="col-sm-2">
			<input class="form-control input-sm" type="text" name="height"   value="${actress.height}"   placeholder="Height"/>
		</div>
		<div class="col-sm-2">
			<input class="form-control input-sm" type="text" name="debut"    value="${actress.debut}"    placeholder="Debut"/>
		</div>
		<div class="col-sm-2">
			<button class="btn btn-default btn-sm" onclick="fnSaveActressInfo()">Save</button>
		</div>
	</div>
	<div class="form-group">
		<span class="label label-info">Studio <small class="badge">${fn:length(actress.studioList)}</small></span>
	</div>
	<div class="form-group" style="padding-left:60px;">
		<c:forEach items="${actress.studioList}" var="studio">
			<span class="box">
				<jk:studio studio="${studio}" view="detail"/>
			</span>
		</c:forEach>
	</div>
	<div class="form-group">
		<span class="label label-info">Video <span class="badge">${fn:length(actress.videoList)}</span></span>
	</div>
	<div class="form-group text-center">
		<ul class="list-inline">
			<c:forEach items="${actress.videoList}" var="video">
				<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
			</c:forEach>
		</ul>
	</div>
</form>

</div>

</body>
</html>
