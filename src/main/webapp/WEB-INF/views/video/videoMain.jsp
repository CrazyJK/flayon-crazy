<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"      uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form"   uri='http://www.springframework.org/tags/form'%>
<%@ taglib prefix="jk"     tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.video"/></title>
<link rel="stylesheet" href="<c:url value="/css/videoMain.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/ihover.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/js/videoMain.js"/>"></script>
<script type="text/javascript">
//bgContinue = false;
var opusArray = ${opusArray};
var bgImageCount = ${bgImageCount};
var totalVideoSize = parseInt('${fn:length(videoList)}');
var currentVideoIndex = getRandomInteger(1, totalVideoSize);
var listViewType = '${videoSearch.listViewType}';
var currBGImageUrl;

/** 바탕화면 보기 */
function fnViewBGImage() {
/* 	
	$("#contentContainer").slideToggle("slow");
	$("#content_div").toggleClass("box");
	$("#bgActionGroup").toggle();	
 */	
	$("#contentContainer").slideToggle({
		duration: 1000,
		start: function() {
			$("#bgActionGroup").toggle({
				duration: 1000,
				start: function() {
					$("#content_div").toggleClass("box");
				},
				complete: function() {
					loading(false);
				}
			});	
		},
		complete: function() {
		}
	});
}
</script>
</head>
<body>
<div class="container-fluid" role="main">

<div id="header_div" class="box">
	<form:form method="POST" commandName="videoSearch" role="form" class="form-inline" onsubmit="return false;">
	<div id="searchDiv">
		<!-- Search : Text -->
		<%-- <form:label path="searchText"><span title="<s:message code="video.search"/>">S</span></form:label> --%>
		<form:input path="searchText" cssClass="form-control input-sm" placeHolder="Search" style="width:120px;"/>
		<!-- Search : Additional condition. video, subtitles -->
		<label title="<s:message code="video.addCondition"/>">
			<form:checkbox path="addCond" cssClass="sr-only"/>
			<span class="label" id="checkbox-addCond1"><s:message code="video.addCondition-short"/></span>
		</label>
		<label title="<s:message code="video.existVideo"/>">
			<form:checkbox path="existVideo" cssClass="sr-only"/>
			<span class="label" id="checkbox-existVideo1">V</span>
		</label>
		<label title="<s:message code="video.existSubtitles"/>">
			<form:checkbox path="existSubtitles" cssClass="sr-only"/>
			<span class="label" id="checkbox-existSubtitles1">S</span>			
		</label>
		<!-- Search : rank -->
		<c:forEach items="${rankRange}" var="rank" varStatus="rankStat">
			<label title="<s:message code="video.rank"/> ${rank}">
				<form:checkbox path="rankRange" value="${rank}" cssClass="sr-only"/>
				<span class="label" id="checkbox-rankRange${rankStat.count}">${rank}</span>
			</label>
		</c:forEach>
		<!-- Search : play count -->
		<form:select path="playCount" items="${playRange}" cssClass="form-control input-sm" title="Play Count"/>
		<!-- Search submit -->			
		<button class="btn btn-xs btn-default" onclick="fnSearch()">
			<s:message code="video.search"/> <span class="badge">${fn:length(videoList)}</span>
		</button>
		<!-- view type -->
		<form:select path="listViewType" items="${views}" itemLabel="desc" cssClass="form-control input-sm" title="View type"/> 
		<!-- sort -->
		<label title="<s:message code="video.reverseSort"/>">
			<form:checkbox path="sortReverse" cssClass="sr-only"/>
			<span class="label" id="checkbox-sortReverse1">R</span>
		</label>
		<form:select path="sortMethod" items="${sorts}" itemLabel="desc" cssClass="form-control input-sm" title="Sort method" style="width:80px;"/>
		<!-- wholeActressStudioView -->
		<label title="<s:message code="video.wholeActressStudioView"/>">
			<form:checkbox path="wholeActressStudioView" cssClass="sr-only"/>
			<span class="label" id="checkbox-wholeActressStudioView1">A</span>
		</label>
		<!-- viewStudioPanel -->
		<label title="<s:message code="video.viewStudioPanel"/>">
			<form:checkbox path="viewStudioDiv" cssClass="sr-only"/>
			<span class="label" id="checkbox-viewStudioDiv1" onclick="fnStudioDivToggle()">S</span>
		</label>
		<!-- viewActressDiv -->
		<label title="<s:message code="video.viewActressPanel"/>">
			<form:checkbox path="viewActressDiv" cssClass="sr-only"/>
			<span class="label" id="checkbox-viewActressDiv1" onclick="fnActressDivToggle()">A</span>	
		</label>
		<!-- viewTagDiv -->
		<label title="<s:message code="video.viewTagPanel"/>">
			<form:checkbox path="viewTagDiv" cssClass="sr-only"/>
			<span class="label" id="checkbox-viewTagDiv1" onclick="fnTagDivToggle()">T</span>
		</label>
		<button class="btn btn-xs btn-default" onclick="fnViewBGImage();" title="<s:message code="video.bgimage.title"/>"><s:message code="video.bgimage"/></button>
		<%-- <button class="btn btn-xs btn-default" onclick="fnReloadVideoSource();" title="<s:message code="video.reload.title"/>"><s:message code="video.reload"/></button> --%>
		<button class="btn btn-xs btn-primary float-right" onclick="fnRandomPlay()" title="<s:message code="video.random-play.title"/>"><s:message code="video.random-play"/></button>

		<ul id="studioDiv" class="box list-inline" style="display:${videoSearch.viewStudioDiv ? '' : 'none'}">
			<li onclick="fnUnchecked(this)"><span class="badge">${fn:length(studioList)}</span></li>
			<c:forEach items="${studioList}" var="studio" varStatus="studioStat">
			<li>
				<jk:studio studio="${studio}" view="label" count="${studioStat.count}"/>
			</li>
			</c:forEach>
		</ul>
		<ul id="actressDiv" class="box list-inline" style="display:${videoSearch.viewActressDiv ? '' : 'none'}">
			<li onclick="fnUnchecked(this)"><span class="badge">${fn:length(actressList)}</span></li>
			<c:forEach items="${actressList}" var="actress" varStatus="actressStat">
			<li>
				<jk:actress actress="${actress}" view="label" count="${actressStat.count}"/>
			</li>
			</c:forEach>
		</ul>
		<ul id="tagDiv" class="box list-inline" style="display:${videoSearch.viewTagDiv ? '' : 'none'}">
			<li onclick="fnUnchecked(this)"><span class="badge">${fn:length(tagList)}</span></li>
			<c:forEach items="${tagList}" var="tag" varStatus="tagStat">
			<li>
				<jk:tags tag="${tag}" view="label" count="${tagStat.count}"/>
			</li>
			</c:forEach>
		</ul>
	</div>
	</form:form>
</div>

<div id="content_div" class="box">

	<div id="contentContainer">
	<c:choose>
		<c:when test="${videoSearch.listViewType eq 'C'}">
			<ul class="list-inline">
				<c:forEach items="${videoList}" var="video">
				<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
				</c:forEach>
			</ul>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'B'}">
			<ul class="list-inline text-center">
				<c:forEach items="${videoList}" var="video" varStatus="status">
				<li style="padding: 0 10px;">
					<div id="opus-${video.opus}" class="ih-item square colored top_to_bottom video-box-bg" style="width:400px; height:270px;"><a href="#">
	        			<div class="img"><img src="<c:url value="/video/${video.opus}/cover" />" alt="img"></div>
	        			<div class="info">
	          				<div class="info-back">
	            				<h3 class="nowrap"><jk:video video="${video}" view="title" mode="s"/></h3>
	            				<p>
		            				<jk:video video="${video}" view="studio" mode="s"/>
									<jk:video video="${video}" view="opus" mode="s"/><br/><br/>
									<jk:video video="${video}" view="actress" mode="s"/><br/><br/>
									<jk:video video="${video}" view="video" mode="s"/>
									<jk:video video="${video}" view="subtitles" mode="s"/>
									<jk:video video="${video}" view="overview" mode="s"/>
									<jk:video video="${video}" view="rank" mode="s"/>
									<jk:video video="${video}" view="score" mode="s"/>
								</p>
	          				</div>
	        			</div></a>
	        		</div>
        		</li>
				<%-- 
				<li>
					<div id="opus-${video.opus}" class="video-box">
						<dl class="video-box-bg" style="background-image:url('<c:url value="/video/${video.opus}/cover" />');">
							<dt class="nowrap"><jk:video video="${video}" view="title" mode="s"/></dt>
							<dd><jk:video video="${video}" view="studio" mode="s"/></dd>
							<dd><jk:video video="${video}" view="opus" mode="s"/></dd>
							<dd><jk:video video="${video}" view="actress" mode="s"/></dd>
							<dd><jk:video video="${video}" view="video" mode="s"/></dd>
							<dd><jk:video video="${video}" view="subtitles" mode="s"/></dd>
							<dd><jk:video video="${video}" view="overview" mode="s"/></dd>
							<dd><jk:video video="${video}" view="rank" mode="s"/></dd>
							<dd><jk:video video="${video}" view="score" mode="s"/></dd>
						</dl>
					</div>
				</li>
				 --%>
				</c:forEach>
			</ul>
			<script type="text/javascript">
			var _randomNumber = getRandomInteger(1, 15);
			$(".ih-item").each(function() {
				$(this).addClass("effect" + _randomNumber);
			});
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'T'}">
			<div class="wrapper" style="overflow-x: hidden;">
				<table id="list" class="table table-condensed table-hover table-bordered">
					<thead>
						<tr>
							<th>Studio</th>
							<th>Opus</th>
							<th>Title</th>
							<th>Actress</th>
							<th>Release</th>
							<th>V</th>
							<th>C</th>
							<th>S</th>
							<th>R</th>
							<th>S</th>
							<th>L</th>
						</tr>
					</thead>
					<tbody>
						<c:forEach items="${videoList}" var="video" varStatus="status">
							<tr id="opus-${video.opus}" class="nowarp">
								<td style="width:80px;">
									<div class="nowrap"><jk:video video="${video}" view="studio"/></div></td>
								<td style="width:80px;">
									<jk:video video="${video}" view="opus"/></td>
								<td style="max-width:200px;">
									<div class="nowrap"><span class="label label-plain" onclick="fnVideoDetail('${video.opus}')" title="${video.title}">${video.title}</span></div>
								</td>
								<td style="max-width:150px;">
									<%-- <div class="nowarp"><jk:video video="${video}" view="actress"/></div> --%>
									<div class="nowrap">
									<c:forEach items="${video.actressList}" var="actress">
										<span class="label label-plain" onclick="fnViewActressDetail('${actress.name}')">${actress.name}</span>
									</c:forEach>
									</div>
								</td>
								<td style="width:70px;">
									<jk:video video="${video}" view="release"/></td>
								<td style="width:20px;">
									<jk:video video="${video}" view="video" mode="s"/></td>
								<td style="width:20px;">
									<jk:video video="${video}" view="cover" mode="s"/></td>
								<td style="width:20px;">
									<jk:video video="${video}" view="subtitles" mode="s"/></td>
								<td style="width:25px;" class="text-right">
									<jk:video video="${video}" view="rank" mode="s"/></td>
								<td style="width:25px;" class="text-right">
									<jk:video video="${video}" view="score" mode="s"/></td>
								<td style="width:50px;" class="text-right">
									<jk:video video="${video}" view="length"/></td>
							</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>
			<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
			<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
			<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
			<script type="text/javascript">
			var table;
			$(document).ready(function() {
			    table = $('#list').DataTable({
			    	scrollY:        (calculatedDivHeight - 70),
			        scrollCollapse: true,
			        paging:         false,
			        searching: false,
			        processing: true,
			        info: false
			    });
			});
			
			function resizeSecondDiv() {
				table.draw();
			}
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'S'}">
			<div id="video-slide-wrapper">
				<div id="slides">
					<c:forEach items="${videoList}" var="video">
						<div id="opus-${video.opus}" class="slidesjs-slide" style="display:none;">
							<dl style="background-image:url('<c:url value="/video/${video.opus}/cover" />');">
								<dt class="nowrap"><jk:video video="${video}" view="title" mode="l"/></dt>
								<dt style="margin: 5px 0px 0px 0px; display: inline-flex;"><jk:video video="${video}" view="rank" mode="l"/></dt>
								<dd><jk:video video="${video}" view="score" mode="l"/></dd>
								<dd><jk:video video="${video}" view="studio" mode="l"/></dd>
								<dd><jk:video video="${video}" view="opus" mode="l"/></dd>
								<dd><jk:video video="${video}" view="actress" mode="l"/></dd>
								<dd><jk:video video="${video}" view="release" mode="l"/></dd>
								<dd><jk:video video="${video}" view="download" mode="l"/></dd>
								<dd><jk:video video="${video}" view="video" mode="l"/></dd>
								<dd><jk:video video="${video}" view="cover" mode="l"/></dd>
								<dd><jk:video video="${video}" view="subtitles" mode="l"/></dd>
								<dd><jk:video video="${video}" view="overview" mode="l"/></dd>
								<dd><jk:video video="${video}" view="tags" mode="l" tagList="${tagList}"/></dd>
							</dl>
						</div>
					</c:forEach>
				</div>
				<div style="position:fixed; right:20px; bottom:15px;"><a class="slidesjs-navigation slidesjs-random" href="#">Random View</a></div>
			</div>
			<link rel="stylesheet" href="<c:url value="/css/video-slides.css"/>"/>
			<script type="text/javascript" src="<c:url value="/js/jquery.slides.min.js"/>"></script>
			<script type="text/javascript" src="<c:url value="/js/jquery.crazy.slide.js"/>"></script>
			<script type="text/javascript">
				$("#slides").slideview();
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'V'}">
			<div id="video-slide-wrapper">
				<div id="slides">
				<c:forEach items="${videoList}" var="video">
					<div id="opus-${video.opus}" class="slidesjs-slide" style="display:none;">    
						<dl>
							<dt style="height:40px;padding-top:3px;">
								<jk:video video="${video}" view="studio"/>
								<jk:video video="${video}" view="opus"/>
								<jk:video video="${video}" view="title"/>
								<jk:video video="${video}" view="score"/>
								<jk:video video="${video}" view="actress"/>
								<br/>
								<jk:video video="${video}" view="video"/>
								<jk:video video="${video}" view="cover"/>
								<jk:video video="${video}" view="subtitles"/>
								<jk:video video="${video}" view="overview"/>
								<jk:video video="${video}" view="rank"/>
							</dt>
							<dd>
								<video poster="<c:url value="/video/${video.opus}/cover" />" 
									preload="none" width="800" height="480"
									controls="controls" class="video-js vjs-default-skin" data-setup="{}"
									src="<c:url value="${video.videoURL}" />"
									><%-- <source src="<c:url value="${video.videoURL}" />" type="video/mp4" ></source> --%></video>
							</dd>
							<dd><a href="<c:url value="${video.videoURL}" />">[<span class="label">${video.videoURL}</span>]</a></dd>
						</dl>				         
					</div>
				</c:forEach>
				</div>
			</div>
			<link rel="stylesheet" href="<c:url value="/css/video-slides.css"/>"/>
			<link rel="stylesheet" href="<c:url value="http://vjs.zencdn.net/c/video-js.css"/>"/>
			<script type="text/javascript" src="<c:url value="http://vjs.zencdn.net/c/video.js"/>"></script>
			<script type="text/javascript" src="<c:url value="/js/jquery.slides.min.js"/>"></script>
			<script type="text/javascript" src="<c:url value="/js/jquery.crazy.slide.js"/>"></script>
			<script type="text/javascript">
				$("#slides").slideview();
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'L'}">
			<div id="video-slide-wrapper">
				<div id="slides" style="display: block;">
				<c:forEach items="${videoList}" var="video" varStatus="status">
					<div id="opus-${video.opus}" tabindex="${status.count}" style="display:none; height: 550px;" class="slidesjs-slide">             
						<dl class="video-slide-bg" style="background-image:url('<c:url value="/video/${video.opus}/cover" />');">
							<dt class="nowrap"><jk:video video="${video}" view="title" mode="l"/></dt>
							<dt><jk:video video="${video}" view="rank" mode="l"/></dt>
							<dd><jk:video video="${video}" view="score" mode="l"/></dd>
							<dd><jk:video video="${video}" view="studio" mode="l"/></dd>
							<dd><jk:video video="${video}" view="opus" mode="l"/></dd>
							<dd><jk:video video="${video}" view="actress" mode="l"/></dd>
							<dd><jk:video video="${video}" view="download" mode="l"/>
							    <jk:video video="${video}" view="release" mode="l"/></dd>
							<dd><jk:video video="${video}" view="video" mode="l"/>
								<jk:video video="${video}" view="cover" mode="l"/>
								<jk:video video="${video}" view="subtitles" mode="l"/>
								<jk:video video="${video}" view="overview" mode="l"/></dd>
						</dl>
					</div>
				</c:forEach>
				</div>
				<div class="text-center"><span id="slideNumber" class="label label-plain"></span></div>
				<div id="video_slide_bar" class="text-center"></div>
			</div>
			<link rel="stylesheet" href="<c:url value="/css/video-slides.css"/>"/>
			<script type="text/javascript" src="<c:url value="/js/jquery.crazy.large.js"/>"></script>
			<script type="text/javascript">
				$("#slides").largeview();
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'F'}">
			<div id="video-slide-wrapper">
				<div id="slides">
					<c:forEach items="${videoList}" var="video">
						<div id="opus-${video.opus}" class="slidesjs-slide" style="display:none;">
							<dl class="box box-small" style="background-image:url('<c:url value="/video/${video.opus}/cover" />'); height: 520px;">
								<dt style="margin-top: 479px;">
									<div class="nowrap">
										<jk:video video="${video}" view="title" mode="l"/>
									</div>
								</dt>
							</dl>
							<div class="box box-small" style="background-color: rgba(218, 18, 18, 0.5);">
								<!-- <h4 style="margin:0;" class="form-inline"> -->
								<div style="margin:0;" class="form-inline">
									<jk:video video="${video}" view="rank" mode="l"/>
								</div>
								<!-- </h4> -->
								<h4><jk:video video="${video}" view="studio" mode="l"/>
									<jk:video video="${video}" view="opus" mode="l"/>
									<jk:video video="${video}" view="release" mode="l"/>
									<jk:video video="${video}" view="download" mode="l"/></h4>
								<h4><jk:video video="${video}" view="actress" mode="l"/></h4>
								<h5><jk:video video="${video}" view="score" mode="l"/>
									<jk:video video="${video}" view="video" mode="l"/>
									<jk:video video="${video}" view="cover" mode="l"/>
									<jk:video video="${video}" view="subtitles" mode="l"/>
									<jk:video video="${video}" view="overview" mode="l"/></h5>
								<div><jk:video video="${video}" view="tags" mode="l" tagList="${tagList}"/></div>
							</div>
						</div>
					</c:forEach>
				</div>
				<div style="position:fixed; right:20px; bottom:15px;"><a class="slidesjs-navigation slidesjs-random" href="#">Random View</a></div>
			</div>
			<link rel="stylesheet" href="<c:url value="/css/video-slides.css"/>"/>
			<script type="text/javascript" src="<c:url value="/js/jquery.slides.min.js"/>"></script>
			<script type="text/javascript" src="<c:url value="/js/jquery.crazy.slide.js"/>"></script>
			<script type="text/javascript">
				$("#slides").slideview({width:800, height:750});
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'A'}">
			<ol class="list-inline text-center">
				<c:forEach items="${videoList}" var="video">
				<li style="padding: 10px;">
					<div id="aperture_${video.opus}" style="width:200px; height: 137px;"></div>
				</li>
				<script type="text/javascript">
				$("#aperture_${video.opus}")
				.attr("onclick", "fnVideoDetail('${video.opus}')")
				.aperture({
					src:"<c:url value="/video/${video.opus}/cover" />",
					baseColor: randomColor(0.5),
					outerMargin: "10 auto",
					width: "200px;",
					height: "137px"
				});
				</script>
				</c:forEach>
			</ol>
		</c:when>
		<c:otherwise>
		</c:otherwise>
	</c:choose>
	</div>

</div>

</div>
</body>
</html>