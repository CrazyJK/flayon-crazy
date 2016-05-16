<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" 	 uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>

<!DOCTYPE html>
<html>
<head>
<title>Parse to Title</title>
<style type="text/css">
.titleArea {
	width:100%;
	height:100%;
	font-size:11px;
	opacity: 0.75;
}
code {
	margin: 0 5px;
	color: red;
}
</style>
<script src="<c:url value="/res/zeroclipboard/ZeroClipboard.js"/>"></script>
<script type="text/javascript">
function fnFindVideo(opus) {
	fnMarkChoice(opus);
	popup('<s:eval expression="@prop['url.search.video']"/>' + opus, 'videoSearch', 900, 950);
}
function resizeSecondDiv() {
	$("#inputDiv").outerHeight(calculatedDivHeight - 25);	
}
function toggleInputDiv() {
	$("#inputTd").toggle();
	if ($("#inputTd").css("display") == 'none') {
		$("#hideBtn").html("Show");
	}
	else {
		$("#hideBtn").html("Hide");
	}
}
function fnSearchOpus() {
	popup('<s:eval expression="@prop['url.search.video']"/>' + $("#query").val(), 'videoSearch', 900, 950);
}
function fnSearchActress() {
	popup('<s:eval expression="@prop['url.search.actress']"/>' + $("#query").val(), 'actressSearch', 900, 950);
}
function fnSearchTorrent() {
	popup('<s:eval expression="@prop['url.search.torrent']"/>' + $("#query").val(), 'torrentSearch', 900, 950);
}
</script>
</head>
<body>

<form method="post" onsubmit="loading(true, 'Parsing...')">

<div id="header_div" class="div-box">
	<ul class="menu-item-ul">
		<li class="label-large">
			<a onclick="toggleInputDiv()" id="hideBtn">hide</a>
		</li>
		<li class="label-large">
			<a onclick="document.forms[0].submit();">Parse(${fn:length(titleList)})</a>	
		</li>
		<li class="label-large">
			<input type="search" id="query" style="width:180px;" class="searchInput" placeholder="<s:message code="video.opus"/>, <s:message code="video.actress"/>, <s:message code="video.torrent"/>"/>
		</li>
		<li class="label-large">
			<a onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"   ><s:message code="video.opus"/></a>
		</li>
		<li class="label-large">
			<a onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
		</li>
		<li class="label-large">
			<a onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</li>
	</ul>
	<%-- 
		<textarea class="titleArea" placeholder="parsing result" readonly><c:forEach items="${titleList}" var="title" varStatus="status">${title}
		</c:forEach></textarea> 
	--%>
</div>

<div id="content_div" class="div-box" style="overflow:auto;">
	<table id="resultList" style="width:100%;">
		<tr>
			<td id="inputTd" style="width:300px;">
				<div id="inputDiv" style="position:absolute; top:80px; left:20px; width:300px;">
					<textarea id="titleData" name="titleData" class="titleArea" placeholder="input title data">${titleData}</textarea>
				</div>
			</td>
			<td>
				<table class="video-table">
					<c:if test="${empty titleList}">
					<tr>
						<td>
							No Video
						</td>
					</tr>
					</c:if>
					<c:forEach items="${titleList}" var="title" varStatus="status">
					<tr id="check-${title.opus}" style="font-size:11px; color:blue;">
						<td class="number" width="10px">
							${status.count}
						</td>
						<td width="80px">
							<span class="label">
							<a id="copyBtn_${title.opus}" data-clipboard-target="dataTitle_${title.opus}" onclick="fnFindVideo('${title.opus}'); document.title='${title}'">Get Info </a>
							<c:if test="${title.check}"><code>${title.checkDescShort}</code></c:if>
							</span>
						</td>
						<%-- <td>
							${title.studio}
						</td>
						<td>
							${title.opus}
						</td>
						<td>
							${title.title}
						</td>
						<td>
							${title.actress}
						</td>
						<td>
							${title.releaseDate}
						</td> --%>
						<td>
							<input id="dataTitle_${title.opus}" class="text" style="width:100%;" value="${title}"/>
						</td>
					</tr>
					<script type="text/javascript">new ZeroClipboard(document.getElementById("copyBtn_${title.opus}"));</script>
					</c:forEach>
				</table>
			</td>
		</tr>
	</table>
</div>

</form>

</body>
</html>