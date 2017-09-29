<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"	tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title>${studio.name}</title>
<style type="text/css">
#studioForm .form-control {
	background-color: rgba(255,255,255,.75);
}
</style>
<script type="text/javascript">
//bgContinue = false;
$(document).ready(function() {
	$("form#studioForm").submit(function(event) {
		console.log("form submit...");
		loading(true, "save...");
		setInterval(function() {
			if (opener) {
				if (opener.location.href.indexOf("video/studio") > -1) 
					opener.location.reload();
			}
			location.href = PATH + "/video/studio/" + $("#newName").val();
		}, 1000);
	});
});
</script>
</head>
<body>
<div class="container">

	<form id="studioForm" method="post" target="ifrm" role="form" action="<s:url value="/video/studio"/>" class="form-horizontal">
		<input type="hidden" name="name" value="${studio.name}"/>
		<br/>
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
				<input class="form-control" id="homepage" name="homepage" value="${studio.homepage}" placeholder="Homepage"/>
			</div>
			<div class="col-sm-5">
				<input class="form-control" id="company" name="company" value="${studio.company}" placeholder="Company"/>
			</div>
			<div class="col-sm-1">
				<button type="submit" class="btn btn-default">Save</button>
			</div>
		</div>
	</form>

	<div class="form-group">
		<span class="label label-info">Actress <i class="badge">${fn:length(studio.actressList)}</i></span>
	</div>
	<div class="form-group" style="padding-left:60px;">
		<ul class="list-inline">
			<c:forEach items="${studio.actressList}" var="actress">
				<li>
					<div class="box box-small">
						<jk:actress actress="${actress}" view="detail"/>
					</div>
				</li>
			</c:forEach>
		</ul>
	</div>
	<div class="form-group">
		<span class="label label-info">Video <i class="badge">${fn:length(studio.videoList)}</i></span>
	</div>
	<div class="form-group text-center">
		<ul class="list-inline">
			<c:forEach items="${studio.videoList}" var="video">
				<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
			</c:forEach>
		</ul>
	</div>

</div>
</body>
</html>
