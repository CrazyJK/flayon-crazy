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
					<col width="220px"/>
					<col/>
					<col width="220px"/>
				</colgroup>
				<tr>
					<td align="left">
						<div class="configInfo">
							<label class="label   nextMethod"></label>
							<label class="label playInterval"></label>
						</div>
					</td>
					<td class="EllipsText">
						<span class="label label-default pointer" id="imageName" title="reload image"></span>
						<%@ include file="/WEB-INF/views/image/config.jspf"%>
					</td>
					<td></td>
				</tr>
				<tr>
					<td align="left">
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
					</td>
					<td align="right">
						<input type="text" name="diameter" value="50" style="width:30px" title="Diameter"/>
						<input type="text" id="imagePercent" value="" style="width:40px" title="Image percent" readonly="readonly"/>
						<input type="text" name="color" value="white" style="width:40px" title="Color"/>
						<input type="text" id='goNumber' title="Image No"/>
						<a class="moveBtn btn-goto">Go</a>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<ul id="navUL"></ul>
					</td>
				</tr>
			</table>
		</nav>

	</div>
</body>
</html>