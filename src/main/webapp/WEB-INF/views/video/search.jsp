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
</style>
<script type="text/javascript">
bgContinue = false;
$(document).ready(function() {
	
	$("#query").on("keyup", function(e) {
		var event = window.event || e;
		$("#debug").html(event.keyCode);
		if (event.keyCode != 13) {
			return;
		}

		loading(true, 'Searching');

		var keyword = $(this).val();
		var queryUrl = PATH + '/video/search.json?q=' + keyword; 
		$("#url").html(queryUrl);
		
		$.getJSON(queryUrl ,function(data) {
			$('#foundVideoList, #foundHistoryList').empty();

			var videoRow = data['videoList'];
			$("#video-count").html(videoRow.length);
			$.each(videoRow, function(entryIndex, entry) {
				var studio 		   = entry['studio'],
					opus 		   = entry['opus'],
					title 		   = entry['title'],
					actress 	   = entry['actress'],
					existVideo 	   = entry['existVideo'],
					existCover 	   = entry['existCover'],
					existSubtitles = entry['existSubtitles'],
					releaseDate    = entry['releaseDate'];
				$('#foundVideoList').append(
						$("<tr>").append(
								$("<td>").append(
										$("<span>", {"class": "label label-plain", "onclick": "fnViewStudioDetail('" + studio + "')"}).html(studio)
								),
								$("<td>").append(
										$("<span>", {"class": "label label-plain", "onclick": "fnVideoDetail('" + opus +"')"}).html(opus)
								),
								$("<td>").append(
										$("<span>", {"class": "label " + (existVideo === "true" ? "label-success" : "label-default")}).html("V"),
										$("<span>", {"class": "label " + (existCover === "true" ? "label-success" : "label-default")}).html("C"),
										$("<span>", {"class": "label " + (existSubtitles === "true" ? "label-success" : "label-default")}).html("S")
								),
								$("<td>").append(
									function() {
										var objs = [], actor = actress.split(",");
										if (actor.length > 0)
											for (var i=0; i<actor.length; i++)
												objs.push($("<span>", {"class": "label label-plain", "onclick": "fnViewActressDetail('" + actor[i] +"')"}).html(actor[i]));
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

			var historyRow = data['historyList'];
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

 		    var rexp = eval('/' + keyword + '/gi');
 		    $("tbody > tr > td > span").each(function() {
 				$(this).html($(this).text().replace(rexp, "<mark>" + keyword + "</mark>"));
 			});

			loading(false);
		});
	});
});

var BOOTSTRAP_COL_LG_6 = 1230,
	moveWatchedVideo = ${MOVE_WATCHED_VIDEO},
	deleteLowerRankVideo = ${DELETE_LOWER_RANK_VIDEO},
	deleteLowerScoreVideo = ${DELETE_LOWER_SCORE_VIDEO},
	fnMoveWatchedVideo = function() {
		actionFrame(PATH + '/video/manager/moveWatchedVideo', {}, 'POST', 'Moving Watched Video');
	},
	setMoveWatchedVideo = function() {
		moveWatchedVideo = !moveWatchedVideo;
		actionFrame(PATH + '/video/set/MOVE_WATCHED_VIDEO/' + moveWatchedVideo, {}, "POST", "Set Watched Video to " + moveWatchedVideo, 0, function() {
			$("#MOVE_WATCHED_VIDEO").html("" + moveWatchedVideo);
		});
	},
	fnRemoveLowerRankVideo = function() {
		actionFrame(PATH + '/video/manager/removeLowerRankVideo', {}, 'POST', 'Deleting Lower Rank');
	},
	setDeleteLowerRankVideo = function() {
		deleteLowerRankVideo = !deleteLowerRankVideo;
		actionFrame(PATH + '/video/set/DELETE_LOWER_RANK_VIDEO/' + deleteLowerRankVideo, {}, "POST", "Set Lower Rank to " + deleteLowerRankVideo, 0, function() {
			$("#DELETE_LOWER_RANK_VIDEO").html("" + deleteLowerRankVideo);	
		});
	},
	fnRemoveLowerScoreVideo = function() {
		actionFrame(PATH + '/video/manager/removeLowerScoreVideo', {}, 'POST', 'Deleting Lower Score');
	},
	setDeleteLowerScoreVideo = function() {
		deleteLowerScoreVideo = !deleteLowerScoreVideo;
		actionFrame(PATH + '/video/set/DELETE_LOWER_SCORE_VIDEO/' + deleteLowerScoreVideo, {}, "POST", "Set Lower Score to " + deleteLowerScoreVideo, 0, function() {
			$("#DELETE_LOWER_SCORE_VIDEO").html("" + deleteLowerScoreVideo);
		});
	},
	fnStartVideoBatch = function(type) {
		actionFrame(PATH + '/video/manager/startVideoBatch/' + type, {}, 'POST', type + ' VideoBatch...');
	},
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
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline" style="padding-top:10px;">
		<label for="query" class="title">
			<s:message code="video.search"/>
		</label>
		<input type="search" id="query" class="form-control input-sm" placeHolder="<s:message code="video.search"/>"/>
		<span id="debug"     class="label label-plain">&nbsp;&nbsp;&nbsp;&nbsp;</span>
		<div class="btn-group btn-group-xs">
			<a class="btn btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"   ><s:message code="video.opus"/></a>
			<a class="btn btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
			<a class="btn btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>		
		<span id="url"       class="label label-info"></span>
		<span id="searchURL" class="label label-primary"></span>

		<span class="close" style="margin-left:10px;" onclick="parent.viewInnerSearchPage()">&times;</span>
		
		<button class="btn btn-xs btn-danger float-right" onclick="$('#batchGroup').toggle(0, resizeDivHeight);">Batch <span class="caret"></span></button>
		<button class="btn btn-xs btn-primary float-right" onclick="fnReloadVideoSource()">Reload</button>

		<div id="batchGroup" style="display:none; padding-top:5px; text-align:right;">
			<hr style="margin: 3px 0;"/>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnMoveWatchedVideo()"><s:message code="video.mng.move"/></button>
				<button class="btn btn-default" onclick="setMoveWatchedVideo()" id="MOVE_WATCHED_VIDEO">${MOVE_WATCHED_VIDEO}</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnRemoveLowerRankVideo()"><s:message code="video.mng.rank"/></button>
				<button class="btn btn-default" onclick="setDeleteLowerRankVideo()" id="DELETE_LOWER_RANK_VIDEO">${DELETE_LOWER_RANK_VIDEO}</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnRemoveLowerScoreVideo()"><s:message code="video.mng.score"/></button>
				<button class="btn btn-default" onclick="setDeleteLowerScoreVideo()" id="DELETE_LOWER_SCORE_VIDEO">${DELETE_LOWER_SCORE_VIDEO}</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnStartVideoBatch('instance')">InstanceVideoBatch</button>
				<button class="btn btn-default" onclick="fnStartVideoBatch('archive')">ArchiveVideoBatch</button>
			</div>
			<div class="btn-group btn-group-xs">
				<button class="btn btn-default" onclick="fnStartVideoBatch('backup')">Backup Batch</button>
			</div>
		</div>
		
	</div>

	<div id="content_div" class="row">
		<div class="col-lg-6">
			<div id="resultVideoDiv" class="box" style="overflow:auto">
				<h4 class="title"><s:message code="video.video"/> <span id="video-count" class="badge"></span></h4>
				<table class="table table-condensed table-hover table-bordered" style="display:none;">
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