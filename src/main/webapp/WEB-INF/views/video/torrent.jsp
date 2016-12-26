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
ul.list-group.list-inline {
	padding: 3px 6px;
}
dl.video-cover {
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
dt.nowrap.text-center {
	width: 97%;
}
.nonExist {
	background-color: rgba(74, 60, 60, 0.3);;
}
.more {
	display: none;
}
.navbar {
	border: 0;
	padding-top: 20px;
}
.navbar-nav, .navbar-right {
	margin: 5px;
}
.nav > li > a {
	padding: 5px 20px;
}
.nav, .navbar-header {
	padding-left: 5px;
}
.sorted {
	font-size: 90%;
}
.navbar-default {
	background-image: linear-gradient(to bottom,#865050 0,#f8f8f8 100%);
}
#table {
	/* font-size: 0.8em; */
}
.clicked {
	background-color: lightgreen;
}
</style>
<script type="text/javascript" src="/js/video-prototype.js"></script>
<script type="text/javascript">
//bgContinue = false;
"use strict";
var videoPath = "/video";
var listViewType = 'prototype';
var lastPage = false;			// 마지막 페이지까지 다 보여줬는지
var pageSize = 12;				// 한페이지게 보여줄 개수
var currSort = '';				// 정렬 항목
var reverse = true;				// 역정렬 여부
var videoList = new Array(); 	// 비디오 배열
var entryIndex = 0;				// 비디오 인덱스 
var renderingCount = 0;			// 보여준 개수
var sortList = [{code: "S", name: "Studio"}, {code: "O", name: "Opus"}, {code: "T", name: "Title"}, 
		{code: "A", name: "Actress"}, {code: "D", name: "Released"}, 
	//	{code: "R", name: "Rank"}, {code: "SC", name: "Score"}, 
		{code: "T", name: "Torrent"}, {code: "F", name: "Favorite"}, {code: "C", name: "Candidates"}];
var candidateCount = 0;
var hadTorrentCount = 0;

(function($) {
	$(document).ready(function() {
		
		// init components
		$.each(sortList, function(i, sort) {
			$("<button>").addClass("btn btn-xs").attr("data-sort-code", sort.code).attr("data-sort-name", sort.name)
				.html(sort.name).appendTo($(".btn-group-sort"));
		});
		$(".tab-content").css("margin-top", $(".navbar").outerHeight() + "px");

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
				videoList.push(new Video(row));
			});
			$("#totalCandidatedVideo").html(candidateCount);
			$("#havingTorrents").html(hadTorrentCount);
			$("button[data-sort-code='C']").click(); // 정렬하여 보여주기
		}
	}).fail(function(jqxhr, textStatus, error) {
		showStatus(true, textStatus + ", " + error, true);
	});	
}

function fnAddEventListener() {
	// scroll
	$(document).scroll(function() {
		var maxHeight = $(document).height();
		var currentScroll = $(window).scrollTop() + $(window).height();

		if (maxHeight <= currentScroll + 50 && !lastPage)
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
		
		$(".sorted").html(sortName + (reverse ? " desc" : ""));
		
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
	if (first) {
		entryIndex = 0;
		renderingCount = 0;
		lastPage = false;
		$("ul.list-group").empty();
		$(".table-list > tbody").empty();
		$(".more").show();
	}
	
	showStatus(true, "loading...");
	
	var displayCount = 0;
	var query = $(".search").val();
	while (entryIndex < videoList.length) {
		if (query != '') {
			if (!videoList[entryIndex].contains(query)) {
				entryIndex++;
				continue;
			}
		}
		if (displayCount < pageSize) {
			renderingCount++; 	// 화면에 보여준 개수
			displayCount++;		// 이번 메서드에서 보여준 개수
			
			$("ul.list-group").append(videoJsonToDom(videoList[entryIndex]));
			$(".table-list > tbody").append(renderTable(videoList[entryIndex]));
			
			$(".count").html(renderingCount + " / " + videoList.length);

			entryIndex++;		// videoList의 현개 인덱스 증가
		}
		else {
			break;
		}
	}

	if (entryIndex >= videoList.length) { // 전부 보여주었으면
		lastPage = true;
		$(".more").hide();
	}
	
	showStatus(false);
	
	var maxHeight = $(document).height();
	var currentScroll = $(window).scrollTop() + $(window).height();
	if (maxHeight === currentScroll && !lastPage) { // 한페이지에 다 보여서 스크롤이 생기지 않으면 한번더
		render();
	}

}

function showStatus(show, msg, isError) {
	// console.log("showStatus", show, msg, isError);
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

function videoJsonToDom(video) {
	var dl = $("<dl>").css("background-image", "url('" + video.coverURL + "')").addClass("video-cover");
	$("<dt>").html(video.titleHtml).addClass("nowrap text-center").appendTo(dl);
	$("<dd>").html(video.studioHtml).appendTo(dl);
	$("<dd>").html(video.opusHtml).appendTo(dl);
	$("<dd>").html(video.actressHtml).appendTo(dl);
	$("<dd>").html(video.releaseHtml).appendTo(dl);
	$("<dd>").html(video.favoriteHtml).appendTo(dl);
	$("<dd>").html(video.videoCandidatesHtml).appendTo(dl);
	$("<dd>").html(video.torrentsHtml).appendTo(dl);
	$("<dd>").html(video.torrentFindBtn).appendTo(dl);
	return $("<li>").append(dl);
}
function renderTable(video) {
	var tr = $("<tr>").attr("id", "check-" + video.opus);
	$("<td>").html('<div style="max-width:450px;" class="nowrap" title="' + video.fullname + '">' + video.fullnameHtml + '</div>').appendTo(tr);
	$("<td>").html(video.favoriteHtml).appendTo(tr);
	$("<td>").html(video.torrentFindBtn).appendTo(tr);
	var div = $("<div>").append(video.videoCandidatesHtml).append(video.torrentsHtml);
	$("<td>").append(div).appendTo(tr);
	return tr;
}
function fnSelectCandidateVideo(dom) {
	$("#totalCandidatedVideo").html(--candidateCount);
	$(dom).parent().parent().parent().hide();
}
function goTorrentSearch(opus) {
	popup(videoPath + "/" + opus + '/cover/title', 'SearchTorrentCover');
	popup(videoPath + '/torrent/search/' + opus, 'torrentSearch', 900, 950);

	$("#check-" + opus).addClass("clicked");
}
function getAllTorrents() {
	actionFrame(videoPath + "/torrent/getAll", {}, "POST", "Torrent get all");
}
</script>
</head>
<body>

	<nav class="navbar navbar-default navbar-fixed-top">
	  	<div class="container-fluid">
	    	<div class="navbar-header">
				<strong class="lead text-justify title">
					Torrent
					<a class="btn btn-sm btn-link" href="javascript:getAllTorrents()">Get All</a>
				</strong>
	    	</div>
	    	<ul class="nav navbar-nav navbar-right">
	      		<li><div class="btn-group btn-group-sort"></div></li>
	    	</ul>
	    	<ul class="nav navbar-nav navbar-right">
	      		<li><input class="form-control input-sm search" placeholder="Search..."></li>
	      	</ul>
	    	<ul class="nav navbar-nav navbar-right">
				<li>
					<label class="label label-primary">Candidate <i id="totalCandidatedVideo"></i></label>
				</li>
	      	</ul>
	    	<ul class="nav navbar-nav navbar-right">
				<li>
					<label class="label label-warning">Having <i id="havingTorrents"></i> torrents</label>
				</li>
	    	</ul>
	  	</div>
		<ul class="nav nav-tabs">
			<li class=""><a data-toggle="tab" href="#box">BOX</a></li>
			<li class="active"><a data-toggle="tab" href="#table">TABLE</a></li>
			<li><a class="text-info count">Initialize...</a></li>
			<li><a class="btn btn-xs text-danger status"></a></li>
			<li style="float: right;"><a class="text-warning sorted"></a></li>
		</ul>
	</nav>

	<div class="container-fluid">
		<div class="tab-content">
			<section id="box" class="tab-pane fade">
				<ul class="list-group list-inline"></ul>
			</section>
			<section id="table" class="tab-pane fade in active">
				<table class="table table-condensed table-hover table-responsive table-list">
					<tbody></tbody>
				</table>
			</section>
			<p class="more text-center"><button class="btn btn-warning" onclick="render()">More...</button></p>
		</div>
	</div>
	<iframe id="actionIframe" style="display:none;"></iframe>
</body>
</html>
