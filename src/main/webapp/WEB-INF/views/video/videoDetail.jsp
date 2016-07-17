<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"	uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"	uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt"	uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="s"	uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"	tagdir="/WEB-INF/tags"%>
<c:set var="ONE_GB" value="${1024*1024*1024}"/>
<!DOCTYPE html>
<html>
<head>
<title>[${video.opus}] ${video.title}</title>
<link rel="stylesheet" href="<c:url value="/css/videoMain.css"/>"/>
<style type="text/css">
#fileinfoDiv .label {
	font-family: '나눔고딕코딩';
}
</style>
<script type="text/javascript">
bgContinue = false;
$(document).ready(function() {
	$("body")
		.css("background-image","url('<c:url value="/video/${video.opus}/cover" />')")
		.css("background-size", "100%")
		.css("background-position", "left top");

});
function fnToggleRenameForm() {
	$("#renameForm").toggle();
}
function fnToggleFileinfo() {
	$("#fileinfoDiv").toggle();
}
</script>
</head>
<body>
<div class="container-fluid">
<c:set var="opus" value="${video.opus}"/>

<dl class="dl-detail">
	<dt style="font-size: x-large;"><jk:video video="${video}" view="title"     mode="l"/></dt>
	<dt class="form-inline"><jk:video video="${video}" view="rank" mode="l"/></dt>
	<dd><jk:video video="${video}" view="score"     mode="l"/></dd>
	<dd><jk:video video="${video}" view="studio"    mode="l"/></dd>
	<dd><jk:video video="${video}" view="opus" 	    mode="l"/></dd>
	<dd><jk:video video="${video}" view="release"   mode="l"/></dd>
	<dd><jk:video video="${video}" view="download"  mode="l"/></dd>
	<dd><jk:video video="${video}" view="video"     mode="l"/></dd>
	<dd><jk:video video="${video}" view="cover"     mode="l"/></dd>
	<dd><jk:video video="${video}" view="subtitles" mode="l"/></dd>
	<dd><jk:video video="${video}" view="overview"  mode="l"/></dd>

	<c:if test="${video.etcInfo ne ''}">
	<dd><span class="label label-plain">ETC info : ${video.etcInfo}</span></dd>
	</c:if>

	<dd><span class="label label-plain" onclick="fnToggleFileinfo()">Files <em><fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0 GB"/></em></span>
		<div id="fileinfoDiv" style="display:none; background-color:rgba(255, 255, 255, 0.75); border-radius: 10px;" class="box">
			<c:forEach items="${video.videoFileList}" var="file">
			<p><span class="label label-info" onclick="opener.fnPlay('${video.opus}')">${file}</span></p>
			</c:forEach>
			<c:forEach items="${video.subtitlesFileList}" var="file">
			<p><span class="label label-danger" onclick="opener.fnEditSubtitles('${video.opus}')">${file}</span></p>
			</c:forEach>
			<p><span class="label label-success" onclick="opener.fnCoverView('${video.opus}')">${video.coverFilePath}</span></p>
			<p><span class="label label-warning" title="${video.info}" data-toggle="tooltip">${video.infoFilePath}</span></p>
			<c:forEach items="${video.etcFileList}" var="file">
			<p><span class="label label-primary">${file}</span></p>
			</c:forEach>
			<form id="renameForm" method="post" action="<s:url value="/video/${video.opus}/rename"/>" target="ifrm" role="form" class="form-horizontal">
				<div class="form-group">
					<div class="col-sm-10">
						<input type="text" name="newname" value="${video.fullname}" class="form-control input-sm"/>
					</div>
					<div class="col-sm-2">
						<input type="submit" value="rename" class="btn btn-default btn-sm"/>
					</div>
				</div>
			</form>
		</div>
	</dd>

	<dd><jk:video video="${video}" view="tags" mode="l" tagList="${tagList}"/></dd>
	
	<c:forEach items="${video.actressList}" var="actress">
	<dd class="box">
		<jk:actress actress="${actress}" view="detail"/>
		<div class="form-group text-center">
			<ul class="list-inline">
				<c:forEach items="${actress.videoList}" var="video">
					<c:choose>
						<c:when test="${video.opus != opus }">
							<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
						</c:when>
					</c:choose>
				</c:forEach>
			</ul>
		</div>
	</dd>
	</c:forEach>
</dl>

</div>
</body>
</html>
