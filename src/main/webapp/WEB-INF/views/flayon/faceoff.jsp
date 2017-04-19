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
	border-radius: 50%;
}
.imageWrapper {
	border: 1px solid #337ab7;
    padding: 10px;
    height: 307px;
    border-radius: 6px;
}
.imageWrapper2 {
	position: relative; 
	top: -306.7px; 
	border:1px solid #337ab7;
    padding: 10px;
    height: 307px;
    border-radius: 6px;
}
.imageWrapper2 img {
	padding-top: 10px;
}
input[type=range] {
    box-shadow: inset 0 0px 0px rgba(0,0,0,0);
}
input[type=range]:focus {
	box-shadow: none;
}
.input-group-sm {
	padding: 0 0 0 15px;
}
.input-group-addon {
	background-color: transparent;
	border: 0;
	color: #337ab7;
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
//	$("img").addClass("img-rounded");
	img1Change(100);
	img2Change(100);
});
function img1Change(val) {
	$("#img1_range").val(val);
	$("#img1_range").next().html(val);
    var opacity = parseInt(val) / 100;
	$("#img1 img, #img1-mix img").css("opacity", opacity);
}
function img2Change(val) {
	$("#img2_range").val(val);
	$("#img2_range").next().html(val);
    var opacity = parseInt(val) / 100;
	$("#img2 img, #img2-mix img").css("opacity", opacity);
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
	      	<h4 class="text-primary">Left Face</h4>
	      	<div class="input-group input-group-sm">
				<input class="form-control" type="range" id="img1_range" min="0" max="100" value="50"/>
				<span class="input-group-addon"></span>
			</div>
			<div id="img1" class="imageWrapper"><img src="<c:url value="/img/face/face1.png"/>"></div>
		</div>
		<div class="col-sm-4 text-center">
			<h4 class="text-primary">Mix</h4>
			<div class="input-group input-group-sm">
				<input class="form-control" type="range" id="imgmix_range" min="0" max="100" value="50"/>
				<span  class="input-group-addon">50</span>
			</div>
			<div id="img1-mix" class="imageWrapper"><img src="<c:url value="/img/face/face1.png"/>"></div>
			<div id="img2-mix" class="imageWrapper2"><img src="<c:url value="/img/face/face2.png"/>"></div>
		</div>
		<div class="col-sm-4 text-center">
			<h4 class="text-primary">Right Face</h4>
	      	<div class="input-group input-group-sm">
				<input class="form-control" type="range" id="img2_range" min="0" max="100" value="50"/>
				<span  class="input-group-addon"></span>
			</div>
			<div id="img2" class="imageWrapper"><img src="<c:url value="/img/face/face2.png"/>" style="margin-top:10px;"></div>
		</div>
	</div>
</div>
</body>
</html>