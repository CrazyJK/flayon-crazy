var calculatedDivHeight = 0;

var CRAZY_DECORATOR_THEME       = 'crazy-decorator.theme';
var THUMBNAMILS_COVER_INDEX     = 'thumbnamils.cover.index';
var THUMBNAMILS_COVER_WIDTH     = 'thumbnamils.cover.width';
var THUMBNAMILS_COVER_HEIGHT    = 'thumbnamils.cover.height';
var THUMBNAMILS_IMAGE_INDEX     = 'thumbnamils.image.index';
var THUMBNAMILS_IMAGE_WIDTH     = 'thumbnamils.image.width';
var THUMBNAMILS_IMAGE_HEIGHT    = 'thumbnamils.image.height';
var THUMBNAMILS_MODE            = 'thumbnamils.mode';
var THUMBNAMILS_BTN_DELETE      = 'thumbnamils.btn.delete';
var THUMBNAMILS_BTN_MAGNIFY     = 'thumbnamils.btn.magnify';
var GRAVIAINTERVIEW_IMAGE_WIDTH = 'graviainterview.image.width';
var VIDEOLISTBYSPA_IMAGE_WIDTH  = 'videolistbyspa.image.width';
var VIDEOMAIN_JK_COVER_WIDTH    = 'videomain.jk.cover.width';

/**
 * div container 높이 조정
 */
function resizeDivHeight() {
	windowHeight = $(window).outerHeight();
	windowWidth  = $(window).width();
	var offsetMargin = 20;
	var headerHeight = $("#header_div").outerHeight();
	calculatedDivHeight = windowHeight - headerHeight - offsetMargin;
	$("#content_div").outerHeight(calculatedDivHeight);
	//console.log("resizeDivHeight", calculatedDivHeight);
	
	$("#innerSearchPage").css({
		width: windowWidth - offsetMargin * 2, 
		height: windowHeight - offsetMargin * 2
	});

	try {
		resizeSecondDiv(); // if it exist
	} catch (e) {
		//console.log("resizeSecondDiv Error", e.message);
	}
}

/**
 * background image set
 * @param imgIdx
 */
function setBackgroundImage(imgIdx) {
//	if (imgIdx)		currBGImageNo = imgIdx;
//	else		currBGImageNo = getRandomInteger(0, bgImageCount-1);
	currBGImageNo = imgIdx ? imgIdx : getRandomInteger(0, bgImageCount-1);
	currBGImageUrl = imagePath + "/" + currBGImageNo;
	$("body").css("background-image", "url(" + currBGImageUrl + ")");
	setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, currBGImageNo);
}

/**
 * toggle studio div
 */
function fnStudioDivToggle() {
	$("#studioDiv").toggle();
	resizeDivHeight();
}
/**
 * toggle actress div
 */
function fnActressDivToggle() {
	$("#actressDiv").toggle();
	resizeDivHeight();
}
/**
 * toggle tag div
 */
function fnTagDivToggle() {
	$("#tagDiv").toggle();
	resizeDivHeight();
}
/**
 * form submit
 */
function fnSearch() {
	document.forms[0].submit();
}
/**
 * call subtitles editer
 * @param selectedOpus
 */
function fnEditSubtitles(selectedOpus) {
	console.log("edit subtitles " + selectedOpus);
	$("#actionIframe").attr("src", videoPath + "/" + selectedOpus + "/subtitles");
}
/**
 * call video player
 * @param selectedOpus
 */
function fnPlay(selectedOpus) {
	//console.log("Video play ", selectedOpus, "listViewType=", listViewType);
//	$("#actionIframe").attr("src", videoPath + "/" + selectedOpus + "/play");
	actionFrame(videoPath + "/" + selectedOpus + "/play", {}, "GET", selectedOpus + " play");
	if (listViewType != 'S' && listViewType != 'L' && listViewType != 'V' && listViewType != 'F' && listViewType != 'K') {
		fnVideoDetail(selectedOpus);
	}  
}
/**
 * reset video info
 * @param selectedOpus
 */
function fnVideoReset(selectedOpus) {
	actionFrame(videoPath + "/" + selectedOpus + "/reset", {}, "PUT", selectedOpus + " reset");
//	$("#hiddenHttpMethod").val("PUT");
//	var frm = document.forms["actionFrm"];
//	frm.action = videoPath + "/" + selectedOpus + "/reset";
//	frm.submit();
}
/**
 * remove wrong video file
 * @param selectedOpus
 */
function fnVideoWrong(selectedOpus) {
	actionFrame(videoPath + "/" + selectedOpus + "/wrong", {}, "PUT", selectedOpus + " mark wrong");
//	$("#hiddenHttpMethod").val("PUT");
//	var frm = document.forms["actionFrm"];
//	frm.action = videoPath + "/" + selectedOpus + "/wrong";
//	frm.submit();
}
/**
 * call video player by random
 */
function fnRandomPlay() {
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
}
/**
 * focus on selected video
 * @param opus
 */
function fnFocusVideo(opus) {
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
}
/**
 * popup view background image
 */
function fnBGImageView() {
	popupImage(currBGImageUrl, "bg-image");
}
/**
 * delete current backgroung image
 */
function fnBGImageDELETE() {
	actionFrame(currBGImageUrl, {}, "DELETE", "this image delete");
//	$("#hiddenHttpMethod").val("DELETE");
//	var actionFrm = document.forms['actionFrm'];
//	actionFrm.action = currBGImageUrl;
//	actionFrm.submit();
}
/**
 * popup view video cover
 * @param opus
 */
function fnCoverView(opus) {
	console.log("Cover image view : " + opus);
	popupImage(videoPath + "/" + opus + "/cover");
}
/**
 * popup overview editer
 * @param opus
 */
function fnEditOverview(opus, event) {
	console.log("Overview Popup : " + opus);
    popup(videoPath + "/" + opus + "/overview", "overview-"+opus, 400, 300, 'Mouse', DEFAULT_SPECS, event);
}
/**
 * popup video detail info
 * @param opus
 */
function fnVideoDetail(opus) {
    popup(videoPath + "/" + opus, "videoDetail-"+opus, 800, 640);
}
/**
 * popup view actress detail
 * @param name
 */
function fnViewActressDetail(name) {
	popup(videoPath + "/actress/" + name, "actressDetail-" + name, 850, 600);
}
/**
 * popup view studio detail
 * @param name
 */
function fnViewStudioDetail(name) {
	popup(videoPath + "/studio/" + name, "studioDetail-" + name, 850, 600);
}

/**
 * save video rank
 * @param opus
 */
function fnRank(opus) {
	var rank = $("#Rank-"+opus);
	var rankLabel = $("#Rank-"+opus+"-label");
	fnRankColor(rank, rankLabel);

	var frm;
	if(opener) {
		try {
			$("#Rank-"+opus, opener.document).val(rank.val());
			$("#Rank-"+opus+"-label", opener.document).html(rank.val());
			opener.fnRankColor($("#Rank-"+opus, opener.document), $("#Rank-"+opus+"-label", opener.document));
		} catch(e) {/*opener가 이상하더라도 submit은 해야하므로*/
			console.log("fnRank opener error", e);
		}
	}
	actionFrame(videoPath + "/" + opus + "/rank/" + rank.val(), {}, "PUT", opus + " rank " + rank.val(), 300);
//	$("#hiddenHttpMethod").val("put");
//	frm = document.forms["actionFrm"];
//	frm.action = videoPath + "/" + opus + "/rank/" + rank.val();
//	frm.submit();
}
/**
 * set rank color
 * @param rank
 */
function fnRankColor(rank, rankLabel) {
	try {
		rankLabel.html(rank.val());
		if(rank.val() == 0) {
			rank.parent().css({"background-color": "rgba(255, 255, 255, 0.5)"});
		}
		else if(rank.val() > 0) {
			rank.parent().css({"background-color": "rgba(255, 0, 0, 0.5)"});
		}
		else {
			rank.parent().css({"background-color": "rgba(0, 0, 255, 0.5)"});
		}
	} catch(e) {}
}
/**
 * set, mark favorite actress
 * @param dom
 * @param name
 */
function fnFavorite(dom, name) {
	var val = dom.innerHTML == '★';
	dom.innerHTML = val ? '☆' : '★';
	actionFrame(videoPath + "/actress/" + name + "/favorite/" + !val, {}, "PUT", name + " set favorite");
//	$("#hiddenHttpMethod").val('PUT');
//	var frm = document.forms["actionFrm"];
//	frm.action = videoPath + "/actress/" + name + "/favorite/" + !val;
//	frm.submit();
}
/**
 * searching content by keyword
 * @param keyword
 */
function searchContent(keyword) {
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
}
/**
 * all un checked in actress/studio/tag div
 * @param obj
 */
function fnUnchecked(obj) {
	$(obj).parent().children().children().children("input[type=checkbox]:checked").each(function() {
		$("#checkbox-" + $(this).attr("id")).click();
	});
}
/**
 * reload video source
 */
function fnReloadVideoSource() {
	actionFrame(videoPath + "/reload", {}, "GET", "Source reload");
//	var frm = document.forms["actionFrm"];
//	frm.action = videoPath + "/reload";
//	frm.submit();
}

/**
 * 비디오 확인을 기억하기 위해 css class를 변경한다.
 */
function fnMarkChoice(opus) {
	$("#check-" + opus).addClass("mark");
}
/**
 * 비디오에 태그 설정
 * @param dom 태그 object
 * @param opus 
 * @param tagId
 */
function fnSetTag(dom, opus, tagId) {
	if ($(dom).hasClass("label-default")) {
		$(dom).removeClass("label-default");
		$(dom).addClass("label-plain");
	}
	else {
		$(dom).removeClass("label-plain");
		$(dom).addClass("label-default");
	}
	actionFrame(videoPath + "/" + opus + "/tag?id=" + tagId, {}, "POST", "set tag " + opus + " <- " + tagId);
//	$("#hiddenHttpMethod").val("POST");
//	var frm = document.forms["actionFrm"];
//	$(frm).append($("<input type=hidden name=id value=" + tagId + ">"));
//	frm.action = videoPath + "/" + opus + "/tag";
//	frm.submit();
}
/**
 * 저장한 태그를 화면에 추가한다
 * @param frm
 */
function addTag(frm) {
	var opus    = $(frm).find("input[name='opus']").val();
	var tagname = $(frm).find("input[name='name']").val();
	var tagdesc = $(frm).find("input[name='description']").val();
	console.log("tag ",  opus, tagname, tagdesc);
	var newTag = $("<span>").addClass("label label-plain").attr("title", tagdesc).html(tagname);
	$("#tags-"+opus).append(newTag);
	$(frm).children().first().click();
	
}
/**
 * 태그 상세화면 팝업.
 * @param name
 */
function fnViewTagDetail(name) {
	popup(videoPath + "/tag/" + name, "tagDetail-" + name, 850, 600);
}
/**
 * 태그 삭제
 * @param tagId
 */
function fnDeleteTag(tagId, dom) {
	if (confirm("Are you sure to delete it?")) {
		$(dom).parent().hide();
		actionFrame(videoPath + "/tag?id=" + tagId, {}, "DELETE", tagId + " tag delete");
//		$("#hiddenHttpMethod").val("DELETE");
//		var frm = document.forms["actionFrm"];
//		$(frm).append($("<input type=hidden name=id value=" + tagId + ">"));
//		frm.action = videoPath + "/tag";
//		frm.submit();
	}
}
function fnSearchOpus() {
	console.log(arguments);
	var opus;
	if (arguments.length == 0)
		opus = $("#query").val();
	else
		opus = arguments[0];
	showDebug("searchURL", urlSearchVideo + opus);
	popup(urlSearchVideo + opus, 'videoSearch', 900, 950);
}
function fnSearchActress(name) {
	var name;
	if (arguments.length == 0)
		name = $("#query").val();
	else
		name = arguments[0];
	showDebug("searchURL", urlSearchActress + name);
	popup(urlSearchActress + name, 'actressSearch', 900, 950);
}
function fnSearchTorrent(opus) {
	var opus;
	if (arguments.length == 0)
		opus = $("#query").val();
	else
		opus = arguments[0];
	showDebug("searchURL", urlSearchTorrent + opus);
	popup(urlSearchTorrent + opus, 'torrentSearch', 900, 950);
}

function showDebug(debugDomId, msg) {
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
}

function goTorrentMove(opus) {
	fnMarkChoice(opus);
	actionFrame(videoPath + "/" + opus + "/moveTorrentToSeed", {}, "POST", "Torrent move");
}

var videoCoverSeenHistory = new Array();
  function getRandomVideoIndex() {
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
  }
