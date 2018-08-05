/**
 * Video Vertical View Javascript
 */
var listViewType = 'Vertical';
var allList;
var videoList;
var video;
var currentIndex;
var direction;
var JQUERY_UI_EFFECTs = ["blind", "bounce", "clip", "drop", "explode", "fade", "fold", "puff", "pulsate", "scale", "shake", "size", "slide"];

$(document).ready(function() {
	prepare();
	
	restCall(PATH + '/rest/video', {data: {p: 0}, title: "request video"}, function(list) {
		allList = list;
		grepList();
	});

});

function prepare() {
	// tag setting
	restCall(PATH + "/rest/tag", {showLoading: false}, function(list) {
		var $div = $(".tag-list");
		$.each(list, function(i, tag) {
			$div.append(
					$("<div>").append(
							$("<span>", {'class': 'label label-default label-tag', title: tag.description, id: 'tag-' + tag.id}).html(tag.name).on("click", function() {
								var $this = $(this);
								var isOn = $this.hasClass("label-plain") === false;
								restCall(PATH + "/rest/video/" + video.opus + "/tag?id=" + tag.id, {method: "PUT"}, function() {
									$this.swapClass("label-default", "label-plain", isOn);
								});
							})
					).css({display: 'inline-block'})
			);
		});
	});
	// new tag save
	$(".btn-tag-save").on("click", function() {
		var newTagName = $("#newTag-name").val();
		var newTagDesc = $("#newTag-desc").val();
		if (newTagName != '') {
			restCall(PATH + "/rest/tag", {method: "POST", data: {opus: video.opus, name: newTagName, description: newTagDesc}, showLoading: false}, function(tag) {
				video.tags.push(tag);
				$(".tag-list").append(
						$("<div>").append(
								$("<span>", {'class': 'label label-default label-plain label-tag', title: tag.description, id: 'tag-' + tag.id}).html(tag.name)
						).css({display: 'inline-block'})
				);
				$("#newTag-name").val('');
				$("#newTag-desc").val('');
				$('.tag-form-wrapper').slideToggle();
			});
		}
	});
	// list condition check
	$("[role='checkbox']").on("click", grepList);
	$("#query").on("keyup", function(e) {
		if (e.keyCode == 13) {
			grepList();
		}
	});
	// sort condition
	$("#radio-sort").on("checked", function() {
		grepList();
	});
	// video label event
	addVideoEvent();
	// navigation event
	navigation.event();
}

function grepList() {
	var query = $("#query").val();
	var fav = $("#favorite").data("checked");
	var vid = $("#video").data("checked");
	var sub = $("#subtitles").data("checked");
	var rank0 = $("#check-rank0").data("checked") ? '0' : '';
	var rank1 = $("#check-rank1").data("checked") ? '1' : '';
	var rank2 = $("#check-rank2").data("checked") ? '2' : '';
	var rank3 = $("#check-rank3").data("checked") ? '3' : '';
	var rank4 = $("#check-rank4").data("checked") ? '4' : '';
	var rank5 = $("#check-rank5").data("checked") ? '5' : '';
	
	videoList = [];
	for (var i=0; i<allList.length; i++) {
		var video = allList[i];

		if (query != '') {
			var fullname = video.studio.name + video.opus + video.title + video.actressName + video.releaseDate;
			if (fullname.indexOf(query) < 0) {
				continue;
			}
		}
		if (fav) {
			if (!video.favorite) {
				continue;
			}
		}
		if (vid) {
			if (!video.existVideoFileList) {
				continue;
			}
		}
		if (sub) {
			if (!video.existVideoFileList || !video.existSubtitlesFileList) {
				continue;
			}
		}
		
		var rank = rank0 + rank1 + rank2 + rank3 + rank4 + rank5;
		if (rank.indexOf(video.rank) < 0) {
			continue;
		} 
		
		videoList.push(video);
	}
	
	function compareTo(data1, data2) {
		var result = 0;
		if (typeof data1 === 'number') {
			result = data1 - data2;
		} else if (typeof data1 === 'string') {
			result = data1.toLowerCase() > data2.toLowerCase() ? 1 : -1;
		} else {
			result = data1 > data2 ? 1 : -1;
		}
		return result;
	}
	
	// sort
	var checkedValue = $("#radio-sort").attr("data-role-value");
	videoList.sort(function(video1, video2) {
		switch(checkedValue) {
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
	
	navigation.random();
}

var navigation = {
		previous: function() {
			if (currentIndex > 0) {
				--currentIndex;
				direction = 'left';
				render();
			}
		},
		next: function () {
			if (currentIndex < videoList.length-1) {
				++currentIndex;
				direction = 'right';
				render();
			}
		},
		random: function() {
			var prevIndex = currentIndex;
			currentIndex = getRandomInteger(0, videoList.length-1);
			direction = prevIndex - currentIndex > 0 ? 'left' : 'right';
			render();
		},
		go: function(idx) {
			currentIndex = idx;
			render();
		},
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
		paging: function() {
			var page = function(idx) {
				var pageLi = $("<li>").append(
						$("<a>").html(idx+1).on("click", function() {
							navigation.go(idx);
						})
				);
				if (idx === currentIndex)
					pageLi.addClass("active");
				if (idx === 0)
					pageLi.addClass("first");
				else if (idx === videoList.length - 1)
					pageLi.addClass("last");
				$(".pagination").append(pageLi);
			};
			
			$(".pagination").empty();
			var start = currentIndex - 4;
			start = start < 0 ? 0 : start;
			var end = currentIndex + 5;
			end = end > videoList.length ? videoList.length : end;
			
			if (start > 0) {
				page(0);
			}
			for (var i = start; i < end; i++) {
				page(i);
			}
			if (end < videoList.length) {
				page(videoList.length - 1);
			}
		}
};

function addVideoEvent() {
	// studio
	$(".info-studio").on("click", function() {
		fnViewStudioDetail(video.studio.name);
	});
	// title
	$(".info-title").on("click", function() {
		fnVideoDetail(video.opus);
	});
	// video file
	$(".info-video").on("click", function() {
		video.existVideoFileList ? fnPlay(video.opus) : fnSearchTorrent(video.opus);
	});
	// subtitles
	$(".info-subtitles").on("click", function() {
		video.existSubtitlesFileList ? fnEditSubtitles(video.opus) : '';
	});
	// overview
	$(".info-overview").on("click", function() {
		$(this).hide();
		$(".info-overview-input").removeClass("hide").val($(this).html());
	});
	// overview input
	$(".info-overview-input").on("keyup", function(e) {
		if (e.keyCode === 13) {
			var $this = $(this);
			var opus = video.opus;
			var text = $this.val();
			restCall(PATH + '/rest/video/' + opus + '/overview', {
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
		restCall(PATH + "/rest/video/" + video.opus + "/rank/" + rank, {method: "PUT", showLoading: false}, function() {
			setRankColor(rank);
		});
	});
}

function render() {
	video = videoList[currentIndex];
	if (video) {
		showVideo();
		navigation.paging();
	} else {
		$(".video-wrapper").hide();
	}
}

function showVideo() {
	// cover
	$(".img-cover").hide("fade", {}, 300, function() {
		$(this).attr("src", PATH + "/cover/video/" + video.opus).show("slide", {direction: direction});
	});
	
	// studio
	$(".info-studio").html(video.studio.name);
	// opus
	$(".info-opus").html(video.opus);
	// title
	$(".info-title").html(video.title);
	// actress & event
	var actressArray = [];
	$.each(video.actressList, function(index, actress) {
		actressArray.push(
				$("<div>").append(
						$("<span>", {'class': 'label label-plain'}).addClass(actress.favorite ? 'favorite' : '').append(
								$("<span>", {'class': 'glyphicon glyphicon-favorite glyphicon-star' + (actress.favorite ? '' : '-empty')}).data("name", actress.name).on("click", function() {
									fnFavorite(this, $(this).data('name'))
								})
						),
						$("<span>", {'class': 'label label-plain info-actress'}).data("name", actress.name).append(
								actress.name
								+ ' ' + actress.localName
								+ ' ' + actress.birth
								+ ' ' + actress.age
								+ ' ' + actress.bodySize
								+ ' ' + actress.height
								+ ' v' + actress.videoCount
						).on("click", function() {
							fnViewActressDetail($(this).data('name'));
						})
				).css({display: 'inline-block'})
		);
	});
	$(".info-wrapper-actress").empty().append(actressArray);
	// release
	$(".info-release").html(video.releaseDate);
	// modified
	$(".info-modified").html(video.videoDate);
	// video file
	$(".info-video").html(video.existVideoFileList ? 'V ' + formatFileSize(video.length) : 'Video')
			.addClass(video.existVideoFileList ? "exist" : "nonExist");
	// subtitles
	$(".info-subtitles").html("Subtitles").swapClass("nonExist", "exist", video.existSubtitlesFileList);
	// overview
	$(".info-overview").html(video.overviewText == '' ? 'Overview' : video.overviewText);
	// rank
	$("#ranker").val(video.rank);
	// rank label
	$("#ranker-label").html(video.rank);
	setRankColor(video.rank);
	// tag
	$(".label-tag").removeClass("label-plain").addClass("label-default");
	$.each(video.tags, function(i, tag) {
		$("#tag-" + tag.id).addClass('label-plain');
	});
}

function setRankColor(rank) {
	var color = '';
	if (rank < 0) {
		color = 'rgba(0, 0, 255, 0.5)';
	} else if (rank == 0) {
		color = 'rgba(255, 255, 255, 0.5)';
	} else {
		color = 'rgba(255, 0, 0, ' + rank*1.5/10 + ')';
	}
	$(".rank-group").css({backgroundColor: color});
}