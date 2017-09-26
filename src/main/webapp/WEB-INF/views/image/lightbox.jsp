<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Lightbox</title>
<link rel="stylesheet" href="${PATH}/css/lightbox.css">
<link rel="stylesheet" href="${PATH}/css/app/image/lightbox.css"/>
<script src="${PATH}/js/lightbox.js"></script>
<script src="${PATH}/js/crazy.image.timer.engine.js"></script>
<script src="${PATH}/js/crazy.image.lightbox.js"></script>
</head>
<body>
	<div class="container">
		<div class="page-header">
			<h1>Lightbox
				<small class="badge imageCount"></small>
			</h1>
		</div>
	
		<div class="form-horizontal box">
			<h1 class="text-center">
				<button class="btn btn-plain btn-sm float-right btn-shuffle">Shuffle</button>
				Options
			</h1>
			<div class="form-group">
				<label class="control-label col-xs-6" for="albumLabel">albumLabel:</label>
				<div class="col-xs-6">
					<input type="text" class="form-control" id="albumLabel" value="Image %1 of %2" placeholder="%1 of %2"/>
				</div>
			</div>
			<div class="form-group">        
				<label class="control-label col-xs-6" for="showDataLabel">showDataLabel:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="showDataLabel">showDataLabel</label>
				</div>
			</div>
			<div class="form-group">        
				<label class="control-label col-xs-6" for="showImageNumberLabel">showImageNumberLabel:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="showImageNumberLabel">showImageNumberLabel</label>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="resizeDuration">resizeDuration:</label>
				<div class="col-xs-6">
					<div class="input-group">
						<span id="resizeDuration-label" class="input-group-addon">700</span>
						<input type="range" class="form-control" id="resizeDuration" value="700" min="100" max="1000" step="100"/>
					</div>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="fadeDuration">fadeDuration:</label>
				<div class="col-xs-6"> 
					<div class="input-group">
						<span id="fadeDuration-label" class="input-group-addon">600</span>
						<input type="range" class="form-control" id="fadeDuration" value="600" min="100" max="1000" step="100"/>
					</div>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="imageFadeDuration">imageFadeDuration:</label>
				<div class="col-xs-6"> 
					<div class="input-group">
						<span id="imageFadeDuration-label" class="input-group-addon">700</span>
						<input type="range" class="form-control" id="imageFadeDuration" value="700" min="100" max="1000" step="100"/>
					</div>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="randomImageEffect">randomImageEffect:</label>
				<div class="col-xs-6"> 
					<label class="checkbox-inline"><input type="checkbox" id="randomImageEffect">randomImageEffect</label>
				</div>
			</div>
			<div class="form-group"> 
				<label class="control-label col-xs-6" for="wrapAround">wrapAround:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="wrapAround">wrapAround</label>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="playInterval">playInterval:</label>
				<div class="col-xs-6"> 
					<div class="input-group">
						<span id="playInterval-label" class="input-group-addon">10</span>
						<input type="range" class="form-control" id="playInterval" value="10" min="5" max="20" step="1"/>
					</div>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="positionFromTop">positionFromTop:</label>
				<div class="col-xs-6"> 
					<div class="input-group">
						<span id="positionFromTop-label" class="input-group-addon">30</span>
						<input type="range" class="form-control" id="positionFromTop" value="30" min="30" max="100" step="10"/>
					</div>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6">playMode</label>
				<div class="col-xs-6">
					<label class="radio-inline"><input type="radio" name="playMode" value="r" checked="checked">Random</label>
					<label class="radio-inline"><input type="radio" name="playMode" value="s">Sequential</label>
				</div>
			</div>
			<div class="form-group">
      			<div class="col-xs-12">
					<button class="btn btn-default btn-block btn-lg btn-view">View</button>
				</div>
			</div>
		</div>
		<div class="debug"></div>
	</div>

	<div id="progressWrapper"></div>

	<div id="imageset"></div>

</body>
</html>
