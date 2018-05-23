<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>${video.opus} :: <s:message code="video.overview"/></title>
<style type="text/css">
.overview {
	width:100%; 
}
</style>
<script type="text/javascript">
var opus = '${video.opus}';
function overviewSave() {
	var overview = $(".overview").val();
	restCall(PATH + '/rest/video/' + opus + '/overview', {
		method: "PUT", 
		data: {overview: overview}, 
		title: "Save overview"
	}, function() {
		$("#overview-" + opus, opener.document).attr("title", overview).html(overview);
		self.close();
	});
}
function resizeSecondDiv() {
	$(".overview").outerHeight($(window).outerHeight() - $(".btn").outerHeight() - 50);
}
</script>
</head>
<body>
	<div class="container-fluid" role="main">
		<div class="box">
			<textarea class="overview" name="overview">${video.overviewText}</textarea>
			<button class="btn btn-success btn-block" onclick="overviewSave()">Overview save</button>
		</div>
	</div>
</body>
</html>