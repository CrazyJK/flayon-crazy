<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.torrent"/></title>
<style type="text/css">
*[onclick] {
	cursor: pointer;
}

/* for navbar 
.navbar {
	border: 0;
	padding-top: 20px;
}
.navbar-default {
	background-image: linear-gradient(to bottom,#865050 0,#f8f8f8 100%);
}
.navbar-header {
	padding-left: 5px;
}
.navbar-nav {
	margin: 5px;
}
.nav-tabs > li > a {
	padding: 5px 20px;
}
*/
/* for box view */
#box > ul {
	padding: 3px 6px;
	text-align: center;
}
#box > ul > li > dl {
	background-repeat: no-repeat;
	background-position: center center;
	background-size: cover;
	transition: all 0.3s;	

	margin: 5px;
	padding: 3px;
	width: 285px;
	height: 210px;
	border-radius: 10px;
	text-align: left;
	box-shadow: 0 3px 9px rgba(0,0,0,.5);
}
#box > ul > li > dl:hover {
	transform:scale(1.1, 1.1);
	box-shadow: 0 0 9px 6px rgba(255, 0, 0, 0.5);
}
#box > ul > li > dl > dt.nowrap.text-center {
	width: 97%;
}

/* for logic */
.found {
	background-color: rgba(73, 153, 108, 0.5);
}
.moved {
	background-color: rgba(206, 55, 145, 0.5);
}
.nonExist {
	background-color: rgba(74, 60, 60, 0.3);;
}
.more {
	display: none;
}
.search {
	/* width: 104px; */
	padding-bottom: 0px;
}
/* for table view */
.tbl-cover {
	display: none;
	position: fixed;
	/* bottom: 20px;
	left: 20px; */
	width: 600px;
	box-shadow: 0 0 6px rgba(255,0,0,1);
	transition: all .2s ease-in-out;
}
</style>
<script type="text/javascript" src="<c:url value="/js/videoMain.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/video-prototype.js"/>"></script>
<script type="text/javascript">
//bgContinue = false;
"use strict";
var lastPage = false;			// 마지막 페이지까지 다 보여줬는지
var pageSize = 12;				// 한페이지게 보여줄 개수
var currSort = '';				// 정렬 항목
var videoList = new Array(); 	// 비디오 배열
var entryIndex = 0;				// 비디오 인덱스 
var renderingCount = 0;			// 보여준 개수
var sortList = [
		{code: "S", name: "Studio"}, {code: "O", name: "Opus"}, {code: "T", name: "Title"}, 
		{code: "A", name: "Actress"}, {code: "D", name: "Released"}, 
		{code: "R", name: "Rank"}, {code: "Sc", name: "Score"}, 
		{code: "To", name: "Torrent"}, {code: "F", name: "Favorite"}, {code: "C", name: "Candidates"}];
var defaultSort = 'D';
var reverse = true;				// 역정렬 여부
var candidateCount = 0;
var hadTorrentCount = 0;
var videoCount = 0;
var withTorrent = false;
var isShortWidth = false;
var queryFoundCount = 0;

(function($) {
	$(document).ready(function() {
		// init components
		$.each(sortList, function(i, sort) {
			$("<button>").addClass("btn btn-xs").data("sort", sort).html(sort.code).appendTo($(".btn-group-sort"));
		});
		// add EventListener
		fnAddEventListener();
		// ajax data		
		request();
		
	});
}(jQuery));

function fnAddEventListener() {
	// scroll
	$("#content_div").scroll(function() {
		if (fnIsScrollBottom())
			render(false); // next page
	});

	// search	
	$(".search").on('keyup', function(e) {
		var event = window.event || e;
		if (event.keyCode == 13)
			render(true);
	});
	
	// sorting & render
	$(".btn-group-sort").children().on('click', function() {
		$(this).parent().children().each(function() {
			var sort = $(this).data("sort");
			$(this).removeClass("btn-success").addClass("btn-default").attr({"title": sort.name}).html(sort.code);
		});
		var sort = $(this).data('sort');
		if (currSort === sort.code) // 같은 정렬
			reverse = !reverse;
		else	// 다른 정렬
			reverse = true;
		currSort = sort.code;
		
		videoSort(videoList, sort.code, reverse);

		$(".sorted").html(sort.name + (reverse ? " desc" : ""));
		$(this).removeClass("btn-default").addClass("btn-success").html(sort.name + (reverse ? ' ▼' : ' ▲'));
		
		render(true);
	});
	
	// re-request
	$(".count").attr({"title": "re-request"}).on('click', function() {
		defaultSort = 'C';
		request();
	});

	// image click
	$("#cover").on("click", function() {
		$("#checkbox-viewImage").click();
		$(this).hide();
	}).css({"cursor": "pointer"});

	// tab event
	$('button[data-toggle="tab"]').on('shown.bs.tab', function (e) {
		$('button[data-toggle="tab"]').removeClass("btn-info").addClass("btn-default");
		$(e.target).removeClass("btn-default").addClass("btn-info");
	});

}

function request() {
	loading(true, "request...");
	showStatus(true, "Request...");

	// reset variables
	reverse = !reverse;
	hadTorrentCount = 0;
	candidateCount = 0;
	videoCount = 0;
	
	$.getJSON({
		method: 'GET',
		url: '/video/list.json',
		data: {"t": withTorrent},
		cache: false,
		timeout: 60000
	}).done(function(data) {
		if (data.exception) {
			showStatus(true, data.exception.message, true);
		}
		else {
			videoList = [];
			$.each(data.videoList, function(i, row) { // 응답 json을 videoList 배열로 변환
				if (row.torrents.length > 0)
					hadTorrentCount++;
				if (row.videoCandidates.length > 0)
					candidateCount++;
				if (row.videoFileList.length > 0)
					videoCount++;
				videoList.push(new Video(i, row));
			});
			$(".candidate").html("Candidate " + candidateCount);
			$(".torrents").html("Torrents " + hadTorrentCount);
			$(".videoCount").html("Video " + videoCount);
			

			// 정렬하여 보여주기 => sort
			$(".btn-group-sort").children().each(function() {
				var sort = $(this).data("sort");
				if (sort.code === defaultSort) {
					$(this).click();
				}
			});
		}
	}).fail(function(jqxhr, textStatus, error) {
		showStatus(true, textStatus + ", " + error, true);
	}).always(function() {
		loading(false);
	});	
}

function render(first) {
	showStatus(true, "rendering...");
	
	var displayCount = 0;
	var query = $(".search").val();
	var parentOfVideoBox  = $("#box > ul");
	var parentOfTableList = $("#table > table > tbody");
	withTorrent = $("#withTorrent").is(":checked");

	if (first) { // initialize if first rendering 
		entryIndex = 0;
		renderingCount = 0;
		lastPage = false;
		parentOfVideoBox.empty();
		parentOfTableList.empty();
		$(".more").show();
		// found count by query
		if (query != '') {
			queryFoundCount = 0;
			for (var i=0; i<videoList.length; i++) {
				if (videoList[i].contains(query)) {
					queryFoundCount++;
				}
			}
		}
	}
	
	while (entryIndex < videoList.length) {
		if (query != '') { // query filtering
			if (!videoList[entryIndex].contains(query)) {
				entryIndex++;
				continue;
			}
		}
		
		if (displayCount < pageSize) { // render html
			renderBox(entryIndex, videoList[entryIndex], parentOfVideoBox);
			renderTable(entryIndex, videoList[entryIndex], parentOfTableList);

			renderingCount++; 	// 화면에 보여준 개수
			displayCount++;		// 이번 메서드에서 보여준 개수
			entryIndex++;		// videoList의 현개 인덱스 증가
		}
		else {
			break;
		}
	}

//	console.log("render", first, displayCount, entryIndex, renderingCount, videoList.length);
	if (entryIndex == videoList.length) { // 전부 보여주었으면
		lastPage = true;
		$(".more").hide();
	}
	
	if (fnIsScrollBottom()) // 한페이지에 다 보여서 스크롤이 생기지 않으면 한번더
		render();
	
	if (query != '') {
		$(".count").html(renderingCount + " / " + queryFoundCount);
	}
	else {
		$(".count").html(renderingCount + " / " + videoList.length);
	}
	
	setTblCoverPosition();
	
	showStatus(false);
}

function fnIsScrollBottom() {
	var containerHeight    = $("#content_div").height();
	var containerScrollTop = $("#content_div").scrollTop();
	var documentHeight     = $("ul.nav-tabs").height() + $("div.tab-content").height();
	var scrollMargin       = $("p.more").height();
//	console.log("fnIsScrollBottom", containerHeight, ' + ', containerScrollTop, ' = ', (containerHeight + containerScrollTop), ' > ', documentHeight, ' + ', scrollMargin, ' = ', (documentHeight - scrollMargin), lastPage);
	return (containerHeight + containerScrollTop > documentHeight - scrollMargin) && !lastPage;
}

function showStatus(show, msg, isError) {
	if (show) { // loading start
		if (isError) {
			$(".status").html(msg).show();
		}
		else {
			$(".status").html(msg).show();
		}
	}
	else { // loading complete
		$(".status").fadeOut(1500);
	}
}

function renderBox(index, video, parent) {
	var dl = $("<dl>").css({"background-image": "url('" + video.coverURL + "')"}).addClass("video-cover");
	$("<dt>").appendTo(dl).html(video.html_title).addClass("nowrap text-center");
	$("<dd>").appendTo(dl).html(video.html_studio);
	$("<dd>").appendTo(dl).html(video.html_opus);
	$("<dd>").appendTo(dl).html(video.html_actress);
	$("<dd>").appendTo(dl).html(video.html_release);
	$("<dd>").appendTo(dl).html(video.html_video);
	$("<dd>").appendTo(dl).html(video.html_subtitles);
	$("<dd>").appendTo(dl).html(video.html_videoCandidates);
	$("<dd>").appendTo(dl).html(video.html_torrents + video.html_torrentFindBtn);
	$("<dd>").appendTo(dl).html(video.overviewText);
	$("<li>").append(dl).appendTo(parent).attr({"data-idx": video.idx});
}

function renderTable(index, video, parent) {
	var tr = $("<tr>").appendTo(parent).attr({"id": "check-" + video.opus, "data-idx": video.idx});
	$('<td>').appendTo(tr).addClass("text-right").html("<span class='label label-plain'>" + (index+1) + "</span>");
	$("<td>").appendTo(tr).html(video.html_studio);
	$("<td>").appendTo(tr).html(video.html_opus);
	$('<td>').appendTo(tr).html(
		$('<div>').addClass("nowrap").append(
			$('<span>').addClass('label label-plain').attr({"onclick": "fnViewVideoDetail('" + video.opus + "')"}).html(video.title).attr({"title": video.title, "data-toggle": "tooltip"}) //.tooltip()
		).append(
			$("<img>").attr({"id": "tbl-cover-" + video.opus,"src": video.coverURL}).addClass("img-thumbnail tbl-cover").hide()
		)
	).css({"max-width": "300px"}).hover(
			function(event) {
				if ($("input:checkbox[id='viewImage']").prop("checked")) {
					var imgTop = event.clientY + 40;
					$(this).find("img").css({"top": imgTop}).show();
				}
			}, function(event) {
				$("#tbl-cover-" + video.opus).hide();
			}
	);
	$("<td>").appendTo(tr).html(video.html_actress).css({"max-width": "100px"}).attr({"title": video.actressName});
	$("<td>").appendTo(tr).html(video.html_release).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_video);
	$("<td>").appendTo(tr).html(video.html_subtitles).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_rank).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_score).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).append(
			$("<div>").append(video.html_videoCandidates).append(video.html_torrents).append(video.html_torrentFindBtn)
	).addClass("extraInfo " + (withTorrent ? "" : "hide"));
}

function fnSelectCandidateVideo(opus, idx) {
	$(".candidate").html("Candidate " + --candidateCount);
	$("[data-idx=" + idx + "]").hide();
}
function goTorrentSearch(opus, idx) {
	$("[data-idx='" + idx + "']").addClass("found");
	popup(videoPath + '/' + opus + '/cover/title', 'SearchTorrentCover', 800, 600);
	popup(videoPath + '/torrent/search/' + opus, 'torrentSearch', 900, 950);
}
function goTorrentMove(opus, idx) {
	$("[data-idx='" + idx + "']").addClass("moved");
	actionFrame(videoPath + "/" + opus + "/moveTorrentToSeed", {}, "POST", "Torrent move");
}
function getAllTorrents() {
	actionFrame(videoPath + "/torrent/getAll", {}, "POST", "Torrent get all");
}
function resizeSecondDiv() {
	isShortWidth = $(window).width() < 950;
	if (isShortWidth)
		$(".shortWidth").addClass("hide");
	else
		$(".shortWidth").removeClass("hide");

	setTblCoverPosition();
}
function setTblCoverPosition() {
	var imgWidth = windowWidth / 2;
	if (imgWidth > 800)
		imgWidth = 800;
	var imgLeft = windowWidth / 4;
	$(".tbl-cover").css({"left": imgLeft, "width": imgWidth});
}
</script>
</head>
<body>
<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
   		<input class="form-control input-sm search" placeholder="Search...">
		<span class="label label-info count">Initialize...</span>
		<label>
			<input type="checkbox" id="withTorrent" name="withTorrent" class="sr-only">
			<span class="label label-default" id="checkbox-withTorrent" data-toggle=".extraInfo">Extra info</span>
		</label>
     	<label>
      		<input type="checkbox" id="viewImage" name="viewImage" checked="checked" class="sr-only">
      		<span class="label label-success" id="checkbox-viewImage">Image</span>
      	</label>
      	<span class="label label-danger status"></span>
      	
      	<div class="float-right">
			<div class="btn-group">
		      	<button class="btn btn-xs btn-info" data-toggle="tab" href="#table">Table</button>
		      	<button class="btn btn-xs btn-default" data-toggle="tab" href="#box">Box</button>
			</div>
			<div class="btn-group btn-group-sort"></div>
			<button class="btn btn-xs btn-primary" onclick="getAllTorrents()">All torrents</button>
      	</div>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<%-- <ul class="nav nav-tabs">
			<li class="active"><a data-toggle="tab" href="#table">TABLE</a></li>
			<li class=""><a data-toggle="tab" href="#box">BOX</a></li>
			<li class="float-right">
				<span class="label label-info videoCount"></span>
				<span class="label label-primary candidate"></span>
				<span class="label label-warning torrents"></span>
				<span class="label label-success sorted hide"></span>
			</li>
		</ul> --%>
		<div class="tab-content">
			<section id="box" class="tab-pane fade">
				<ul class="list-group list-inline vbox"></ul>
			</section>
			<section id="table" class="tab-pane fade in active table-responsive">
				<table class="table table-condensed table-hover table-bordered">
					<tbody></tbody>
				</table>
			</section>
			<p class="more text-center"><button class="btn btn-warning" onclick="render()">More...</button></p>
		</div>
	</div>

</div>

</body>
</html>
