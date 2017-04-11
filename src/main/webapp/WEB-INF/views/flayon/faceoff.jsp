<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Face off</title>
<style type="text/css">
img {
	width: 200px;
}
</style>
<script type="text/javascript">
$(document).ready(function(){
    $("#img1_range").on("input", function() {
    	img1Change($(this).val());
    });
    $("#img2_range").on("input", function() {
    	img2Change($(this).val());
    });
    $("#imgmix_range").on("input", function() {
		$(this).next().html($(this).val());
		var val = $(this).val();
		img1Change(100-val);
		img2Change(val);
    });
    $("img").addClass("img-rounded");
	img1Change(100);
	img2Change(100);
});
function img1Change(val) {
	$("#img1_range").val(val);
	$("#img1_range").next().html(val);
    var opacity = parseInt(val) / 100;
	$("#img1, #img1-mix").css("opacity", opacity);
}
function img2Change(val) {
	$("#img2_range").val(val);
	$("#img2_range").next().html(val);
    var opacity = parseInt(val) / 100;
	$("#img2, #img2-mix").css("opacity", opacity);
}
</script>
</head>
<body>
<div class="container">
	<div class="page-header">
		<h1>Face off</h1>
 	</div>

	<div class="row">
		<div class="col-sm-4 text-center">
			<div class="form-group has-feedback">
		      	<label for="img1_range">Left Face</label>
				<input class="form-control" type="range" id="img1_range" min="0" max="100" value="50"/>
				<span  class="form-control-feedback"></span>
			</div>
			<div id="img1" class="imageWrapper"><img src="<c:url value="/img/face/face1.png"/>"></div>
		</div>
		<div class="col-sm-4 text-center">
			<div class="form-group has-feedback">
		      	<label for="imgmix_range">Mix</label>
				<input class="form-control" type="range" id="imgmix_range" min="0" max="100" value="50"/>
				<span  class="form-control-feedback">50</span>
			</div>
			<div id="img1-mix" class="imageWrapper"><img src="<c:url value="/img/face/face1.png"/>"></div>
			<div id="img2-mix" class="imageWrapper" style="position: relative; top: -285.7px; padding-top: 10px;"><img src="<c:url value="/img/face/face2.png"/>"></div>
		</div>
		<div class="col-sm-4 text-center">
			<div class="form-group has-feedback">
		      	<label for="img2_range">Right Face</label>
				<input class="form-control" type="range" id="img2_range" min="0" max="100" value="50"/>
				<span  class="form-control-feedback"></span>
			</div>
			<div id="img2" class="imageWrapper"><img src="<c:url value="/img/face/face2.png"/>"></div>
		</div>
	</div>
</div>
</body>
</html>