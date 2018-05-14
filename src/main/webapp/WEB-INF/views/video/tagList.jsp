<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.tags"/></title>
<style type="text/css">
dd {
	font-size: 80%;
}
</style>
<script type="text/javascript">
bgContinue = opener ? false : true;
$(document).ready(function() {
	var $ul = $("#list");
	var appendTagInfo = function(tag) {
		$ul.append(
				$("<li>").append(
						$("<dl>", {"class": "box box-small"}).append(
								$("<dt>").append(
										$("<a>").data('tagId', tag.id).addClass("link link-black").html(tag.name).on("click", function() {
											var tagId = $(this).data('tagId');
											popup('/video/tag/' + tagId, 'tag-' + tagId, 800, 600);
										}),
										$("<span>", {"class": "badge-black float-right"}).append(tag.count)
								),		
								$("<dd>").append(
										tag.description
								)		
						).css({fontSize: parseInt(14 + tag.count / 2)})
				)
		);
	};

	restCall(PATH + "/rest/tag/list", {}, function(list) {
		$(".list-count").html(list.length);
		$.each(list, function(idx, tag) {
			appendTagInfo(tag);
		});
		resizeWindow();
	});
	
	$("#newTagBtn").on("click", function() {
		restCall(PATH + "/rest/tag", {
			method: "POST", 
			data: $("#newForm").serialize(), 
			title: "add tag"
		}, function(tag) {
			appendTagInfo(tag);
		});
	});
});

function resizeWindow() {
	if (opener) {
		var windowWidth  = $(window).width() + 16;
		var headerHeight = $("#header_div").outerHeight();
		var listHeight   = $("#list").outerHeight();
		window.resizeTo(windowWidth, headerHeight + listHeight + 140);
		console.log("resizeSecondDiv", windowWidth, headerHeight, listHeight);
	}
}
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search" class="title">
			<s:message code="video.tags"/> <span class="badge list-count">0</span>
		</label>
		<form id="newForm" style="display: inline;" onsubmit="return false;">
			<input id="newTagName" name="name"        placeholder="Name"        class="form-control input-sm" required="required"/>
			<input id="newTagDesc" name="description" placeholder="Description" class="form-control input-sm"/>
			<button id="newTagBtn" class="btn btn-default btn-xs">Regist</button>
		</form>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<ul id="list" class="list-inline"></ul>
	</div>

</div>
</body>
</html>
