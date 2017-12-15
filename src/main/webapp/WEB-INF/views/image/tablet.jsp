<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Image Tablet</title>
<link rel="stylesheet" href="${PATH}/css/app/image/slide.css"/>
<link rel="stylesheet" href="${PATH}/css/app/image/tablet.css"/>
<script src="${PATH}/js/crazy.image.timer.engine.js"></script>
<script src="${PATH}/js/crazy.image.tablet.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	tablet.init();
});
</script>
</head>
<body>
	<div class="container-fluid container-tablet">
		<div>
			<div id="leftTop">
				<div id="progressWrapper"></div>
			</div>
			<div id="leftBottom">
				<div class="configInfo">
					<code class="label label-plain sourceMode"></code>
					<code class="label label-plain effectMode"></code>
					<code class="label label-plain rotateDeg"></code>
					<code class="label label-plain playMode"></code>
					<code class="label label-plain interval"></code>
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
					<h4 class="modal-title">Configuration
					<button class="btn btn-plain btn-sm btn-shuffle">Shuffle</button>
					</h4>
				</div>
				<div class="modal-body">
					<div id="configBox">
						<div class="row">
							<div class="col-xs-3 text-bold">Source Mode</div>
							<div class="col-xs-4 text-right">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="sourceMode">Image</span>
							</div>
							<div class="col-xs-1 text-center">
								<input type="range" role="switch" id="sourceMode" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
							</div>
							<div class="col-xs-4 text-left">
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="sourceMode">Cover</span>
							</div>
						</div>
						<div class="row">
							<div class="col-xs-3 text-bold">Effect</div>
							<div class="col-xs-4 text-right">
								<select id="effectTypes"></select>
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="effectMode">Specific</span>
							</div>
							<div class="col-xs-1 text-center">
								<input type="range" role="switch" id="effectMode" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
							</div>
							<div class="col-xs-4 text-left">
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="effectMode">Random</span>
							</div>
						</div>	
						<div class="row">
							<div class="col-xs-3 text-bold">Effect Rotate</div>
							<div class="col-xs-9 text-right">
								<input type="range" id="rotateDeg" value="15" min="0" max="360"/>
							</div>
						</div>	
						<div class="row">
							<div class="col-xs-3 text-bold">Play mode</div>
							<div class="col-xs-4 text-right">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="playMode">Sequencial</span>
							</div>
							<div class="col-xs-1 text-center">
								<input type="range" role="switch" id="playMode" value="1" min="0" max="1" style="width: 35px; display: inline-block; height: 8px;"/>
							</div>
							<div class="col-xs-4 text-left">
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="playMode">Random</span>
							</div>
						</div>	
						<div class="row">
							<div class="col-xs-3 text-bold">Play interval</div>
							<div class="col-xs-9 text-right">
								<input type="range" id="interval" value="10" min="1" max="20"/>
							</div>
						</div>	
					</div>
				</div>
				<div class="modal-footer">
					<div class="config-summary">
						<span class="config-key">Source  </span> <span class="config-value sourceMode"></span> 
						<span class="config-key">Effect  </span> <span class="config-value effectMode"></span> 
						<span class="config-key">Rotate  </span> <span class="config-value  rotateDeg"></span>
						<span class="config-key">Play    </span> <span class="config-value   playMode"></span>
						<span class="config-key">Interval</span> <span class="config-value   interval"></span>
					</div>
					<div class="box box-small box-inset text-left key-map">
						<div class="row">
  							<div class="col-xs-4">
  								<kbd>Insert</kbd> Source mode
  							</div>
  							<div class="col-xs-4">
  								<kbd>Home</kbd> Effect
  							</div>
  							<div class="col-xs-4">
  								<kbd>PageUp</kbd> Play mode
  							</div>
						</div>
						<div class="row">
  							<div class="col-xs-4">
  								<kbd>Delete</kbd> Image clear
  							</div>
  							<div class="col-xs-4">
  								<kbd>End</kbd> Tile
  							</div>
  							<div class="col-xs-4">
  								<kbd>PageDown</kbd> Shake
  							</div>
						</div>
						<div class="row">
  							<div class="col-xs-4">
  								<kbd>Space</kbd> Play image
  							</div>
  							<div class="col-xs-4">
  								<kbd>c</kbd> Config
  							</div>
  							<div class="col-xs-4">
  								<kbd>Numpad</kbd> Interval
  							</div>
						</div>
						<hr/>
						<div class="row">
  							<div class="col-xs-12 text-center">
  								<table style="display:inline-block;">
  									<tr>
  										<td rowspan="2">
  											Prev image
  											 <kbd>Left</kbd> 
  										</td>
  										<td>
  										</td>
  										<td style="border-right: 2px solid #222; border-bottom: 2px solid #222; padding-bottom:2px;">
  											<kbd>Up</kbd>
  										</td>
  										<td style="width:5px; border-top: 2px solid #222;">
  										</td>
  										<td rowspan="2">
  											<kbd>Right</kbd> 
  											Next image
  										</td>
  									</tr>
  									<tr>
  										<td style="width:5px; border-bottom: 2px solid #222;">
  										</td>
  										<td style="border-left: 2px solid #222;">
  											<kbd>Down</kbd>
  										</td>
  										<td>
  										</td>
  									</tr>
  								</table>
  							</div>
						</div>
						<hr/>
						<div class="row">
  							<div class="col-xs-2">
  								Mouse
  							</div>
  							<div class="col-xs-3">
  								<kbd>Left</kbd> Drag
  							</div>
  							<div class="col-xs-4">
  								<kbd>Middle</kbd>
  							</div>
  							<div class="col-xs-3">
  								<kbd>Right</kbd>
  							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>
