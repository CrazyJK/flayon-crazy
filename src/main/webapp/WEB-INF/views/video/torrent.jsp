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

/* for navbar */
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
.nav-tabs > li > a.nav-info:hover {
	border-color: transparent;
	background-color: transparent;
}

/* for box view */
#box > ul {
	padding: 3px 6px;
}
#box > ul > li > dl {
	background-repeat: no-repeat;
	background-position: center center;
	background-size: cover;
	transition: all 3s;	

	margin: 5px;
	padding: 3px;
	width: 290px;
	height: 210px;
	border-radius: 10px;
	text-align: left;
	box-shadow: 0 3px 9px rgba(0,0,0,.5);
}
#box > ul > li > dl > dt.nowrap.text-center {
	width: 97%;
}

/* for logic */
.nav-info {
	font-size: 90%;
	padding: 5px 10px !important;
	text-shadow: 1px 1px azure;
}
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
</style>
<script type="text/javascript" src="/js/video-prototype.js"></script>
<script type="text/javascript">
//bgContinue = false;
"use strict";
var lastPage = false;			// 마지막 페이지까지 다 보여줬는지
var pageSize = 12;				// 한페이지게 보여줄 개수
var currSort = '';				// 정렬 항목
var reverse = true;				// 역정렬 여부
var videoList = new Array(); 	// 비디오 배열
var entryIndex = 0;				// 비디오 인덱스 
var renderingCount = 0;			// 보여준 개수
var sortList = [
		{code: "S", name: "Studio"}, {code: "O", name: "Opus"}, {code: "T", name: "Title"}, 
		{code: "A", name: "Actress"}, {code: "D", name: "Released"}, 
	//	{code: "R", name: "Rank"}, {code: "SC", name: "Score"}, 
		{code: "T", name: "Torrent"}, {code: "F", name: "Favorite"}, {code: "C", name: "Candidates"}];
var candidateCount = 0;
var hadTorrentCount = 0;

(function($) {
	$(document).ready(function() {
		
		// init components
		$.each(sortList, function(i, sort) {
			$("<button>")
				.addClass("btn btn-xs")
				.attr({"data-sort-code": sort.code, "data-sort-name": sort.name})
				.html(sort.name)
				.appendTo($(".btn-group-sort"));
		});

		// add EventListener
		fnAddEventListener();
		
		request();
	});
}(jQuery));

function request() {
	showStatus(true, "Request...");
	$.getJSON({
		method: 'GET',
		url: '/video/torrent.json',
		data: {'data': true},
		cache: false,
		timeout: 60000
	}).done(function(data) {
		if (data.exception) {
			showStatus(true, data.exception.message, true);
		}
		else {
			$.each(data.videoList, function(i, row) { // 응답 json을 videoList 배열로 변환
				if (row.torrents.length > 0)
					hadTorrentCount++;
				if (row.videoCandidates.length > 0)
					candidateCount++;
				videoList.push(new Video(i, row));
			});
			$(".candidate").html("Candidate " + candidateCount);
			$(".torrents").html("Having " + hadTorrentCount + " torrents");
			$("button[data-sort-code='C']").click(); // 정렬하여 보여주기 => sort
		}
	}).fail(function(jqxhr, textStatus, error) {
		showStatus(true, textStatus + ", " + error, true);
	});	
}

function fnIsScrollBottom() {
	var containerHeight    = $("#content_div").height();
	var containerScrollTop = $("#content_div").scrollTop();
	var documentHeight     = $("ul.nav-tabs").height() + $("div.tab-content").height();
	var scrollMargin       = $("p.more").height();
//	console.log("fnIsScrollBottom", containerHeight, ' + ', containerScrollTop, ' = ', (containerHeight + containerScrollTop), ' > ', documentHeight, ' + ', scrollMargin, ' = ', (documentHeight - scrollMargin), lastPage);
	return (containerHeight + containerScrollTop > documentHeight - scrollMargin) && !lastPage;
}

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
	
	// sort
	$(".btn-group-sort").children().on('click', function() {
		$(this).parent().children().each(function() {
			var sortName = $(this).attr("data-sort-name");
			$(this).removeClass("btn-warning").addClass("btn-default").html(sortName);
		});
		var sortCode = $(this).attr('data-sort-code');
		var sortName = $(this).attr('data-sort-name');
		if (currSort === sortCode) // 같은 정렬
			reverse = !reverse;
		else	// 다른 정렬
			reverse = true;
		currSort = sortCode;
		
		videoList.sort(function(video1, video2) {
			switch(sortCode) {
			case 'S':
				return compareTo(video1.studio.name, video2.studio.name, reverse); 
			case 'O':
				return compareTo(video1.opus, video2.opus, reverse); 
			case 'T':
				return compareTo(video1.title, video2.title, reverse); 
			case 'A':
				return compareTo(video1.actress, video2.actress, reverse); 
			case 'D':
				return compareTo(video1.releaseDate, video2.releaseDate, reverse); 
			case 'R':
				return compareTo(video1.rank, video2.rank, reverse); 
			case 'SC':
				return compareTo(video1.score, video2.score, reverse); 
			case 'T':
				return compareTo(video1.torrents.length, video2.torrents.length, reverse); 
			case 'F':
				return compareTo(video1.favorite, video2.favorite, reverse); 
			case 'C':
				var result = compareTo(video1.existCandidates, video2.existCandidates, reverse);
				if (result == 0)
					result = compareTo(video1.favorite, video2.favorite, reverse);
				if (result == 0)
					result = compareTo(video1.existTorrents, video2.existTorrents, reverse);
				if (result == 0)
					result = compareTo(video1.opus, video2.opus, reverse); 
				return result; 
			default:
				return video1.title > video2.title ? 1 : -1;
			}
		});

		$(".sorted").html(sortName + (reverse ? " desc" : ""));
		$(this).removeClass("btn-default").addClass("btn-warning").html(sortName + (reverse ? ' ▼' : ' ▲'));
		
		render(true);
	});
}

function compareTo(data1, data2, reverse) {
	var result = 0;
	if (typeof data1 === 'number') {
		result = data1 - data2;
	} else if (typeof data1 === 'string') {
		result = data1.toLowerCase() > data2.toLowerCase() ? 1 : -1;
	} else if (typeof data1 === 'boolean') {
		result = data1 ? 1 : (data2 ? -1 : 0);
	} else {
		result = data1 > data2 ? 1 : -1;
	}
	return result * (reverse ? -1 : 1);
}

function render(first) {
	showStatus(true, "rendering...");
	
	var displayCount = 0;
	var query = $(".search").val();
	var parentOfVideoBox  = $("#box > ul");
	var parentOfTableList = $("#table > table > tbody");
	
	if (first) { // initialize if first rendering 
		entryIndex = 0;
		renderingCount = 0;
		lastPage = false;
		parentOfVideoBox.empty();
		parentOfTableList.empty();
		$(".more").show();
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

	$(".count").html(renderingCount + " / " + videoList.length);
	showStatus(false);
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
	$("<dt>").addClass("nowrap text-center").html(video.titleHtml).appendTo(dl);
	$("<dd>").appendTo(dl).html(video.studioHtml);
	$("<dd>").appendTo(dl).html(video.opusHtml);
	$("<dd>").appendTo(dl).html(video.actressHtml);
	$("<dd>").appendTo(dl).html(video.releaseHtml);
	$("<dd>").appendTo(dl).html(video.favoriteHtml);
	$("<dd>").appendTo(dl).html(video.videoCandidatesHtml);
	$("<dd>").appendTo(dl).html(video.torrentsHtml);
	$("<dd>").appendTo(dl).html(video.torrentFindBtn);
	$("<li>").append(dl).appendTo(parent).attr({"data-idx": video.idx});
}
function renderTable(index, video, parent) {
	var tr = $("<tr>").appendTo(parent).attr({"id": "check-" + video.opus, "data-idx": video.idx});
	$('<td>').appendTo(tr).addClass("text-right").html("<span class='label label-plain'>" + (index+1) + "</span>");
	$('<td>').appendTo(tr).css({"max-width": "450px"}).html('<div class="nowrap" title="' + video.fullname + '">' + video.fullnameHtml + '</div>');
	$("<td>").appendTo(tr).html(video.favoriteHtml);
	$("<td>").appendTo(tr).html(video.torrentFindBtn);
	$("<td>").appendTo(tr).append($("<div>").append(video.videoCandidatesHtml).append(video.torrentsHtml));
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
</script>
</head>
<body>
<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
		<label class="title">
			Torrent
		</label>
      	<input class="form-control input-sm search" placeholder="Search...">
		<span class="nav-info text-info count">Initialize...</span>
      	<span class="nav-info text-danger status"></span>
      	<div class="float-right">
			<div class="btn-group btn-group-sort"></div>
			<button class="btn btn-xs btn-default" onclick="getAllTorrents()">Get All</button>
      	</div>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<ul class="nav nav-tabs">
			<li class=""><a data-toggle="tab" href="#box">BOX</a></li>
			<li class="active"><a data-toggle="tab" href="#table">TABLE</a></li>
			<li class="float-right"><a class="nav-info text-success sorted"></a></li>
			<li class="float-right"><a class="nav-info text-warning candidate"></a></li>
			<li class="float-right"><a class="nav-info text-primary torrents"></a></li>
		</ul>
		<div class="tab-content">
			<section id="box" class="tab-pane fade">
				<ul class="list-group list-inline"></ul>
			</section>
			<section id="table" class="tab-pane fade in active">
				<table class="table table-condensed table-hover table-responsive">
					<tbody></tbody>
				</table>
			</section>
			<p class="more text-center"><button class="btn btn-warning" onclick="render()">More...</button></p>
		</div>
	</div>

</div>	
</body>
</html>
