/**
 * Video Vertical View Javascript
 */
var listViewType = 'Vertical';

var videoList = [];
var tagList = [];
var collectedList = [];

var currentVideo = null;
var currentIndex = -1;

var isFirstLoad = true;
var slideTimer;
var keyInput = "";
var keyLastInputTime = new Date().getTime();
var collecting = false;

$(document).ready(function() {

	attachEventListener();

	loadData();

});

function loadData() {
	// load tag list
	restCall(PATH + "/rest/tag", {showLoading: false}, (list) => {
		tagList = list;

		// load video list
		restCall(PATH + '/rest/video', {data: {p: 0}, title: "Load video"}, (list) => {
			videoList = list;

			deploy();
		});
	});

}

$.fn.appendTag = function(tagList, tag) {
	var createTag = tag => {
		return $("<div>", {'class': 'inline-block'}).append(
				$("<span>", {'class': 'label label-tag', title: tag.description, 'data-tag-id': tag.id}).html(tag.name).data("tag", tag)
		);
	};
	
	return this.each(function() {
		var $this = $(this);
		if (tagList) {
			$.each(tagList, (i, tag) => {
				$this.append(createTag(tag));
			});
		}
		if (tag) {
			$this.append(createTag(tag));
		}
	});
};

var deploy = () => {
	
	$(".tag-list").appendTag(tagList);

	$(document).trigger("collect");

};

function attachEventListener() {
	// header tag event
	$("#tagChoice").on("click", ".label-tag", function() {
		console.log('#tagChoice > .label-tag click', this);
		if ($("#popupTag").data("checked")) {
			var tagId = $(this).data("tag").id;
			popup(PATH + '/video/tag/' + tagId, 'tag-' + tagId, 800, 600);
		} else {
			$(this).toggleClass("on");
			var checkedLength = $("#tagChoice").find(".label-tag.on").length;
			if (checkedLength == 1) {
				$("#deselectTag").switchClass('btn-link', 'btn-warning');
			} else if (checkedLength == 0) {
				$("#deselectTag").switchClass('btn-warning', 'btn-link');
			}
			$(document).trigger("collect");
		}
	});

	// body tag event
	$("#videoTags").on("click", ".label-tag", function() {
		console.log('#videoTags > .label-tag click', this);
		var $this = $(this);
		var tagId = $this.data("tag").id;
		var isOn  = $this.hasClass("on");
		restCall(PATH + "/rest/video/" + currentVideo.opus + "/tag?id=" + tagId, {method: "PUT"}, function() {
			$this.toggleClass("on", !isOn);
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
				$("#tagChoice").appendTag(null, tag);
				$("#videoTags").appendTag(null, tag);
				$(".label-tag[data-tag-id='" + tag.id + "']", "#videoTags").addClass("on");
				$("#newTag-name, #newTag-desc").val('');
				$('.tag-form-wrapper').slideToggle();
			});
		}
	});
	// deselectTag
	$("#deselectTag").on("click", function() {
		var count = 0;
		$("#tagChoice").find(".label-tag.on").each(function(idx, tagLabel) {
			$(tagLabel).toggleClass("on");
			count++;
		});
		$(this).switchClass('btn-warning', 'btn-link');
		if (count > 0) {
			$(document).trigger("collect");
		}
	});

	// query
	$("#query").on("keyup", function(e) {
		e.stopPropagation();
		if (e.keyCode == 13) {
			$(document).trigger("collect");
		}
	});
	
	// filter & rank condition
	$("#checkbox-filter-group > [role='checkbox'], #checkbox-rank-group > [role='checkbox']").on("change", collectList);
	
	// sort condition
	$("#radio-sort").on("change", collectList);
	
	// video label event
	addVideoEvent();
	
	// navigation event
	navigation.event();
	
	// auto slide
	$("#autoSlide").on("change", function() {
		if ($(this).data("checked")) {
			navigation.slide.on();
		} else {
			navigation.slide.off();
		}
	});
	
	// toggle tags
	$("#toggle-tags").on('change', function() {
		$("#tagChoice").toggle();
		resizeDivHeight();
	});
	
	// collect
	$(document).on("collect", function() {
		!collecting && collectList();
	});
}

function collectList() {
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
	
	collecting = true;
	loading(true, 'Collect list');
	$(".video-wrapper").hide();
	
	var query = $("#query").val();
	var fav   = $("#favorite"   ).data("checked");
	var vid   = $("#video"      ).data("checked");
	var sub   = $("#subtitles"  ).data("checked");
	var rank0 = $("#check-rank0").data("checked") ? '0' : '';
	var rank1 = $("#check-rank1").data("checked") ? '1' : '';
	var rank2 = $("#check-rank2").data("checked") ? '2' : '';
	var rank3 = $("#check-rank3").data("checked") ? '3' : '';
	var rank4 = $("#check-rank4").data("checked") ? '4' : '';
	var rank5 = $("#check-rank5").data("checked") ? '5' : '';
	var sort  = $("#radio-sort" ).data("value");
	var selectedTags  = [];
	$(".label-tag.on", "#tagChoice").each(function(idx, tagLabel) {
		selectedTags.push($(tagLabel).data("tag").id);
	});
	
	collectedList = [];
	// filtering
	for (var i=0; i<videoList.length; i++) {
		var video = videoList[i];

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
		
		if (selectedTags.length > 0) {
			var found = false;
			for (var x in video.tags) {
				if (selectedTags.includes(video.tags[x].id)) {
					found = found || true;
				}
			}
			if (!found) {
				continue;
			}
		}
		
		collectedList.push(video);
	}
	
	// sorting
	collectedList.sort(function(video1, video2) {
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

	// fill tag count info
	$(".label-tag", "#tagChoice").each(function(index, tagLabel) {
		var tag = $(tagLabel).addClass("nonExist").data("tag");
		tag.count = 0;
	});

	console.log('collectedList.length', collectedList.length);
	if (collectedList.length > 0) {
		
		for (var x in collectedList) {
			var video = collectedList[x];
			for (var y in video.tags) {
				var videoTag = video.tags[y];
				var tag = $(".label-tag[data-tag-id='" + videoTag.id + "']", "#tagChoice").data("tag");
				if (tag) {
					tag.count++;
				} else {
					throw "Notfound tag.id " + videoTag.id + " in [" + video.opus + "]";
				}
			}
		}
		$(".label-tag", "#tagChoice").each(function(index, tagLabel) {
			var tag = $(tagLabel).data("tag");
			if (tag.count > 0) {
				$(tagLabel).removeClass("nonExist").html(tag.name + " " + tag.count);
			} else {
				$(tagLabel).html(tag.name);
			}
		});
		
		navigation.random();
		$(".video-wrapper").show();
	}
	collecting = false;
	loading(false);
}

function notice(msg) {
	$("<span>", {class: 'label label-plain'}).html(msg).appendTo($(".notice-bar")).fadeOut(5000, function() {
		$(this).remove();
	});
}

var navigation = {
		event: function() {
			$("#content_div").navEvent(function(signal, e) {
				switch(signal) {
				case 1: // mousewheel: up
				case 37: // key : left
					navigation.previous();
					break;
				case -1: // mousewheel: down
				case 39: // key : right
					navigation.next();
					break;
				case 32: // key: space
					navigation.random();
					break;
				case 1002: // mousedown  : middle click
					navigation.random();
					$(".info-video").trigger("click"); // video play
					break;
				case 1001: // mousedown  : left click. auto slide off
					$("#autoSlide").data("checked") && $("#autoSlide").trigger("click");
					break;
				case 36: // key: home
					navigation.go(0);
					break;
				case 35: // key: end
					navigation.go(collectedList.length -1);
					break;
				case 33: // key: pageUp
					navigation.go(currentIndex - 9);
					break;
				case 34: // key: pageDown 	
					navigation.go(currentIndex + 9);
					break;
				}
				var currentTime = new Date().getTime();
				if (currentTime - keyLastInputTime > 5000) { // 5s over, key reset
					keyInput = "";
				}
				keyLastInputTime = currentTime;
				// navigation.go of input number
				if (signal === 13 && keyInput != '') { // enter
					var idx = parseInt(keyInput) - 1;
					keyInput = "";
					navigation.go(idx);
				} else if (/^\d+$/.test(e.key)) { // key is number
					keyInput += e.key;
					notice(keyInput);
				} else if (signal === 8) { // backspace
					keyInput = keyInput.slice(0, -1);
					notice(keyInput);
				}
			});
		},
		on: function() {
			$("#content_div").navActive(true);
		},
		off: function() {
			$("#content_div").navActive(false);
		},
		previous: function() {
			navigation.go(currentIndex - 1);
		},
		next: function () {
			navigation.go(currentIndex + 1);
		},
		random: function() {
			navigation.go(getRandomInteger(0, collectedList.length-1));
		},
		go: function(idx) {
			if (idx < 0 || idx > collectedList.length - 1) {
				console.log('navigation.go wrong index', idx);
				return;
			}
			var prevIndex = currentIndex;
			currentIndex = idx;
			if (prevIndex === currentIndex) {
				return;
			}
			currentVideo = collectedList[currentIndex];
			
			// direction = 1: next, -1: previous, over: random
			showVideo(currentIndex - prevIndex);
			navigation.paging();
		},
		paging: function() {
			var addPaginationBtn = function(idx) {
				$("<li>", {
					'class': (idx === 0 ? 'first ' : '') + (idx === collectedList.length - 1 ? 'last ' : '') + (idx === currentIndex ? 'active' : '')
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
			end = end > collectedList.length ? collectedList.length : end;
			
			if (start > 0) { // first navi
				addPaginationBtn(0);
			}
			for (var i = start; i < end; i++) {
				addPaginationBtn(i);
			}
			if (end < collectedList.length) { // last navi
				addPaginationBtn(collectedList.length - 1);
			}
		},
		slide: {
			on: function() {
				var run = function() {
					var mode  = $("#radio-autoSlideMode").data("value");
					if (mode === 'R') {
						navigation.random();
					} else {
						navigation.next();
					}
				};
				run();
				slideTimer = setInterval(() => {
					run();
				}, 5000);
			},
			off: function() {
				clearInterval(slideTimer);
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
		$(".info-overview-input").removeClass("hide").focus();
	});
	// overview input
	$(".info-overview-input").on("keyup", function(e) {
		e.stopPropagation();
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
	// actress name click
	$(".info-wrapper-actress").on("click", ".info-actress", function() {
		var actress = $(this).data("actress");
		actress.name != 'Amateur' && fnViewActressDetail(actress.name);
	});
	// actress favorite click
	$(".info-wrapper-actress").on("click", ".glyphicon-favorite", function() {
		var actress = $(this).data("actress");
		fnFavorite(this, actress.name);
	});
}

function showVideo(direction) {
	function showInfo() {
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
									$("<span>", {'class': 'glyphicon glyphicon-favorite glyphicon-star' + (actress.favorite ? '' : '-empty')}).data("actress", actress)
							),
							// actress
							$("<span>", {'class': 'label label-plain info-actress'}).data("actress", actress).html(actress.name),
							$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.localName),
							$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.birth),
							$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.age),
							$("<span>", {'class': 'label label-plain info-actress-extra'}).html(actress.debut),
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
		$(".on", "#videoTags.tag-list").removeClass("on");
		$.each(currentVideo.tags, function(i, tag) {
			$(".label-tag[data-tag-id='" + tag.id + "']", "#videoTags").addClass('on');
		});
		navigation.on();
	}
	
	navigation.off();
	// Cover animate
	var prevCoverURL = PATH, currCoverURL = PATH, nextCoverURL = PATH;
	prevCoverURL += (0 < currentIndex) ? "/cover/video/" + collectedList[currentIndex-1].opus : '/image/random?_t=' + new Date().getTime();
	currCoverURL += "/cover/video/" + currentVideo.opus;
	nextCoverURL += (currentIndex < collectedList.length-1) ? "/cover/video/" + collectedList[currentIndex+1].opus : '/image/random?_t=' + new Date().getTime();
	if (isFirstLoad) {
		$(".cover-box.previous").css({backgroundImage: 'url(' + prevCoverURL + ')'}).show('fade');
		$(".cover-box.current").css({backgroundImage: 'url(' + currCoverURL + ')'}).show("fade");
		$(".cover-box.next").css({backgroundImage: 'url(' + nextCoverURL + ')'}).show('fade');
		isFirstLoad = false;
		showInfo();
	} else {
		// direction = 1: next, -1: previous, over: random
		var effect = 'slide';
		var step1Duration = 300, step2Duration = 500, step3Duration = 300;
		var showOption = {direction: direction === 1 ? 'right' : 'left'}, hideOption = {direction: direction === -1 ? 'right' : 'left'};
		var is3View = $(".cover-wrapper-inner.previous").css("display") != 'none';
		if (is3View) {
			if (direction === 1) {
				// step 0
				$(".cover-box.previous").hide();
				// step 1
				$(".cover-box.previous").css({backgroundImage: 'url(' + prevCoverURL + ')'}).show(effect, showOption, step1Duration);
				$(".cover-box.current").hide(effect, hideOption, step1Duration, function() {
					// step 2
					$(this).css({backgroundImage: 'url(' + currCoverURL + ')'}).show(effect, showOption, step2Duration, function() {
						showInfo();
					});
					$(".cover-box.next").hide(effect, hideOption, step2Duration, function() {
						// step 3
						$(this).css({backgroundImage: 'url(' + nextCoverURL + ')'}).show(effect, showOption, step3Duration);
					});
				});
			} else if (direction === -1) {
				$(".cover-box.next").hide();
				$(".cover-box.next").css({backgroundImage: 'url(' + nextCoverURL + ')'}).show(effect, showOption, step1Duration);
				$(".cover-box.current").hide(effect, hideOption, step1Duration, function() {
					$(this).css({backgroundImage: 'url(' + currCoverURL + ')'}).show(effect, showOption, step2Duration, function() {
						showInfo();
					});
					$(".cover-box.previous").hide(effect, hideOption, step2Duration, function() {
						$(this).css({backgroundImage: 'url(' + prevCoverURL + ')'}).show(effect, showOption, step3Duration);
					});
				});
			} else {
				$(".cover-box.previous").hide('fade', {}, step3Duration, function() {
					$(this).css({backgroundImage: 'url(' + prevCoverURL + ')'}).show('fade', {}, step2Duration);
				});
				$(".cover-box.current").hide('fade', {}, step3Duration, function() {
					showInfo();
					$(this).css({backgroundImage: 'url(' + currCoverURL + ')'}).show('fade', {}, step2Duration);
				});
				$(".cover-box.next").hide('fade', {}, step3Duration, function() {
					$(this).css({backgroundImage: 'url(' + nextCoverURL + ')'}).show('fade', {}, step2Duration);
				});
			}
		} else {
			$(".cover-box.previous").css({backgroundImage: 'url(' + prevCoverURL + ')'}).show();
			$(".cover-box.next").css({backgroundImage: 'url(' + nextCoverURL + ')'}).show();
			if (direction === 1 || direction === -1) {
				$(".cover-box.current").hide(effect, hideOption, step3Duration, function() {
					showInfo();
					$(this).css({backgroundImage: 'url(' + currCoverURL + ')'}).show('fade', {}, step3Duration);
				});
			} else {
				$(".cover-box.current").hide('fade', {}, step3Duration, function() {
					showInfo();
					$(this).css({backgroundImage: 'url(' + currCoverURL + ')'}).show('fade', {}, step3Duration);
				});
			}
		}
	}
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