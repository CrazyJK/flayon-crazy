<%@ tag language="java" pageEncoding="UTF-8" body-content="tagdependent"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="s"   uri="http://www.springframework.org/tags"%>

<%@ attribute name="video"   required="true" type="jk.kamoru.flayon.crazy.video.domain.Video"%>
<%@ attribute name="view"    required="true"%>
<%@ attribute name="mode"    required="false"%><%-- mode : s(Small), l(Large) --%>
<%@ attribute name="tooltip" required="false"%><%-- tooltip test --%>
<%@ attribute name="tagList" required="false" type="java.util.List<jk.kamoru.flayon.crazy.video.domain.VTag>" %>

<c:set var="cssClass" value="label label-plain"/>
<c:set var="ONE_GB" value="${1024*1024*1024}"/>

<%
	if (view.equalsIgnoreCase("video")) {
%>
<span class="${cssClass} ${video.existVideoFileList ? 'exist' : 'nonExist'}" 
		title="${video.playCount} played" 
		onclick="fnPlay('${video.opus}')">
			${mode eq 's' ? 'V' : 'Video'}
<c:if test="${mode eq 'l'}">			
			<em>${video.size}</em>
			<em><fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.#GB"/></em>
</c:if>			
</span>
<%
	} else if (view.equalsIgnoreCase("cover")) {
%>
<span class="${cssClass} ${video.existCoverFile ? 'exist' : 'nonExist'}" onclick="fnImageView('${video.opus}')">${mode eq 's' ? 'C' : 'Cover'}</span>
<%
	} else if (view.equalsIgnoreCase("subtitles")) {
%>
<span class="${cssClass} ${video.existSubtitlesFileList ? 'exist' : 'nonExist'}" onclick="fnEditSubtitles('${video.opus}')">${mode eq 's' ? 's' : 'smi'}</span>
<%
	} else if (view.equalsIgnoreCase("overview")) {
%>
<span class="${cssClass}" onclick="fnEditOverview('${video.opus}')" title="${video.overviewText}">${mode eq 's' ? 'O' : (video.existOverview ? video.overviewText : 'Overview')}</span>
<%
	} else if (view.equalsIgnoreCase("download")) {
%>
<span class="${cssClass}" title="download date">${video.videoDate}</span>
<%
	} else if (view.equalsIgnoreCase("release")) {
%>
<span class="${cssClass}" title="release date">${video.releaseDate}</span>
<%
	} else if (view.equalsIgnoreCase("actress")) {
%>
<c:forEach items="${video.actressList}" var="actress" varStatus="status">
<span class="${cssClass}" onclick="fnViewActressDetail('${actress.name}')" title="${actress}">
	${actress.name}
	<c:if test="${mode eq 'l'}">
		<em>${actress.age}</em>
	</c:if>
</span>
<c:if test="${mode eq 'l'}">&nbsp;
	<span class="${cssClass}" title="set Favorite actress"
			onclick="fnFavorite(this, '${actress.name}')">${actress.favorite ? '★' : '☆'}</span>
	<%-- <img src="<c:url value="/img/magnify${status.count%2}.png"/>" width="12px" title="<s:message code="video.find-info.actress"/>"
			onclick="popup('<s:eval expression="@environment.getProperty('url.search.actress')"/>${actress.reverseName}', 'info_${actress.name}', 800, 600)"/> --%>
	<span class="${cssClass}" title="<s:message code="video.find-info.actress"/>"
			onclick="popup('<s:eval expression="@environment.getProperty('url.search.actress')"/>${actress.reverseName}', 'info_${actress.name}', 800, 600)"
		><span class="glyphicon glyphicon-user"></span></span>
</c:if>
&nbsp;
</c:forEach>
<%
	} else if (view.equalsIgnoreCase("opus")) {
%>
<span class="${cssClass}" onclick="fnViewVideoDetail('${video.opus}')" title="${video.fullname}">${video.opus}</span>
<c:if test="${mode eq 'l'}">
	<%-- <img src="<c:url value="/img/magnify${status.count%2}.png"/>" width="12px" title="<s:message code="video.find-info.opus"/>"
		onclick="popup('<s:eval expression="@environment.getProperty('url.search.video')"/>${video.opus}', 'info_${video.opus}', 800, 600)"/> --%>
	<span class="${cssClass}" title="<s:message code="video.find-info.opus"/>"
		onclick="popup('<s:eval expression="@environment.getProperty('url.search.video')"/>${video.opus}', 'info_${video.opus}', 800, 600)"
		><span class="glyphicon glyphicon-picture"></span></span>
</c:if>
<%
	} else if (view.equalsIgnoreCase("torrent")) {
%>
<%-- <img src="<c:url value="/img/magnify${status.count%2}.png"/>" width="12px" title="<s:message code="video.find-info.torrent"/>"
	onclick="popup('<s:eval expression="@environment.getProperty('url.search.torrent')"/>${video.opus}', 'torrentDownload', 800, 600); this.style.backgroundColor='red';"/> --%>
<span class="${cssClass}" title="<s:message code="video.find-info.torrent"/>"
	onclick="popup('<s:eval expression="@environment.getProperty('url.search.torrent')"/>${video.opus}', 'torrentDownload', 800, 600); this.style.backgroundColor='red';"
	><span class="glyphicon glyphicon-download-alt"></span></span>
<%
	} else if (view.equalsIgnoreCase("length")) {
%>
<fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.0GB"/>
<%
	} else if (view.equalsIgnoreCase("studio")) {
%>
<span class="${cssClass}" onclick="fnViewStudioDetail('${video.studio.name}')" title="${video.studio}">${video.studio.name}</span>
<%
	} else if (view.equalsIgnoreCase("title")) {
%>
	<span class="${cssClass}" onclick="fnVideoDetail('${video.opus}')" title="${video.title}">${video.title}</span>
<%
	} else if (view.equalsIgnoreCase("score")) {
%>
<span class="${cssClass} rangeLabel" title="${video.scoreDesc}">${video.score}</span>
<c:if test="${mode eq 'l'}">
	<span class="${cssClass}" onclick="fnVideoReset('${video.opus}')">Reset</span>
	<span class="${cssClass}" onclick="fnVideoWrong('${video.opus}')">Wrong</span>
</c:if>
<%
	} else if (view.equalsIgnoreCase("rank")) {
%>
	<%	if (!"s".equals(mode)) { %>
<input type="range" id="Rank-${video.opus}" name="points" class="form-control" 
	min="${minRank}" max="${maxRank}" value="${video.rank}"
	onmouseup="fnRank('${video.opus}')" onchange="document.getElementById('Rank-${video.opus}-label').innerHTML = this.value;" />
	<%	} %>	
<span id="Rank-${video.opus}-label" class="${cssClass} rangeLabel" title="rank">${video.rank}</span>
<%
	} else if (view.equalsIgnoreCase("label")) {
%>
<span class="${cssClass}" onclick="fnVideoDetail('${video.opus}')" title="${video.fullname} ${tooltip}" data-opus="${video.opus}">${mode eq 'simple' ? 'O' : video.opus}</span>
<%
	} else if (view.equalsIgnoreCase("span")) {
%>
<span style="padding: 5px; margin: 5px;"
	class="item box nowrap'" 
	onclick="fnVideoDetail('${video.opus}')" 
	title="${video.fullname} ${tooltip} ${video.score}"> 
		${mode eq 's' ? 'O' : video.opus}
</span>
<%
	} else if (view.equalsIgnoreCase("tags")) {
%>
	<div id="tags-${video.opus}">
<%
		if ("l".equals(mode)) {
			for (jk.kamoru.flayon.crazy.video.domain.VTag tag : tagList) {
				
				if (video.getTags() == null || !video.getTags().contains(tag)) {
%>
		<span class="label label-default" title="<%=tag.getDescription()%>" onclick="fnSetTag(this, '<%=video.getOpus()%>', '<%=tag.getId()%>')"><%=tag.getName()%></span>
<%
				}
				else {
%>
		<span class="${cssClass}" title="<%=tag.getDescription()%>" onclick="fnSetTag(this, '<%=video.getOpus()%>', '<%=tag.getId()%>')"><%=tag.getName()%></span>
<%
				}
			}
%>
	</div>
	<form action="<c:url value="/video/tag"/>" method="post" role="form" class="form-inline" style="margin-top: 5px;" onsubmit="addTag(this)">
		<span class="label label-info" onclick="$('#newTag-${video.opus}').slideToggle(); $('#newTag-name-${video.opus}').focus();">NEW</span>
		<span style="display:none; bg-info" id="newTag-${video.opus}">
			<input type="hidden" name="_method" id="hiddenHttpMethod-${video.opus}" value="PUT"/>
			<input type="hidden" name="opus" value="${video.opus}"/>
			<input name="name" placeholder="name" id="newTag-name-${video.opus}" class="form-control input-sm" required="required"/>
			<input name="description" placeholder="Description" class="form-control input-sm"/>
			<button class="btn btn-primary btn-xs" type="submit">Regist</button>
		</span>
	</form>
<%
		}
		else {
%>
<c:forEach items="${video.tags}" var="tag">
	<span class="${cssClass}" title="${tag.description}" onclick="fnViewTagDetail('${tag.name}')">${tag.name}</span>
</c:forEach>
<%-- 
<c:forEach items="${tagList}" var="tag">
	<span class="${cssClass}" title="${tag.description}" onclick="fnViewTagDetail('${tag.name}')">${tag.name}</span>
</c:forEach>
 --%>
<%
		}
	} else {
%>
${view} is invalid argement
<%
	}
%>