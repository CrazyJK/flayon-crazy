<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" 	 uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>Source RSS</title>
<style type="text/css">
.gravia-item {
	position: fixed;
	top: 80px;
}
.gravia-content {
	font-size: 12px;
	background-color: rgba(255, 255, 255, 0.5);
}
div#content_div ul.nav li a {
	font-size: 12px;
    padding: 5px;
    margin: 0 3px 5px;
    border: 1px solid rgb(51, 122, 183);
}
div#content_div ol li {
	font-size: 12px;
	display: inline-flex;
    border-radius: 6px;
    border: 1px solid #eee;
    width: 180px;
    height: 230px;
    background-position: center center;
    background-size: contain;
}
div#content_div ol li div {
	width: 100%;
	font-weight: 700;
	vertical-align: bottom;
	text-align: center;
	margin-top: 150px;
}
div#content_div ol li div span {
	background-color: rgba(255, 255, 255, 0.5);
}
</style>
<script type="text/javascript">
bgContinue = false;
var graviaList = new Array();

(function($) {
	$(document).ready(function() {
	
		request();
	
	});
}(jQuery));

function request() {
	loading(true, "request...");
	$.getJSON({
		method: 'GET',
		url: '/video/gravia/data.json',
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
				graviaList.push({"itemIndex": i, "itemTitle": itemTitle, "itemList": titles});
			});
		}
		console.log(graviaList[0]);
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
		var link = $("<a>").addClass("nowrap")
						.attr({"href": "#item-" + graviaList[i].itemIndex, "onclick": "renderContent(" + i + ")", "data-toggle": "pill"})
						.html(graviaList[i].itemTitle + " " + graviaList[i].itemList.length);
		$("<li>").css({"max-width": "150px"}).append(link).appendTo(titleNavContainer);
		
	}
}
function renderContent(idx) {
	var mode = $("input:radio[name='mode']:checked").val();
	console.log("mode is ", mode);
	var rowContainer = $(".gravia-content").empty();
	
	if (mode === 'text') {
		for (var i=0; i < graviaList[idx].itemList.length; i++) {
			var title = graviaList[idx].itemList[i];
			$("<p>").addClass(title.check ? "text-danger" : "text-info").attr({"title": title.rowData}).html(title.styleString).appendTo(rowContainer);;
		}
	}
	else if(mode === 'image') {
	}
	else if(mode === 'edit') {
		var table = $("<table>").addClass("table table-condensed");
		var tbody = $("<tbody>");
		for (var i=0; i < graviaList[idx].itemList.length; i++) {
			var title = graviaList[idx].itemList[i];
			var tr = $("<tr>").addClass(title.check ? "danger" : "default");
			var td0 = $("<td>").css({"width": "50px"});
			var findBtn = $("<a>").addClass("btn btn-xs btn-default").attr({"onclick": "fnFindVideo('" + title.opus + "')"}).html("Find");
			td0.append(findBtn);
			var td1 = $("<td>").css({"width": "50px"});
			var checkLabel = $("<span>").addClass("label label-warning").html(title.checkDescShort);
			td1.append(checkLabel);
			var td2 = $("<td>");
			var input = $("<input>").addClass("form-control input-sm").val(title.styleString);
			td2.append(input);
			tr.append(td0).append(td1).append(td2).appendTo(tbody);
		}
		tbody.appendTo(table);
		table.appendTo(rowContainer);
	}	
	
}
function fnFindVideo(opus) {
	fnMarkChoice(opus);
	popup('${urlSearchVideo}' + opus, 'videoSearch', 900, 950);
}

</script>
</head>
<body>

<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
		<label class="title">
			GraviaInterview source
		</label>
		<input type="search" id="query" class="form-control input-sm" placeholder="Opus Actress Torrent"/>
		<div class="btn-group">
			<a class="btn btn-xs btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"><s:message code="video.opus"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>
	
		<div class="btn-group" data-toggle="buttons">
			<a class="btn btn-xs btn-default active"><input type="radio" name="mode" value="text" checked="checked">Text</a>
			<a class="btn btn-xs btn-default"><input type="radio" name="mode" value="image">Image</a>
			<a class="btn btn-xs btn-default"><input type="radio" name="mode" value="edit">Editable</a>
		</div>
	
	
	</div>

	<div id="content_div" class="box row" style="overflow:auto;">
		<div class="col-sm-2">
			<ul class="nav nav-pills nav-stacked gravia-item"></ul>
		</div>
		<div class="col-sm-10 gravia-content"></div>
	</div>

</div>
</body>
</html>