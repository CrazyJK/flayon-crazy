<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.overview"/> [${video.opus}]</title>
<style type="text/css">
.overviewTxt {
	width:100%; 
	height: 180px;
}
</style>
<script type="text/javascript">
function overviewSave() {
	var overview = $(".overviewTxt");
	$("#overview-${video.opus}", opener.document).attr("title", overview.val()).html(overview.val());
	var frm = document.forms['overviewFrm'];
	frm.submit();
}
function resizeSecondDiv() {
	var offset = 50;
	var windowHeight = $(window).outerHeight();
	var header = $(".btn").outerHeight();
	calculatedDivHeight = windowHeight - header - offset;
	$(".overviewTxt").outerHeight(calculatedDivHeight);

}
</script>
</head>
<body>
<div class="container-fluid" role="main">
	<form method="post" name="overviewFrm" action="<c:url value="/video/${video.opus}/overview"/>" class="box">
		<input type="hidden" name="opus" value="${video.opus}">
		<textarea class="overviewTxt" name="overViewTxt">${video.overviewText}</textarea>
		<button class="btn btn-success btn-block" onclick="overviewSave()">Save</button>
	</form>
</div>
</body>
</html>