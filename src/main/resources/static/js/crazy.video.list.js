/**
 * video-list module 
 */

var videoList = (function() {
	'use strict';
	
	var sortList = [
		{code: "S", name: "Studio"}, {code: "O", name: "Opus"}, {code: "T", name: "Title"}, {code: "A", name: "Actress"}, 
		{code: "D", name: "Release"}, {code: "M", name: "Modified"}, {code: "R", name: "Rank"}, {code: "SC", name: "Score"}
	];
	var currentSort = {code: 'M', reverse: true}; // 현재 정렬 방법
	var tagKeys = [];

	var    requestedCount = 0;		// 요청해서 받은 개수
	var    renderingCount = 0;		// 보여준 개수
	var   hadTorrentCount = 0;		// torrent 파일 개수
	var hadVideoFileCount = 0;		// video 파일 개수
	var    candidateCount = 0;		// candidate 파일 개수
	
	var endOfList = false;			// 마지막 페이지까지 다 보여줬는지
	var page = 1;					// 현재 페이지 번호
	var PAGESIZE = 50;				// 한페이지에 보여줄 개수

	var currentVideoNo    = -1;		// table 뷰에서 커서/키가 위치한 tr번호. 커버 보여주기 위해
	
	var withTorrent       = false;	// table 뷰에서 torrent 정보 컬럼 보여줄지 여부
	var isCheckedFavorite = false;	// favorite 체크박스가 체크되어 있는지 여부
	var isCheckedNoVideo  = false;	// novideo  체크박스가 체크되어 있는지 여부
	var isCheckedTags     = false;	// tags     체크박스가 체크되어 있는지 여부

	var currentView   = '#table';	// 현재 보여지고 있는 뷰. #table or #box
	var isShowCover = false;
	var coverPosition = {};

	var parentOfVideoBox  = $("#box > ul");
	var parentOfTableList = $("#table tbody");

	var fn = {
			isrequiredMoreRendering: function() {
				if (endOfList) 
					return false;
				
				var isScrollBottom = function() {
					var containerHeight    = $("#content_div").height();
					var containerScrollTop = $("#content_div").scrollTop();
					var documentHeight     = $("ul.nav-tabs").height() + $("div.tab-content").height();
					var scrollMargin       = $("p.more").height();
					//console.log("fn.isrequiredMoreRendering.isScrollBottom", '(containerHeight[',containerHeight,'] + containerScrollTop[',containerScrollTop,'])[',(containerHeight+containerScrollTop),'] > (documentHeight[',documentHeight,'] - scrollMargin[',scrollMargin,'])[',(documentHeight-scrollMargin),'] => ', (containerHeight + containerScrollTop) > (documentHeight - scrollMargin));
					return (containerHeight + containerScrollTop) > (documentHeight - scrollMargin);
				}();
				//console.log('fn.isrequiredMoreRendering', '!endOfList[',!endOfList,'] && isScrollBottom[',isScrollBottom,'] => ', !endOfList && isScrollBottom);
				return !endOfList && isScrollBottom;
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
						thisTr.addClass("trFocus").find("img.tbl-cover").css({"top": imgTop}).css(coverPosition).show();
					}
				}
			},
			videoContains: function(video, query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags) {
				var fulltext = video.fullname + video.videoDate + video.overviewText;
				var containsTag = function(video) {
					for (var i = 0; i < tagKeys.length; i++) {
						var key = tagKeys[i];
						if (fulltext.toLowerCase().indexOf(key.toLowerCase()) > -1) {
							return true;
						}
					}
					return false;
				};
				return fulltext.toLowerCase().indexOf(query.toLowerCase()) > -1
					&& (isCheckedFavorite ?  video.favorite           : true)
					&& (isCheckedNoVideo  ? !video.existVideoFileList : true)
					&& (isCheckedTags     ?  containsTag(video)       : true);
			}
	};

	var initUiAndEvent = function() {

		// request TagList and set TagKeys
		restCall(PATH + '/rest/tag', {showLoading: false}, function(list) {
			for (var i = 0; i < list.length; i++) {
				var tag = list[i];
				tagKeys.push($.trim(tag.name));
				var descs = tag.description.split(',');
				for (var j = 0; j < descs.length; j++) {
					var desc = $.trim(descs[j]);
					if (desc) {
						tagKeys.push(desc);
					}
				}
			}
		});

		// scroll
		$("#content_div").scroll(function() {
			determineMoreList();
		});

		// search	
		$(".search").on('keyup', function(e) {
			if (e.keyCode == 13)
				initiatePage();
		});
		
		// for checkbox
		$("#favorite, #novideo, #tags, #torrent").on("click", function() {
			initiatePage();
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
			var isCurrent = currentSort.code === sort.code;
			$("<button>", {
				"class": "btn btn-" + (isCurrent ? "success" : "default") + " btn-sort btn-sort-" + sort.code, 
				title: sort.name
			}).data("sort", sort).html(sort.code + (isCurrent ? (currentSort.reverse ? " ▼" : " ▲") : "")).appendTo($(".btn-group-sort"));
			
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
			
			initiatePage();
		});
		
		// Box mode, size
		$("#img-width").on("change", function() {
			var imgWidth  = parseInt($('#img-width').val());
			var imgHeight = Math.round(imgWidth * 0.6725);
			var isLarge   = imgWidth > 500;
			var coverSizeStyle = "<style>#box>ul>li>dl {width:" + imgWidth + "px; height:" + imgHeight + "px; font-size:" + (isLarge ? '22px' : '16px') + ";}</style>";
			$("#coverSizeStyle").empty().append(coverSizeStyle);
			$('#img-width').attr({title: imgWidth + " x " + imgHeight});
			setLocalStorageItem(VIDEOLISTBYSPA_IMAGE_WIDTH, imgWidth);
			console.log("#img-width change width", imgWidth, "height", imgHeight);
		}).val(getLocalStorageItem(VIDEOLISTBYSPA_IMAGE_WIDTH, 290)).trigger("change");

		// view more btn
		$("#viewMore").on("click", requestVideoList).parent().show();

		$(window).on({
			"resize": function() {
				console.log("window resize");
				var setCoverPositionOnTableView = function() {
					windowWidth = $(window).width();
					var imgWidth = Math.floor(windowWidth / 2);
					if (imgWidth > 800) 
						imgWidth = 800;
					var imgLeft = Math.floor(windowWidth / 4);
					//$(".tbl-cover").css({left: imgLeft, width: imgWidth});
					coverPosition = {left: imgLeft, width: imgWidth};
					console.log("setCoverPositionOnTableView", coverPosition);
				};
				
				setCoverPositionOnTableView();
			},
			"keyup": function(e) {
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
	
	var initiatePage = function() {
		isCheckedFavorite = $("#favorite").data("checked");
		isCheckedNoVideo  = $("#novideo").data("checked");
		isCheckedTags     = $("#tags").data("checked");
		withTorrent       = $("#torrent").data("checked");

		parentOfVideoBox.empty();
		parentOfTableList.empty();

		endOfList = false;
		page = 1;
		renderingCount = 0;
		requestedCount = 0;
		hadVideoFileCount = 0;
		candidateCount = 0;
		
		determineMoreList();
	};

	var determineMoreList = function() {
		if (fn.isrequiredMoreRendering()) {
			requestVideoList();
		}
	};
	
	var requestVideoList = function() {
		console.log("requestVideoList", withTorrent, page, PAGESIZE, currentSort.code, currentSort.reverse);
		   
		restCall(PATH + '/rest/video', {
			data : {t: withTorrent, p: page++, s: PAGESIZE, o: currentSort.code, r: currentSort.reverse}, 
			title: "Request video",
			showLoading: false
		}, function(list) {

			if (list.length == 0) {
				endOfList = true;
				$("#viewMore").html('End of Video').swapClass("btn-warning", "btn-primary", true).addClass("disabled").off("click");
				$(".more").height(400);
				console.log("[requestVideoList] no more list");
				return;
			}
			
			var renderingList = [];
			$.each(list, function(i, row) {
				if (row.existVideoFileList)			hadVideoFileCount++;
				if (row.videoCandidates.length > 0)	candidateCount++;
				if (row.torrents.length > 0)		hadTorrentCount++;
				
				renderingList.push(new Video(i, row));
			});
			
			$(".videoCount").html("V " + hadVideoFileCount);
			$(".candidate" ).html("C " + candidateCount);
			$("#torrent"   ).html("T " + hadTorrentCount);

			render(renderingList);
		});
	};

	var render = function(list) {
		
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
			var   shortWidthClass = "shortWidth"; // table 뷰에서 가로폭이 좁을때 css에서 보이지 않게 한다
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
									$("<div>")
										.append(video.label_seedFindBtn)
										.append("&nbsp;")
										.append(video.label_videoCandidates)
										.append("&nbsp;")
										.append(video.label_torrentSeed)
							)
					)
			);
		};

		showSnackbar("Rendering...", 1000);
		
		var query = $(".search").val();

		var isFilter = query != '' || isCheckedFavorite || isCheckedNoVideo || isCheckedTags;
		
		for (var entryIndex in list) {
			requestedCount++;
			
			if (isFilter) // query filtering
				if (!fn.videoContains(list[entryIndex], query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags))
					continue;
			
			renderBox(  renderingCount, list[entryIndex], parentOfVideoBox);
			renderTable(renderingCount, list[entryIndex], parentOfTableList);

			renderingCount++; 	// 화면에 보여준 개수
		}
		
		$(".status").html(renderingCount + " / " + requestedCount);
		
		determineMoreList();
	};

	/*
	 * init UI and Event
	 * initiate Page
	 * need more list
	 *     -> request
	 *         -> render
	 * */
	var start = function() {
		initUiAndEvent();
		initiatePage();
	};
	
	return {
		init : start
	};
	
}());
