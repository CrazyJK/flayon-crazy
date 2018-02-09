<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>
<%@ taglib prefix="jk"   tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.video"/></title>
<script type="text/javascript">
var opusArray = ${opusArray};
var bgImageCount = ${bgImageCount};
var totalVideoSize = parseInt('${fn:length(videoList)}');
var currentVideoIndex = getRandomInteger(1, totalVideoSize);
var currBGImageUrl;
listViewType = '${videoSearch.listViewType}';
</script>
</head>
<body>
<div class="container-fluid" role="main">

<div id="header_div" class="box">
	<form:form method="POST" commandName="videoSearch" role="form" class="form-inline" onsubmit="return false;">
	<div id="searchDiv" class="text-center">
		<!-- Search : Text -->
		<%-- <form:label path="searchText"><span title="<s:message code="video.search"/>">S</span></form:label> --%>
		<form:input path="searchText" cssClass="form-control input-sm search" placeHolder="Search" style="width:120px;"/>
		<!-- Search : Additional condition. video, subtitles, cover -->
		<label title="<s:message code="video.existVideo"/>">
			<form:checkbox path="existVideo" cssClass="sr-only"/>
			<span class="label" id="checkbox-existVideo1">V</span>
		</label>
		<label title="<s:message code="video.existSubtitles"/>">
			<form:checkbox path="existSubtitles" cssClass="sr-only"/>
			<span class="label" id="checkbox-existSubtitles1">VS</span>			
		</label>
		<label title="<s:message code="video.existCover"/>">
			<form:checkbox path="existCover" cssClass="sr-only"/>
			<span class="label" id="checkbox-existCover1">C</span>			
		</label>
		<label title="<s:message code="video.favorite"/>">
			<form:checkbox path="favorite" cssClass="sr-only"/>
			<span class="label" id="checkbox-favorite1">F</span>			
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
		<!-- Play -->
		<a class="btn btn-xs btn-primary float-right" onclick="fnRandomPlay()" title="<s:message code="video.random-play.title"/>"><s:message code="video.random-play"/></a>

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

	<div id="contentContainer" style="overflow-x: hidden;">
	<c:choose>
		<c:when test="${videoSearch.listViewType eq 'C'}">
			<ul class="list-inline text-center">
				<c:forEach items="${videoList}" var="video">
				<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
				</c:forEach>
			</ul>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'B'}">
			<ul class="list-inline text-center">
				<c:forEach items="${videoList}" var="video" varStatus="status">
				<li>
					<div id="opus-${video.opus}" class="video-box">
						<dl style="background-image:url('${PATH}/video/${video.opus}/cover');">
							<dt class="nowrap"><jk:video video="${video}" view="title" mode="s"/></dt>
							<dd><jk:video video="${video}" view="studio"    mode="s"/></dd>
							<dd><jk:video video="${video}" view="opus"      mode="s"/></dd>
							<dd><jk:video video="${video}" view="actress"   mode="s"/></dd>
							<dd><jk:video video="${video}" view="video"     mode="s"/></dd>
							<dd><jk:video video="${video}" view="subtitles" mode="s"/></dd>
							<dd><jk:video video="${video}" view="overview"  mode="s"/></dd>
							<dd><jk:video video="${video}" view="rank"      mode="s"/>
								<jk:video video="${video}" view="score"     mode="s"/></dd>
						</dl>
					</div>
				</li>
				</c:forEach>
			</ul>
			<script type="text/javascript">
			// Add listener : video box click. set active
			$("div[id^='opus-']").click(function() {
				$(this).toggleClass("active");
			});
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'IH'}">
			<ul class="list-inline text-center">
				<c:forEach items="${videoList}" var="video" varStatus="status">
				<li style="margin:5px;">
					<div id="opus-${video.opus}" class="ih-item square colored top_to_bottom" style="width:400px; height:269px;">
						<div>
		        			<div class="img"><img class="lazy" src="${PATH}/video/${video.opus}/cover" style="height:253px;"></div>
	    	    			<div class="info">
	            				<h3 class="nowrap"><jk:video video="${video}" view="title" mode="s"/></h3>
	            				<div>
		            				<jk:video video="${video}" view="studio"    mode="s"/>
									<jk:video video="${video}" view="opus"      mode="s"/><br/><br/>
									<jk:video video="${video}" view="actress"   mode="s"/><br/><br/>
									<jk:video video="${video}" view="video"     mode="s"/>
									<jk:video video="${video}" view="subtitles" mode="s"/>
									<jk:video video="${video}" view="overview"  mode="s"/>
									<jk:video video="${video}" view="rank"      mode="s"/>
									<jk:video video="${video}" view="score"     mode="s"/>
								</div>
		        			</div>
		        		</div>
	        		</div>
        		</li>
				</c:forEach>
			</ul>
			<link rel="stylesheet" href="${PATH}/css/ihover.css"/>
			<script type="text/javascript">
			$(".ih-item").each(function() {
				var _randomNumber = getRandomInteger(1, 15);
				$(this).addClass("effect" + _randomNumber);
			});
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'T'}">
			<div class="wrapper">
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
			<link rel="stylesheet" href="${PATH}/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>
			<script type="text/javascript" src="${PATH}/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"></script>
			<script type="text/javascript" src="${PATH}/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"></script>
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
							<dl style="background-image:url('${PATH}/video/${video.opus}/cover');">
								<dt class="nowrap"><jk:video video="${video}" view="title" mode="l"/></dt>
								<dd><jk:video video="${video}" view="rank"      mode="l"/></dd>
								<dd><jk:video video="${video}" view="score"     mode="l"/></dd>
								<dd><jk:video video="${video}" view="studio"    mode="l"/></dd>
								<dd><jk:video video="${video}" view="opus"      mode="l"/></dd>
								<dd><jk:video video="${video}" view="release"   mode="l"/></dd>
								<dd><jk:video video="${video}" view="download"  mode="l"/></dd>
								<dd><jk:video video="${video}" view="video"     mode="l"/></dd>
								<dd><jk:video video="${video}" view="cover"     mode="l"/></dd>
								<dd><jk:video video="${video}" view="subtitles" mode="l"/></dd>
								<dd><jk:video video="${video}" view="overview"  mode="l"/></dd>
								<dd><jk:video video="${video}" view="actress"   mode="f"/></dd>
								<dd>
									<span class="label label-plain" onclick="$('.tags-${video.opus}').toggleClass('hide');">
										Tags<i class="caret"></i>
									</span>
								</dd>
								<dd class="hide tags-${video.opus}">
									<small><jk:video video="${video}" view="tags" mode="l" tagList="${tagList}"/></small>
								</dd>
							</dl>
						</div>
					</c:forEach>
				</div>
				<div style="position:fixed; right:20px; bottom:15px;"><a class="slidesjs-navigation slidesjs-random" href="#">Random View</a></div>
			</div>
			<link rel="stylesheet" href="${PATH}/css/video-slides.css"/>
			<script type="text/javascript" src="${PATH}/js/jquery.slides.min.js"></script>
			<script type="text/javascript" src="${PATH}/js/crazy.video.main.slide.js"></script>
			<script type="text/javascript">
			totalVideoSize > 0 && $("#slides").slideview();
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'V'}">
			<div id="video-slide-wrapper">
				<div id="slides">
				<c:forEach items="${videoList}" var="video">
					<div id="opus-${video.opus}" class="slidesjs-slide" style="display:none;">    
						<video poster="${PATH}/video/${video.opus}/cover" src="<c:url value="${video.videoURL}" />"
							preload="none" width="800" height="540" controls="controls" class="video-js vjs-default-skin" data-setup="{}"
							><%-- <source src="<c:url value="${video.videoURL}" />" type="video/mp4" ></source> --%>
						</video>
						<div class="box box-small">
							<h3 class="nowrap" style="margin:0 0 5px; height:30px;">
								<jk:video video="${video}" view="title"/>
							</h3>
								<jk:video video="${video}" view="rank"      mode="l"/>
							<h4><jk:video video="${video}" view="studio"    mode="l"/>
								<jk:video video="${video}" view="opus"      mode="l"/>
								<jk:video video="${video}" view="release"   mode="l"/>
								<jk:video video="${video}" view="download"  mode="l"/>
								<a class="label label-plain" href="<c:url value="${video.videoURL}"/>" title="${video.videoURL}">
									<span class="glyphicon glyphicon-download-alt"></span></a></h4>
							<h4><jk:video video="${video}" view="actress"   mode="f"/></h4>
							<h5><jk:video video="${video}" view="score"     mode="l"/>
								<jk:video video="${video}" view="video"     mode="l"/>
								<jk:video video="${video}" view="cover"     mode="l"/>
								<jk:video video="${video}" view="subtitles" mode="l"/>
								<jk:video video="${video}" view="overview"  mode="l"/></h5>
							<div><jk:video video="${video}" view="tags"     mode="l" tagList="${tagList}"/></div>
						</div>
					</div>
				</c:forEach>
				</div>
			</div>
			<link rel="stylesheet" href="${PATH}/css/video-slides.css"/>
			<link rel="stylesheet" href="<c:url value="http://vjs.zencdn.net/c/video-js.css"/>"/>
			<script type="text/javascript" src="<c:url value="http://vjs.zencdn.net/c/video.js"/>"></script>
			<script type="text/javascript" src="${PATH}/js/jquery.slides.min.js"></script>
			<script type="text/javascript" src="${PATH}/js/crazy.video.main.slide.js"></script>
			<script type="text/javascript">
				function resizeSecondDiv() {
					var flayonSlideHeight = calculatedDivHeight - 100;
					$("#slides").slideview({width:800, height:flayonSlideHeight});
				}

			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'L'}">
			<div id="video-slide-wrapper">
				<table style="width: 100%; max-width: 100%;">
					<tbody style="vertical-align: top;">
					<tr>
						<td>
							<div class="prevCover text-right"></div>
						</td>
						<td style="width:800px;">
							<div id="slides" style="display: block;">
							<c:forEach items="${videoList}" var="video" varStatus="status">
								<div id="opus-${video.opus}" tabindex="${status.count}" style="display:none;" class="slidesjs-slide">             
									<dl class="box box-cover" style="background-image:url('${PATH}/video/${video.opus}/cover'); height: 530px; margin: 6px;">
										<dt class="nowrap" style="height:510px;">
											<span class="label label-plain video-title" title="${video.title}" onclick="fnVideoDetail('${video.opus}')" 
												style="writing-mode:vertical-rl; padding:10px 10px; margin:5px auto; text-shadow: 0px 0px 5px #0c0c0c; color: #fff; font-weight: 700; background: rgba(51, 122, 183, .5)">${video.title}</span>
										</dt>
									</dl>
									<div class="box box-small box-detail">
										<h3 class="nowrap" style="margin:0 0 5px; height:30px;">
											<jk:video video="${video}" view="title"/>
										</h3>
											<jk:video video="${video}" view="rank"      mode="l"/>
										<h4><jk:video video="${video}" view="studio"    mode="l"/>
											<jk:video video="${video}" view="opus"      mode="l"/>
											<jk:video video="${video}" view="release"   mode="l"/>
											<jk:video video="${video}" view="download"  mode="l"/></h4>
										<h5><jk:video video="${video}" view="score"     mode="l"/>
											<jk:video video="${video}" view="video"     mode="l"/>
											<jk:video video="${video}" view="cover"     mode="l"/>
											<jk:video video="${video}" view="subtitles" mode="l"/>
											<jk:video video="${video}" view="overview"  mode="l"/></h5>
										<h4 style="margin-bottom:0;">
											<jk:video video="${video}" view="actress"   mode="f"/></h4>
									   <div><jk:video video="${video}" view="tags"      mode="l" tagList="${tagList}"/></div>
									</div>
								</div>
							</c:forEach>
							</div>
						</td>
						<td>
							<div class="nextCover text-left"></div>
						</td>
					</tr>
					</tbody>
				</table>
				<div class="text-center" style="position: fixed; bottom: 0; width: 100%; left: 0;">
					<ul class="pagination text-center">
					  	<li><a href="#">1</a></li>
					  	<li><a href="#">2</a></li>
					  	<li><a href="#">3</a></li>
					  	<li><a href="#">4</a></li>
					  	<li><a href="#">5</a></li>
					</ul>
				</div>
				<div style="position:fixed; right:20px; bottom:25px;" data-lazy-class="w3-animate-right, 1000" class="hide">
					<a id="randomViewBtn" class="btn-random-view">Random View</a>
				</div>
			</div>
			<link rel="stylesheet" href="${PATH}/css/video-slides.css"/>
			<link rel="stylesheet" href="${PATH}/css/videoMain.large.css"/>
			<script type="text/javascript" src="${PATH}/js/crazy.video.main.large.js"></script>
			<script type="text/javascript">
				$("#slides").largeview();
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'F'}">
			<div id="video-slide-wrapper">
				<div id="slides">
					<c:forEach items="${videoList}" var="video" varStatus="status">
						<div id="opus-${video.opus}" class="slidesjs-slide" style="display:none;" data-index="${status.index}">
							<dl class="box box-small box-cover" style="background-image:url('${PATH}/video/${video.opus}/cover'); height: 520px; padding: 0;">
								<dt class="nowrap" style="height: inherit;">
									<span class="label video-title_v" title="${video.title}" onclick="fnVideoDetail('${video.opus}')">${video.title}</span>
								</dt>
							</dl>
							<div class="box box-small box-detail" style="margin-top: 15px;">
								<h3 class="nowrap" style="margin:0 0 5px; height:33px;">
									<jk:video video="${video}" view="title"/>
								</h3>
								<div><jk:video video="${video}" view="rank"      mode="l"/></div>
								<h4><jk:video video="${video}" view="studio"    mode="l"/>
									<jk:video video="${video}" view="opus"      mode="l"/>
									<jk:video video="${video}" view="release"   mode="l"/>
									<jk:video video="${video}" view="download"  mode="l"/></h4>
								<h5><jk:video video="${video}" view="score"     mode="l"/>
									<jk:video video="${video}" view="video"     mode="l"/>
									<jk:video video="${video}" view="cover"     mode="l"/>
									<jk:video video="${video}" view="subtitles" mode="l"/>
									<jk:video video="${video}" view="overview"  mode="l"/></h5>
								<h4 style="margin-bottom:0;">
									<jk:video video="${video}" view="actress"   mode="f"/></h4>
							   <div><jk:video video="${video}" view="tags"      mode="l" tagList="${tagList}"/></div>
							</div>
						</div>
					</c:forEach>
				</div>
				<div style="position:fixed; right:20px; bottom:15px; display:none;" data-lazy-class="w3-animate-zoom, 500">
					<a class="slidesjs-navigation slidesjs-random" href="#">Random View</a>
				</div>
			</div>
			<link rel="stylesheet" href="${PATH}/css/video-slides.css"/>
			<link rel="stylesheet" href="${PATH}/css/app/video/videoMain.flay.css"/>
			<script type="text/javascript" src="${PATH}/js/jquery.slides.min.js"></script>
			<script type="text/javascript" src="${PATH}/js/crazy.video.main.slide.js"></script>
			<script type="text/javascript">
			totalVideoSize > 0 && $("#slides").slideview({width:800, height:700});
			function resizeSecondDiv() {
				var slidesjsContainerCss = {height: calculatedDivHeight - $(".slidesjs-pagination").outerHeight() - 30};
				console.log("Flay slidesjsContainerCss", slidesjsContainerCss);
				$("#slides > .slidesjs-container").css(slidesjsContainerCss);
			}
			</script>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'A'}">
			<ul class="list-inline text-center">
				<c:forEach items="${videoList}" var="video">
				<li style="padding: 10px;">
					<div id="aperture_${video.opus}"></div>
				</li>
                <script type="text/javascript" src="${PATH}/js/flayon.effect.aperture.js"></script>
				<script type="text/javascript">
				$("#aperture_${video.opus}")
					.attr("onclick", "fnVideoDetail('${video.opus}')")
					.aperture({
						src:"${PATH}/video/${video.opus}/cover",
						baseColor: getRandomColor(0.5),
						outerMargin: "0 auto",
						width: "200px",
						height: "134px",
						content: '${video.title}',
						innerCirclePadding: "5px",
						outerRadius: "0",
						//borderRadius: "50%"
					});
				</script>
				</c:forEach>
			</ul>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'K'}">
			<link rel="stylesheet" href="${PATH}/css/videoMain.jk.css"/>
			<script type="text/javascript" src="${PATH}/js/crazy.video.main.jk.js"></script>
			<div class="jk-video-wrapper" style="visibility:hidden;" data-lazy-class="w3-animate-opacity, 300">
				<c:forEach items="${videoList}" var="video">
					<div class="jk-video" id="opus-${video.opus}">
						<div class="jk-video-inner">
							<div class="jk-video-cover lazy-load" data-src="${PATH}/video/${video.opus}/cover">
								<h3 class="jk-video-title">
									<jk:video video="${video}" view="title" css="label"/>
								</h3>
							</div>
							<div class="jk-video-detail">
								<h3 class="nowrap" style="margin:0 0 5px; height:33px;">
									<jk:video video="${video}" view="title"/>
								</h3>
									<jk:video video="${video}" view="rank"      mode="l"/>
								<h4><jk:video video="${video}" view="studio"    mode="l"/>
									<jk:video video="${video}" view="opus"      mode="l"/>
									<jk:video video="${video}" view="release"   mode="l"/>
									<jk:video video="${video}" view="download"  mode="l"/></h4>
								<h5><jk:video video="${video}" view="score"     mode="l"/>
									<jk:video video="${video}" view="video"     mode="l"/>
									<jk:video video="${video}" view="cover"     mode="l"/>
									<jk:video video="${video}" view="subtitles" mode="l"/>
									<jk:video video="${video}" view="overview"  mode="l"/></h5>
								<h4 style="margin-bottom:0;">
									<jk:video video="${video}" view="actress"   mode="f"/></h4>
							   <div><jk:video video="${video}" view="tags"      mode="l" tagList="${tagList}"/></div>
							</div>
						</div>
					</div>
				</c:forEach>
				<div class="clear" style="height:100px;"></div>
			</div>
			<div style="position:fixed; left:20px; bottom:15px;" data-lazy-class="w3-animate-left, 3000" class="range-cover-wrap hide">
				<input type="range" id="rangeCover" min="200" max="800" value="800" step="50"/>
			</div>
			<div style="position:fixed; right:20px; bottom:15px;" data-lazy-class="w3-animate-right, 3000" class="hide">
				<a id="randomViewBtn" class="btn-random-view">Random View</a>
			</div>
		</c:when>
		<c:otherwise>
			<div class="panel-group">
				<div class="panel panel-primary" style="background-color:rgba(255,255,255,.5);">
					<div class="panel-heading" onclick="$('.video-2-list').toggleClass('hide')">
						More than 2 video files <span class="caret"></span>
					</div>
					<div class="panel-body">
						<ol class="video-2-list hide">
							<c:forEach items="${videoList}" var="video">
								<c:if test="${video.videoFileList.size() > 1 }">
									<li>
										<span class="glyphicon glyphicon-film text-red"></span>
										<jk:video video="${video}" view="opus" mode="s"/>
										<ul>
											<c:forEach items="${video.videoFileList}" var="file">
												<li>
													<span class="label label-plain"><fmt:formatNumber value="${file.length()}" type="NUMBER"/></span>
													<span class="label label-plain" onclick="fnPlay('${video.opus}')">${file}</span></li>
											</c:forEach>
										</ul>
									</li>
								</c:if>
							</c:forEach>
						</ol>
					</div>
				</div>
				<div class="panel panel-primary" style="background-color:rgba(255,255,255,.5);">
					<div class="panel-heading">
						No Cover
					</div>
					<div class="panel-body">
						<ol>
							<c:forEach items="${videoList}" var="video">
								<c:if test="${!video.existCoverFile}">
									<li>
										<span class="glyphicon glyphicon-film text-red"></span>
										<span class="label label-plain" onclick="fnVideoDetail('${video.opus}')">${video.opus}</span>
									</li>
								</c:if>
							</c:forEach>
						</ol>
					</div>
				</div>
			</div>
		</c:otherwise>
	</c:choose>
	</div>

</div>

</div>
</body>
</html>