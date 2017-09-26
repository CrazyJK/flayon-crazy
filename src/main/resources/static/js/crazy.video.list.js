/**
 * video-list module 
 */

var videoList = (function() {
	'use strict';
	
	var sortList    = [{code: "S", name: "Studio"}, {code: "O", name: "Opus"}, {code: "T", name: "Title"}, {code: "A", name: "Actress"}, {code: "D", name: "Release"}, {code: "M", name: "Modified"}, 
		{code: "R", name: "Rank"}, {code: "Sc", name: "Score"}, {code: "To", name: "Torrrent"}, {code: "F", name: "Favorite"}, {code: "C", name: "Candidated"}];
	var currentSort = {code: 'M', reverse: false}; // 현재 정렬 방법
	var videoList   = new Array(); 	// 비디오 배열
	var   tagList   = [];
	var        entryIndex = 0;		// 비디오 인덱스
	var    renderingCount = 0;		// 보여준 개수
	var   hadTorrentCount = 0;		// torrent 파일 개수
	var hadVideoFileCount = 0;		// video 파일 개수
	var     filteredCount = 0;		// 검색으로 찾은 비디오 개수
	var    candidateCount = 0;		// candidate 파일 개수
	var lastPage   = false;			// 마지막 페이지까지 다 보여줬는지
	var pageSize   = 12;			// 한페이지에 보여줄 개수

	var currentVideoNo    = -1;		// table 뷰에서 커서/키가 위치한 tr번호. 커버 보여주기 위해
	var withTorrent       = false;	// table 뷰에서 torrent 정보 컬럼 보여줄지 여부 
	var isShortWidth      = false;	// table 뷰에서 가로폭이 좁은지 여부
	var isCheckedFavorite = false;	// favorite 체크박스가 체크되어 있는지 여부
	var isCheckedNoVideo  = false;	// novideo  체크박스가 체크되어 있는지 여부
	var isCheckedTags     = false;
	var isShowCover       = false;
	var currentView   = '#table';	// 현재 보여지고 있는 뷰. #table or #box
	var coverPosition = {};

	var fn = {
			isrequiredMoreRendering: function() {
				var isScrollBottom = function() {
					var containerHeight    = $("#content_div").height();
					var containerScrollTop = $("#content_div").scrollTop();
					var documentHeight     = $("ul.nav-tabs").height() + $("div.tab-content").height();
					var scrollMargin       = $("p.more").height();
					console.log("fn.isrequiredMoreRendering.isScrollBottom", '(containerHeight[',containerHeight,'] + containerScrollTop[',containerScrollTop,'])[',(containerHeight+containerScrollTop),'] > (documentHeight[',documentHeight,'] - scrollMargin[',scrollMargin,'])[',(documentHeight-scrollMargin),'] => ', (containerHeight + containerScrollTop) > (documentHeight - scrollMargin));
					return (containerHeight + containerScrollTop) > (documentHeight - scrollMargin);
				}();
				console.log('fn.isrequiredMoreRendering', '!lastPage[',!lastPage,'] && isScrollBottom[',isScrollBottom,'] => ', !lastPage && isScrollBottom);
				return !lastPage && isScrollBottom;
			},
			sortVideo: function(list, sort) {
				console.log("fn.sortVideo", sort);
				list.sort(function(video1, video2) {
					switch(sort.code) {
					case 'S':
						return compareTo(video1.studio.name, video2.studio.name, sort.reverse); 
					case 'O':
						return compareTo(video1.opus, video2.opus, sort.reverse); 
					case 'T':
						return compareTo(video1.title, video2.title, sort.reverse); 
					case 'A':
						return compareTo(video1.actress, video2.actress, sort.reverse); 
					case 'D':
						return compareTo(video1.releaseDate, video2.releaseDate, sort.reverse); 
					case 'M':
						return compareTo(video1.videoDate, video2.videoDate, sort.reverse); 
					case 'R':
						return compareTo(video1.rank, video2.rank, sort.reverse); 
					case 'SC':
						return compareTo(video1.score, video2.score, sort.reverse); 
					case 'T':
						return compareTo(video1.torrents.length, video2.torrents.length, sort.reverse); 
					case 'F':
						return compareTo(video1.favorite, video2.favorite, sort.reverse); 
					case 'C':
						var result = compareTo(video1.existCandidates, video2.existCandidates, sort.reverse);
						if (result == 0)
							result = compareTo(video1.favorite, video2.favorite, sort.reverse);
						if (result == 0)
							result = compareTo(video1.existTorrents, video2.existTorrents, sort.reverse);
						if (result == 0)
							result = compareTo(video1.opus, video2.opus, sort.reverse); 
						return result; 
					default:
						return video1.title > video2.title ? 1 : -1;
					}
				});
			},
			showCover: function(isKey) {
				$(".trFocus").removeClass("trFocus").find("img").hide();
				if (isShowCover) {
					if (currentVideoNo > -1) {
						if (isKey) {
							$("#content_div").scrollTop(currentVideoNo * 30);
						}
						var thisTr = $("tr[data-no='" + currentVideoNo + "']");
						var imgTop = $(thisTr).offset().top + 40;
						thisTr.addClass("trFocus").find("img").css({"top": imgTop}).css(coverPosition).show();
					}
				}
			},
			videoContains: function(video, query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags) {
				var containsTag = function(video) {
					if (video.tags.length > 0)
						return true;
					for (var i = 0; i < tagList.length; i++) {
						var tag = tagList[i];
						if (fullname.toLowerCase().indexOf(tag.name.toLowerCase()) > -1) {
							return true;
						}
					}
					return false;
				};
				var fullname = video.fullname + video.videoDate + video.overviewText;
				return fullname.toLowerCase().indexOf(query.toLowerCase()) > -1
					&& (isCheckedFavorite ?  video.favorite           : true)
					&& (isCheckedNoVideo  ? !video.existVideoFileList : true)
					&& (isCheckedTags     ?  containsTag(video)       : true);
			}
	};

	var render = function(first) {
		
		var renderBox = function(index, video, parent) {
			parent.append(
					$("<li>", {"data-idx": video.idx}).append(
							$("<dl>").css({backgroundImage: 'url(' + video.coverURL + ')'}).addClass("video-cover").hover(
								function(event) {
									// console.log("tr hover event.type mouseenter", event);
									if ($("#magnify").data("checked")) $(this).addClass("box-hover");
								}, function(event) {
									// console.log("tr hover event.type mouseleave", event);
									if ($("#magnify").data("checked")) $(this).removeClass("box-hover");
								}
							).append(
									$("<dt>").append(video.label_title).addClass("nowrap text-center"),
									$("<dd>").append(video.label_studio),
									$("<dd>").append(video.label_opus, "&nbsp;", video.label_overview),
									$("<dd>").append(video.label_actress),
									$("<dd>").append(video.label_release),
									$("<dd>").append(video.label_video),
									$("<dd>").append(video.label_subtitles),
									$("<dd>").append(video.label_seedFindBtn),
//									$("<dd>").append(video.label_videoCandidates).append("&nbsp;").append(video.label_torrentSeed)
							)
					)
			);
		};

		var renderTable = function(index, video, parent) {
			var   shortWidthClass = isShortWidth ? "shortWidth hide" : "shortWidth";
			var widthTorrentClass = withTorrent ? "torrent" : "torrent hide";
			parent.append(
					$("<tr>", {"id": "check-" + video.opus, "data-idx": video.idx, "data-no": index}).on("mouseenter", function(event) {
							currentVideoNo = $(this).attr("data-no");
							fn.showCover();
					}).append(
							$("<td>").addClass("text-right").append(
									$("<span>").addClass('label label-plain').html(index+1),
									$("<input>", {name: "opus", type: "hidden", value: video.opus})
							),
							$("<td>").append(video.label_studio),
							$("<td>").append(video.label_opus),
							$("<td>").css({maxWidth: "300px"}).append(
									$('<div>').addClass("nowrap").append(
											video.label_title,
											$("<img>", {"class": "img-thumbnail tbl-cover", id: "tbl-cover-" + video.opus, src: video.coverURL}).hide(),
											"&nbsp;",
											video.label_overview
									)
							),
							$("<td>").css({maxWidth: "100px"}).attr({title: video.actressName}).append(video.label_actress),
							$("<td>").addClass(shortWidthClass).append(video.label_release),
							$("<td>").addClass(shortWidthClass).append(video.label_modified),
							$("<td>").append(video.label_video),
							$("<td>").addClass(shortWidthClass).append(video.label_subtitles),
							$("<td>").addClass(shortWidthClass).append(video.label_rank),
							$("<td>").addClass(shortWidthClass).append(video.label_score),
							$("<td>").addClass(widthTorrentClass).append(
									$("<div>").append(video.label_seedFindBtn).append("&nbsp;").append(video.label_videoCandidates).append("&nbsp;").append(video.label_torrentSeed)
							)
					)
			);
		};

		showSnackbar("Rendering...", 1000);
		console.log("render", first);
		
		var displayCount = 0;
		var query = $(".search").val();
		var parentOfVideoBox  = $("#box > ul");
		var parentOfTableList = $("#table tbody");

		var isFilter = query != '' || isCheckedFavorite || isCheckedNoVideo || isCheckedTags;
		//console.log("render isFilter", query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags, " = " + isFilter);
		
		if (first == true) { // initialize if first rendering 
			entryIndex = 0;
			renderingCount = 0;
			lastPage = false;
			parentOfVideoBox.empty();
			parentOfTableList.empty();
			$(".more").show();
			
			if (isFilter) { // found count by query
				filteredCount = 0;
				for (var i = 0; i < videoList.length; i++) {
					if (fn.videoContains(videoList[i], query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags)) {
						filteredCount++;
					}
				}
			}
		}
		
		while (entryIndex < videoList.length) {
			//console.log("render entryIndex", entryIndex, "displayCount", displayCount);
			if (isFilter) { // query filtering
				if (!fn.videoContains(videoList[entryIndex], query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags)) {
					entryIndex++;
					continue;
				}
			}
			
			if (displayCount < pageSize) { // render html
				renderBox(  renderingCount, videoList[entryIndex], parentOfVideoBox);
				renderTable(renderingCount, videoList[entryIndex], parentOfTableList);

				renderingCount++; 	// 화면에 보여준 개수
				displayCount++;		// 이번 메서드에서 보여준 개수
				entryIndex++;		// videoList의 현개 인덱스 증가
			}
			else {
				break;
			}
		}

		if (entryIndex == videoList.length) { // 전부 보여주었으면
			lastPage = true;
			$("#viewMore").html('End of Video').swapClass("btn-warning", "btn-primary", true).addClass("disabled").off("click");
			$(".more").height(400);
		}
		
		$(".count").html(renderingCount + " / " + (isFilter ? filteredCount : videoList.length));
		
		if (fn.isrequiredMoreRendering())
			render();
	};
	
	var initAndEvent = function() {
		// scroll
		$("#content_div").scroll(function() {
			if (fn.isrequiredMoreRendering())
				render(false); // next page
		});

		// search	
		$(".search").on('keyup', function(e) {
			if (e.keyCode == 13)
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

		// for tags checkbox
		$("#tags").on("click", function() {
			isCheckedTags = $(this).data("checked");
			render(true);
		});

		// re-request
		$("#request").on('click', function() {
			currentSort = {code: 'C', reverse: false};
			request();
		});
		
		// for torrent checkbox
		$("#torrent").on("click", function() {
			withTorrent = $(this).data("checked");
			$(".torrent").toggleClass("hide", !withTorrent);
		});

		// for cover checkbox
		$("#cover").on("click", function() {
			isShowCover = $(this).data("checked");
			fn.showCover();
		});

	 	// tab event
		$('button[data-toggle="tab"]').on('shown.bs.tab', function (e) {
			$('button[data-toggle="tab"]').swapClass("btn-info", "btn-default", true).css({"border-color": "#28a4c9"});
			currentView = $(e.target).swapClass("btn-default", "btn-info", true).attr("data-target");
			if (currentView === '#box') { 	// for box
				$(".forBox").show();
				$(".forTable").hide();
			}
			else {							// for table
				$(".forBox").hide();
				$(".forTable").show();
			}
		});
		$('button[data-target="' + currentView + '"]').click();

		// sorting & render
		$.each(sortList, function(i, sort) {
			$("<button>").addClass("btn btn-default btn-sort btn-sort-" + sort.code).data("sort", sort).attr({title: sort.name}).html(sort.code).appendTo($(".btn-group-sort"));
		});
		$(".btn-sort").on('click', function() {
			$(".btn-sort").each(function() {
				$(this).swapClass("btn-success", "btn-default", true).html($(this).data("sort").code);
			});
			
			var sort = $(this).data('sort');
			if (currentSort.code === sort.code) // 같은 정렬
				currentSort.reverse = !currentSort.reverse;
			else	// 다른 정렬
				currentSort.reverse = true;
			currentSort.code = sort.code;

			$(this).swapClass("btn-default", "btn-success", true).html(sort.code + (currentSort.reverse ? ' ▼' : ' ▲'));
			
			fn.sortVideo(videoList, currentSort);
			render(true);
			$(window).trigger("resize")
		});
		
		// All torrents
		$("#getAllTorrents").on("click", function() {
			actionFrame(PATH + "/video/torrent/get", $("#table form").serialize(), "POST", "Get torrent in list");
		});
		
		// Box mode, size
		$("#img-width").on("change", function() {
			var imgWidth  = parseInt($('#img-width').val());
			var imgHeight = Math.round(imgWidth * 0.6725);
			var isLarge   = imgWidth > 500;
			var coverSizeStyle = "<style>#box>ul>li>dl {width:" + imgWidth + "px; height:" + imgHeight + "px; font-size:" + (isLarge ? '22px' : '16px') + ";}</style>";
			$("#cover-size-style").empty().append(coverSizeStyle);
			$('#img-width').attr({title: imgWidth + " x " + imgHeight});
			setLocalStorageItem(VIDEOLISTBYSPA_IMAGE_WIDTH, imgWidth);
			console.log("#img-width change width", imgWidth, "height", imgHeight);
		}).val(getLocalStorageItem(VIDEOLISTBYSPA_IMAGE_WIDTH, 290)).trigger("change");

		// view more btn
		$("#viewMore").on("click", render);

		$(window).on({
			"resize": function() {
				console.log("window resize");
				var setCoverPositionOnTableView = function() {
					windowWidth = $(window).width();
					var imgWidth = windowWidth / 2;
					if (imgWidth > 800)
						imgWidth = 800;
					var imgLeft = windowWidth / 4;
					//$(".tbl-cover").css({left: imgLeft, width: imgWidth});
					coverPosition = {left: imgLeft, width: imgWidth};
					console.log("setCoverPositionOnTableView", {left: imgLeft, width: imgWidth});
				};
				
				isShortWidth = $(window).width() < 960;
				$(".shortWidth").toggleClass("hide", isShortWidth);
				setCoverPositionOnTableView();
			},
			'keyup': function(e) {
				if (currentView === '#table') {
					console.log("window keyup", e.keyCode);
					if (e.keyCode == 38) { // up key
						currentVideoNo > -1 && currentVideoNo--;
					} 
					else if (e.keyCode == 40) { // down key
						currentVideoNo < renderingCount - 1 && currentVideoNo++;
					} 
					else {
						return; // nothing
					}
					fn.showCover(true);
				}
			}
		});
	};
	
	var request = function() {
		console.log("request");
		loading(true, "request...");

		// reset variables
		hadVideoFileCount = 0;
		  hadTorrentCount = 0;
		   candidateCount = 0;
		
		$.getJSON({
			method: 'GET',
			url: PATH + '/video/list.json',
			data: {t: withTorrent},
//			cache: false,
			timeout: 60000
		}).done(function(data) {
			if (data.exception) {
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
						hadVideoFileCount++;
					videoList.push(new Video(i, row));
				});
				$(".candidate" ).html("C " + candidateCount);
				$(".videoCount").html("V " + hadVideoFileCount);
				$("#torrent"   ).html("T " + hadTorrentCount);

				// 정렬하여 보여주기 => sort
				$(".btn-sort-" + currentSort.code).click();
			}
		}).fail(function(jqxhr, textStatus, error) {
			showSnackbar("Error "+ textStatus + ", " + error);
		}).always(function() {
			loading(false);
		});	
	};
	
	var initModule = function() {
		initAndEvent();
		request();
	};
	
	return {
		init : initModule
	};
	
}());
