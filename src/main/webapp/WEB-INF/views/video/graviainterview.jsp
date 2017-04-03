<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" 	 uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>Gravia Source RSS</title>
<style type="text/css">
.gravia-item {
	position: fixed;
	top: 80px;
}
.gravia-item.nav-pills > li {
	max-width: 150px;
}
.gravia-item.nav-pills > li > a {
    background-color: rgba(51, 122, 183, 0.3);
	font-size: 12px;
    padding: 5px;
    margin: 0 3px 5px;
    border: 1px solid rgb(51, 122, 183);
    color: #eee;
}
.gravia-item.nav-pills > li.active > a {
	color: #fff;
    background-color: #337ab7;
}

#gravia-content {
	font-size: 12px;
	background-color: rgba(255, 255, 255, 0.5);
	border-radius: 9px;
	padding: 10px;
	margin-left: 132px;
}
#graviaForm > div {
    margin: 0 3px 5px;
    padding: 2px;
    border-radius: 4px;
    line-height: 24px;
}
#content-title, #content-length {
	font-weight: bold; 
	color: #fff; 
	text-shadow: 0px 0px 5px #0c0c0c;
}
.hover_img > a { 
	text-decoration: none;
	padding-left: 5px;
}
.hover_img > a > span { 
	display:none; 
	z-index:99; 
}
.hover_img > a:hover > span { 
 	display:block;
}
.hover_img > a:hover > span > img {
	position: fixed;
	right: 42px;
	top: 128px;
	z-index: 3;
}

.cover-wrapper {
	display: inline-block;
	margin: 1px;
    padding: 3px;
	border-radius: 4px;
	transition: height .5s, transform 0.3s;
}
.cover-image {
	width: 204px;
	height: 270px;
}
.cover-title {
	width: 100%;
	padding: 0;
	margin: 0;
}
.box-hover {
	transform: scale(1.1, 1.1);
	box-shadow: 0 0 9px 6px rgba(255, 0, 0, 0.5) !important;
}
.forImage {
    display: inline-block;
}
.input-group-addon {
    background-color: transparent;
    border: 0;
    color: #337ab7 !important;
    font-size: 12px;
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
	
		$("input:radio[name='mode']").on('change', function() {
			fnToggleSubmitBtn();
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
		
		// for nocover checkbox
		$("#nocover").on("click", function() {
			isCheckedNoCover = $(this).data("checked");
			//console.log("isCheckedNoCover", isCheckedNoCover, selectedIndex);
			renderContent(selectedIndex);
		});
	
		resizeCover(true);
	});
}(jQuery));

function request() {
	loading(true, "request...");
	$.getJSON({
		method: 'GET',
		url: '${PATH}/video/gravia/data.json',
		data: {},
		cache: false,
		timeout: 60000
	}).done(function(data) {
		if (data.exception) {
			showStatus(true, data.exception.message, true);
		}
		else {
			$.each(data.tistoryGraviaItemList, function(i, row) { // 응답 json을 List 배열로 변환
				var itemTitle = row.title;
				var titles = row.titles;
				graviaList.push(row);
			});
			render();
		}
	}).fail(function(jqxhr, textStatus, error) {
		loading(true, textStatus + ", " + error);
	}).always(function() {
		loading(false);
	});	
}

function render() {
	renderNav();
	renderContent(0);
}
function renderNav() {
	var titleNavContainer = $(".gravia-item");
	for (var i=0; i<graviaList.length; i++) {
		var title = graviaList[i].title.replace('출시작', '');
		var idx = title.indexOf("(");
		if (idx > -1)
			title = title.substring(0, idx);
		$("<li>").append(
				$("<a>").addClass("nowrap").attr({"href": "#item-" + graviaList[i].itemIndex, "onclick": "renderContent(" + i + ")", "data-toggle": "pill"}).append(
						$("<span>").addClass("badge float-right").html(graviaList[i].titles.length)
				).append(
						$("<span>").html(title)
				)
		).appendTo(titleNavContainer);
	}
	titleNavContainer.children().first().addClass("active");
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
		if (title.check) {
			stateClass += " bg-danger";
			checkCount++;
		}
		
		var onClick = {"onclick": "fnFindVideo('" + title.opus + "'); " + (title.exist ? "fnVideoDetail('" + title.opus + "');" : ""), "data-src": (title.exist ? "/video/" + title.opus + "/cover" : title.imgSrc)};
				
		$("<div>").addClass("cover-wrapper" + stateClass).append(
				$("<img>").addClass("img-thumbnail cover-image").attr({src: title.imgSrc}).attr(onClick)
		).append(
				$("<div>").addClass("nowrap text-center cover-title").attr({title: title.styleString}).append(
						$("<span>").addClass("label label-plain").html(title.title)		
				)
		).hover(
			function(event) {
				if ($("#magnify").data("checked")) {
					$(this).addClass("box-hover");
				}
			}, function() {
				if ($("#magnify").data("checked")) {
					$(this).removeClass("box-hover");
				}
			}
		).appendTo(imageWrapper);

		$("<div>").addClass("input-group" + stateClass).append(
				$("<div>").addClass('input-group-btn hover_img').append(
						$("<a>").addClass("btn btn-link btn-xs").attr(onClick).html("Find").append(
								$('<span>').append(
										$('<img>').css({"width": (title.exist ? "400px" : "200px")}).addClass("img-thumbnail")		
								)
						)
				)
		).append(
				$("<input>").attr({"name": "title"}).addClass("form-control input-sm").css({"font-size": "12px", marginTop: "2px"}).val(title.styleString)
		).append(
				$("<span>").addClass("input-group-addon row-data hide").html(title.rowData)
		).append(
				$("<div>").addClass("input-group-btn").append(
						$("<a>").addClass("btn btn-link btn-xs").on('click', function() {
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
	fnToggleSubmitBtn();
	
	$(".hover_img a").hover(function() {
		var src = $(this).attr("data-src");
		// console.log(src);
	    $(this).find("img").attr("src", src);
	}, function() {});
	
}
function fnFindVideo(opus) {
	fnMarkChoice(opus);
	popup('${urlSearchVideo}' + opus, 'videoSearch', 900, 950);
}
function fnOpenSource(url) {
	popup(url, 'gravia', 900, 950);
}
function fnToggleSubmitBtn() {
	var mode = $("input:radio[name='mode']:checked").val();
	if (mode === 'image') {
		$("#submitBtn").hide();
		$(".forImage").removeClass("hide");
	} 
	else if (mode === 'edit') {
		$("#submitBtn").show();
		$(".forImage").addClass("hide");
	} 
}
function saveCoverAll() {
	actionFrame(videoPath + "/gravia", $("form#graviaForm").serialize(), "POST", "call saveCoverAll");
}
function resizeCover(first) {
	var imgWidth;
	if (first) {
		imgWidth = getlocalStorageItem("graviainterview.coverImageSize", 200);
		$('#img-width').val(imgWidth);
	}else {
		imgWidth = $('#img-width').val();
	}
	var imgHeight = Math.round(parseInt(imgWidth) * 1.3235);
	var coverSizeStyle = "<style>.cover-image {width:" + imgWidth + "px; height:" + imgHeight + "px;} .cover-title {width:" + imgWidth + "px;}</style>";
	$("#cover-size-style").empty().append(coverSizeStyle);
	setlocalStorageItem("graviainterview.coverImageSize", imgWidth);
	$('#img-width').attr({title: imgWidth + " x " + imgHeight});
	$('.addon-width').html(imgWidth + " x " + imgHeight);
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

		<span class="label label-default" id="nocover"  role="checkbox" data-role-value="false" title="only no cover">NoCover</span>
		<span class="label label-info"    id="exist">Exist</span>
		<span class="label label-danger"  id="check">Check</span>
	
		<div class="btn-group btn-group-xs btn-mode" data-toggle="buttons">
			<a class="btn btn-default" data-toggle="tab" data-target="#imageTab"><input type="radio" name="mode" value="image">Image</a>
			<a class="btn btn-default active" data-toggle="tab" data-target="#editTab"><input type="radio" name="mode" value="edit" checked="checked">Editable</a>
		</div>
	
		<div class="forImage hide">
	   		<span class="label label-default" id="magnify"  role="checkbox" data-role-value="false" title="active magnify">Magnify</span>
	   		
	   		<div class="input-group input-group-xs">
				<input type="range" id="img-width" class="form-control input-sm" min="100" max="700" value="200" step="50" onchange="resizeCover()"/>
				<span class="input-group-addon addon-width">Width</span>
			</div>
		</div>
		
		<div class="float-right">
			<button class="btn btn-xs btn-primary" style="display:none;" id="submitBtn" onclick="saveCoverAll()">All Save</button>
		</div>
	</div>

	<div id="content_div" class="box" style="overflow:auto;">
		<ul class="nav nav-pills nav-stacked gravia-item"></ul>
		<div class="tab-content" id="gravia-content">
			<h4>
				<span id="content-title"></span>
				<span id="content-length"></span>
				<a id="content-source" class="float-right"></a>
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