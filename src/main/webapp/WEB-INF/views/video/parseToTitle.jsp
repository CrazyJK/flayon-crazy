<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" 	 uri="http://www.springframework.org/tags" %>

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
</style>
<script src="<c:url value="/js/zeroclipboard/ZeroClipboard.js"/>"></script>
<script type="text/javascript">
function fnFindVideo(opus) {
	fnMarkChoice(opus);
	popup('${urlSearchVideo}' + opus, 'videoSearch', 900, 950);
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

<form method="post" onsubmit="loading(true, 'Parsing...')">

	<div id="header_div" class="box form-inline">
		<a class="btn btn-xs btn-default" onclick="toggleInputDiv()" id="hideBtn">hide</a>
		<a class="btn btn-xs btn-default" onclick="document.forms[0].submit();">Parse <i class="badge">${titleList.size()}</i></a>	
		<input type="search" id="query" class="form-control input-sm" placeholder="Opus Actress Torrent"/>
		<div class="btn-group">
			<a class="btn btn-xs btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"><s:message code="video.opus"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>
	</div>

	<div id="content_div" class="box" style="overflow:auto;">
		<table id="resultList" style="width:100%;">
			<tr>
				<td id="inputTd" style="width:200px;">
					<div id="inputDiv" style="position:absolute; top:10px; left:10px; width:200px; padding-right: 5px;">
						<textarea id="titleData" name="titleData" class="titleArea" placeholder="input title data">${titleData}</textarea>
					</div>
				</td>
				<td>
					<table class="table table-condensed table-hover table-bordered">
						<c:if test="${empty titleList}">
						<tr>
							<td>
								No Video
							</td>
						</tr>
						</c:if>
						<c:forEach items="${titleList}" var="title" varStatus="status">
						<tr id="check-${title.opus}" style="font-size:0.9em;">
							<td class="text-right" width="10px">
								${status.count}
							</td>
							<td width="100px">
								<a class="btn btn-xs btn-default" id="copyBtn_${title.opus}" data-clipboard-target="dataTitle_${title.opus}" onclick="fnFindVideo('${title.opus}'); document.title='${title}'">
									Get Info 
									<c:if test="${title.check}"><mark>${title.checkDescShort}</mark></c:if>
								</a>
							</td>
							<td>
								<input id="dataTitle_${title.opus}" style="width:100%;" value="${title}"/>
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

</div>
</body>
</html>