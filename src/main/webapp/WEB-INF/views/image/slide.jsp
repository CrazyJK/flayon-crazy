<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title><s:message code="image.image-viewer"/></title>
<link rel="stylesheet" href="${PATH}/css/app/image/slide.css"/>
<script src="${PATH}/js/app/image/timer.engine.js"></script>
<script src="${PATH}/js/app/image/slide.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	slide.init();
});
</script>
</head>
<body>
	<div class="container-fluid">
	
		<div id="navDiv">
			<div id="progressWrapper"></div>
		  	<div id="title-area">
				<span class="label label-info paging paging-first"><span id="firstNo">0</span></span>
				<span class="label label-info paging"><input id="currNo"/></span>
				<span class="label label-info title popup-image">&nbsp;</span>
				<span class="label label-info paging paging-end"><span id="endNo">&nbsp;</span></span>
		  	</div>
			<div>
				<span class="label label-info effectInfo" title="Next effect"></span>
			</div>
			<div id="config-box">
				<img src="${PATH}/img/config.png" width="20px" data-toggle="modal" data-target="#configModal"/>
			</div>
			<div id="delete-box">
				<span class="close close-o0 delete-image">&times;</span>
			</div>
		</div>
		<div id="imageDiv"></div>
		<div id="thumbnailDiv"><ul id="thumbnailUL" class="list-inline"></ul></div>
	</div>
	
	<div id="configModal" class="modal fade" role="dialog">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<h4 class="modal-title">Configuration</h4>
				</div>
				<div class="modal-body">
					<table class="table">
						<tr>
							<th>Source Mode</th>
							<td class="text-center">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="sourceMode">Image</span>
								<input type="range" role="switch" id="sourceMode" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="sourceMode">Cover</span>
							</td>
						</tr>
						<tr>
							<th>Effect</th>
							<td class="text-center">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="effectMode">Fadein</span>
								<input type="range" role="switch" id="effectMode" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="effectMode">Random</span>
							</td>
						</tr>
						<tr>
							<th>Play mode</th>
							<td class="text-center">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="playMode">Sequencial</span>
								<input type="range" role="switch" id="playMode" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="playMode">Random</span>
							</td>
						</tr>
						<tr>
							<th>Play interval</th>
							<td><input type="range" id="interval" value="10" min="5" max="20"/></td>
						</tr>
					</table>
				</div>
				<div class="modal-footer">
					<div class="text-center">
						Source   <span class="label label-info sourceMode"></span> 
						Effect   <span class="label label-info effectMode"></span> 
						Play     <span class="label label-info   playMode"></span>
						Interval <span class="label label-info   interval"></span>
						<button class="btn btn-plain btn-sm float-right btn-shuffle">Shuffle</button>
					</div>
				</div>
			</div>
		</div>
	</div>

</body>
</html>
