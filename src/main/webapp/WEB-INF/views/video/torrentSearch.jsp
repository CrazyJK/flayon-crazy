<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"     tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.torrent"/> <s:message code="video.search"/> ${video.opus}</title>
<style type="text/css">
#coverDiv {
    position: absolute;
    top: 110px;
    right: 40px;
	width: 300px;
	height: 200px;
	display: block;
    z-index: 99;
    background-position: center center;
	background-size: contain;
	background-image: url("<c:url value="/video/${video.opus}/cover"/>");
}
#torrentFrame {
	width: 100%;
	height: 850px;
	border: 0;
	overflow: hidden;
}
</style>
<script type="text/javascript">
bgContinue = false;
//popup('<c:url value="/video/${video.opus}/cover/title"/>', 'SearchTorrentCover', 800, 600);
//window.open('<c:url value="/video/${video.opus}/cover/title"/>', 'SearchTorrentCover')
$(document).ready(function() {
	location.href = '${urlSearchTorrent}${video.opus}';
});
</script>
</head>
<body>

<div class="div-box">
	<h3>Image Popup</h3>
	<p>
		<a href='<c:url value="/video/${video.opus}/cover/title"/>' target="_blank"><c:url value="/video/${video.opus}/cover/title"/></a>
	</p>
</div>

<div class="div-box">
	<h3>Search Torrent</h3>
	<div>
		<a href='${urlSearchTorrent}${video.opus}' target="_blank">${urlSearchTorrent}${video.opus}</a>
	</div>
</div>	
	
<%-- 
<div id="header_div" class="div-box">
	<span style="font-size:12px;">${video.fullname}</span>
	<span class="button" onclick='$("#coverDiv").toggle();' style="float:right;">Cover</span>
</div>

<div id="coverDiv" class="div-box"></div>

<div id="content_div" class="div-box" style="overflow:hidden;">
	<iframe id="torrentFrame" src="${urlSearchTorrent}${video.opus}"></iframe>
</div>
 --%>
</body>
</html>
