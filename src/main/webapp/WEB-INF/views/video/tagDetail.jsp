<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>Tag : ${tag.id} : ${tag.name}</title>
<style type="text/css">
@media (min-width: 1200px) {
	.container-video-card {
    	width: 100%;
	}
	.container-video-card li {
		transform: scale(2, 2);
		margin: 65px 100px;
	}
	.video-card {
		background-color: rgb(171, 116, 91);
    }
	.video-card:hover {
		background-color: rgb(209, 125, 148);
    	transform: none;
    }
}
</style>
<script type="text/javascript">
//bgContinue = false;
function fnSaveTagInfo() {
	restCall(PATH + '/rest/tag', {method: "PUT", data: $("form#tagForm").serialize(), title: "Save tag"}, function() {
		if (opener) {
			if (opener.location.href.indexOf("video/briefing") > -1) {
				opener.location.href = opener.location.origin + opener.location.pathname + "?tab=tags";
			}
		}
	});
}
</script>
</head>
<body>
<div class="container">
	<br>
	<form id="tagForm" method="post" role="form" class="form-horizontal">
		<input type="hidden" name="_method" id="hiddenHttpMethod" value="post"/>
		<input type="hidden" name="id" value="${tag.id}"/>
		<div class="form-group">
			<div class="col-sm-4">
				<input class="form-control" type="text" name="name" value="${tag.name}" placeholder="Tag name"/>
			</div>
			<div class="col-sm-7">
				<input class="form-control" type="text" name="description" value="${tag.description}" placeholder="Description"/>
			</div>
			<div class="col-sm-1">
				<span class="btn btn-default" onclick="fnSaveTagInfo()">Save</span>
			</div>
		</div>
	</form>
</div>
	
<div class="container container-video-card">
	<h3>
		<span class="label label-plain">Video <i class="badge badge-black">${fn:length(tag.videoList)}</i></span>
	</h3>
	<div class="box">
		<ul class="list-inline text-center">
			<c:forEach items="${tag.videoList}" var="video">
				<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
			</c:forEach>
		</ul>
	</div>
</div>
</body>
</html>
