<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"      uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form"   uri='http://www.springframework.org/tags/form'%>
<%@ taglib prefix="jk"     tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.archive"/></title>
<script type="text/javascript">
//var opusArray = ${opusArray};
var bgImageCount = ${bgImageCount};
var totalVideoSize = parseInt('${fn:length(videoList)}');
var currentVideoIndex = getRandomInteger(1, totalVideoSize);
var listViewType = '${videoSearch.listViewType}';
var currBGImageUrl;
</script>
</head>
<body>
<div class="container-fluid" role="main">

<div id="header_div" class="box">
	<form:form method="POST" modelAttribute="videoSearch" role="form" class="form-inline" onsubmit="return false;">
		<div id="searchDiv" class="text-center">
			<!-- Search : Text -->
			<form:input path="searchText" cssClass="form-control input-sm" placeHolder="Search" style="width:120px;"/>
	
			<!-- Search submit -->			
			<button class="btn btn-xs btn-default" onclick="fnSearch()">
				<s:message code="video.search"/> <span class="badge">${fn:length(videoList)}</span>
			</button>
	
			<!-- view type -->
			<form:select path="listViewType" items="${views}" cssClass="form-control input-sm" title="View type"/> 
	
			<!-- sort -->
			<span title="<s:message code="video.reverseSort"/>">
				<form:checkbox path="sortReverse" cssClass="sr-only"/>
				<label class="label label-checkbox" for="sortReverse1">R</label>
			</span>
			<form:select path="sortMethod" items="${sorts}" itemLabel="desc" cssClass="form-control input-sm" title="Sort method" style="width:80px;"/>
		</div>
	</form:form>
</div>

<div id="content_div" class="box">
	<div id="contentContainer">
	<c:choose>
		<c:when test="${videoSearch.listViewType eq 'Card'}">
			<ul class="list-inline">
				<c:forEach items="${videoList}" var="video">
				<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
				</c:forEach>
			</ul>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'Box'}">
			<ul class="list-inline">
				<c:forEach items="${videoList}" var="video" varStatus="status">
				<li>
					<div id="opus-${video.opus}" class="video-box">
						<dl style="background-image:url('<c:url value="/cover/video/${video.opus}" />');">
							<dt class="nowrap"><jk:video video="${video}" view="title" mode="s"/></dt>
							<dd><jk:video video="${video}" view="studio" mode="s"/></dd>
							<dd><jk:video video="${video}" view="opus" mode="s"/></dd>
							<dd><jk:video video="${video}" view="subtitles" mode="s"/></dd>
							<dd><jk:video video="${video}" view="overview" mode="s"/></dd>
						</dl>
					</div>
				</li>
				</c:forEach>
			</ul>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'Table'}">
			<table class="table table-condensed table-hover table-bordered">
				<c:forEach items="${videoList}" var="video" varStatus="status">
				<tr id="opus-${video.opus}" class="nowarp">
					<td style="width:80px;">
						<div class="nowrap"><jk:video video="${video}" view="studio"/></div></td>
					<td style="width:80px;">
						<jk:video video="${video}" view="opus"/></td>
					<td style="max-width:300px;">
						<div class="nowrap"><span class="label label-plain" onclick="fnVideoDetail('${video.opus}')" title="${video.title}">${video.title}</span></div>
					</td>
					<td style="max-width:150px;">
						<div class="nowrap">
						<c:forEach items="${video.actressList}" var="actress">
							<span class="label label-plain" onclick="fnViewActressDetail('${actress.name}')">${actress.name}</span>
						</c:forEach>
						</div>
					</td>
					<td style="width:70px;">
						<jk:video video="${video}" view="release"/></td>
					<td style="width:20px;">
						<jk:video video="${video}" view="cover" mode="s"/></td>
					<td style="width:20px;">
						<jk:video video="${video}" view="subtitles" mode="s"/></td>
				</tr>
				</c:forEach>
			</table>
		</c:when>
		<c:when test="${videoSearch.listViewType eq 'Flay'}">
			<div id="video-slide-wrapper">
				<div id="slides">
					<c:forEach items="${videoList}" var="video">
						<div id="opus-${video.opus}" class="slidesjs-slide" style="display:none;">
							<dl class="box box-small" style="background-image: url('<c:url value="/cover/video/${video.opus}" />'); height: 520px;"></dl>
							<div class="box box-small box-detail">
								<dl class="video-info">
									<dt class="title nowrap">
										<jk:video video="${video}" view="title"/></dt>
									<dd class="info">
										<jk:video video="${video}" view="studio"    mode="l"/>
										<jk:video video="${video}" view="opus"      mode="l"/>
										<jk:video video="${video}" view="release"   mode="l"/>
										<jk:video video="${video}" view="download"  mode="l"/></dd>
									<dd class="action">
										<jk:video video="${video}" view="cover"     mode="l"/>
										<jk:video video="${video}" view="subtitles" mode="l"/>
										<jk:video video="${video}" view="overview"  mode="l"/></dd>
									<dd class="actress">
										<jk:video video="${video}" view="actress"   mode="f"/></dd>
								    <dd class="tags">
										<c:forEach items="${video.tags}" var="tag">
											<span class="label label-info">${tag.name}</span>
										</c:forEach>
								    </dd>
								</dl>
							</div>
						</div>
					</c:forEach>
				</div>
				<div style="position:fixed; right:20px; bottom:15px;"><a class="slidesjs-navigation slidesjs-random" href="#">Random View</a></div>
			</div>
			<link rel="stylesheet" href="<c:url value="/css/video-slides.css"/>"/>
			<link rel="stylesheet" href="${PATH}/css/app/video/videoMain.flay.css"/>
			<script type="text/javascript" src="<c:url value="/js/jquery.slides.min.js"/>"></script>
			<script type="text/javascript" src="<c:url value="/js/crazy.video.main.slide.js"/>"></script>
			<script type="text/javascript">
				$("#slides").slideview({width:800, height:750});
			</script>
		</c:when>
		<c:otherwise>
	        <div class="jumbotron">
	            <h1 class="text-center">
	                Not supported View
	            </h1>
	        </div>
		</c:otherwise>
	</c:choose>
	</div>
</div>

</div>
</body>
</html>