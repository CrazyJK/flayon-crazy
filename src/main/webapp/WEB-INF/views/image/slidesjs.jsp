<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="image.image-viewer"/> by SlidesJS</title>
<link rel="stylesheet" href="${PATH}/css/app/image/slidesjs.css"/>
<script src="${PATH}/js/jquery.slides.js"></script>
<script src="${PATH}/js/crazy.image.timer.engine.js"></script>
<script src="${PATH}/js/crazy.image.slidesjs.js"></script>
</head>
<body>
<div class="container-fluid">

	<div class="title"><span class="label label-info label-title"></span></div>
	
	<div id="container-slidesjs"></div>
	
	<div id="config-box">
		<img src="${PATH}/img/config.png" width="20px" data-toggle="modal" data-target="#configModal"/>
	</div>
	<div id="configModal" class="modal fade" role="dialog">
		<div class="modal-dialog modal-sm">
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
							<th>Play interval</th>
							<td><input type="range" id="interval" value="10" min="5" max="20"/></td>
						</tr>
					</table>
				</div>
				<div class="modal-footer">
					<div class="text-center">
						Source   <span class="label label-info sourceMode"></span> 
						Interval <span class="label label-info interval"></span>
					</div>
				</div>
			</div>
		</div>
	</div>

</div>
</body>
</html>