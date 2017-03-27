/**
 * for videoListBySpa.jsp
 */

"use strict";

var lastPage = false;			// 마지막 페이지까지 다 보여줬는지
var pageSize = 12;				// 한페이지에 보여줄 개수
var defaultSort = 'M';			// 기본 정렬 방법
var currSort = '';				// 현재 정렬 방법
var reverse = true;				// 역정렬 여부
var videoList = new Array(); 	// 비디오 배열
var entryIndex = 0;				// 비디오 인덱스 
var renderingCount = 0;			// 보여준 개수
var sortList = [
		{code: "S", name: "Studio"},  {code: "O", name: "Opus"},     {code: "T", name: "Title"}, 
		{code: "A", name: "Actress"}, {code: "D", name: "Rel"}, {code: "M", name: "Mod"}, 
		{code: "R", name: "Rank"},    {code: "Sc", name: "Score"}, 
		{code: "To", name: "Torrent"}, 
//		{code: "F", name: "Favorite"}, 
		{code: "C", name: "Candi"}];
var candidateCount = 0;			// candidate 파일 개수
var hadTorrentCount = 0;		// torrent 파일 개수
var videoCount = 0;				// video 파일 개수
var queryFoundCount = 0;		// 검색으로 찾은 비디오 개수
var withTorrent = false;		// table 뷰에서 torrent 정보 컬럼 보여줄지 여부 
var currentVideoNo = -1;		// table 뷰에서 커서/키가 위치한 tr번호. 커버 보여주기 위해
var isShortWidth = false;		// table 뷰에서 가로폭이 좁은지 여부
var isCheckedFavorite = false;	// favorite 체크박스가 체크되어 있는지 여부
var isCheckedNoVideo  = false;	// novideo  체크박스가 체크되어 있는지 여부
var isCheckedTags = false;
var currentView = '#table';		// 현재 보여지고 있는 뷰
var tagList;

(function($) {
	$(document).ready(function() {
		// init components
		initComponent();
		// add EventListener
		fnAddEventListener();
		// ajax data		
		request();
		
	});
}(jQuery));

function initComponent() {
	$.each(sortList, function(i, sort) {
		$("<button>").addClass("btn btn-xs").data("sort", sort).html(sort.code).appendTo($(".btn-group-sort"));
	});
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
	
	// sorting & render
	$(".btn-group-sort").children().on('click', function() {
		$(this).parent().children().each(function() {
			var sort = $(this).data("sort");
			$(this).swapClass("btn-success", "btn-default", true).attr({"title": sort.name}).html(sort.code).css({"border-color": "#3e8f3e"});
		});
		var sort = $(this).data('sort');
		if (currSort === sort.code) // 같은 정렬
			reverse = !reverse;
		else	// 다른 정렬
			reverse = true;
		currSort = sort.code;
		
		videoSort(videoList, sort.code, reverse);

		$(".sorted").html(sort.name + (reverse ? " desc" : ""));
		$(this).swapClass("btn-default", "btn-success", true).html(sort.name + (reverse ? ' ▼' : ' ▲'));
		
		render(true);
	});
	
	// re-request
	$(".count").attr({"title": "re-request"}).on('click', function() {
		defaultSort = 'C';
		request();
	});

 	// tab event
	$('button[data-toggle="tab"]').on('shown.bs.tab', function (e) {
		$('button[data-toggle="tab"]').swapClass("btn-info", "btn-default", true).css({"border-color": "#28a4c9"});
		currentView = $(e.target).attr("href");
		if (currentView === '#box') { 	// for box
			$("#magnify").show();
			$("#cover").hide();
			$("#torrent").hide();
			$('#img-width').show();
		}
		else {							// for table
			$("#magnify").hide();
			$("#cover").show();
			$("#torrent").show();
			$('#img-width').hide();
		}
		$(e.target).swapClass("btn-default", "btn-info", true);
	});
	$(currentView).addClass("in active");
	$('button[href="' + currentView + '"]').click();

	// for tags checkbox
	$("#tags").on("click", function() {
		isCheckedTags = $(this).data("checked");
		render(true);
	});
	// for favorite checkbox
	$("#favorite").on("click", function() {
		isCheckedFavorite = $(this).data("checked");
		render(true);
	});
	// for novideo checkbox
	$("#novideo").on("click", function() {
		isCheckedNoVideo = $(this).data("checked");
		render(true);
	});
	// for cover checkbox
	$("#cover").on("click", function() {
		if ($(this).data("checked")) {
			showCover();
		}
		else {
			$(".trFocus").removeClass("trFocus").find("img").hide();
		}
	});
	// for torrent checkbox
	$("#torrent").on("click", function() {
		$(".torrent").toggleClass("hide", !$(this).data("checked"));
	});
	
	$(window).on('keyup', function(e) {
		if (currentView === '#table') {
			if (e.keyCode == 38) { // up key
				if (currentVideoNo > -1)
					currentVideoNo--;
			} else if (e.keyCode == 40) { // down key
				if (currentVideoNo < renderingCount - 1)
					currentVideoNo++;
			} else {
				// nothing			
			}
			if (e.keyCode == 38 || e.keyCode == 40) {
				showCover(true);
			}
		}
	});
	
}

function showCover(isKey) {
	if ($("#cover").data("checked")) {
		$(".trFocus").removeClass("trFocus").find("img").hide();
		if (currentVideoNo > -1) {
			if (isKey) {
				$("#content_div").scrollTop(currentVideoNo * 30);
			}
			var thisTr = $("tr[data-no='" + currentVideoNo + "']");
			var imgTop = $(thisTr).offset().top + 40;
			thisTr.addClass("trFocus").find("img").css({"top": imgTop}).show();
		}
	}
}

function request() {
	loading(true, "request...");
//	showStatus(true, "Request...");
//	showSnackbar("Request...");

	// reset variables
	reverse = !reverse;
	hadTorrentCount = 0;
	candidateCount = 0;
	videoCount = 0;
	withTorrent = $("#torrent").data("checked");
	
	$.getJSON({
		method: 'GET',
		url: videoPath + '/list.json',
		data: {"t": withTorrent},
		cache: false,
		timeout: 60000
	}).done(function(data) {
		if (data.exception) {
//			showStatus(true, data.exception.message);
			showSnackbar("Error.. " + data.exception.message);
		}
		else {
			videoList = [];
			tagList = data.tagList;
			$.each(data.videoList, function(i, row) { // 응답 json을 videoList 배열로 변환
				if (row.torrents.length > 0)
					hadTorrentCount++;
				if (row.videoCandidates.length > 0)
					candidateCount++;
				if (row.existVideoFileList)
					videoCount++;
				videoList.push(new Video(i, row));
			});
			$(".candidate" ).html("C " + candidateCount);
			$(".videoCount").html("V " + videoCount);
			$("#torrent"   ).html("T " + hadTorrentCount);

			// 정렬하여 보여주기 => sort
			$(".btn-group-sort").children().each(function() {
				var sort = $(this).data("sort");
				if (sort.code === defaultSort) {
					$(this).click();
				}
			});
		}
	}).fail(function(jqxhr, textStatus, error) {
//		showStatus(true, textStatus + ", " + error);
		showSnackbar("Error "+ textStatus + ", " + error);
	}).always(function() {
		loading(false);
	});	
}

function render(first) {
//	showStatus(true, "rendering...");
	showSnackbar("Rendering...", 1000);
	
	var displayCount = 0;
	var query = $(".search").val();
	var parentOfVideoBox  = $("#box > ul");
	var parentOfTableList = $("#table tbody");
	withTorrent = $("#torrent").data("checked");

	var isFilter = query != '' || isCheckedFavorite || isCheckedNoVideo || isCheckedTags;
	// console.log("isFilter", query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags, " = " + isFilter);
	
	if (first) { // initialize if first rendering 
		entryIndex = 0;
		renderingCount = 0;
		lastPage = false;
		parentOfVideoBox.empty();
		parentOfTableList.empty();
		$(".more").show();
		// found count by query
		if (isFilter) {
			queryFoundCount = 0;
			for (var i=0; i<videoList.length; i++) {
				if (videoList[i].contains(query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags)) {
					queryFoundCount++;
				}
			}
		}
	}
	
	while (entryIndex < videoList.length) {
		if (isFilter) { // query filtering
			if (!videoList[entryIndex].contains(query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags)) {
				entryIndex++;
				continue;
			}
		}
		
		if (displayCount < pageSize) { // render html
			renderBox(renderingCount, videoList[entryIndex], parentOfVideoBox);
			renderTable(renderingCount, videoList[entryIndex], parentOfTableList);

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
	
	if (isFilter) {
		$(".count").html(renderingCount + " / " + queryFoundCount);
	}
	else {
		$(".count").html(renderingCount + " / " + videoList.length);
	}
	
	setTblCoverPosition();
	
//	showStatus(false);
}

function fnIsScrollBottom() {
	var containerHeight    = $("#content_div").height();
	var containerScrollTop = $("#content_div").scrollTop();
	var documentHeight     = $("ul.nav-tabs").height() + $("div.tab-content").height();
	var scrollMargin       = $("p.more").height();
//	console.log("fnIsScrollBottom", containerHeight, ' + ', containerScrollTop, ' = ', (containerHeight + containerScrollTop), ' > ', documentHeight, ' + ', scrollMargin, ' = ', (documentHeight - scrollMargin), lastPage);
	return (containerHeight + containerScrollTop > documentHeight - scrollMargin) && !lastPage;
}

function showStatus(show, msg, autoClose) {
	if (show) {
		$(".status").html(msg).show(); // loading start
	}
	else { 
		$(".status").hide('fade', [], 1500); // loading complete
	}
	if (autoClose) {
		setTimeout(function() {
			$(".status").hide('fade', [], 1500); // auto complete
		}, 1000);
	}
}

function renderBox(index, video, parent) {
	var dl = $("<dl>").css({"background-image": "url('" + video.coverURL + "')"}).addClass("video-cover").hover(function(event) {
		if ($("#magnify").data("checked")) {
			$(this).addClass("box-hover");
		}
	}, function() {
		if ($("#magnify").data("checked")) {
			$(this).removeClass("box-hover");
		}
	});
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
	var tr = $("<tr>").appendTo(parent).attr({"id": "check-" + video.opus, "data-idx": video.idx, "data-no": index}).hover(
			function(event) {
				currentVideoNo = $(this).attr("data-no");
				showCover();
			}, function(event) {
			}
	);
	$("<td>").appendTo(tr).addClass("text-right").append(
			$("<span>").addClass('label label-plain').html(index+1)
	).append(
			$("<input>").attr({name: "opus", type: "hidden"}).val(video.opus)
	);
	$("<td>").appendTo(tr).html(video.html_studio);
	$("<td>").appendTo(tr).html(video.html_opus);
	$("<td>").appendTo(tr).html(
		$('<div>').addClass("nowrap").append(
			$('<span>').addClass('label label-plain').attr({"onclick": "fnVideoDetail('" + video.opus + "')"}).html(video.title).attr({"title": video.title, "data-toggle": "tooltip"}) //.tooltip()
		).append(
			$("<img>").attr({"id": "tbl-cover-" + video.opus,"src": video.coverURL}).addClass("img-thumbnail tbl-cover").hide()
		).append(
			$('<span>').addClass('label label-plain').css({color: "#a94442 !important"}).html(video.overviewText)
		)
	).css({"max-width": "300px"});
	$("<td>").appendTo(tr).html(video.html_actress).css({"max-width": "100px"}).attr({"title": video.actressName});
	$("<td>").appendTo(tr).html(video.html_release).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_modified).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_video);
	$("<td>").appendTo(tr).html(video.html_subtitles).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_rank).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_score).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).append(
			$("<div>").append(video.html_videoCandidates).append(video.html_torrents).append(video.html_torrentFindBtn)
	).addClass("torrent " + (withTorrent ? "" : "hide"));
}

function fnSelectCandidateVideo(opus, idx, i) {
	$("[data-candidate='" + opus + "-" + i + "']").hide();
	$(".candidate").html("C " + --candidateCount);
//	showStatus(true, "accept file", true);
	showSnackbar("accept file " + opus);
}
function goTorrentMove(opus, idx, i) {
	$("[data-torrent='" + opus + "-" + i + "']").hide();
	$("[data-idx='" + idx + "']").addClass("moved");
	actionFrame(videoPath + "/" + opus + "/moveTorrentToSeed", {}, "POST", "Torrent move");
//	showStatus(true, ",move torrent", true);
	showSnackbar("move torrent " + opus);
}
function goTorrentSearch(opus, idx) {
	$("[data-idx='" + idx + "']").addClass("found");
	popup(videoPath + '/' + opus + '/cover/title', 'SearchTorrentCover', 800, 600);
	popup(videoPath + '/torrent/search/' + opus, 'torrentSearch', 900, 950);
}

function getAllTorrents() {
	actionFrame(videoPath + "/torrent/get", $("#table form").serialize(), "POST", "Get torrent in list");
}

function resizeSecondDiv() {
	isShortWidth = $(window).width() < 960;
	$(".shortWidth").toggleClass("hide", isShortWidth);
	setTblCoverPosition();
}

function setTblCoverPosition() {
	var imgWidth = windowWidth / 2;
	if (imgWidth > 800)
		imgWidth = 800;
	var imgLeft = windowWidth / 4;
	$(".tbl-cover").css({"left": imgLeft, "width": imgWidth});
}

function resizeCover() {
	var imgWidth = parseInt($('#img-width').val());
	var imgHeight = imgWidth * 0.6725;
	var coverSizeStyle = "<style>#box>ul>li>dl {width:" + imgWidth + "px; height:" + imgHeight + "px;}</style>";
	$("#cover-size-style").empty().append(coverSizeStyle);
	showSnackbar("width:" + imgWidth + "px; height:" + imgHeight + "px;", 1000);
}
