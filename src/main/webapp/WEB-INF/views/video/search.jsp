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
</style>
<script type="text/javascript">
//bgContinue = false;
var BOOTSTRAP_COL_LG_6 = 970;

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
		var queryUrl = context + 'video/search.json?q=' + keyword; 
		
		$.getJSON(queryUrl ,function(data) {
			$('#foundVideoList').empty();
			$('#foundHistoryList').empty();
			$('#foundVideoList').slideUp();
			$('#foundHistoryList').slideUp();
			$("#url").html(queryUrl);

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
				
				var li  = $("<li>");
				var div = $("<div>");

				var studioDom 		  = $("<span>").addClass("label label-plain").attr("onclick", "fnViewStudioDetail('" + studio +"')").html(studio);				
				var opusDom 		  = $("<span>").addClass("label label-plain").attr("onclick", "fnViewVideoDetail('" + opus +"')").html(opus);
				var titleDom 		  = $("<span>").addClass("label label-plain").html(title);
				var actressDom 		  = $("<span>").addClass("label label-plain").attr("onclick", "fnViewActressDetail('" + actress +"')").html(actress);
				var existVideoDom 	  = $("<span>").addClass("label").addClass((existVideo == "true" ? "label-success" : "label-default" )).html("V");
				var existCoverDom 	  = $("<span>").addClass("label").addClass((existCover == "true" ? "label-success" : "label-default" )).html("C");
				var existSubtitlesDom = $("<span>").addClass("label").addClass((existSubtitles == "true" ? "label-success" : "label-default" )).html("S");

				div.append(studioDom);
				div.append(opusDom);
				div.append(titleDom);
				div.append(actressDom);
				div.append(existVideoDom);
				div.append(existCoverDom);
				div.append(existSubtitlesDom);
				li.append(div);
				$('#foundVideoList').append(li);
			});

			var historyRow = data['historyList'];
			$("#history-count").html(historyRow.length);
 			$.each(historyRow, function(entryIndex, entry) {
				
				var date = entry['date'];
				var opus = entry['opus'];
				var act  = entry['act'];
				var desc = entry['desc'];
				
				var li  = $("<li>");
				var div = $("<div>");

				var dateDom 		  = $("<span>").addClass("label label-plain").html(date);
				var opusDom 		  = $("<span>").addClass("label label-plain").attr("onclick", "fnViewVideoDetail('" + opus +"')").html(opus);
				var actDom	 		  = $("<span>").addClass("label label-plain").html(act);
				var descDom 		  = $("<span>").addClass("label label-plain").html(desc);

				div.append(dateDom);
				div.append(opusDom);
				div.append(actDom);
				div.append(descDom);
				li.append(div);
				$('#foundHistoryList').append(li);
			}); 

 		    var rexp = eval('/' + keyword + "/gi");
 		    $("div > ol > li > div > span").each(function() {
 				$(this).html($(this).html().replace(rexp,"<mark>"+keyword+"</mark>"));
 			});

 		    $('#foundVideoList').slideDown();
 			$('#foundHistoryList').slideDown();
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

	$("#resultVideoDiv").outerHeight(calculatedDivHeight);	
	$("#resultHistoryDiv").outerHeight(calculatedDivHeight);	
}

function fnSearchOpus() {
	popup('${urlSearchVideo}' + $("#query").val(), 'videoSearch', 900, 950);
}
function fnSearchActress() {
	popup('${urlSearchActress}' + $("#query").val(), 'actressSearch', 900, 950);
}
function fnSearchTorrent() {
	popup('${urlSearchTorrent}' + $("#query").val(), 'torrentSearch', 900, 950);
}
</script>
</head>
<body>
<div class="container">

	<div id="header_div" class="box form-inline">
		<label for="search">
			<s:message code="video.video"/> <s:message code="video.search"/>
		</label>
		<input type="search" id="query" class="form-control input-sm" placeHolder="<s:message code="video.search"/>"/>
		<div class="btn-group">
				<a class="btn btn-xs btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"   ><s:message code="video.opus"/></a>
				<a class="btn btn-xs btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
				<a class="btn btn-xs btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>		
		<span id="url"></span>
		<span id="debug"></span>
	</div>
	
	<div id="content_div" class="row">
		<div class="col-lg-6">
			<div id="resultVideoDiv" class="box" style="overflow:auto">
				<h4><s:message code="video.video"/> <span id="video-count" class="badge"></span></h4>
				<ol id="foundVideoList" class="items"></ol>
			</div>
		</div>
		<div class="col-lg-6">		
			<div id="resultHistoryDiv" class="box" style="overflow:auto">
				<h4><s:message code="video.history"/> <span id="history-count" class="badge"></span></h4>
				<ol id="foundHistoryList" class="items"></ol>
			</div>
		</div>
	</div>

</div>
</body>
</html>