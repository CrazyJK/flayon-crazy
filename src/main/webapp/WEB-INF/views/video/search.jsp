<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix='form'   uri='http://www.springframework.org/tags/form'%>
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
</style>
<script type="text/javascript">
//bgContinue = false;
var BOOTSTRAP_COL_LG_6 = 1230;

$(document).ready(function(){
	
	$("#query").bind("keyup", function(e) {
		
		var event = window.event || e;
		$("#debug").html(event.keyCode);
		/* 
		if (!(event.keyCode >= 48 && event.keyCode <= 57) // 0 ~ 9
				&& !(event.keyCode >= 65 && event.keyCode <= 90) // a ~ z
				&& !(event.keyCode >= 96 && event.keyCode <= 105) // keypad : 0 ~ 9
				&& event.keyCode != 109 // keypad : -
				&& event.keyCode != 189 // -
				&& event.keyCode != 8 // backspace
				&& event.keyCode != 13 // enter
				) {
			return;
		}
		 */
		if (event.keyCode != 13) {
			return;
		}

		loading(true, 'Searching');

		var keyword = $(this).val();
		var queryUrl = videoPath + '/search.json?q=' + keyword; 
		$("#url").html(queryUrl);
		
//		$(".table").hide();
		
		$.getJSON(queryUrl ,function(data) {
			$('#foundVideoList').empty();
			$('#foundHistoryList').empty();

			var videoRow = data['videoList'];
			$("#video-count").html(videoRow.length);
			$.each(videoRow, function(entryIndex, entry) {
				
				var studio 		   = entry['studio'];
				var opus 		   = entry['opus'];
				var title 		   = entry['title'];
				var actress 	   = entry['actress'];
				var existVideo 	   = entry['existVideo'];
				var existCover 	   = entry['existCover'];
				var existSubtitles = entry['existSubtitles'];
				
				var studioDom 		  = $("<span>").addClass("label label-plain").attr("onclick", "fnViewStudioDetail('" + studio +"')").html(studio);				
				var opusDom 		  = $("<span>").addClass("label label-plain").attr("onclick", "fnViewVideoDetail('" + opus +"')").html(opus);
				var titleDom 		  = $("<span>").addClass("label label-plain").html(title);
				var actressTD = $("<td>");
				var actor = actress.split(",");
				if (actor.length > 0) {
					for (var i=0; i<actor.length; i++) {
						$("<span>").addClass("label label-plain").attr("onclick", "fnViewActressDetail('" + actor[i] +"')").html(actor[i]).appendTo(actressTD);
					}
				}
				var infoTD = $("<td>");
				$("<span>").addClass("label").addClass((existVideo == "true" ? "label-success" : "label-default" )).html("V").appendTo(infoTD);
				$("<span>").addClass("label").addClass((existCover == "true" ? "label-success" : "label-default" )).html("C").appendTo(infoTD);
				$("<span>").addClass("label").addClass((existSubtitles == "true" ? "label-success" : "label-default" )).html("S").appendTo(infoTD);

				var tr  = $("<tr>");
				tr.append($("<td>").append(studioDom));
				tr.append($("<td>").append(opusDom));
				tr.append(infoTD);
				tr.append(actressTD);
				tr.append($("<td>").append(titleDom));
				$('#foundVideoList').append(tr);
			});
			if (videoRow.length > 0)
				$("#resultVideoDiv > table").show();
			else
				$("#resultVideoDiv > table").hide();

			var historyRow = data['historyList'];
			$("#history-count").html(historyRow.length);
 			$.each(historyRow, function(entryIndex, entry) {
				
				var date = entry['date'];
				var opus = entry['opus'];
				var act  = entry['act'];
				var desc = entry['desc'];
				
				var dateDom = $("<span>").addClass("label label-plain").html(date);
				var opusDom = $("<span>").addClass("label label-plain").html(opus).attr("onclick", "fnViewVideoDetail('" + opus +"')");
				var actDom	= $("<span>").addClass("label label-plain").html(act);
				var descDom = $("<span>").addClass("label label-plain").html(desc);

				var tr  = $("<tr>");
				tr.append($("<td>").append(dateDom));
				tr.append($("<td>").append(opusDom));
				tr.append($("<td>").append(actDom));
				tr.append($("<td>").append(descDom));
				$('#foundHistoryList').append(tr);
			});
 			if (historyRow.length > 0)
 				$("#resultHistoryDiv > table").show();
 			else
 				$("#resultHistoryDiv > table").hide();

 		    var rexp = eval('/' + keyword + "/gi");
 		    $("tbody > tr > td > span").each(function() {
 				$(this).html($(this).text().replace(rexp,"<mark>"+keyword+"</mark>"));
 			});

 		    resizeDivHeight();

			loading(false);
		});
	});
});
 
function resizeSecondDiv() {
	var contentDivHeight = $("#content_div").outerHeight();
	var contentDivWidth  = $("#content_div").width();
	var calculatedDivHeight = 0;
	if (contentDivWidth > BOOTSTRAP_COL_LG_6) {
		calculatedDivHeight = (contentDivHeight) - 20;	
	}
	else {
		calculatedDivHeight = (contentDivHeight) / 2 - 15;
	}

	//console.log(contentDivWidth, calculatedDivHeight);
	
	$("#resultVideoDiv").outerHeight(calculatedDivHeight);	
	$("#resultHistoryDiv").outerHeight(calculatedDivHeight);	
}
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="query" class="title">
			<s:message code="video.video"/> <s:message code="video.search"/>
		</label>
		<input type="search" id="query" class="form-control input-sm" placeHolder="<s:message code="video.search"/>"/>
		<span id="debug"     class="label label-plain">&nbsp;&nbsp;&nbsp;&nbsp;</span>
		<div class="btn-group">
				<a class="btn btn-xs btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"   ><s:message code="video.opus"/></a>
				<a class="btn btn-xs btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
				<a class="btn btn-xs btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>		
		<span id="url"       class="label label-info"></span>
		<span id="searchURL" class="label label-primary"></span>
	</div>
	
	<div id="content_div" class="row" style="margin:0;">
		<div class="col-lg-6">
			<div id="resultVideoDiv" class="box" style="overflow:auto">
				<h4><s:message code="video.video"/> <span id="video-count" class="badge"></span></h4>
				<table class="table table-condensed table-hover table-bordered" style="display:none;">
					<thead>
						<tr>
							<th>Studio</th>
							<th>Opus</th>
							<th>Info</th>
							<th>Actress</th>
							<th>Title</th>
						</tr>
					</thead>
					<tbody id="foundVideoList"></tbody>
				</table>
			</div>
		</div>
		<div class="col-lg-6">		
			<div id="resultHistoryDiv" class="box" style="overflow:auto">
				<h4><s:message code="video.history"/> <span id="history-count" class="badge"></span></h4>
				<table class="table table-condensed table-hover table-bordered" style="display:none;">
					<thead>
						<tr>
							<th>Date</th>
							<th>Opus</th>
							<th>Act</th>
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