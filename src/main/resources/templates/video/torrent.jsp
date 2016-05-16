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
#searchInput {
	width:200px;
}
#currentVideo {
	margin: 5px;
	padding: 0; 
	font-size: 0.8em;
	display: none; 
	width: 100%; 
	background-color: rgb(231, 231, 120); 
	/* position: absolute; */ 
	/* top: 60px; */ 
	/* left: 0px; */ 
	/* z-index: 99; */
	/* height: 50px; */ 
	/* overflow: hidden;  */
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
		$("div#content_div input:text").each(function() {
			if ($(this).val().toLowerCase().indexOf(keyword.toLowerCase()) > -1)
				$(this).parent().parent().show();
			else
				$(this).parent().parent().hide();
		});
	});
});

/*
 * 선택된 토렌트 찾기
 */
function fnGoSearch(opus) {
	popup('<c:url value="/video/"/>' + opus + '/cover/title', 'SearchTorrentCover');
	popup('<c:url value="/video/torrent/search/"/>' + opus, 'torrentSearch', 900, 950);

	if (isHideClickedTorrentButton) { // 토렌트 찾기 모드일때, 숨기고, 선택된 비디오 이름 보여주기
		$("#check-" + opus + "-t").hide();
		$("#currentVideo").hide();
		$("#currentVideo").html($("#fullname-"+opus).val());
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

<div id="header_div" class="div-box">
	<ul class="menu-item-ul">
		<li class="label-large">
			<s:message code="video.torrent-summary" arguments="${fn:length(videoList)}"/><code id="totalCandidatedVideo"></code>
		</li>
		<li class="label-large">Mode
			<label><input type="radio" name="mode" onclick="fnChangeMode(MODE_CANDIDATED);" checked>File</label>
			<label><input type="radio" name="mode" onclick="fnChangeMode(MODE_TORRENT);">Torrent</label>
		</li>
		<li class="label-large">
			<input type="search" id="searchInput" class="searchInput" placeHolder="<s:message code="video.search"/>" />
		</li>
		<li class="label-large">
			<a onclick="confirmAll()">Confirm all!!!</a>
		</li>
	</ul>
</div>

<div id="content_div" class="div-box" style="overflow:auto;">
	<div id="forCandidate">
		<table class="video-table">
			<c:if test="${empty videoList}">
			<tr>
				<td>
					No Video
				</td>
			</tr>
			</c:if>
			<c:forEach items="${videoList}" var="video" varStatus="status">
			<tr id="check-${video.opus}" class="nowrap">
				<td class="number">
					${status.count}
				</td>
				<td class="label torrentButton" onclick="fnGoSearch('${video.opus}');">
					Torrent
				</td>
				<td>
					<input id="fullname-${video.opus}" value="${video.fullname}" class="text" style="width:600px;" onclick="fnViewVideoDetail('${video.opus}')" />
				</td>
				<td>
					<c:forEach items="${video.videoCandidates}" var="candidate">
					<form method="post" target="ifrm" action="<c:url value="/video/${video.opus}/confirmCandidate"/>">
						<input type="hidden" name="path" value="${candidate.absolutePath}"/>
						<input type="submit" value="${candidate.name}" onclick="fnSelectCandidateVideo('${video.opus}');"/>
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
		<p id="currentVideo" class="div-box"></p>
		<ul>
			<c:forEach items="${videoList}" var="video" varStatus="status">
			<li id="check-${video.opus}-t" style="display:inline;">
				<div class="label torrentButton" style="width:75px;" onclick="fnGoSearch('${video.opus}');">
					${video.opus}<br>Torrent
				</div>
			</li>
			</c:forEach>
		</ul>
	</div>
</div>

</body>
</html>
