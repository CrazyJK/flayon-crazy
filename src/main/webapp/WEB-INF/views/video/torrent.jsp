<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>

<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.torrent"/></title>
<style type="text/css">
#currentVideo {
	margin: 5px;
	font-size: 0.8em;
	display: none; 
}
.clicked {
	background-color: lightgreen;
}
</style>
<script type="text/javascript">
var totalCandidatedVideo = 0;
var MODE_TORRENT = 1;
var MODE_CANDIDATED = 2;
var isHideClickedTorrentButton = false;

$(document).ready(function(){
	$("#totalCandidatedVideo").html(totalCandidatedVideo);
	
	$("#searchInput").bind("keyup", function() {
		var keyword = $(this).val();
		$(".fullname").each(function() {
			if ($(this).text().toLowerCase().indexOf(keyword.toLowerCase()) > -1)
				$(this).parent().parent().parent().show();
			else
				$(this).parent().parent().parent().hide();
		});
	});
});

/*
 * 선택된 토렌트 찾기
 */
function goTorrentSearch(opus) {
	popup(videoPath + "/" + opus + '/cover/title', 'SearchTorrentCover');
	popup(videoPath + '/torrent/search/' + opus, 'torrentSearch', 900, 950);

	if (isHideClickedTorrentButton) { // 토렌트 찾기 모드일때, 숨기고, 선택된 비디오 이름 보여주기
		$("#check-" + opus + "-t").hide();
		$("#currentVideo").hide();
		$("#currentVideo").html($("#fullname-"+opus).text());
		$("#currentVideo").fadeIn('slow');
	}
	else { // 일반모드일대, 선택 마크
		fnMarkChoice(opus);
	}
	$("#check-" + opus).addClass("clicked");
}
/*
 * cadidate파일을 누르면, form에의해 submit되면서 숨기고, 카운트를 줄인다.
 */
function fnSelectCandidateVideo(opus) {
	$("#check-" + opus).hide();
	$("#totalCandidatedVideo").html(--totalCandidatedVideo);
}
function confirmAll() {
//	alert("Not working...");
	$("form input:submit").each(function() {
		$(this).click();
		$(this).parent().parent().parent().hide();
	}); 
}
/*
 * 보기 모드를 변경한다. 토렌트 찾기 모드와 cadidate선택 모드
 */
function fnChangeMode(mode) {
	if (mode == MODE_TORRENT) {
		isHideClickedTorrentButton = true;
		$("#forCandidate").hide();
		$("#forTorrent").show();
	}
	else if (mode == MODE_CANDIDATED) {
		isHideClickedTorrentButton = false;
		$("#forTorrent").hide();
		$("#forCandidate").show();
	}
}
</script>
</head>
<body>
<div class="container">

<div id="header_div" class="box form-inline">
	<s:message code="video.total"/> <s:message code="video.video"/> <span class="badge">${videoList.size()}</span> 
	Candidate <span class="badge" id="totalCandidatedVideo"></span>
	<label class="btn btn-xs btn-default"><input type="radio" name="mode" class="sr-only" onclick="fnChangeMode(MODE_CANDIDATED);" checked="checked"/>File</label>
	<label class="btn btn-xs btn-default"><input type="radio" name="mode" class="sr-only" onclick="fnChangeMode(MODE_TORRENT);"/>Torrent</label>
	<input id="searchInput" class="form-control input-sm" placeHolder="Search"/>
	<a onclick="confirmAll()">Confirm all!!!</a>
</div>

<div id="content_div" class="box" style="overflow:auto;">
	<div id="forCandidate">
		<table class="table table-condensed table-hover table-bordered">
			<c:if test="${empty videoList}">
			<tr>
				<td>
					No Video
				</td>
			</tr>
			</c:if>
			<c:forEach items="${videoList}" var="video" varStatus="status">
			<tr id="check-${video.opus}" class="nowrap">
				<td style="width: 40px;" class="text-right">
					${status.count}
				</td>
				<td style="width: 70px;">
					<button class="btn btn-xs btn-default" onclick="goTorrentSearch('${video.opus}');">Torrent</button>
				</td>
				<td style="min-width:450px; width:500px; max-width:600px;">
					<div class="nowrap">
						<small id="fullname-${video.opus}" class="text-primary" onclick="fnViewVideoDetail('${video.opus}')">${video.fullname}</small>
					</div>
				</td>
				<td>
					<c:forEach items="${video.videoCandidates}" var="candidate">
					<form method="post" target="ifrm" action="<c:url value="/video/${video.opus}/confirmCandidate"/>">
						<input type="hidden" name="path" value="${candidate.absolutePath}"/>
						<button type="submit" class="btn btn-xs btn-default" onclick="fnSelectCandidateVideo('${video.opus}');">${candidate.name}</button>
					</form>
					<script type="text/javascript">
						totalCandidatedVideo += 1;	
					</script>
					</c:forEach>
				</td>
			</tr>
			</c:forEach>
		</table>
	</div>
	
	<div id="forTorrent" style="display:none;">
		<div id="currentVideo" class="box"></div>
		<ul class="list-inline">
			<c:forEach items="${videoList}" var="video">
			<li id="check-${video.opus}-t"  class="box" style="width:80px;">
				<div class="nowrap text-center" onclick="goTorrentSearch('${video.opus}');">
					${video.opus}<br>Torrent
				</div>
			</li>
			</c:forEach>
		</ul>
	</div>
</div>

</div>
</body>
</html>
