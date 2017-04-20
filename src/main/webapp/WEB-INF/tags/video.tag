<%@ tag language="java" pageEncoding="UTF-8" body-content="tagdependent"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="s"   uri="http://www.springframework.org/tags"%>
<%@ attribute name="video"   required="true" type="jk.kamoru.flayon.crazy.video.domain.Video" %>
<%@ attribute name="view"    required="true"  %>
<%@ attribute name="mode"    required="false" %><%-- mode : s(Small), l(Large) --%>
<%@ attribute name="tooltip" required="false" %><%-- tooltip --%>
<%@ attribute name="tagList" required="false" type="java.util.List" %>
<%@ attribute name="css"     required="false" %>
<c:set var="cssClass" value="${empty css ? 'label label-plain' : css}"/>
<c:set var="ONE_GB" value="${1024*1024*1024}"/>
<%  if (view.equalsIgnoreCase("video")) { %>
	<span class="${cssClass} ${video.existVideoFileList ? 'exist' : 'nonExist'}" title="${video.playCount} played" style="margin-right:3px;" onclick="fnPlay('${video.opus}')">
		${mode eq 's' ? 'V' : 'Video'}
		<c:if test="${mode eq 'l'}">
			<em>${video.size}</em>
			<em><fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.#GB"/></em>
		</c:if>
	</span>
<%  } else if (view.equalsIgnoreCase("cover")) { %>
	<span class="${cssClass} ${video.existCoverFile ? 'exist' : 'nonExist'}" onclick="fnCoverView('${video.opus}')">${mode eq 's' ? 'C' : 'Cover'}</span>
<%  } else if (view.equalsIgnoreCase("subtitles")) { %>
	<span class="${cssClass} ${video.existSubtitlesFileList ? 'exist' : 'nonExist'}" onclick="fnEditSubtitles('${video.opus}')">${mode eq 's' ? 's' : 'smi'}</span>
<%  } else if (view.equalsIgnoreCase("overview")) { %>
	<span class="${cssClass}" title="${video.overviewText}" id="overview-${video.opus}" style="${video.existOverview ? 'color:red' : ''}" onclick="fnEditOverview('${video.opus}', event)">${mode eq 's' ? 'O' : (video.existOverview ? video.overviewText : 'Overview')}</span>
<%  } else if (view.equalsIgnoreCase("download")) { %>
	<span class="${cssClass}" title="download date">${video.videoDate}</span>
<%  } else if (view.equalsIgnoreCase("release")) { %>
	<span class="${cssClass}" title="release date">${video.releaseDate}</span>
<%  } else if (view.equalsIgnoreCase("actress")) { %>
	<div style="max-height:${mode eq 'f' ? '70' : '50'}px; overflow:auto;">
	<c:forEach items="${video.actressList}" var="actress">
		${mode eq 'f' ? '<div style="margin-bottom: 5px; display:inline-block;">' : '' }
		<span class="${cssClass} ${actress.favorite ? 'favorite' : ''}" style="margin-right:3px;"> 
			<c:if test="${mode ne 'f'}">
				<span title="${actress}" onclick="fnViewActressDetail('${actress.name}')">${actress.name}</span>
				<c:if test="${mode eq 's'}">
				<span title="set Favorite actress" onclick="fnFavorite(this, '${actress.name}')">${actress.favorite ? '★' : '☆'}</span>
				</c:if>
			</c:if>
			<c:if test="${mode eq 'f'}">
				<span title="set Favorite actress" onclick="fnFavorite(this, '${actress.name}')">${actress.favorite ? '★' : '☆'}</span>
				<span onclick="fnViewActressDetail('${actress.name}')">${actress}</span>
				<span title="age">${actress.age}</span> 
				<span title="<s:message code="video.find-info.actress"/>" onclick="fnSearchActress('${actress.reverseName}')"><span class="glyphicon glyphicon-user"></span></span>
			</c:if>
		</span>
		${mode eq 'f' ? '</div>' : ''}
	</c:forEach>
	</div>
<%  } else if (view.equalsIgnoreCase("opus")) { %>
	<span class="${cssClass}" title="${video.fullname}" onclick="fnVideoDetail('${video.opus}')">${video.opus}</span>
	<c:if test="${mode eq 'l'}">
		<span class="${cssClass}" title="<s:message code="video.find-info.opus"/>" onclick="fnSearchOpus('${video.opus}')"><span class="glyphicon glyphicon-picture"></span></span>
		<span class="${cssClass}" title="<s:message code="video.find-info.torrent"/>" onclick="fnSearchTorrent('${video.opus}'); this.style.backgroundColor='red';"><span class="glyphicon glyphicon-magnet"></span></span>
		<c:if test="${video.torrents.size() > 0}">
		<span class="${cssClass}" title="Start torrent download ${video.torrents}" onclick="goTorrentMove('${video.opus}'); this.style.backgroundColor='red';"><span class="glyphicon glyphicon-cloud-download"></span></span>
		</c:if>
	</c:if>
<%  } else if (view.equalsIgnoreCase("length")) { %>
	<span class="${cssClass}"><fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.0GB"/></span>
<%  } else if (view.equalsIgnoreCase("studio")) { %>
	<span class="${cssClass}" title="${video.studio}" onclick="fnViewStudioDetail('${video.studio.name}')">${video.studio.name}</span>
<%  } else if (view.equalsIgnoreCase("title")) { %>
	<span class="${cssClass} video-title" title="${video.title}" onclick="fnVideoDetail('${video.opus}')">${video.title}</span>
<%  } else if (view.equalsIgnoreCase("score")) { %>
	<span class="${cssClass}" title="${video.scoreDesc}">${video.score}</span>
	<c:if test="${mode eq 'l'}">
		<span class="${cssClass}" onclick="fnVideoReset('${video.opus}')">Reset</span>
		<span class="${cssClass}" onclick="fnVideoWrong('${video.opus}')">Wrong</span>
	</c:if>
<%  } else if (view.equalsIgnoreCase("rank")) { %>
	<c:if test="${mode ne 's'}">
		<div style="margin:0; display:inline-block;" class="form-inline">
			<div class="input-group rank-group">
				<input type="range" id="Rank-${video.opus}" name="rankPoints" class="form-control rank-range" data-opus="${video.opus}" min="${minRank}" max="${maxRank}" value="${video.rank}" onmouseup="fnRank('${video.opus}')" />
				<span id="Rank-${video.opus}-label" class="input-group-addon rank-range-addon">${video.rank}</span>
			</div>
		</div>
	</c:if>
	<c:if test="${mode eq 's'}">
		<span id="Rank-${video.opus}-label" class="${cssClass}" title="rank">${video.rank}</span>
	</c:if>
<%  } else if (view.equalsIgnoreCase("label")) { %>
	<span class="${cssClass}" title="${video.fullname} ${tooltip}" data-opus="${video.opus}" onclick="fnVideoDetail('${video.opus}')">${mode eq 'simple' ? 'O' : video.opus}</span>
<%  } else if (view.equalsIgnoreCase("span")) { %>
	<span class="item box nowrap'" style="padding: 5px; margin: 5px;" title="${video.fullname} ${tooltip} ${video.score}" onclick="fnVideoDetail('${video.opus}')">${mode eq 's' ? 'O' : video.opus}</span>
<%  } else if (view.equalsIgnoreCase("tags")) { %>
	<c:if test="${mode eq 'l'}">
		<div id="tags-${video.opus}">
	<%	for (int i=0; i<tagList.size(); i++) {
			jk.kamoru.flayon.crazy.video.domain.VTag tag = (jk.kamoru.flayon.crazy.video.domain.VTag)tagList.get(i);
			String _cssClass = "label-plain";
			if (video.getTags() == null || !video.getTags().contains(tag)) {
				_cssClass = "label-default";
			} %>
			<span class="label <%=_cssClass %>" title="<%=tag.getDescription()%>" onclick="fnSetTag(this, '<%=video.getOpus()%>', '<%=tag.getId()%>')"><%=tag.getName()%></span>
	<%	} %>
			<span class="label label-info" onclick="$('#newTag-${video.opus}').slideToggle(); $('#newTag-name-${video.opus}').focus();">NEW</span>
		</div>
		<form action="<c:url value="/video/tag"/>" method="post" role="form" class="form-inline" style="margin-top: 5px;" onsubmit="addTag(this)">
			<span style="display:none; padding:3px;" class="bg-primary" id="newTag-${video.opus}">
				<input type="hidden" name="_method" id="hiddenHttpMethod-${video.opus}" value="PUT"/>
				<input type="hidden" name="opus" value="${video.opus}"/>
				<input name="name" placeholder="name" id="newTag-name-${video.opus}" class="form-control input-sm" required="required"/>
				<input name="description" placeholder="Description" class="form-control input-sm"/>
				<button class="btn btn-primary btn-xs" type="submit">Regist</button>
			</span>
		</form>
	</c:if>
	<c:if test="${mode ne 'l'}">
		<c:forEach items="${video.tags}" var="tag">
			<span class="${cssClass}" title="${tag.description}" onclick="fnViewTagDetail('${tag.name}')">${tag.name}</span>
		</c:forEach>
	</c:if>
<%  } else { %>
	${view} is invalid argement
<%	} %>
