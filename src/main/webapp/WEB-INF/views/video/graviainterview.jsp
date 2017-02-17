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
	max-width: 130px;
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
.gravia-content {
	font-size: 12px;
	background-color: rgba(255, 255, 255, 0.5);
	border-radius: 9px;
}
.gravia-content p {
    margin: 0 0 5px;
    padding: 3px;
    border-radius: 4px;
}

.hover_img > a { 
	position:relative;
	text-decoration: none;
}
.hover_img > a > span { 
	position:absolute; 
	display:none; 
	z-index:99; 
}
.hover_img > a:hover > span { 
	display:block; 
}
.hover_img > a:hover > span > img {
	position: fixed;
	right: 30px;
	top: 125px;
}

.exist {
    background-color: #dff0d8;
}
.exist::after {
 	/* display: inline-block;
    width: 12px;
    height: 12px;
    margin-left: 5px;
    content: "";
    background: url("/img/yes_check_mini.png") no-repeat 0 0;
    background-size: 100%;
    float: right; */
	/* content: url(/img/yes_check_mini.png); */
}
</style>
<script type="text/javascript">
//bgContinue = false;
var graviaList = new Array();
var foundList = new Array();
var selectedIndex = 0;

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
			var keyword = $(this).val().toLowerCase();
			foundList = new Array();
			for (var idx = 0; idx < graviaList.length; idx++) {
				for (var i = 0; i < graviaList[idx].titles.length; i++) {
					var title = graviaList[idx].titles[i];
					if (title.styleString.toLowerCase().indexOf(keyword) > -1) {
						foundList.push(title);
					}
				}
			}
//			console.log(foundList);
			renderContent(-1, foundList);
			loading(false);
		});
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
//				graviaList.push({"itemIndex": i, "itemTitle": itemTitle, "itemList": titles});
				graviaList.push(row);
			});
		}
//		console.log(graviaList[0]);
		render();
	}).fail(function(jqxhr, textStatus, error) {
		loading(true, textStatus + ", " + error);
	}).always(function() {
		loading(false);
	});	
}

function render() {
	var titleNavContainer = $(".gravia-item");
	for (var i=0; i<graviaList.length; i++) {
		graviaList[i].itemTitle;
		var link = $("<a>").addClass("nowrap").attr({"href": "#item-" + graviaList[i].itemIndex, "onclick": "renderContent(" + i + ")", "data-toggle": "pill"}).html(graviaList[i].title.replace('출시작', ''));
		var count = $("<code>").addClass("float-right").html(graviaList[i].titles.length).appendTo(link);
		$("<li>").append(link).appendTo(titleNavContainer);
	}
	titleNavContainer.children().first().addClass("active");
	renderContent(0);
}
function renderContent(idx) {
	selectedIndex = idx;
	
	var contentList;
	var guidUrl = "";
	var headerTitle = "";
	if (idx == -1) {
		contentList = foundList;
		headerTitle = "Search result " + foundList.length;
	}
	else {
		contentList = graviaList[idx].titles;
		guidUrl = graviaList[idx].guid;
		headerTitle = graviaList[idx].title;
	}
	
	var mode = $("input:radio[name='mode']:checked").val();
	// console.log("mode is ", mode);
	var rowContainer = $(".gravia-content").empty();
	
	if (guidUrl != "") {
		$('<a>').addClass('btn btn-link float-right').attr({'onclick': 'fnOpenSource(\'' + guidUrl + '\')'}).html("Open source").appendTo(rowContainer);
	}
	var header = $("<div>").appendTo(rowContainer);
	$('<h4>').html(headerTitle).appendTo(header);
	
	if (mode === 'text') {
		for (var i=0; i < contentList.length; i++) {
			var title = contentList[i];
			$("<p>").addClass("hover_img " + (title.check ? "bg-danger" : "bg-info") + " " + (title.exist ? "exist" : "")).attr({"title": title.rowData}).append(
				$('<a>').attr({"data-src": (title.exist ? "/video/" + title.opus + "/cover" : title.imgSrc), "onclick": (title.exist ? "fnViewVideoDetail('" + title.opus + "')" : "")}).html(title.rowData).append(
					$('<span>').append(
						$('<img>').css({"width": (title.exist ? "400px" : "200px")}).addClass("img-thumbnail")		
					)
				)
			).appendTo(rowContainer);
		}
	}
	else if(mode === 'image') {
		for (var i=0; i < contentList.length; i++) {
			var title = contentList[i];
			var div = $("<div>").css({"width": "210px", "height": "290px", "display": "inline-block"});
			$("<img>").attr({"src": title.imgSrc, "title": title.styleString}).addClass("img-thumbnail").css({"width": "210px", "height": "270px"}).appendTo(div);
			$("<div>").addClass("nowrap").css({"padding": "0 10px"}).html(title.title).appendTo(div);
			div.appendTo(rowContainer);
		}
	}
	else if(mode === 'edit') {
		var table = $("<table>").addClass("table table-condensed");
		var tbody = $("<tbody>");
		for (var i=0; i < contentList.length; i++) {
			var title = contentList[i];
			var tr = $("<tr>").addClass((title.check ? "bg-danger" : "") + " " + (title.exist ? "exist" : ""));
			
			var td0 = $("<td>").css({"width": "50px"});
			$("<a>").addClass("btn btn-xs btn-default").attr({"onclick": "fnFindVideo('" + title.opus + "')"}).html("Find").appendTo(td0);

			var td1 = $("<td>").css({"width": "80px"}).addClass("hover_img");
			$('<a>').attr({"data-src": (title.exist ? "/video/" + title.opus + "/cover" : title.imgSrc), "onclick": (title.exist ? "fnViewVideoDetail('" + title.opus + "')" : "")}).addClass("label label-info").html("Image").append(
				$('<span>').append(
					$('<img>').css({"width": (title.exist ? "400px" : "200px")}).addClass("img-thumbnail")		
				)
			).appendTo(td1);
			$("<span>").addClass("label label-warning").html(title.checkDescShort).attr({"onclick": "fnToggleRowdata('#title-rowdata-" + i + "')"}).appendTo(td1);
			
			var td2 = $("<td>");
			$("<input>").attr({"name": "title"}).addClass("form-control input-sm").css({"font-size": "12px"}).val(title.styleString).appendTo(td2);
			$("<p>").addClass("label label-info").css({"display": "none"}).attr({"id": "title-rowdata-" + i}).html(title.rowData).appendTo(td2);
			
			tr.append(td0).append(td1).append(td2).appendTo(tbody);
		}
		tbody.appendTo(table);
		table.appendTo(rowContainer);
	}
	
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
function fnToggleRowdata(id) {
	$(id).toggle();
}
function fnToggleSubmitBtn() {
	var mode = $("input:radio[name='mode']:checked").val();
	if (mode === 'edit') {
		$("#submitBtn").show();
	}
	else {
		$("#submitBtn").hide();
	}
	renderContent(selectedIndex);
}
function saveCoverAll() {
	loading(true, 'Saving cover');
	document.forms[0].submit();
	loading(false);
}
</script>
</head>
<body>

<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
		<label class="title">
			GraviaInterview
		</label>
		<input type="search" id="query" class="form-control input-sm" placeholder="Opus Actress Torrent"/>
		<div class="btn-group">
			<a class="btn btn-xs btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"><s:message code="video.opus"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>
	
		<div class="btn-group btn-mode" data-toggle="buttons">
			<a class="btn btn-xs btn-default active"><input type="radio" name="mode" value="text" checked="checked">Text</a>
			<a class="btn btn-xs btn-default"><input type="radio" name="mode" value="image">Image</a>
			<a class="btn btn-xs btn-default"><input type="radio" name="mode" value="edit">Editable</a>
		</div>
	
		<a class="btn btn-xs btn-primary" style="display:none;" id="submitBtn" onclick="saveCoverAll()">All Save</a>
		
		<c:if test="${pageContext.request.method == 'POST'}">
			<span id="saveCount" class="label label-info">Save ${saveCount} Cover</span>
		</c:if>
		
	</div>

	<div id="content_div" class="box row" style="overflow:auto;">
		<div class="col-sm-2">
			<ul class="nav nav-pills nav-stacked gravia-item"></ul>
		</div>
		<form method="post" target="ifrm">
		<div class="col-sm-10 gravia-content"></div>
		</form>
	</div>

</div>
</body>
</html>