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
.mark {
	color: red;
}
#inputDiv {
	position: fixed; 
	top: 74px; 
	left: 18px; 
	width: 200px; 
	padding-right: 5px;
}
</style>
<script type="text/javascript">
function fnFindVideo(opus) {
	fnMarkChoice(opus);
	popup('${urlSearchVideo}' + opus, 'videoSearch', 900, 950);
}
function resizeSecondDiv() {
	$("#inputDiv").offset({top: $(".table").offset().top}).outerHeight(calculatedDivHeight - 25);
	//console.log("Top", $(".table").offset().top);
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
function saveCover(opus) {
	fnMarkChoice(opus);
	restCall(PATH + "/rest/video/" + opus + "/saveCover", {method: "POST", data: {title: $("#dataTitle_" + opus).val()}, title: 'save cover ' + opus});
}
function saveCoverAll() {
	$("#saveCoverAll").val(true);
	document.forms[0].submit();
}
</script>
</head>
<body>
<div class="container-fluid">

<form method="post" onsubmit="loading(true, 'Parsing...')">
	<input type="hidden" id="saveCoverAll" name="saveCoverAll" value="false"/> 
	<div id="header_div" class="box form-inline">
		<label class="title">
			ParseToTitle
		</label>
		<a class="btn btn-xs btn-default" onclick="toggleInputDiv()" id="hideBtn">hide</a>
		<a class="btn btn-xs btn-default" onclick="document.forms[0].submit();">Parse <span class="badge">${titleList.size()}</span></a>	
		<input type="search" id="query" class="form-control input-sm" placeholder="Opus Actress Torrent"/>
		<div class="btn-group">
			<a class="btn btn-xs btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"><s:message code="video.opus"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>
		<span id="debug"     class="label label-info"></span>
		<span id="searchURL" class="label label-info"></span>
		<div class="float-right">
			<a class="btn btn-xs btn-primary" onclick="saveCoverAll()">All Save</a>
		</div>
	</div>

	<div id="content_div" class="box" style="overflow:auto;">
		<table id="resultList" style="width:100%;">
			<tr>
				<td id="inputTd" style="width:200px;">
					<div id="inputDiv">
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
									Info
								</a>
								<c:if test="${title.check}"><mark class="text-danger">${title.checkDescShort}</mark></c:if>
								<c:if test="${!title.check}">
									<a class="btn btn-xs btn-primary" onclick="saveCover('${title.opus}')">Save</a>
								</c:if>
							</td>
							<td>
								<input id="dataTitle_${title.opus}" style="width:100%; font-size: 12px;" value="${title}"/>
							</td>
						</tr>
						<script type="text/javascript">
							var client_${status.count} = new ZeroClipboard(document.getElementById("copyBtn_${title.opus}"));
							client_${status.count}.on('ready', function(readyEvent) {
								/* console.log('ZeroClipboard SWF is ready', ${title.opus}); */
								client_${status.count}.on('aftercopy', function(event) {
									event.target.style.color = 'red';
									$("#check-${title.opus}").css('color', 'red');
									console.log('Copied text to clipboard: ' + event.data['text/plain'], '${title.opus}');
								});
							});
						</script>
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