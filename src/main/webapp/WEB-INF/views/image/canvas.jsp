<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>Canvas <s:message code="image.image-viewer"/></title>
<link rel="stylesheet" href="${PATH}/css/app/image/canvas.css"/>
<script src="${PATH}/js/crazy.image.canvas.js"></script>
</head>
<body>
	<div class="container-fluiid">

		<section id="img-section">
			<canvas id="cv"></canvas>
		</section>

		<nav id="img-nav">
			<table>
				<colgroup>
					<col width="320px"/>
					<col/>
					<col width="320px"/>
				</colgroup>
				<tr>
					<td colspan="3" class="EllipsText">
						<span class="moveBtn label label-default" id="imageName" onclick="loadImage()" title="reload image"></span>
						<%@ include file="/WEB-INF/views/image/config.jspf"%>
					</td>
				</tr>
				<tr>
					<td align="left">
						<a class="moveBtn" onclick="fnPopupView()">Popup</a>
						<label><input type="radio" name="pencil" value="circle"/><span>Circle</span></label>
						<label><input type="radio" name="pencil" value="rubber"/><span>Rubber</span></label>
						<label><input type="radio" name="pencil" value="cursor" checked="checked"/><span>Cursor</span></label>
					</td>
					<td>
						<a class="moveBtn move-left " title="Move left;  Numpad 6"><span class="glyphicon glyphicon-arrow-left"></span></a>
						<a class="moveBtn move-right" title="Move right; Numpad 4"><span class="glyphicon glyphicon-arrow-right"></span></a>
						<a class="moveBtn move-up   " title="Move up;    Numpad 8"><span class="glyphicon glyphicon-arrow-up"></span></a>
						<a class="moveBtn move-down " title="Move down;  Numpad 2"><span class="glyphicon glyphicon-arrow-down"></span></a>
						<a class="moveBtn zoom-in   " title="Zoom In;    Numpad +"><span class="glyphicon glyphicon-plus"></span></a>
						<a class="moveBtn zoom-out  " title="Zoom Out;   Numpad -"><span class="glyphicon glyphicon-minus"></span></a>
						<a class="moveBtn" onclick='imgLandscape()' title="Landscape; Numpad 9"><span class="glyphicon glyphicon-resize-horizontal"></span></a>
					</td>
					<td align="right">
						<a class="moveBtn" onclick="fnDelete()">Del</a>
						<a class="moveBtn" onclick="togglePlay()" id="play" title="Slide play; Numpad 7">Play</a>
						<input type="text" name="ratio" value="" style="width:40px" title="Ratio" readonly="readonly"/>
						<input type="text" name="color" value="white" style="width:40px" title="Color"/>
						<input type="text" name="diameter" value="50" style="width:30px" title="Diameter"/>
						<input type="text" id='goNumber' title="Image No"/><a class="moveBtn" onclick='goPage()'>Go</a>
					</td>
				</tr>
				<tr>
					<td colspan="3"><ul id="navUL"></ul></td>
				</tr>
			</table>
		</nav>

	</div>
</body>
</html>