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
dt, dd {
	padding: 2px;
}
.fileinfoDiv {
	font-family: '나눔고딕코딩';
	background-color:rgba(255, 255, 255, 0.75); 
	border-radius: 10px;
}
.fileinfoDiv p {
	margin-bottom: 5px;
}
.dl-detail {
	overflow: auto; 
	margin: 0;
 	background-image: url('${PATH}/video/${video.opus}/cover');
	background-position: center top;
	background-attachment: fixed;
	background-repeat: no-repeat;
	background-size: 100%;
}
.dl-detail > dt.title {
	font-size: x-large;
}
.tag-wrapper {
	position: fixed; 
	bottom: 0; 
	text-align: center;
}
.popover {
	max-width: 700px;
}
body {
	background-image: linear-gradient(to right, rgb(255, 0, 0) 0, rgb(255, 255, 255) 100%);
}
</style>
<script type="text/javascript">
bgContinue = false;
$(document).ready(function() {
	$('[data-toggle="popover"]').popover(); 
	
	$(".label-etcfile").on("click", function() {
		var file = $(this).attr("data-file");
		restCall(PATH + '/rest/file/out', {method: "PUT", data: {"file": file}, title: "move subtitle to root"});
	});
});
function renameVideoName() {
	restCall(PATH + '/rest/video/${video.opus}/rename', {
		method: "PUT", data: $("form#renameForm").serialize(), title: "Rename video name"
	}, function() {
		location.reload();
	});
}
function resizeSecondDiv() {
	var _offsetMargin = 10;
	var _tagWrapperHeight = $(".tag-wrapper").outerHeight();
	var _windowOuterHeight = $(window).outerHeight();
	var _calculatedDivHeight = _windowOuterHeight - _tagWrapperHeight - _offsetMargin;
	console.log(_windowOuterHeight, _offsetMargin, _tagWrapperHeight, _calculatedDivHeight);
	$(".dl-detail").outerHeight(_calculatedDivHeight);
}
</script>
</head>
<body>
<div class="container-fluid">
	<dl class="dl-detail">
		<dt class="nowrap title"><jk:video video="${video}" view="title" mode="l"/></dt>
		<dd><jk:video video="${video}" view="rank"      mode="l"/></dd>
		<dd><jk:video video="${video}" view="score"     mode="l"/></dd>
		<dd><jk:video video="${video}" view="studio"    mode="l"/></dd>
		<dd><jk:video video="${video}" view="opus" 	    mode="l"/></dd>
		<dd><jk:video video="${video}" view="release"   mode="l"/></dd>
		<dd><jk:video video="${video}" view="download"  mode="l"/></dd>
		<dd><jk:video video="${video}" view="video"     mode="l"/></dd>
		<dd><jk:video video="${video}" view="cover"     mode="l"/></dd>
		<dd><jk:video video="${video}" view="subtitles" mode="l"/></dd>
		<dd><jk:video video="${video}" view="overview"  mode="l"/></dd>
		<dd><span class="label label-plain ${empty video.etcInfo ? 'hide' : ''}">ETC info : ${video.etcInfo}</span></dd>
		<dd><span class="label label-plain" onclick="$(this).next().toggleClass('hide')">Files <em id="filesize-${video.opus}"><fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.0# GB"/></em></span>
			<div class="box fileinfoDiv hide">
				<c:forEach items="${video.videoFileList}" var="file">
				<p class="video-file-p-${video.opus}"><span class="label label-info" onclick="opener.fnPlay('${video.opus}')">${file} <fmt:formatNumber value="${file.length()}" type="NUMBER"/></span></p>
				</c:forEach>
				<c:forEach items="${video.subtitlesFileList}" var="file">
				<p><span class="label label-danger" onclick="opener.fnEditSubtitles('${video.opus}')">${file} <fmt:formatNumber value="${file.length()}" type="NUMBER"/></span></p>
				</c:forEach>
				<p><span class="label label-success" onclick="opener.fnCoverView('${video.opus}')">${video.coverFilePath} <fmt:formatNumber value="${video.coverFile.length()}" type="NUMBER"/></span></p>
				<p><span class="label label-warning" title="${video.title}" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="${video.info}">${video.infoFilePath} <fmt:formatNumber value="${video.infoFile.length()}" type="NUMBER"/></span></p>
				<c:forEach items="${video.etcFileList}" var="file">
				<p><span class="label label-primary label-etcfile pointer" data-file="${file}" title="move to root">${file} <fmt:formatNumber value="${file.length()}" type="NUMBER"/></span></p>
				</c:forEach>
				<form id="renameForm" class="form-horizontal">
					<div class="form-group">
						<div class="col-sm-10">
							<input type="text" name="newname" value="${video.fullname}" class="form-control input-sm"/>
						</div>
						<div class="col-sm-2">
							<button class="btn btn-default btn-block btn-xs" onclick="renameVideoName()">Rename</button>
						</div>
					</div>
				</form>
			</div>
		</dd>
		<c:forEach items="${video.actressList}" var="actress">
			<c:if test="${actress.name ne 'Amateur'}">
				<dd>
					<jk:actress actress="${actress}" view="detail"/>
				</dd>
			</c:if>
		</c:forEach>
		<dd class="tag-wrapper"><jk:video video="${video}" view="tags" mode="l" tagList="${tagList}"/></dd>
	</dl>
</div>
</body>
</html>
