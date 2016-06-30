<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="s"   uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"  tagdir="/WEB-INF/tags"%>
<c:set var="ONE_GB" value="${1024*1024*1024}"/>
<c:set var="tab" value="${empty param.tab ? 'folder' : param.tab}"/>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.briefing"/></title>
<link rel="stylesheet" href="<c:url value="/css/videoMain.css"/>"/>
<script type="text/javascript">
$(document).ready(function(){
	
	$("input:radio[name=viewType]").bind("click", function() {
		var view = $(this).val();
		$("[data-opus]").each(function() {
			if (view == 'normal') {
				$(this).html($(this).attr("data-opus"));
			}
			else {
				$(this).html('O');
			}
		});
	}).css("display","none");
	
	// set initial view
	$('input:radio[name=viewType]:nth(1)').click();
	
});
var MOVE_WATCHED_VIDEO = ${MOVE_WATCHED_VIDEO};
var DELETE_LOWER_RANK_VIDEO = ${DELETE_LOWER_RANK_VIDEO};
var DELETE_LOWER_SCORE_VIDEO = ${DELETE_LOWER_SCORE_VIDEO};

function setMOVE_WATCHED_VIDEO() {
	MOVE_WATCHED_VIDEO = !MOVE_WATCHED_VIDEO;
	actionFrame('<c:url value="/video/set/MOVE_WATCHED_VIDEO/"/>' + MOVE_WATCHED_VIDEO, "POST", "Set Watched Video to " + MOVE_WATCHED_VIDEO);
	$("#MOVE_WATCHED_VIDEO").html("" + MOVE_WATCHED_VIDEO);
}
function setDELETE_LOWER_RANK_VIDEO() {
	DELETE_LOWER_RANK_VIDEO = !DELETE_LOWER_RANK_VIDEO;
	actionFrame('<c:url value="/video/set/DELETE_LOWER_RANK_VIDEO/"/>' + DELETE_LOWER_RANK_VIDEO, "POST", "Set Lower Rank to " + MOVE_WATCHED_VIDEO);
	$("#DELETE_LOWER_RANK_VIDEO").html("" + DELETE_LOWER_RANK_VIDEO);
}
function setDELETE_LOWER_SCORE_VIDEO() {
	DELETE_LOWER_SCORE_VIDEO = !DELETE_LOWER_SCORE_VIDEO;
	actionFrame('<c:url value="/video/set/DELETE_LOWER_SCORE_VIDEO/"/>' + DELETE_LOWER_SCORE_VIDEO, "POST", "Set Lower Score to " + MOVE_WATCHED_VIDEO);
	$("#DELETE_LOWER_SCORE_VIDEO").html("" + DELETE_LOWER_SCORE_VIDEO);
}
function moveWatchedVideo() {
	actionFrame(videoPath + '/manager/moveWatchedVideo', 'POST', 'Moving Watched Video');
}
function removeLowerRankVideo() {
	actionFrame(videoPath + '/manager/removeLowerRankVideo', 'POST', 'Deleting Lower Rank');
}
function removeLowerScoreVideo() {
	actionFrame(videoPath + '/manager/removeLowerScoreVideo', 'POST', 'Deleting Lower Score');
}
function reloadVideo() {
	actionFrame(videoPath + '/reload', 'POST', 'Reloading');
}
/*]]>*/
</script>
</head>
<body>
<div class="container-fluid">

<div id="header_div" class="box">
	<ul class="list-inline">
		<li><label class="btn btn-xs btn-default"><input type="radio" name="viewType" value="normal"/><span>Normal</span></label></li>
		<li><label class="btn btn-xs btn-default"><input type="radio" name="viewType" value="simple"/><span>Simple</span></label></li>
		<li><span class="label label-info">Max : <fmt:formatNumber value="${maxEntireVideo}"/> GB</span></li>
		<li>
			<div class="btn-group">
				<button class="btn btn-xs btn-default" onclick="moveWatchedVideo()"><s:message code="video.mng.move"/></button>
				<button class="btn btn-xs btn-default" onclick="setMOVE_WATCHED_VIDEO()" id="MOVE_WATCHED_VIDEO">${MOVE_WATCHED_VIDEO}</button>
			</div>
			<div class="btn-group">
				<button class="btn btn-xs btn-default" onclick="removeLowerRankVideo()"><s:message code="video.mng.rank"/></button>
				<button class="btn btn-xs btn-default" onclick="setDELETE_LOWER_RANK_VIDEO()" id="DELETE_LOWER_RANK_VIDEO">${DELETE_LOWER_RANK_VIDEO}</button>
			</div>
			<div class="btn-group">
				<button class="btn btn-xs btn-default" onclick="removeLowerScoreVideo()"><s:message code="video.mng.score"/></button>
				<button class="btn btn-xs btn-default" onclick="setDELETE_LOWER_SCORE_VIDEO()" id="DELETE_LOWER_SCORE_VIDEO">${DELETE_LOWER_SCORE_VIDEO}</button>
			</div>
			</li>
		<li><button type="button" class="btn btn-xs btn-default" onclick="reloadVideo()"><s:message code="video.reload.title"/></button></li>
	</ul>
</div>

<div id="content_div" class="box" style="overflow:auto;">

 	<ul class="nav nav-tabs">
	    <li class="${tab eq 'folder'    ? 'active' : ''}"><a data-toggle="tab" href="#folder"     ><s:message code="video.video-by-folder"/></a></li>
	    <li class="${tab eq 'date'      ? 'active' : ''}"><a data-toggle="tab" href="#date"		><s:message code="video.video-by-date"/></a></li>
	    <li class="${tab eq 'play'      ? 'active' : ''}"><a data-toggle="tab" href="#play"		><s:message code="video.video-by-play"/></a></li>
		<li class="${tab eq 'rank'      ? 'active' : ''}"><a data-toggle="tab" href="#rank"		><s:message code="video.video-by-rank"/></a></li>
		<li class="${tab eq 'score'     ? 'active' : ''}"><a data-toggle="tab" href="#score"		><s:message code="video.video-by-score"/></a></li>
		<li class="${tab eq 'length'    ? 'active' : ''}"><a data-toggle="tab" href="#length"		><s:message code="video.video-by-length"/></a></li>
		<li class="${tab eq 'extension' ? 'active' : ''}"><a data-toggle="tab" href="#extension"	><s:message code="video.video-by-extension"/></a></li>
		<%-- <li><a data-toggle="tab" href="#video"		><s:message code="video.video"/>   <span class="badge">${videoList.size()}</span></a></li> --%>
		<li class="${tab eq 'studio'    ? 'active' : ''}"><a data-toggle="tab" href="#studio"		><s:message code="video.studio"/>  <span class="badge">${studioList.size()}</span></a></li>
		<li class="${tab eq 'actress'   ? 'active' : ''}"><a data-toggle="tab" href="#actress"	><s:message code="video.actress"/> <span class="badge">${actressList.size()}</span></a></li>
		<li class="${tab eq 'tags'      ? 'active' : ''}"><a data-toggle="tab" href="#tags"		><s:message code="video.tags"/>    <span class="badge">${tagList.size()}</span></a></li>
  	</ul>

	<div class="tab-content">
		<section id="folder" class="tab-pane fade ${tab eq 'folder' ? 'in active' : ''}">
			<table class="table table-condensed table-hover table-bordered">
				<thead>
					<tr>
						<th><s:message code="video.folder"/></th>
						<th><s:message code="video.size"/></th>
						<th><s:message code="video.length"/></th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${pathMap}" var="path" varStatus="status">
					<c:choose>
						<c:when test="${path.key ne 'Total'}">
					<tr>
						<td>${path.key}</td>
						<td class="text-right"><span class="videoCount"><fmt:formatNumber value="${path.value[0]}" type="NUMBER"/></span></td>
						<td class="text-right"><span class="videoSize"><fmt:formatNumber value="${path.value[1] / ONE_GB}" pattern="#,##0 GB"/></span></td>
					</tr>
						</c:when>
						<c:otherwise>
							<c:set var="totalSize"   value="${path.value[0]}"/>
							<c:set var="totalLength" value="${path.value[1]}"/>
						</c:otherwise>
					</c:choose>
					</c:forEach>
					<tr>
						<td style="border-top:1px double blue;"><s:message code="video.total"/></td>
						<td class="text-right" style="border-top:1px double blue;"><fmt:formatNumber value="${totalSize}" type="NUMBER"/></td>
						<td class="text-right" style="border-top:1px double blue;"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></td>
					</tr>
				</tbody>
			</table>
		</section>

		<section id="date" class="tab-pane fade ${tab eq 'date' ? 'in active' : ''}">
			<table class="table table-condensed table-hover table-bordered">
				<thead>
					<tr>
						<th><s:message code="video.date"/></th>
						<th>Rank 0</th>
						<th>Rank 1</th>
						<th>Rank 2</th>
						<th>Rank 3</th>
						<th>Rank 4</th>
						<th>Rank 5</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${dateMap}" var="date" varStatus="status">
					<tr>
						<td style="width:100px;">${date.key} <span class="badge float-right">${fn:length(date.value)}</span></td>
						<td style="max-width:130px;">
							<div id="rank0-${date.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank1-${date.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank2-${date.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank3-${date.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank4-${date.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank5-${date.key}" class="nowrap"></div>
						</td>
					</tr>
						<c:forEach items="${date.value}" var="video" varStatus="status">
							<script type="text/javascript">
								var vItem = $("<span>");
								vItem.addClass("label label-plain");
								vItem.attr("data-opus", "${video.opus}");
								vItem.attr("onclick", "fnViewVideoDetail('${video.opus}')");
								vItem.attr("title", "${video.fullname}");
								$("#rank${video.rank}-${date.key}").append(vItem).append("&nbsp;");
							</script>
						</c:forEach>
					</c:forEach>		
				</tbody>
			</table>
		</section>

		<section id="play" class="tab-pane fade ${tab eq 'play' ? 'in active' : ''}">
			<table class="table table-condensed table-hover table-bordered">
				<thead>
					<tr>
						<th>Play</th>
						<th>Rank 0</th>
						<th>Rank 1</th>
						<th>Rank 2</th>
						<th>Rank 3</th>
						<th>Rank 4</th>
						<th>Rank 5</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${playMap}" var="play" varStatus="status">
					<tr>
						<td style="width:100px;">${play.key} <span class="badge float-right">${fn:length(play.value)}</span></td>
						<td style="max-width:130px;">
							<div id="rank0-${play.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank1-${play.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank2-${play.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank3-${play.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank4-${play.key}" class="nowrap"></div>
						</td>
						<td style="max-width:130px;">
							<div id="rank5-${play.key}" class="nowrap"></div>
						</td>
					</tr>
						<c:forEach items="${play.value}" var="video" varStatus="status">
							<script type="text/javascript">
								var vItem = $("<span>");
								vItem.addClass("label label-plain");
								vItem.attr("data-opus", "${video.opus}");
								vItem.attr("onclick", "fnViewVideoDetail('${video.opus}')");
								vItem.attr("title", "${video.fullname}");
								$("#rank${video.rank}-${play.key}").append(vItem).append("&nbsp;");
							</script>
						</c:forEach>
					</c:forEach>
				</tbody>
			</table>
		</section>

		<section id="rank" class="tab-pane fade ${tab eq 'rank' ? 'in active' : ''}">
			<table class="table table-condensed table-hover table-bordered">
				<thead>
					<tr>
						<th><s:message code="video.rank"/></th>
						<th><s:message code="video.length"/></th>
						<th><s:message code="video.video"/></th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${rankMap}" var="rank" varStatus="status">
					<tr class="nowrap">
						<td style="width: 60px;">${rank.key} <span class="badge float-right">${fn:length(rank.value)}</span></td>
						<td style="width: 80px;" class="text-right">
							<c:set var="totalLength" value="0"/>
							<c:forEach items="${rank.value}" var="video" varStatus="status">
								<c:set var="totalLength" value="${totalLength + video.length}"/>
							</c:forEach>				
							<span class="videoSize"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></span>
						</td>
						<td style="max-width: 760px;">
							<div class="nowrap">
							<c:forEach items="${rank.value}" var="video" varStatus="status">
								<jk:video video="${video}" view="label"/>
							</c:forEach>
							</div>
						</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</section>

		<section id="score" class="tab-pane fade ${tab eq 'score' ? 'in active' : ''}">
			<table class="table table-condensed table-hover table-bordered">
				<thead>
					<tr>
						<th><s:message code="video.score"/></th>
						<th><s:message code="video.length"/></th>
						<th><s:message code="video.length.sum"/></th>
						<th><s:message code="video.video"/></th>
					</tr>
				</thead>
				<tbody>
					<c:set var="totalLength" value="0"/>
					<c:forEach items="${scoreMap}" var="score" varStatus="status">
						<c:set var="stepLength" value="0"/>
						<c:forEach items="${score.value}" var="video" varStatus="status">
							<c:set var="stepLength"  value="${stepLength + video.length}"/>
							<c:set var="totalLength" value="${totalLength + video.length}"/>
						</c:forEach>
					<tr>
						<td style="width: 80px;">${score.key} <span class="badge float-right">${fn:length(score.value)}</span></td>
						<td class="text-right">
							<fmt:formatNumber value="${stepLength / ONE_GB}" pattern="#,##0 GB"/>
						</td>
						<td style="width: 80px;" class="text-right">
							<span class="videoSize"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></span>
						</td>
						<td style="max-width: 660px;">
							<div class="nowrap">
							<c:forEach items="${score.value}" var="video" varStatus="status">
								<jk:video video="${video}" view="label" tooltip="${video.scoreDesc}"/>
							</c:forEach>
							</div>
						</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</section>

		<section id="length" class="tab-pane fade ${tab eq 'length' ? 'in active' : ''}">
			<table class="table table-condensed table-hover table-bordered">
				<thead>
					<tr>
						<th><s:message code="video.length"/></th>
						<th><s:message code="video.length"/></th>
						<th><s:message code="video.video"/></th>
					</tr>
				</thead>
				<tbody>
					<c:set var="totalLength" value="0"/>
					<c:forEach items="${lengthMap}" var="length" varStatus="status">
					<tr>
						<td style="width: 100px;">${length.key} GB↓ <span class="badge float-right">${fn:length(length.value)}</span></td>
						<td style="width: 80px;" class="text-right">
							<c:set var="totalLength" value="0"/>
							<c:forEach items="${length.value}" var="video" varStatus="status">
								<c:set var="totalLength" value="${totalLength + video.length}"/>
							</c:forEach>
							<fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/>
						</td>
						<td style="max-width: 720px;">
							<div class="nowrap">
							<c:forEach items="${length.value}" var="video" varStatus="status">
								<jk:video video="${video}" view="label"/>
							</c:forEach>
							</div>
						</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</section>

		<section id="extension" class="tab-pane fade ${tab eq 'extension' ? 'in active' : ''}">
			<table class="table table-condensed table-hover table-bordered">
				<thead>
					<tr>
						<th><s:message code="video.extension"/></th>
						<th><s:message code="video.length"/></th>
						<th><s:message code="video.video"/></th>
					</tr>
				</thead>
				<tbody>
					<c:set var="totalLength" value="0"/>
					<c:forEach items="${extensionMap}" var="extension" varStatus="status">
					<tr>
						<td style="width: 100px;">${extension.key} <span class="badge float-right">${fn:length(extension.value)}</span></td>
						<td style="width: 100px;" class="text-right">
							<c:set var="totalLength" value="0"/>
							<c:forEach items="${extension.value}" var="video" varStatus="status">
								<c:set var="totalLength" value="${totalLength + video.length}"/>
							</c:forEach>
							<fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/>
						</td>
						<td style="max-width: 700px;">
							<div class="nowrap">
							<c:forEach items="${extension.value}" var="video" varStatus="status">
								<jk:video video="${video}" view="label"/>
							</c:forEach>
							</div>
						</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</section>
<%-- 
		<section id="video" class="tab-pane fade">
			<table class="table table-condensed table-bordered">
				<tr>
					<td>
						<c:forEach items="${videoList}" var="video" varStatus="status">
							<jk:video video="${video}" view="span"/>
						</c:forEach>
					</td>
				</tr>
			</table>
		</section>
 --%>
		<section id="studio" class="tab-pane fade ${tab eq 'studio' ? 'in active' : ''}">
			<ul class="list-inline">
				<c:forEach var="studio" items="${studioList}">
					<li><jk:studio studio="${studio}" view="span"/></li>
				</c:forEach>
			</ul>
		</section>

		<section id="actress" class="tab-pane fade ${tab eq 'actress' ? 'in active' : ''}">
			<ul class="list-inline">
				<c:forEach items="${actressList}" var="actress">
					<li><jk:actress actress="${actress}" view="span"/></li>
				</c:forEach>
			</ul>
		</section>

		<section id="tags" class="tab-pane fade ${tab eq 'tags' ? 'in active' : ''}">
			<ul class="list-inline" id="taglist">
				<c:forEach items="${tagList}" var="tag">
					<li><jk:tags tag="${tag}" view="span"/></li>
				</c:forEach>
			</ul>
			<form action="<c:url value="/video/tag"/>" method="post" role="form" class="form-inline" onsubmit="appendNewTag();" style="margin-top:10px;">
				<input type="hidden" name="_method" id="hiddenHttpMethod2" value="PUT"/>
				<input id="newTagName" name="name" placeholder="name" class="form-control" required="required"/>
				<input id="newTagDesc" name="description" placeholder="Description" class="form-control"/>
				<button class="btn btn-primary" type="submit">Regist</button>
			</form>
			<script type="text/javascript">
			function appendNewTag() {
				var newTag = $("<span>").attr("style", "padding: 5px; margin: 5px; background-color:#ff0;")
								.attr("title", $("#newTagDesc").val())
								.addClass("item box nowrap")
								.html($("#newTagName").val());
				//console.log("tags", $("#taglist"));
				$("#taglist").append(newTag);
			}
			</script>
		</section>

	</div>

</div>
</div>
</body>
</html>