<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title><s:message code="video.thumbnails"/></title>
<link rel="stylesheet" href="${PATH}/css/lightbox.css">
<link rel="stylesheet" href="${PATH}/css/app/image/thumbnails.css"/>
<script src="${PATH}/js/lightbox.js"></script>
<script src="${PATH}/js/crazy.image.thumbnails.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	thumbnails.init();
});
</script>
</head>
<body>

	<div id="header_div" class="box form-inline">
		<label class="title">
			<s:message code="video.thumbnails"/>
		</label>
		
		<div class="btn-group btn-group-xs btn-mode" data-toggle="buttons">
			<a class="btn btn-default" data-toggle="tab" data-target="#imageTab"><input type="radio" name="mode" value="image">Image</a>
			<a class="btn btn-default" data-toggle="tab" data-target="#coverTab"><input type="radio" name="mode" value="cover">Cover</a>
		</div>
		
		<div class="input-group input-group-xs">
			<span class="input-group-addon addon-width">Width</span>
			<input type="range" id="img-width"  class="form-control" min="100" max="800" value="120" step="50"/>
		</div>
		<div class="input-group input-group-xs">
			<span class="input-group-addon addon-height">Height</span>
			<input type="range" id="img-height" class="form-control" min="100" max="800" value="100" step="50"/>
		</div>
		
		<select id="paths" class="form-control input-sm float-right"></select>
		
		<span class="label label-primary total-count"   title="Total"></span>
		<span class="label label-primary current-index" title="Index"></span>
   		<span class="label label-checkbox" id="magnify"  role="checkbox" title="active magnify">Magnify</span>
		<span class="label label-warning debug"></span>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<div id="thumbnailDiv">
			<ul id="thumbnailUL" class="list-inline">
			</ul>
		</div>
	</div>

</body>
</html>
