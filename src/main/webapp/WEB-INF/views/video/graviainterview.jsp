<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" 	 uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>Gravia Source RSS</title>
<style type="text/css">
.forImage, .forEdit {
    display: inline-block;
}

.nav-gravia {
	position: fixed;
	top: 80px;
	margin-top: 10px;
}
.nav-gravia.nav-pills > li {
	max-width: 150px;
}
.nav-gravia.nav-pills > li > a {
	background-color: rgba(51, 122, 183, 0.3);
	font-size: 12px;
    padding: 5px;
    margin: 0 3px 5px;
    border: 1px solid rgb(51, 122, 183);
    color: #eee;
	transition: all .2s;
}
.nav-gravia.nav-pills > li.active > a {
	color: #fff;
	background-color: #337ab7;
}
.nav-gravia.nav-pills > li:hover > a {
	background-color: rgba(51, 122, 183, 0.8);
}

.tab-content.tab-gravia {
	font-size: 12px;
	background-color: rgba(255, 255, 255, 0.5);
	border-radius: 9px;
	padding: 10px;
	/* margin-left: 160px; */
}
.tab-content.tab-gravia > h4 {
	margin-top: 0;
}
#content-title, #content-length {
	font-weight: bold; 
	color: #fff; 
	text-shadow: 0px 0px 5px #0c0c0c;
	margin-left: 10px;
}

#graviaForm > div {
    margin: 0 3px 5px;
    padding: 2px;
    border-radius: 4px;
    line-height: 24px;
}
#graviaForm > div > .hover_img > a { 
	text-decoration: none;
	padding-left: 5px;
}
#graviaForm > div > .hover_img > a > span { 
	display:none; 
}
#graviaForm > div > .hover_img > a:hover > span { 
 	display:block;
}
#graviaForm > div > .hover_img > a:hover > span > img {
	position: fixed;
	right: 42px;
	top: 118px;
	z-index: 3;
}

.btn, .form-control {
	z-index: initial !important;
}
.input-group-addon {
    background-color: transparent;
    border: 0;
    color: #337ab7;
    font-size: 12px;
}

#imageWrapper > .cover-wrapper {
	display: inline-block;
	margin: 1px;
    padding: 3px;
	border-radius: 4px;
	transition: transform 0.3s;
}
#imageWrapper > .cover-wrapper.cover-hover {
	transform: scale(1.1, 1.1);
}
#imageWrapper > .cover-wrapper > .cover-image {
	width: 204px;
	height: 270px;
	transition: height .5s, height .5s;
}
#imageWrapper > .cover-wrapper > .cover-title {
	width: 100%;
	padding: 0;
	margin: 0;
}
</style>
<script type="text/javascript">
//bgContinue = false;
var graviaList = new Array();
var foundList = new Array();
var selectedIndex = 0;
var previousIndex = 0;
var isCheckedNoCover = false;

(function($) {
	$(document).ready(function() {
	
		request();

		resizeCover(true);
	
		$("input:radio[name='mode']").on('change', fnToggleBtnMode);
		// for nocover checkbox
		$("#nocover").on("click", function() {
			isCheckedNoCover = $(this).data("checked");
			//console.log("isCheckedNoCover", isCheckedNoCover, selectedIndex);
			renderContent(selectedIndex);
		});
		
		$("#query").bind("keyup", function(e) {
			var event = window.event || e;
			if (event.keyCode != 13) {
				return;
			}
			loading(true, 'Searching');
			var keyword = $(this).val().toLowerCase().trim();
			if (keyword != '') {
				foundList = new Array();
				for (var idx = 0; idx < graviaList.length; idx++) {
					for (var i = 0; i < graviaList[idx].titles.length; i++) {
						var title = graviaList[idx].titles[i];
						if (title.styleString.toLowerCase().indexOf(keyword) > -1) {
							foundList.push(title);
						}
					}
				}
				renderContent(-1, foundList);
			}
			else {
				renderContent(previousIndex);
			}
			loading(false);
		});
		
	});
})(jQuery);

function request() {
	restCall(PATH + '/rest/video/gravia', {}, function(list) {
		$.each(list, function(i, row) {
				graviaList.push(row);
		});
		renderNav();
		renderContent(0);
	});
}

function renderNav() {
	var navGravia = $(".nav-gravia");
	for (var i=0; i<graviaList.length; i++) {
		var title = graviaList[i].title.replace('출시작', '');
		var idx = title.indexOf("(");
		if (idx > -1)
			title = title.substring(0, idx);
		$("<li>").append(
				$("<a>").addClass("nowrap").attr({"onclick": "renderContent(" + i + ")", "data-toggle": "pill"}).append(
						$("<span>").addClass("badge float-right").html(graviaList[i].titles.length)
				).append(
						$("<span>").html(title)
				)
		).appendTo(navGravia);
	}
	navGravia.children().first().addClass("active");
	console.log("navGravia.width", navGravia.width());
	$(".tab-gravia").css({marginLeft: navGravia.width() + 10});
}

function renderContent(idx) {
	previousIndex = selectedIndex;
	selectedIndex = idx;
	
	var contentList;
	var headerTitle = "";
	var displayCount = 0;
	var novideoCount = 0;
	var existCount = 0;
	var checkCount = 0;

	if (idx == -1) {
		contentList = foundList;
		headerTitle = "Search result";
	}
	else {
		contentList = graviaList[idx].titles;
		headerTitle = graviaList[idx].title;
	}
	
	var imageWrapper = $("#imageWrapper").empty();
	var graviaForm  = $("#graviaForm").empty();
	for (var i=0; i < contentList.length; i++) {
		var title = contentList[i];
		
		if (isCheckedNoCover && title.exist) {
			continue;
		}
		else {
			displayCount++;
		}
		
		var stateClass = " ";
		if (title.exist) {
			stateClass += "bg-info";
			existCount++;
		}
		else {
			stateClass += "bg-success";
			novideoCount++;
		}
		if (title.invalid) {
			stateClass += " bg-danger";
			checkCount++;
		}
		
		var onClick = {"onclick": "fnFindVideo('" + title.opus + "'); " + (title.exist ? "fnVideoDetail('" + title.opus + "');" : ""), "data-src": (title.exist ? PATH + "/video/" + title.opus + "/cover" : title.imgSrc)};
				
		$("<div>").addClass("cover-wrapper" + stateClass).append(
				$("<img>").addClass("img-thumbnail cover-image").attr({src: title.imgSrc}).attr(onClick)
		).append(
				$("<div>").addClass("nowrap text-center cover-title").attr({title: title.styleString}).append(
						$("<span>").addClass("label label-plain").html(title.title)		
				)
		).hover(
			function(event) {
				if ($("#magnify").data("checked")) {
					$(this).addClass("cover-hover");
				}
			}, function() {
				if ($("#magnify").data("checked")) {
					$(this).removeClass("cover-hover");
				}
			}
		).appendTo(imageWrapper);

		$("<div>").addClass("input-group" + stateClass).attr({"id": "check-" + title.opus}).append(
				$("<div>").addClass('input-group-btn hover_img').append(
						$("<a>").addClass("btn btn-link btn-xs btn-img").attr(onClick).html("Find").append(
								$('<span>').append(
										$('<img>').css({"width": (title.exist ? "400px" : "200px")}).addClass("img-thumbnail")		
								)
						).hover(function() {
							var src = $(this).attr("data-src");
							var top = $(this).offset().top - 2;
						//	console.log("top", top);
						    $(this).find("img").attr("src", src).css({top: top});
						}, function() {})
				)
		).append(
				$("<input>").attr({"name": "title"}).addClass("form-control input-sm").css({"font-size": "12px", marginTop: "2px"}).val(title.styleString)
		).append(
				$("<span>").addClass("input-group-addon row-data hide").html(title.rowData)
		).append(
				$("<div>").addClass("input-group-btn").append(
						$("<a>").addClass("btn btn-link btn-xs btn-row").on('click', function() {
							$(this).parent().parent().find('.row-data').toggleClass("hide");
							$(this).find('i').toggleClass("glyphicon-plus-sign glyphicon-minus-sign");
						}).append(
								$("<i>").addClass("glyphicon glyphicon-plus-sign")
						)
				)
		).appendTo(graviaForm);
	}

	$("#content-title").html(headerTitle);
	$("#content-length").html(displayCount);
	if (idx > -1) {
		$("#content-source").attr({'onclick': 'fnOpenSource(\'' + graviaList[idx].guid + '\')'}).html("Open source");
	}
	$("#nocover").html("NoVideo " + novideoCount);
	$("#exist").html("Exist " + existCount);
	$("#check").html("Check " + checkCount);
	fnToggleBtnMode();
}

function fnFindVideo(opus) {
	fnMarkChoice(opus);
	popup('${urlSearchVideo}' + opus, 'videoSearch', 900, 950);
}

function fnOpenSource(url) {
	popup(url, 'gravia', 900, 950);
}

function fnToggleBtnMode() {
	var mode = $("input:radio[name='mode']:checked").val();
	if (mode === 'image') {
		$(".forImage").removeClass("hide");
		$(".forEdit").addClass("hide");
	} 
	else if (mode === 'edit') {
		$(".forImage").addClass("hide");
		$(".forEdit").removeClass("hide");
	} 
}

function saveCoverAll() {
	restCall(PATH + "/rest/video/gravia", {method: "POST", data: $("form#graviaForm").serialize(), title: "call saveCoverAll"});
}

function resizeCover(first) {
	var imgWidth;
	if (first) {
		imgWidth = getLocalStorageItem(GRAVIAINTERVIEW_IMAGE_WIDTH, 200);
		$('#img-width').val(imgWidth);
	}else {
		imgWidth = $('#img-width').val();
	}
	var imgHeight = Math.round(parseInt(imgWidth) * 1.3235);
	var coverSizeStyle = "<style>#imageWrapper>.cover-wrapper>.cover-image {width:" + imgWidth + "px; height:" + imgHeight + "px;} #imageWrapper>.cover-wrapper>.cover-title {width:" + imgWidth + "px;}</style>";
	$("#coverSizeStyle").empty().append(coverSizeStyle);
	$('#img-width').attr({title: imgWidth + " x " + imgHeight});
	$('.addon-width').html(imgWidth + " x " + imgHeight);
	setLocalStorageItem(GRAVIAINTERVIEW_IMAGE_WIDTH, imgWidth);
//	showSnackbar("width:" + imgWidth + "px; height:" + imgHeight + "px;", 1000);
}
</script>
</head>
<body>
<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
		<label class="title">
			GraviaInterview
		</label>
		<input type="search" id="query" class="form-control input-sm" placeholder="Search"/>

		<div class="btn-group btn-group-xs btn-mode" data-toggle="buttons">
			<a class="btn btn-default" data-toggle="tab" data-target="#imageTab"><input type="radio" name="mode" value="image">Image</a>
			<a class="btn btn-default active" data-toggle="tab" data-target="#editTab"><input type="radio" name="mode" value="edit" checked="checked">Editable</a>
		</div>
	
		<span class="label label-default" id="nocover"  role="checkbox" data-role-value="false" title="only no cover">NoCover</span>
		<span class="label label-info"    id="exist">Exist</span>
		<span class="label label-danger"  id="check">Check</span>
	
		<div class="forImage hide">
	   		<span class="label label-default" id="magnify"  role="checkbox" data-role-value="false" title="active magnify">Magnify</span>
	   		<div class="input-group input-group-xs">
				<input type="range" id="img-width" class="form-control" min="100" max="700" value="200" step="50" onchange="resizeCover()"/>
				<span class="input-group-addon addon-width">Size</span>
			</div>
		</div>
		
		<div class="forEdit hide">
			<span class="label label-default" id="showrowdata"  role="checkbox" data-role-value="false" title="show row data" onclick="$('#graviaForm>div>div>a.btn.btn-row').click();">Row Data</span>
		</div>
		<div class="forEdit hide float-right">
			<button class="btn btn-xs btn-primary" onclick="saveCoverAll()">All Save</button>
		</div>
	</div>

	<div id="content_div" class="box" style="overflow:auto;">
		<ul class="nav nav-pills nav-stacked nav-gravia"></ul>
		<div class="tab-content tab-gravia">
			<h4>
				<span id="content-title"></span>
				<span id="content-length"></span>
				<a id="content-source" class="float-right small"></a>
			</h4>
			<section id="imageTab" class="tab-pane fade">
				<div id="imageWrapper"></div>
			</section>
			<section id="editTab"  class="tab-pane fade active in">
				<form id="graviaForm"></form>
			</section>
		</div>
	</div>

</div>
</body>
</html>