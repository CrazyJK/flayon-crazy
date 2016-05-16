<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<c:set var="ONE_GB" value="${1024*1024*1024}"/>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.video"/> <s:message code="video.list"/></title>
<script type="text/javascript">
$(document).ready(function(){
	
	$("input[type=radio]").bind("click", function(){
		var selectedSort = $(this).val();
		var reverseOrder = '${sort}' == selectedSort ? !${reverse} : true;
		location.href = "?sort=" + selectedSort + "&r=" + reverseOrder;
	}).css("display","none");

});
</script>
</head>
<body>
<div id="header_div" class="div-box">
	<ul class="menu-item-ul">
		<li class="label-large">
			<s:message code="video.total"/> <s:message code="video.video"/> : ${fn:length(videoList)}
		</li>
		<li class="label-large">
			<input type="search" name="search" id="search" style="width:100px;" 
				class="searchInput" placeHolder="<s:message code="video.search"/>" onkeyup="searchContent(this.value)"/>
		</li>
		<li class="label-large">
			<c:forEach items="${sorts}" var="s">
			<label class="item sort-item">
				<input type="radio" name="sort" value="${s}" ${s eq sort ? 'checked' : ''} style="display:none;">
				<span><s:message code="video.sort.${s.desc}"/></span></label>
			</c:forEach>
		</li>
		<li class="label">
			<span title="Rank[<s:eval expression="@prop['score.ratio.rank']"/>] 
Play[<s:eval expression="@prop['score.ratio.play']"/>]
Actress[<s:eval expression="@prop['score.ratio.actress']"/>]
Subtitles[<s:eval expression="@prop['score.ratio.subtitles']"/>]
Unseen[<s:eval expression="@prop['score.ratio.unseen']"/>]">Ratio</span>
		
		</li>
	</ul>
</div>

<div id="content_div" class="div-box">
	<table class="video-table">
		<c:forEach items="${videoList}" var="video" varStatus="status">
		<tr class="nowrap">
			<td class="number">
				${status.count}
			</td>
			<td class="${sort eq 'S' ? 'sorted-column' : ''}">
				<div class="overflow-hidden width100"><span onclick="fnViewStudioDetail('${video.studio.name}')">${video.studio.name}</span></div>
			</td>
			<td class="${sort eq 'O' ? 'sorted-column' : ''}">
				<span onclick="fnViewVideoDetail('${video.opus}')">${video.opus}</span>
			</td>
			<td class="${sort eq 'T' ? 'sorted-column' : ''}">
				<div class="overflow-hidden width400" title="${video.title}">${video.title}</div>
			</td>
			<td class="${sort eq 'A' ? 'sorted-column' : ''}">
				<div class="overflow-hidden width100">
				<c:forEach items="${video.actressList}" var="actress">
					<span onclick="fnViewActressDetail('${actress.name}')">${actress.name}</span>
				</c:forEach>
				</div>
			</td>
			<td class="${sort eq 'M' ? 'sorted-column' : ''}">
				${video.videoDate}
			</td>
			<td class="${sort eq 'P' ? 'sorted-column' : ''}">
				${video.playCount}
			</td>
			<td class="${sort eq 'R' ? 'sorted-column' : ''}">
				${video.rank}
			</td>
			<td class="${sort eq 'L' ? 'sorted-column' : ''} number">
				<fmt:formatNumber value="${video.length / ONE_GB}" pattern="#,##0.00G"/>
			</td>
			<td class="${sort eq 'SC' ? 'sorted-column' : ''} number">
				<span title="${video.scoreDesc}">${video.score}</span>
			</td>
		</tr>
		</c:forEach>
	</table>
</div>
  
</body>
</html>
