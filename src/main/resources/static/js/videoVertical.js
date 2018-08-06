/**
 * Video Vertical View Javascript
 */
var listViewType = 'Vertical';
var allList = [];
var videoList = [];
var currentVideo = null;
var currentIndex = -1;
var isFirstLoad = true;

$(document).ready(function() {
	prepare();
	
	loadVideo();
});

function loadVideo() {
	// load video list
	restCall(PATH + '/rest/video', {data: {p: 0}, title: "Load video"}, function(list) {
		allList = list;
		collectList();
	});
}

function prepare() {
	// tag list
	setTags();
	// reload
	$("#reload").on("click", function() {
		loadVideo();
	});
	// query
	$("#query").on("keyup", function(e) {
		if (e.keyCode == 13) {
			collectList();
		}
	});
	// rank condition
	$("[role='checkbox']").on("click", collectList);
	// sort condition
	$("#radio-sort").on("checked", collectList);
	// video label event
	addVideoEvent();
	// navigation event
	navigation.event();
}

function setTags() {
	function makeTag(tag) {
		return $("<div>", {'class': 'inline-block'}).append(
				$("<span>", {'class': 'label label-tag', title: tag.description, id: 'tag-' + tag.id}).html(tag.name).on("click", function() {
					var $this = $(this);
					var isOn = $this.hasClass("on");
					restCall(PATH + "/rest/video/" + currentVideo.opus + "/tag?id=" + tag.id, {method: "PUT"}, function() {
						$this.toggleClass("on", !isOn);
					});
				})
		);
	}
	// tag list setting
	restCall(PATH + "/rest/tag", {showLoading: false}, function(list) {
		var $div = $(".tag-list");
		$.each(list, function(i, tag) {
			$div.append(makeTag(tag));
		});
	});
	// new tag btn
	$(".label-tag-new").on("click", function() {
		$('.tag-form-wrapper').slideToggle();
		$('#newTag-name').focus();
	});
	// new tag save
	$(".btn-tag-save").on("click", function() {
		var newTagName = $("#newTag-name").val(), newTagDesc = $("#newTag-desc").val();
		if (newTagName != '') {
			restCall(PATH + "/rest/tag", {method: "POST", data: {opus: currentVideo.opus, name: newTagName, description: newTagDesc}, showLoading: false}, function(tag) {
				currentVideo.tags.push(tag);
				$(".tag-list").append(makeTag(tag));
				$("#tag-" + tag.id).addClass("on");
				$("#newTag-name, #newTag-desc").val('');
				$('.tag-form-wrapper').slideToggle();
			});
		}
	});
}

function collectList() {
	loading(true, 'Collect list');
	$(".video-wrapper").hide();
	
	var query = $("#query").val();
	var fav   = $("#favorite").data("checked");
	var vid   = $("#video").data("checked");
	var sub   = $("#subtitles").data("checked");
	var rank0 = $("#check-rank0").data("checked") ? '0' : '';
	var rank1 = $("#check-rank1").data("checked") ? '1' : '';
	var rank2 = $("#check-rank2").data("checked") ? '2' : '';
	var rank3 = $("#check-rank3").data("checked") ? '3' : '';
	var rank4 = $("#check-rank4").data("checked") ? '4' : '';
	var rank5 = $("#check-rank5").data("checked") ? '5' : '';
	var sort  = $("#radio-sort").attr("data-role-value");
	var compareTo = function(data1, data2) {
		var result = 0;
		if (typeof data1 === 'number') {
			result = data1 - data2;
		} else if (typeof data1 === 'string') {
			result = data1.toLowerCase() > data2.toLowerCase() ? 1 : -1;
		} else {
			result = data1 > data2 ? 1 : -1;
		}
		return result;
	};
	videoList = [];

	// filtering
	for (var i=0; i<allList.length; i++) {
		var video = allList[i];

		if (vid && sub) { // 비디오와 자막 모두 있는
			if (!video.existVideoFileList || !video.existSubtitlesFileList) 
				continue;
		} else if (vid && !sub) { // 비디오가 있으면
			if (!video.existVideoFileList)
				continue;
		} else if (!vid && sub) { // 비디오 없는 자막
			if (video.existVideoFileList || !video.existSubtitlesFileList)
				continue;
		} else { // 비디오와 자막 모두 없는
			if (video.existVideoFileList || video.existSubtitlesFileList) // 비디오가 있고
				continue;
		}
		
		var rank = rank0 + rank1 + rank2 + rank3 + rank4 + rank5;
		if (rank.indexOf(video.rank) < 0) {
			continue;
		} 
		
		if (fav) {
			if (!video.favorite) {
				continue;
			}
		}
		
		if (query != '') {
			var fullname = video.studio.name + video.opus + video.title + video.actressName + video.releaseDate + video.overviewText;
			if (fullname.indexOf(query) < 0) {
				continue;
			}
		}
		
		videoList.push(video);
	}
	
	// sorting
	videoList.sort(function(video1, video2) {
		switch(sort) {
		case 'S':
			return compareTo(video1.studio.name, video2.studio.name); 
		case 'O':
			return compareTo(video1.opus, video2.opus); 
		case 'T':
			return compareTo(video1.title, video2.title); 
		case 'A':
			return compareTo(video1.actressName, video2.actressName); 
		case 'D':
			return compareTo(video1.releaseDate, video2.releaseDate); 
		case 'M':
			return compareTo(video1.videoDate, video2.videoDate); 
		}
	});
	
	if (videoList.length > 0) {
		navigation.random();
		$(".video-wrapper").show();
	}
	loading(false);
}

var navigation = {
		event: function() {
			$("#content_div").navEvent(function(signal) {
				switch(signal) {
				case 1: // mousewheel: up
					navigation.previous();
					break;
				case -1: // mousewheel: down
					navigation.next();
					break;
				case 32: // key: space
					navigation.random();
					break;
				case 1002:
					navigation.random();
					break;
				}
			});
		},
		previous: function() {
			navigation.go(currentIndex - 1);
		},
		next: function () {
			navigation.go(currentIndex + 1);
		},
		random: function() {
			navigation.go(getRandomInteger(0, videoList.length-1));
		},
		go: function(idx) {
			if (idx < 0 || idx > videoList.length - 1) {
				console.log('navigation.go wrong index', idx);
				return;
			}
			var prevIndex = currentIndex;
			currentIndex = idx;
			if (prevIndex === currentIndex) {
				return;
			}
			currentVideo = videoList[currentIndex];
			
			showVideo(currentIndex > prevIndex);
			navigation.paging();
		},
		paging: function() {
			var addPaginationBtn = function(idx) {
				$("<li>", {
					'class': (idx === 0 ? 'first ' : '') + (idx === videoList.length - 1 ? 'last ' : '') + (idx === currentIndex ? 'active' : '')
				}).append(
						$("<a>").html(idx+1).on("click", function() {
							navigation.go(idx);
						})
				).appendTo($(".pagination"));
			};
			
			$(".pagination").empty();
			var start = currentIndex - 4;
			start = start < 0 ? 0 : start;
			var end = currentIndex + 5;
			end = end > videoList.length ? videoList.length : end;
			
			if (start > 0) { // first navi
				addPaginationBtn(0);
			}
			for (var i = start; i < end; i++) {
				addPaginationBtn(i);
			}
			if (end < videoList.length) { // last navi
				addPaginationBtn(videoList.length - 1);
			}
		}
};

function addVideoEvent() {
	// studio
	$(".info-studio").on("click", function() {
		fnViewStudioDetail(currentVideo.studio.name);
	});
	// title
	$(".info-title").on("click", function() {
		fnVideoDetail(currentVideo.opus);
	});
	// video file
	$(".info-video").on("click", function() {
		currentVideo.existVideoFileList ? fnPlay(currentVideo.opus) : fnSearchTorrent(currentVideo.opus);
	});
	// subtitles
	$(".info-subtitles").on("click", function() {
		currentVideo.existSubtitlesFileList ? fnEditSubtitles(currentVideo.opus) : '';
	});
	// overview
	$(".info-overview").on("click", function() {
		$(this).hide();
		$(".info-overview-input").removeClass("hide");
	});
	// overview input
	$(".info-overview-input").on("keyup", function(e) {
		if (e.keyCode === 13) {
			var $this = $(this);
			var text = $this.val();
			restCall(PATH + '/rest/video/' + currentVideo.opus + '/overview', {
				method: "PUT", 
				data: {overview: text}, 
				showLoading: false
			}, function() {
				$this.addClass("hide");
				$(".info-overview").html(text).show();
			});
		}
	});
	// rank
	$("#ranker").on("mouseup", function() {
		var rank = $(this).val();
		restCall(PATH + "/rest/video/" + currentVideo.opus + "/rank/" + rank, {method: "PUT", showLoading: false}, function() {
			decorateRank(rank);
		});
	});
}

function showVideo(isForward) {
	if (isFirstLoad) {
		$(".cover-box.current").css({backgroundImage: 'url(' + PATH + "/cover/video/" + currentVideo.opus + ')'}).show("fade", {});
		isFirstLoad = false;
	} else {
		// previous Cover
		$(".cover-box.previous").hide("slide", {direction: !isForward ? 'right' : 'left'}, 300, function() {
			var prevCoverURL = (0 < currentIndex) ? "/cover/video/" + videoList[currentIndex-1].opus : '/image/random?_t=' + new Date().getTime();
			$(this).css({backgroundImage: 'url(' + PATH + prevCoverURL + ')'}).show("slide", {direction: isForward ? 'right' : 'left'});
		});
		// current Cover
		$(".cover-box.current").hide("slide", {direction: !isForward ? 'right' : 'left'}, 300, function() {
			$(this).css({backgroundImage: 'url(' + PATH + "/cover/video/" + currentVideo.opus + ')'}).show("slide", {direction: isForward ? 'right' : 'left'});
		});
		// next Cover
		$(".cover-box.next").hide("slide", {direction: !isForward ? 'right' : 'left'}, 300, function() {
			var nextCoverURL = (currentIndex < videoList.length-1) ? "/cover/video/" + videoList[currentIndex+1].opus : '/image/random?_t=' + new Date().getTime();
			$(this).css({backgroundImage: 'url(' + PATH + nextCoverURL + ')'}).show("slide", {direction: isForward ? 'right' : 'left'});
		});
	}

	// studio
	$(".info-studio").html(currentVideo.studio.name);
	// opus
	$(".info-opus").html(currentVideo.opus);
	// title
	$(".info-title").html(currentVideo.title);
	// actress & event
	var actressArray = [];
	$.each(currentVideo.actressList, function(index, actress) {
		actressArray.push(
				$("<div>").append(
						// favorite
						actress.name != 'Amateur' &&
						$("<span>", {'class': 'label label-plain info-actress-favorite'}).addClass(actress.favorite ? 'favorite' : '').append(
								$("<span>", {'class': 'glyphicon glyphicon-favorite glyphicon-star' + (actress.favorite ? '' : '-empty')}).data("name", actress.name).on("click", function() {
									fnFavorite(this, $(this).data('name'))
								})
						),
						// actress
						$("<span>", {'class': 'label label-plain info-actress'}).data("name", actress.name).append(
								actress.name
						).on("click", function() {
							actress.name != 'Amateur' && fnViewActressDetail($(this).data('name'));
						}),
						$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.localName),
						$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.birth),
						$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.age),
						$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.bodySize),
						$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.height),
						$("<span>", {'class': 'label label-plain info-actress-extra'}).html('v' + actress.videoCount)
				)
		);
	});
	$(".info-wrapper-actress").empty().append(actressArray);
	// release
	$(".info-release").html(currentVideo.releaseDate);
	// modified
	$(".info-modified").html(currentVideo.videoDate);
	// video file
	$(".info-video").html(currentVideo.existVideoFileList ? 'V ' + formatFileSize(currentVideo.length) : 'Video')
			.swapClass("nonExist", "exist", currentVideo.existVideoFileList);
	// subtitles
	$(".info-subtitles").html("Subtitles").swapClass("nonExist", "exist", currentVideo.existSubtitlesFileList);
	// overview
	$(".info-overview-input").val(currentVideo.overviewText).addClass("hide");
	$(".info-overview").html(currentVideo.overviewText == '' ? 'Overview' : currentVideo.overviewText)
			.swapClass("nonExist", "exist", currentVideo.overviewText != '').show();
	// rank
	$("#ranker").val(currentVideo.rank);
	// rank decorate
	decorateRank(currentVideo.rank);
	// tag
	$(".on", ".tag-list").removeClass("on");
	$.each(currentVideo.tags, function(i, tag) {
		$("#tag-" + tag.id).addClass('on');
	});
}

function decorateRank(rank) {
	var color = '';
	if (rank < 0) {
		color = 'rgba(0, 0, 255, 0.5)';
	} else if (rank == 0) {
		color = 'rgba(255, 255, 255, 0.5)';
	} else {
		color = 'rgba(255, 0, 0, ' + rank*1.5/10 + ')';
	}
	$(".rank-group").css({backgroundColor: color});
	$(".rank-range-addon").html(rank);
}