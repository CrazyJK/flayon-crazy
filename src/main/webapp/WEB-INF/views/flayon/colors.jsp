<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Standard colors</title>
<style type="text/css">
.color-body {
	padding: 10px;
	transition: all .5s ease;
}
.color-box {
	width: 110px;
	display: inline-block;
	margin: 3px 1px;
	padding: 5px;
	text-align: center;
	border-radius: 5px;
}
.color-squre {
	height: 100px;
	border-radius: 5px;
	margin-bottom: 5px;
	box-shadow: 0 2px 2px 0 rgba(0,0,0,0.16),0 0 0 1px rgba(0,0,0,0.08);
	transition: all .5s ease;
}
.color-squre:hover {
    box-shadow: 0 3px 8px 0 rgba(0,0,0,0.2),0 0 0 1px rgba(0,0,0,0.08);
    transform: scale(1.1, 1.1);
}
#newColor {
	border: 0;
	margin: 0 3px;
	size: 200px;
	font-size: 90%;
    color: #c7254e;
    background-color: #f9f2f4;
}
</style>
<script type="text/javascript">
var colorApp = (function() {
	var colors = ['aqua', 'black', 'blue', 'fuchsia', 'gray', 'green', 'lime', 'maroon', 'navy', 'olive', 'orange', 'purple', 'red', 'silver', 'teal', 'white', 'yellow'];
	var colorHtml;
		
	var util = {
			addColor: function(color) {
				if (!color)
					return;
				var colorDom = $(colorHtml);
				colorDom.attr({title: color});
				colorDom.find(".color-squre").css({backgroundColor: color});
				colorDom.find(".color-name").html(color);
				$(".color-body").append(colorDom);
			}	
	};
		
	var manipulate = function() {
		colorHtml = $(".color-body").html();
		$(".color-body").empty();
		if (reqParam.c)
			colors.push(reqParam.c);
		$.each(colors, function(index, color) {
			util.addColor(color);
		});
	};
	
	var addEventListener = function() {
		$(".color-squre").hover(function() {
				$(".color-body").css("background-color", $(this).css("background-color"));
			}, function() {
				$(".color-body").css("background-color", "#fff");
		});
		$(".btn-add").on("click", function() {
			util.addColor($("#newColor").val());
		});
		$("#newColor").on("keyup", function(e) {
			var event = window.event || e;
			if (event.keyCode == 13)
				util.addColor($(this).val());
		});
	};
	
	var init = function() {
		manipulate();
		addEventListener();
	};
	
	return {
		init : init
	}
}());

$(document).ready(function() {
	colorApp.init();
});
</script>
</head>
<body>
	<div class="container">
		<div class="page-header">
			<h1>Color Palette</h1>
	 	</div>
	 	<div class="panel panel-default">
	 		<div class="panel-heading">
	 			<h3 class="panel-title">
	 				If you want to see custom color, 
	      			<span class="btn btn-default btn-xs btn-add">Add</span>
	      			<input value="rgba(123,123,123,0.5)" id="newColor" placeholder="color expression"/>
	 			</h3>
		 	</div>
			<div class="panel-body color-body">
				<div class="color-box nowrap">
					<div class="color-squre" style="background-color: color;"></div>
					<code class="color-name">color</code>
				</div>
			</div>
	 		<div class="panel-footer text-right">
				Find more color <a href="http://www.color-hex.com/" target="_blank">www.color-hex.com</a>
			</div>
		</div>
	
	</div>
</body>
</html>
