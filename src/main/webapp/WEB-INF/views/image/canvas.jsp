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
				<tr>
					<td width="220px" align="left">
						<div class="label-wrapper">
							<label>
								<input type="radio" name="pencil" value="circle" class="sr-only" checked="checked"/>
								<span>Circle</span>
							</label>
						</div>
						<div class="label-wrapper">
							<label>
								<input type="radio" name="pencil" value="rubber" class="sr-only"/>
								<span>Rubber</span>
							</label>
						</div>
					</td>
					<td class="text-ellipsis">
						<span class="label  imageSource"></span>
						<span class="label   nextMethod"></span>
						<span class="label playInterval"></span>
						<span class="label label-default pointer" id="imageName" title="reload image"></span>
						<span class="label label-default" id="imagePercent"></span>
						<%@ include file="/WEB-INF/views/image/config.jspf"%>
					</td>
					<td width="220px" align="right">
						<input type="color" id="color" value="#ffffff" title="Color"/>
						<div class="label-wrapper">
							<label>
								d<input type="number" id="diameter" value="30" min="10" step="10" title="Diameter"/>
							</label>
						</div>
						<div class="label-wrapper">
							<label>
								p<input type="number" id="goto" min="0" title="Image No"/>
							</label>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<ul id="navUL" class="list-inline"></ul>
					</td>
				</tr>
			</table>
		</nav>

	</div>
</body>
</html>