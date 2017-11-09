var calculatedDivHeight = 0,
	CRAZY_DECORATOR_THEME       = 'crazy-decorator.theme',
	THUMBNAMILS_COVER_INDEX     = 'thumbnamils.cover.index',
	THUMBNAMILS_COVER_WIDTH     = 'thumbnamils.cover.width',
	THUMBNAMILS_COVER_HEIGHT    = 'thumbnamils.cover.height',
	THUMBNAMILS_IMAGE_INDEX     = 'thumbnamils.image.index',
	THUMBNAMILS_IMAGE_WIDTH     = 'thumbnamils.image.width',
	THUMBNAMILS_IMAGE_HEIGHT    = 'thumbnamils.image.height',
	THUMBNAMILS_MODE            = 'thumbnamils.mode',
	THUMBNAMILS_BTN_DELETE      = 'thumbnamils.btn.delete',
	THUMBNAMILS_BTN_MAGNIFY     = 'thumbnamils.btn.magnify',
	GRAVIAINTERVIEW_IMAGE_WIDTH = 'graviainterview.image.width',
	VIDEOLISTBYSPA_IMAGE_WIDTH  = 'videolistbyspa.image.width',
	VIDEOMAIN_JK_COVER_WIDTH    = 'videomain.jk.cover.width',
	/**
	 * toggle studio div
	 */
	fnStudioDivToggle = function() {
		$("#studioDiv").toggle();
		resizeDivHeight();
	},
	/**
	 * toggle actress div
	 */
	fnActressDivToggle = function() {
		$("#actressDiv").toggle();
		resizeDivHeight();
	},
	/**
	 * toggle tag div
	 */
	fnTagDivToggle = function() {
		$("#tagDiv").toggle();
		resizeDivHeight();
	},
	/**
	 * form submit
	 */
	fnSearch = function() {
		document.forms[0].submit();
	},
	/**
	 * call subtitles editer
	 * @param selectedOpus
	 */
	fnEditSubtitles = function(selectedOpus) {
		restCall(PATH + '/rest/video/' + selectedOpus + '/exec/subtitles', {method: "PUT", showLoading: false});
		
	},
	/**
	 * call video player
	 * @param selectedOpus
	 */
	fnPlay = function(selectedOpus) {
		restCall(PATH + '/rest/video/' + selectedOpus + '/exec/play', {method: "PUT", showLoading: false}, function() {
			if (!['S', 'L', 'V', 'F', 'K'].includes(listViewType)) {
				fnVideoDetail(selectedOpus);
			}
		});
	},
	/**
	 * reset video info
	 * @param selectedOpus
	 */
	fnVideoReset = function(selectedOpus) {
		restCall(PATH + '/rest/video/' + selectedOpus + '/reset', {method: "PUT", title: selectedOpus + " reset"}, function() {
			if (opener)
				location.reload();
		});
	},
	/**
	 * remove wrong video file
	 * @param selectedOpus
	 */
	fnVideoWrong = function(selectedOpus) {
		restCall(PATH + '/rest/video/' + selectedOpus + '/wrong', {method: "PUT", title: selectedOpus + " mark wrong"}, function() {
			if (opener)
				location.reload();
		});
	},
	/**
	 * call video player by random
	 */
	fnRandomPlay = function() {
		//console.log("Random play start");
		if(opusArray.length == 0) {
			alert("다 봤슴당");
			return;
		}
		var selectedNumber = getRandomInteger(0, opusArray.length);
		var selectedOpus = opusArray[selectedNumber];
		opusArray.splice(selectedNumber, 1);
		fnFocusVideo(selectedOpus);
		fnPlay(selectedOpus);
	},
	/**
	 * focus on selected video
	 * @param opus
	 */
	fnFocusVideo = function(opus) {
		//console.log("fnFocusVideo", opus, "listViewType = ", listViewType);
		if (listViewType == 'L') {
			$.large.focusVideo(opus);
		}
		else if (listViewType == 'S' || listViewType == 'V' || listViewType == 'F') {
			$.slide.focusVideo(opus);
		}
		else if (listViewType == 'C' || listViewType == 'B' || listViewType == 'IH') {
			$("#opus-" + opus).animate({opacity: 0.5}, 1000, function(){
				$(this).addClass("video-focus");
			});
		}
		else if (listViewType == 'K') {
			location.href = "#opus-" + opus;
		}
		else {
			var topValue = $("#opus-" + opus).position().top - $("#header_div").outerHeight() - 20;
			console.log("fnFocusVideo", opus, "listViewType = ", listViewType, 
					"position.top", $("#opus-" + opus).position().top, 
					"offset.top", $("#opus-" + opus).offset().top, 
					"header", $("#header_div").outerHeight(), 
					"scrollTop", topValue);
			$("#content_div").scrollTop(topValue);
		}
	},
	/**
	 * popup view video cover
	 * @param opus
	 */
	fnCoverView = function(opus) {
		console.log("Cover image view : " + opus);
		popupImage(PATH + "/video/" + opus + "/cover");
	},
	/**
	 * popup overview editer
	 * @param opus
	 */
	fnEditOverview = function(opus, event) {
		console.log("Overview Popup : " + opus);
	    popup(PATH + "/video/" + opus + "/overview", "overview-"+opus, 400, 300, 'Mouse', DEFAULT_SPECS, event);
	},
	/**
	 * popup video detail info
	 * @param opus
	 */
	fnVideoDetail = function(opus) {
	    popup(PATH + "/video/" + opus, "videoDetail-"+opus, 800, 640);
	},
	/**
	 * popup view actress detail
	 * @param name
	 */
	fnViewActressDetail = function(name) {
		popup(PATH + "/video/actress/" + name, "actressDetail-" + name, 850, 600);
	},
	/**
	 * popup view studio detail
	 * @param name
	 */
	fnViewStudioDetail = function(name) {
		popup(PATH + "/video/studio/" + name, "studioDetail-" + name, 850, 600);
	},
	/**
	 * save video rank
	 * @param opus
	 */
	fnRank = function(opus) {
		var rank = $("#Rank-"+opus);
		var rankLabel = $("#Rank-"+opus+"-label");
		fnRankColor(rank, rankLabel);
	
		var frm;
		if (opener) {
			try {
				$("#Rank-"+opus, opener.document).val(rank.val());
				$("#Rank-"+opus+"-label", opener.document).html(rank.val());
				opener.fnRankColor($("#Rank-"+opus, opener.document), $("#Rank-"+opus+"-label", opener.document));
			} catch(e) {/*opener가 이상하더라도 submit은 해야하므로*/
				console.log("fnRank opener error", e);
			}
		}
		restCall(PATH + "/rest/video/" + opus + "/rank/" + rank.val(), {method: "PUT", showLoading: false});
	},
	/**
	 * set rank color
	 * @param rank
	 */
	fnRankColor = function(rank, rankLabel) {
		try {
			rankLabel.html(rank.val());
			rank.val() == 0 ? rank.parent().css({"background-color": "rgba(255, 255, 255, 0.5)"}) :
				rank.val() > 0 ? rank.parent().css({"background-color": "rgba(255, 0, 0, 0.5)"}) :
					rank.parent().css({"background-color": "rgba(0, 0, 255, 0.5)"});
		} catch(e) {}
	},
	/**
	 * set, mark favorite actress
	 * @param dom
	 * @param name
	 */
	fnFavorite = function(dom, name) {
		var $self = $(dom), val = $self.text() == '★';
		restCall(PATH + "/rest/actress/" + name + "/favorite/" + !val, {method: "PUT", showLoading: false}, function(result) {
			console.log("fnFavorite", result, dom.innerHTML);
			$self.html(result ? '★' : '☆').attr({title: "Favorite " + result});
		});
	},
	/**
	 * searching content by keyword
	 * @param keyword
	 */
	searchContent = function(keyword) {
		if(event.keyCode != 13)
			return;
		loading(true, "Search : " + keyword);
		var foundCount = 0;
		$("div#content_div table tr").each(function() {
			var found = false;
			$(this).children().each(function() {
				if ($(this).text().toLowerCase().indexOf(keyword.toLowerCase()) > -1) {
					found = true;
					foundCount++;
				}
			});
			$(this).toggle(found);
		});
		if (keyword === '') {
			$(".label-search").hide();
		}
		else {
			$(".label-search").removeClass("hide").show();
			$(".count-search").html(foundCount);
		}
		loading(false);
	},
	/**
	 * all un checked in actress/studio/tag div
	 * @param obj
	 */
	fnUnchecked = function(obj) {
		$(obj).parent().children().children().children("input[type=checkbox]:checked").each(function() {
			$("#checkbox-" + $(this).attr("id")).click();
		});
	},
	/**
	 * reload video source
	 */
	fnReloadVideoSource = function() {
		restCall(PATH + "/rest/video/reload", {method: "PUT", title: "Source reload"});
	},
	/**
	 * 비디오 확인을 기억하기 위해 css class를 변경한다.
	 */
	fnMarkChoice = function(opus) {
		$("#check-" + opus).addClass("mark");
	},
	/**
	 * 비디오에 태그 설정
	 * @param dom 태그 object
	 * @param opus 
	 * @param tagId
	 */
	fnToggleTag = function(dom) {
		var opus  = $(dom).attr("data-opus");
		var tagId = $(dom).attr("data-tagid");
		var isSet = $(dom).attr("data-tagset") === 'false';
		$(dom).swapClass("label-default", "label-plain", isSet);
		restCall(PATH + "/rest/video/" + opus + "/tag?id=" + tagId, {method: "PUT", title: opus + (isSet ? " set" : " unset") + " tagId " + tagId}, function() {
			$(dom).attr("data-tagset", isSet);
		});
	},
	/**
	 * 저장한 태그를 화면에 추가하고, 서버에 저장시킨다.
	 * @param frm
	 */
	fnAddTag = function(frm) {
		var opus    = $(frm).find("input[name='opus']").val();
		var tagname = $(frm).find("input[name='name']").val();
		var tagdesc = $(frm).find("input[name='description']").val();
		restCall(PATH + "/rest/tag", {method: "POST", data: $(frm).serialize(), title: "add tag " + opus + " -> " + tagname}, function() {
			$("#tags-"+opus).append(
					$("<span>").addClass("label label-plain").attr("title", tagdesc).html(tagname)
			);
		});
		console.log("fnAddTag",  opus, tagname, tagdesc);
		return false;
	},
	/**
	 * 태그 상세화면 팝업.
	 * @param name
	 */
	fnViewTagDetail = function(id) {
		popup(PATH + "/video/tag/" + id, "tagDetail-" + id, 850, 600);
	},
	/**
	 * 태그 삭제
	 * @param tagId
	 */
	fnDeleteTag = function(tagId, dom) {
		if (confirm("Are you sure to delete it?")) {
			restCall(PATH + "/video/tag?id=" + tagId, {method: "DELETE", title: tagId + " tag delete"}, function(result) {
				$(dom).parent().hide();
			});
		}
	},
	fnSearchOpus = function() {
		var query = arguments.length == 0 ? $("#query").val() : arguments[0];
		showDebug("searchURL", urlSearchVideo + query);
		popup(urlSearchVideo + query, 'videoSearch', 1200, 950);
	},
	fnSearchActress = function() {
		var query = arguments.length == 0 ? $("#query").val() : arguments[0];
		showDebug("searchURL", urlSearchActress + query);
		popup(urlSearchActress + query, 'actressSearch', 900, 950);
	},
	fnSearchTorrent = function() {
		var query = arguments.length == 0 ? $("#query").val() : arguments[0];
		showDebug("searchURL", urlSearchTorrent + query);
		popup(urlSearchTorrent + query, 'torrentSearch', 900, 950);
	},
	showDebug = function(debugDomId, msg) {
		console.log('showDebug', debugDomId, msg);
		var resultId = "copyResult";
		var resultObj = $("#" + resultId);
		if (resultObj.length == 0)
			resultObj = $("<span>").attr("id", resultId).addClass("label label-danger").html("Copied").hide();
		$("#" + debugDomId).attr("data-clipboard-text", msg).css("cursor", "pointer").html("Click to copy url").show().parent().append(resultObj);
	
		new ZeroClipboard(document.getElementById(debugDomId)).on('aftercopy', function(event) {
			// event.target.style.color = 'red';
			event.target.style.display = 'none';
			resultObj.show();
			setTimeout(function() {
				resultObj.fadeOut(500);
		    }, 1000);
		});	
	},
	goTorrentMove = function(opus) {
		fnMarkChoice(opus);
		restCall(PATH + "/rest/video/" + opus + "/moveTorrentToSeed", {method: "PUT", title: "Torrent move"});
	},
	videoCoverSeenHistory = new Array(),
	getRandomVideoIndex = function() {
		if (videoCoverSeenHistory.length === totalVideoSize) {
			showSnackbar("Turned around whole video");
			videoCoverSeenHistory = [];
			return getRandomVideoIndex();
		}
		var idx = getRandomInteger(1, totalVideoSize);
		if (videoCoverSeenHistory.includes(idx)) {
			return getRandomVideoIndex();
		}
		else {
			videoCoverSeenHistory.push(idx);
			console.log('getRandomVideoIndex videoCoverSeenHistory', videoCoverSeenHistory);
			return  idx;
		}
	};
