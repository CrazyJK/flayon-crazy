<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.video"/> <s:message code="video.search"/></title>
<style type="text/css">
.label {
	margin-right: 3px;
}
mark {
	padding:0;
}
.row {
	margin: 0;
}
.col-lg-6 {
	padding: 0;
}
.btn {
	min-width: 40px;
}
#content_div {
	background-color: transparent !important;
}
.findMode {
	display: none;
}
.findMode input,
#downloadPageImageForm input {
	font-family: D2Coding;
	border: 1px solid #cacaca;
}
input#fullname.input-sm {
	color: #337ab7;
	width: 100% !important;
	box-shadow: 0 2px 2px 0 rgba(0,0,0,0.16) inset, 0 0 0 1px rgba(0,0,0,0.08) inset;
	height: 22px;
}
.save-history {
    font-family: D2Coding;
    font-size: 12px;
    margin: 6px 0 0 0;
    padding-left: 30px;
	color: #337ab7;
}
.ui-dialog-danger {
    border: 1px solid #ddd;
    background: rgb(173, 103, 103);
    color: #fdfdfd;
}
</style>
<script type="text/javascript">
bgContinue = false;
$(document).ready(function() {

	$("#query, #opus").on("keyup", function(e) {
		var event = window.event || e;
		$("#debug").html(event.keyCode);
		if (event.keyCode != 13) {
			return;
		}

		var keyword = $(this).val();
		var queryUrl = PATH + '/rest/video/search/' + keyword;
		$("#url").html(queryUrl);

		restCall(queryUrl, {}, function(result) {
			$('#foundVideoList, #foundHistoryList').empty();

			var videoRow = result.videoResult;
			$("#video-count").html(videoRow.length);
			$.each(videoRow, function(entryIndex, entry) {
				var studio 		= entry['studio'],
					opus 		= entry['opus'],
					title 		= entry['title'],
					actress 	= entry['actress'],
					existV 	    = entry['existVideo'] === "true" ? "success" : "default",
					existC 	    = entry['existCover'] === "true" ? "success" : "default",
					existS      = entry['existSubtitles'] === "true" ? "success" : "default",
					releaseDate = entry['releaseDate'],
					videoLength = entry['length'];
				$('#foundVideoList').append(
						$("<tr>").append(
								$("<td>").append(
										$("<span>", {"class": "label label-plain", "onclick": "fnViewStudioDetail('" + studio + "')"}).html(studio)
								),
								$("<td>").append(
										$("<span>", {"class": "label label-plain", "onclick": "fnVideoDetail('" + opus +"')"}).html(opus)
								),
								$("<td>").append(
										$("<span>", {"class": "label label-" + existV}).html("V"),
										$("<span>", {"class": "label label-" + existC}).html("C"),
										$("<span>", {"class": "label label-" + existS}).html("S"),
										$("<span>", {"class": "label label-plain"}).html(formatFileSize(videoLength))
								),
								$("<td>").append(
									function() {
										var objs = [], actor = actress.split(",");
										if (actor.length > 0)
											for (var i=0; i<actor.length; i++) {
												var name = $.trim(actor[i]);
												objs.push($("<span>", {"class": "label label-plain", "onclick": "fnViewActressDetail('" + name + "')"}).html(name));
											}
										return objs;
									}
								),
								$("<td>").append(
										$("<span>", {"class": "label label-plain"}).html(releaseDate)
								),
								$("<td>").append(
										$("<span>", {"class": "label label-plain"}).html(title)
								)
						)
				);
			});
			$("#resultVideoDiv > table").toggle(videoRow.length > 0);

			var historyRow = result.historyResult;
			$("#history-count").html(historyRow.length);
 			$.each(historyRow, function(entryIndex, entry) {
				var date = entry['date'],
					opus = entry['opus'],
					act  = entry['act'],
					desc = entry['desc'];
				$('#foundHistoryList').append(
						$("<tr>").append(
								$("<td>").append(
										$("<span>", {"class": "label label-plain"}).html(date)
								),
								$("<td>").append(
										$("<span>", {"class": "label label-plain", "onclick": "fnVideoDetail('" + opus +"')"}).html(opus)
								),
								$("<td>").append(
										$("<span>", {"class": "label label-plain"}).html(act)
								),
								$("<td>").append(
										$("<span>", {"class": "label label-plain"}).html(desc)
								)
						)
				);
			});
 			$("#resultHistoryDiv > table").toggle(historyRow.length > 0);

 			var torrents = result.torrentResult;
			$(".torrent-count").html(torrents.length);
			$("#torrentList").empty();
 			$.each(torrents, function(entryIndex, torrent) {
 				$("#torrentList").append(
 						$("<li>").append(
 							$("<a>", {title: "move to seed : " + torrent.path, "class": "label label-primary"}).append(
 									torrent.name,
 									"&nbsp;&nbsp;&nbsp;",
 									$("<small>").html(torrent.size)
 							).data("path", torrent.path).on("click", function() {
 	 							restCall(PATH + '/rest/video/torrent/seed/move', {method: "PUT", data: {"seed": $(this).data("path")}, title: "move seed"});
 	 						})
 						)
 				);
 			});

 			var studioList = result.studioResult;
 			if (studioList.length > 0) {
 				$("#studio").val(studioList[0].studio);
 			}
 			
 		    var rexp = eval('/' + keyword + '/gi');
 		    $("tbody > tr > td > span").each(function() {
 				$(this).html($(this).text().replace(rexp, "<mark>" + keyword + "</mark>"));
 			});

		});

	});

	$(".input-title > input").on("keyup", function() {
		var fullname = "";
		$(".input-title > input").each(function() {
			var value = $(this).val();
			value = $.trim(value);
			if ($(this).attr("id") === "opus") {
				value = value.toUpperCase();
				$("#query").val(value);
			}
			fullname += '[' + value + ']';
		});
		$(".output-title > input").val(fullname);
	});

	
	$("#downloadDir").val(getLocalStorageItem("DOWNLOAD_LOCAL_PATH", ""));

});

var	fnSetVideoBatchOption = function(type, dom) {
		var $self = $(dom), newValue = !($self.text() == 'true'), name = $self.prev().text();
		restCall(PATH + '/rest/video/batch/option', {
			method: "PUT",
			data: {k: type, v: newValue},
			title: name,
			showLoading: false
		}, function(result) {
//			showSnackbar("Set option " + name + " to " + result, 1000);
//			$("#restCallResult").html(name + " = " + result).show().fadeOut(3000);
			$self.html("" + result).effect("highlight", {color: "#ff9999"}, 500);
		});
	},
	fnStartVideoBatch = function(type, dom) {
		restCall(PATH + '/rest/video/batch/start', {method: "PUT", data: {t: type}, title: $(dom).text()});
	};

var BOOTSTRAP_COL_LG_6 = 1200,
	resizeSecondDiv = function() {
		$("#content_div").css("background-color", "transparent");
		$("#resultVideoDiv, #resultHistoryDiv").outerHeight(
				$("#content_div").width() > BOOTSTRAP_COL_LG_6
					? $("#content_div").outerHeight() - 20
					: $("#content_div").outerHeight() / 2 - 15
		).each(function() {
			$(this).css("background-color", getRandomColor(0.3));
		});
	};

function fnSaveCover() {
	var opus = $("#opus").val();
	var title = $("#fullname").val();
	restCall(PATH + '/rest/video/' + opus + '/saveCover', {method: "POST", data: {title: title}}, function() {
		fnAddHistory();
		resizeSecondDiv();
	});
}
function fnAddHistory() {
	var title = $("#fullname").val();
	$(".save-history").append(
			$("<li>").html(title)	
	);
}
function fnFindRandomOpus() {
	var opus = getRandomInteger(1, 999);
	fnSearchOpus(opus);
}
function fnDownloadPageImage() {
	restCall(PATH + '/rest/image/pageImageDownload', {
		data: $("#downloadPageImageForm").serialize(),
		title: 'Download images'
	}, function(result) {
	    $("#notice > p").empty().append(
				$("<ul>").addClass('list-unstyled').append(
						$("<li>").addClass("text-info").html(result.images.length + " images"),		
						$("<li>").addClass("text-primary btn-link pointer").append(
								$("<span>").on("click", function() {
									fsOpen(result.localPath);
								}).html(result.localPath)
						)
				)
	    );
		$("#notice").dialog({
			classes: {
			    "ui-dialog": (result.result ? "ui-widget-shadow" : "ui-dialog-danger")
			},
			width: 500,
			height: 200,
			title: result.message,
		});
		setLocalStorageItem("DOWNLOAD_LOCAL_PATH", $("#downloadDir").val());
	});	
}
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline" style="padding-top:10px;">
		<label for="query" class="title">
			<s:message code="video.search"/>
		</label>
		<input type="search" id="query" class="form-control input-sm" placeHolder="<s:message code="video.search"/>"/>
		<span id="debug" class="label label-plain">&nbsp;&nbsp;&nbsp;&nbsp;</span>
		<div class="btn-group btn-group-xs">
			<a class="btn btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"   ><s:message code="video.opus"/></a>
			<a class="btn btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
			<a class="btn btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>

		<button class="btn btn-xs btn-default" onclick="$('.findMode').toggle(0, resizeDivHeight);">Find mode <span class="caret"></span></button>

		<button class="btn btn-xs btn-info" onclick="$('#pageImageDownloader').toggle(0, resizeDivHeight);">Page Image Downloader <span class="caret"></span></button>

		<span id="url"       class="label label-info"></span>
		<span id="searchURL" class="label label-primary"></span>

		<span class="close" style="margin-left:10px;" onclick="parent.viewInnerSearchPage()">&times;</span>

		<button class="btn btn-xs btn-danger float-right" onclick="$('#batchGroup').toggle(0, resizeDivHeight);">Batch <span class="caret"></span></button>
		<button class="btn btn-xs btn-primary float-right" onclick="fnReloadVideoSource()">Reload</button>

		<div class="findMode" style="padding-top:5px;">
			<hr style="margin: 3px 0;"/>
			<div class="input-title">
				<input class="form-control input-sm" id="studio"  style="width: 100px !important;" placeholder="Studio"/>
				<input class="form-control input-sm" id="opus"    style="width:  70px !important;" placeholder="Opus"/>
				<input class="form-control input-sm" id="title"   style="width: 300px !important;" placeholder="Title"/>
				<input class="form-control input-sm" id="actress" style="width: 100px !important;" placeholder="Actress"/>
				<input class="form-control input-sm" id="release" style="width:  80px !important;" placeholder="Release"/>
				<button class="btn btn-xs btn-default" onclick="fnSaveCover()">Save cover</button>
				<button class="btn btn-xs btn-default" onclick="fnAddHistory()">Add history</button>
				<button class="btn btn-xs btn-warning" onclick="fnFindRandomOpus();">Random Find</button>
			</div>
			<div class="output-title">
				<input class="form-control input-sm" id="fullname" placeholder="Full name"/>
			</div>
		</div>

		<div id="batchGroup" style="display:none; padding-top:5px; text-align:right;">
			<hr style="margin: 3px 0;"/>
			<span id="restCallResult" class="label label-warning"></span>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnStartVideoBatch('W', this)"><s:message code="video.mng.move"/></button>
				<button class="btn btn-default" onclick="fnSetVideoBatchOption('W', this)">${moveWatchedVideo}</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnStartVideoBatch('R', this)"><s:message code="video.mng.rank"/></button>
				<button class="btn btn-default" onclick="fnSetVideoBatchOption('R', this)">${deleteLowerRankVideo}</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnStartVideoBatch('S', this)"><s:message code="video.mng.score"/></button>
				<button class="btn btn-default" onclick="fnSetVideoBatchOption('S', this)">${deleteLowerScoreVideo}</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnStartVideoBatch('I', this)">InstanceVideoBatch</button>
				<button class="btn btn-default" onclick="fnStartVideoBatch('A', this)">ArchiveVideoBatch</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnStartVideoBatch('B', this)">Backup Batch</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnStartVideoBatch('D', this)">Delete Empty Folder</button>
			</div>
		</div>
		
		<div id="pageImageDownloader" style="display:none; padding-top:5px;">
			<hr style="margin: 3px 0;"/>
			<form id="downloadPageImageForm" onsubmit="return false;">
				<input class="form-control input-sm" name="pageUrl"       style="width:  100% !important;" placeholder="Image page URL"/><br>
				<input class="form-control input-sm" name="downloadDir"   style="width:  100% !important;" placeholder="Download local path" id="downloadDir"/><br>
				<input class="form-control input-sm" name="folderName"    style="width: 200px !important;" placeholder="Folder name"/><span class="label label-desc"> / </span>
				<input class="form-control input-sm" name="titlePrefix"   style="width: 200px !important;" placeholder="Title prefix"/><span class="label label-desc"> or </span>
				<input class="form-control input-sm" name="titleCssQuery" style="width: 200px !important;" placeholder="Title css selector"/>
				<input class="form-control input-sm" name="minimumKbSize" style="width:  50px !important;" placeholder="KB" value="30" type="number"/><span class="label label-desc"> kB </span>
				<button type="button" class="btn btn-xs btn-info" onclick="fnDownloadPageImage();">Download</button>
			</form>
		</div>
	</div>

	<div id="content_div" class="row">
		<div class="col-lg-6">
			<div id="resultVideoDiv" class="box" style="overflow:auto">
				<h4 class="title"><s:message code="video.video"/> <span id="video-count" class="badge"></span></h4>
				<table class="table table-condensed table-hover table-bordered table-responsive" style="display:none;">
					<thead>
						<tr>
							<th>Studio</th>
							<th>Opus</th>
							<th>Info</th>
							<th>Actress</th>
							<th>Release</th>
							<th>Title</th>
						</tr>
					</thead>
					<tbody id="foundVideoList"></tbody>
				</table>
				
				<h4 class="title">Torrent archives <span class="badge torrent-count"></span></h4>
				<ol id="torrentList" class="list-unstyled"></ol>

				<div class="findMode">
					<h4 class="title">Save history</h4>
					<ol class="save-history"></ol>
				</div>
			</div>
		</div>
		<div class="col-lg-6">
			<div id="resultHistoryDiv" class="box" style="overflow:auto">
				<h4 class="title"><s:message code="video.history"/> <span id="history-count" class="badge"></span></h4>
				<table class="table table-condensed table-hover table-bordered" style="display:none;">
					<thead>
						<tr>
							<th>Date</th>
							<th>Opus</th>
							<th>Action</th>
							<th>Desc</th>
						</tr>
					</thead>
					<tbody id="foundHistoryList"></tbody>
				</table>
			</div>
		</div>
	</div>

</div>
</body>
</html>