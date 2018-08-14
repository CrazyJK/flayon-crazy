<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.tags"/></title>
<style type="text/css">
dl.active {
	background-color: yellow;
}
dd {
	font-size: 80%;
}
.btn-close {
    color: #a94442
}
#tagDetailDiv {
	position: fixed;
	bottom: 20px;
	margin: 0;
	background-color: #fff;
}
#tagDetailDiv > iframe {
	width: 100%;
	border: 0;
}
</style>
<script type="text/javascript">
bgContinue = opener ? false : true;

var tagList = [];
var tagIndex = -1;

$(document).ready(function() {
	var $ul = $("#list");
	var appendTagInfo = function(tag) {
		$ul.append(
				$("<li>").append(
						$("<dl>", {"class": "box box-small", id: "tag-id-" + tag.id}).append(
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
		tagList = list;
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
	
	$(".btn-left, .btn-right").on("click", function() {
		var tag;
		var isLeft = $(this).hasClass("btn-left");
		if (isLeft) {
			if (tagIndex > 0)
				tag = tagList[--tagIndex];
		} else {
			if (tagIndex < tagList.length)
				tag = tagList[++tagIndex];
		}
		if (tag) {
			if ($("#popup").data("checked")) {
				$("#tagDetailDiv").addClass("hide");
				popup(PATH + '/video/tag/' + tag.id, 'tag-id-' + tag.id, 800, 600);
			} else {
				$("#tagDetailDiv").removeClass("hide");
				$("#tagDetailDiv > iframe").attr("src", PATH + '/video/tag/' + tag.id + '?position=frame');
			}
			$("dl", "#list").removeClass("active");
			$("#tag-id-" + tag.id).addClass("active");
		}
	});
	
	$(".btn-close").on("click", function() {
		$("#tagDetailDiv").addClass("hide");
		$("dl", "#list").removeClass("active");
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

function resizeSecondDiv() {
	var offsetMargin = 20, outerHeight = $("#content_div").outerHeight();
	$("#tagDetailDiv").css({
		width: $(window).width() - offsetMargin * 2, 
		height: outerHeight - offsetMargin * 1
	});
	$("#tagDetailDiv > iframe").css({
		height: outerHeight - offsetMargin * 3
	});
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
		
		<div style="display:inline-block; width: 20px;"></div>
		<label class="title">View detail</label>
		<div style="display:inline-block; width: 10px;"></div>
		<div class="btn-group">
  			<button type="button" class="btn btn-primary btn-xs btn-left"><span class="glyphicon glyphicon-step-backward"></span><span class="glyphicon glyphicon-arrow-left"></span></button>
  			<button type="button" class="btn btn-primary btn-xs btn-right"><span class="glyphicon glyphicon-arrow-right"></span><span class="glyphicon glyphicon-step-forward"></span></button>
		</div>
		<div style="display:inline-block; width: 10px;"></div>
		<span role="checkbox" class="label label-checkbox" id="popup" title="popup detail">Popup</span>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<ul id="list" class="list-inline"></ul>
		<div id="tagDetailDiv" class="box hide">
			<button class="btn btn-link btn-xs btn-close float-right"><span class="glyphicon glyphicon-remove"></span></button>
			<iframe></iframe>
		</div>
	</div>

</div>
</body>
</html>
