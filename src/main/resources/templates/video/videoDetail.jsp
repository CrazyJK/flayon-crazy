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
<style type="text/css">
dl {
	background-color: rgba( 255, 255, 255, 0.5 );
}
</style>
<script type="text/javascript">
$(document).ready(function() {
	$("body").css("background-image","url('<c:url value="/video/${video.opus}/cover" />')");
//	$("body").css("background-size", "cover");
//	$("#renameForm").hide();
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
<c:set var="opus" value="${video.opus}"/>

<dl class="dl-detail">
	<dt><jk:video video="${video}" view="title" mode="l"/>
		<jk:video video="${video}" view="score" mode="l"/>
		<br/>
		<jk:video video="${video}" view="rank" mode="l"/>
	</dt>

	<dd><jk:video video="${video}" view="studio" mode="l"/></dd>
	<dd><jk:video video="${video}" view="opus" mode="l"/></dd>
	<dd><jk:video video="${video}" view="release" mode="l"/></dd>
	<dd><jk:video video="${video}" view="download" mode="l"/></dd>

	<c:if test="${video.etcInfo ne ''}">
	<dd><span class="label-large">ETC info : ${video.etcInfo}</span></dd>
	</c:if>
	<%-- 
	<dd><span class="label" onclick="fnToggleRenameForm()">Rename</span>
		<form id="renameForm" method="post" action="<s:url value="/video/${video.opus}/rename"/>" target="ifrm">
			<input type="text" name="newname" value="${video.fullname}" style="width:600px; background-color:rgba(255,255,255);" class="text"/>
			<input type="submit" value="rename" class="text"/>
		</form>
	</dd>
	 --%>
	<dd><span class="label-large" onclick="fnToggleFileinfo()">Files <em><fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0 GB"/></em></span>
		<div id="fileinfoDiv" style="display:none; background-color:white; border-radius: 10px;" class="">
			<ul>
				<li><span class="label" onclick="opener.fnPlay('${video.opus}')" title="VIDEO ">${video.videoFileListPath}</span>
				<li><span class="label" title="COVER" onclick="opener.fnImageView('${video.opus}')">${video.coverFilePath}</span>
				<li><span class="label" title="INFO">${video.infoFilePath}</span>
				
				<c:if test="${video.subtitlesFileListPath ne ''}">
				<li><span class="label" onclick="opener.fnEditSubtitles('${video.opus}')" title="SMI">${video.subtitlesFileListPath}</span>
				</c:if>
	
				<c:if test="${video.etcFileListPath ne ''}">
				<li><div  class="label" title="ETC"> : ${video.etcFileListPath}</div>
				</c:if>
				<li><form id="renameForm" method="post" action="<s:url value="/video/${video.opus}/rename"/>" target="ifrm" style="padding:0 0 3px 5px;">
					<input type="text" name="newname" value="${video.fullname}" style="width:750px; background-color:rgba(255,255,255);" class="text"/>
					<input type="submit" value="rename" class="text"/>
					</form>
				
			</ul>
		</div>
	</dd>
	
	<c:if test="${video.overviewText ne ''}">
	<dd><pre  class="label-large" onclick="opener.fnEditOverview('${video.opus}')" >${video.overviewText}</pre></dd>
	</c:if>
	
	<dd>
		<c:forEach items="${video.actressList}" var="actress">
		<span class="label-large actressSpan" onclick="fnViewActressDetail('${actress.name}')">
			${actress.name} <em>${actress.age}</em> (${fn:length(actress.videoList)}), Score ${actress.score}</span>
		<div style="padding-left:60px;">
			<ul>
			<c:forEach items="${actress.videoList}" var="video">
				<c:choose>
					<c:when test="${video.opus != opus }">
						<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
					</c:when>
				</c:choose>
			</c:forEach>
			</ul>
		</div>
		</c:forEach>
	</dd>
</dl>
</body>
</html>
