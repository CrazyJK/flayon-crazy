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
}
.tag-wrapper {
	position: fixed; 
	bottom: 0; 
	text-align: center;
}
.popover {
	max-width: 700px;
}

</style>
<script type="text/javascript">
bgContinue = false;
var thisWidth = $(this).width();
$(document).ready(function() {

	$("body").css({
		backgroundImage: "url('<c:url value="/video/${video.opus}/cover" />')",
		backgroundSize: thisWidth + "px",
		backgroundPosition: "center top",
		backgroundAttachment: "fixed",
		backgroundRepeat: "no-repeat",
		backgroundColor: randomColor(0.5)
	});
	
	$("form#renameForm").submit(function(event) {
		console.log("form submit...");
		loading(true, "rename...");
		setInterval(function() {
			location.reload();
		}, 1000);
	});

	$('[data-toggle="popover"]').popover(); 
		
});
function fnVideoToggle(dom) {
	$(dom).next().next().toggleClass("hide");
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

	<c:if test="${!empty video.etcInfo}">
	<dd><span class="label label-plain">ETC info : ${video.etcInfo}</span></dd>
	</c:if>

	<dd>
		<span class="label label-plain" onclick="$(this).next().toggleClass('hide')">Files <em><fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.0# GB"/></em></span>
		<div class="box fileinfoDiv hide">
			<c:forEach items="${video.videoFileList}" var="file">
			<p><span class="label label-info" onclick="opener.fnPlay('${video.opus}')">${file}</span></p>
			</c:forEach>
			<c:forEach items="${video.subtitlesFileList}" var="file">
			<p><span class="label label-danger" onclick="opener.fnEditSubtitles('${video.opus}')">${file}</span></p>
			</c:forEach>
			<p><span class="label label-success" onclick="opener.fnCoverView('${video.opus}')">${video.coverFilePath}</span></p>
			<p><span class="label label-warning" title="${video.title}" data-toggle="popover" data-placement="bottom" data-trigger="hover" data-content="${video.info}">${video.infoFilePath}</span></p>
			<c:forEach items="${video.etcFileList}" var="file">
			<p><span class="label label-primary">${file}</span></p>
			</c:forEach>
			<form id="renameForm" method="post" action="<s:url value="/video/${video.opus}/rename"/>" target="ifrm" role="form" class="form-horizontal">
				<div class="form-group">
					<div class="col-sm-10">
						<input type="text" name="newname" value="${video.fullname}" class="form-control input-sm"/>
					</div>
					<div class="col-sm-2">
						<input type="submit" value="rename" class="btn btn-default btn-block btn-xs"/>
					</div>
				</div>
			</form>
		</div>
	</dd>
	
	<c:forEach items="${video.actressList}" var="actress">
		<c:if test="${actress.name ne 'Amateur'}">
			<dd>
				<jk:actress actress="${actress}" view="detail"/>
				<div class="form-group text-center box hide">
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
		</c:if>
	</c:forEach>
	
	<dd class="tag-wrapper"><jk:video video="${video}" view="tags" mode="l" tagList="${tagList}"/></dd>
	
</dl>

</div>
</body>
</html>
