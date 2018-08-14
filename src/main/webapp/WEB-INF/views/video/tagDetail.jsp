<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>Tag : ${tag.id} : ${tag.name}</title>
<link rel="stylesheet" href="${PATH}/css/videoCard-Detail.css"/>
<style type="text/css">
.container-tag-form {
	margin-top: 10px;
}
</style>
<script type="text/javascript">
if (reqParam.position === 'frame') {
	bgContinue = false;
}
var tagId = "${tag.id}";
var tagName = "${tag.name}";

$(document).ready(function() {
	// attach event listener
	$(".btn-save").on("click", fnSaveTagInfo);
	$(".btn-delete").on("click", fnDeleteTag);
	$(".btn-check-all").on("click", fnCheckAll);
	$(".candidates-list").on("change", "input.input-check-tag", function() {
		restCall(PATH + "/rest/video/" + $(this).data("opus") + "/tag?id=${tag.id}", {method: "PUT"});
	});
	// add candidate checkbox
	$("li", ".candidates-list").each(function() {
		var opus = $(this).attr("data-opus");
		$(this).find(".video-title").parent().prepend(
				$("<input>", {type: 'checkbox', 'class': 'input-check-tag'}).data("opus", opus)
		);
	});
	
});
function fnSaveTagInfo() {
	restCall(PATH + '/rest/tag', {method: "PUT", data: $("form#tagForm").serialize(), title: "Save tag"}, function() {
		if (opener) {
			if (opener.location.href.indexOf("video/tag") > -1) {
				opener.location.reload(); 
			}
		}
	});
}

function fnDeleteTag() {
	if (confirm('Confirm to delete This tag')) {
		restCall(PATH + "/rest/tag?id=" + tagId, {method: "DELETE", title: tagName + " tag delete"}, function(result) {
			if (result) {
				if (opener) {
					if (opener.location.href.indexOf("video/tag") > -1) {
						opener.location.reload(); 
					}
				}
				window.close();
			} else {
				alert("Failed to delete");
			}
		});
	}
}
function fnCheckAll() {
	$(".input-check-tag").each(function() {
		$(this).click();
	});
}
</script>
</head>
<body>
<div class="container container-tag-form">
	<form id="tagForm" method="post" role="form" class="form-horizontal">
		<input type="hidden" name="_method" id="hiddenHttpMethod" value="post"/>
		<input type="hidden" name="id" value="${tag.id}"/>
		<div class="form-group">
			<div class="col-sm-3">
				<input class="form-control" type="text" name="name" value="${tag.name}" placeholder="Tag name"/>
			</div>
			<div class="col-sm-7">
				<input class="form-control" type="text" name="description" value="${tag.description}" placeholder="Description"/>
			</div>
			<div class="col-sm-1">
				<span class="btn btn-success btn-save">Save</span>
			</div>
			<div class="col-sm-1">
				<span class="btn btn-danger btn-delete">Del</span>
			</div>
		</div>
	</form>
</div>
	
<div class="container container-video-card">
	<h3>
		<span class="label label-plain">Video <i class="badge badge-black">${fn:length(tag.videoList)}</i></span>
		<span class="label label-plain float-right">Candidates <i class="badge badge-black">${fn:length(likeVideoList)}</i></span>
	</h3>
	<div class="box">
		<ul class="list-inline text-center">
			<c:forEach items="${tag.videoList}" var="video">
				<li data-opus="${video.opus}">
					<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
				</li>
			</c:forEach>
		</ul>
	</div>
	<h3>
		<span class="label label-plain">Candidates <i class="badge badge-black">${fn:length(likeVideoList)}</i></span>
		<button class="btn btn-info btn-sm btn-check-all"><span class="glyphicon glyphicon-check"></span> Check All</button>
	</h3>
	<div class="box">
		<ul class="list-inline text-center candidates-list">
			<c:forEach items="${likeVideoList}" var="video">
				<li data-opus="${video.opus}">
					<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
				</li>
			</c:forEach>
		</ul>
	</div>
</div>
</body>
</html>
