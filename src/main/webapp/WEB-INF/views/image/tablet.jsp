<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Image Tablet</title>
<link rel="stylesheet" href="${PATH}/css/app/image/slide.css"/>
<style type="text/css">
.img-card {
	position: fixed;
	visibility: hidden;
	transition: unset;
}
.img-card-focus {
	border: 1px solid #337ab7;
}
.ui-draggable-dragging {
	box-shadow: 
		-3px -3px 3px 3px rgba(255, 0, 0, 0.25), 
		 3px -3px 3px 3px rgba(0, 255, 0, 0.25), 
		 3px  3px 3px 3px rgba(0, 0, 255, 0.25), 
		-3px  3px 3px 3px rgba(255, 255, 0, 0.25);
}
</style>
<script src="${PATH}/js/app/image/timer.engine.js"></script>
<script src="${PATH}/js/app/image/tablet.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	slide.init();
});
</script>
</head>
<body>
	<div class="container-fluid">
		<div>
			<div id="leftTop">
				<div id="progressWrapper"></div>
			</div>
			<div id="leftBottom">
				<div class="configInfo">
					<code class="label label-plain sourceInfo"></code>
					<code class="label label-plain effectInfo"></code>
					<code class="label label-plain playInfo"></code>
					<code class="label label-plain intervalInfo"></code>
				</div>
			</div>
			<div id="rightTop"></div>
			<div id="rightBottom"></div>
			<div id="fixedBox">
				<img class="btn-config" src="${PATH}/img/config.png" width="20px" data-toggle="modal" data-target="#configModal"/>
				<span class="label label-plain displayCount">&nbsp;</span>
				<span class="label label-plain title popup-image">&nbsp;</span>
				<span class="close close-o0 delete-image">&times;</span>
			</div>
		</div>
		<div id="imageDiv"></div>
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
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="effectMode">Fade</span>
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
							<td><input type="range" id="interval" value="10" min="1" max="20"/></td>
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
