<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="s"   uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"  tagdir="/WEB-INF/tags"%>

<!DOCTYPE html>
<html lang="${locale}">
<head>
<title><s:message code="video.briefing"/></title>
<style type="text/css">
div#content_div.div-box section {
	margin: 2px;
	border-radius:5px; 
	border: 1px solid orange;
}
div#content_div.div-box h3 {
	margin: 2px;
	padding: 5px;
	cursor: pointer;
	text-shadow: 1px 1px 1px white;
	/* background-color: linen;
	border-radius: 5px;
	opacity: 0.75; */
}
div#content_div.div-box h3:hover {
	border-radius:5px; 
	background-color:rgba(255,165,0,.5);
}
div#content_div.div-box article {
	margin: 10px;
	display: none;
}
#videoDiv, #studioDiv, #actressDiv {
	background-color:rgba(255, 255, 255,.5);
}
.h3-toggle-on {
	border: 1px solid blue;
	border-radius:5px; 
	background-color:rgba(255,165,0,.25);
}

.videoCount {
	float:right;
	color:blue;
}
.videoSize {
	float:right;
	color:green;
}
th {
	text-align: center;
}
td {
	border-top: 1px solid gray;
	border-right: 1px solid gray;
}
</style>
<script type="text/javascript">
$(document).ready(function(){
	
	$("h3").bind("click", function() {
		$(this).next().slideToggle("slow", function() {
			$(this).prev().toggleClass("h3-toggle-on");
		});
	});
	
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
</script>
</head>
<body>

<div id="header_div" class="div-box">
	<label class="item sort-item"><input type="radio" name="viewType" value="normal"/><span>Normal</span></label>
	<label class="item sort-item"><input type="radio" name="viewType" value="simple"/><span>Simple</span></label>

	<em>Max : <s:eval expression="@prop['size.video.storage']"/> GB</em>
				
	<div style="float:right">
		<ul class="menu-item-ul">
			<li class="label-large">
				<a onclick="actionFrame('<c:url value="/video/manager/moveWatchedVideo"/>', 'POST', 'Moving Watched Video')"><s:message code="video.mng.move"/></a>
				<span class="label"><a id="MOVE_WATCHED_VIDEO" onclick="setMOVE_WATCHED_VIDEO()">${MOVE_WATCHED_VIDEO}</a></span>
			</li>
			<li class="label-large">
				<a onclick="actionFrame('<c:url value="/video/manager/removeLowerRankVideo"/>', 'POST', 'Deleting Lower Rank')"><s:message code="video.mng.rank"/></a>
				<span class="label"><a id="DELETE_LOWER_RANK_VIDEO" onclick="setDELETE_LOWER_RANK_VIDEO()">${DELETE_LOWER_RANK_VIDEO}</a></span>
			</li>
			<li class="label-large">
				<a onclick="actionFrame('<c:url value="/video/manager/removeLowerScoreVideo"/>', 'POST', 'Deleting Lower Score')"><s:message code="video.mng.score"/></a>
				<span class="label"><a id="DELETE_LOWER_SCORE_VIDEO" onclick="setDELETE_LOWER_SCORE_VIDEO()">${DELETE_LOWER_SCORE_VIDEO}</a></span>
			</li>
			<li class="label-large">
				<a onclick="actionFrame('<c:url value="/video/reload"/>', 'POST', 'Reloading')"><s:message code="video.reload.title"/></a>
			</li>
		</ul>
	</div>
</div>

<div id="content_div" class="div-box" style="overflow:auto; text-align:left;">

	<section>
		<h3><s:message code="video.video-by-folder"/></h3>
		<article>
			<table class="video-table" style="background-color:lightgray">
				<tr>
					<th style="text-align:left;"><s:message code="video.folder"/></th>
					<th style="text-align:right;"><s:message code="video.size"/></th>
					<th style="text-align:right;"><s:message code="video.length"/></th>
				</tr>
				<c:set var="ONE_GB" value="${1024*1024*1024}"/>
				<c:forEach items="${pathMap}" var="path" varStatus="status">
					<c:choose>
						<c:when test="${path.key ne 'Total'}">
				<tr>
					<td>${path.key}</td>
					<td><span class="videoCount"><fmt:formatNumber value="${path.value[0]}" type="NUMBER"/></span></td>
					<td><span class="videoSize"><fmt:formatNumber value="${path.value[1] / ONE_GB}" pattern="#,##0 GB"/></span></td>
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
					<td style="border-top:1px double blue;"><span class="videoCount"><fmt:formatNumber value="${totalSize}" type="NUMBER"/></span></td>
					<td style="border-top:1px double blue;"><span class="videoSize"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></span></td>
				</tr>
			</table>
		</article>
	</section>

	<section>
		<h3><s:message code="video.video-by-date"/></h3>
		<article>
			<table class="video-table" style="background-color:lightgray">
				<tr>
					<th class="nowrap width50"><s:message code="video.date"/></th>
					<th class="nowrap width-rank">Rank 0</th>
					<th class="nowrap width-rank">Rank 1</th>
					<th class="nowrap width-rank">Rank 2</th>
					<th class="nowrap width-rank">Rank 3</th>
					<th class="nowrap width-rank">Rank 4</th>
					<th class="nowrap width-rank">Rank 5</th>
				</tr>
				<c:forEach items="${dateMap}" var="date" varStatus="status">
				<tr>
					<td class="nowrap">${date.key} <span class="videoCount">${fn:length(date.value)}</span></td>
					<td id="rank0-${date.key}" class="nowrap"></td>
					<td id="rank1-${date.key}" class="nowrap"></td>
					<td id="rank2-${date.key}" class="nowrap"></td>
					<td id="rank3-${date.key}" class="nowrap"></td>
					<td id="rank4-${date.key}" class="nowrap"></td>
					<td id="rank5-${date.key}" class="nowrap"></td>
				</tr>
					<c:forEach items="${date.value}" var="video" varStatus="status">
						<script type="text/javascript">
							var vItem = $("<span>");
							vItem.addClass("label");
							vItem.attr("data-opus", "${video.opus}");
							vItem.attr("onclick", "fnViewVideoDetail('${video.opus}')");
							vItem.attr("title", "${video.fullname}");
							$("#rank${video.rank}-${date.key}").append(vItem);
						</script>
					</c:forEach>
				</c:forEach>		
			</table>
		</article>
	</section>

	<section>
		<h3><s:message code="video.video-by-play"/></h3>
		<article>
			<table class="video-table" style="background-color:lightgray">
				<tr>
					<th class="nowrap width50">Play</th>
					<th class="nowrap width-rank">Rank 0</th>
					<th class="nowrap width-rank">Rank 1</th>
					<th class="nowrap width-rank">Rank 2</th>
					<th class="nowrap width-rank">Rank 3</th>
					<th class="nowrap width-rank">Rank 4</th>
					<th class="nowrap width-rank">Rank 5</th>
				</tr>
				<c:forEach items="${playMap}" var="play" varStatus="status">
				<tr>
					<td class="nowrap">${play.key} <span class="videoCount">${fn:length(play.value)}</span></td>
					<td id="rank0-${play.key}" class="nowrap"></td>
					<td id="rank1-${play.key}" class="nowrap"></td>
					<td id="rank2-${play.key}" class="nowrap"></td>
					<td id="rank3-${play.key}" class="nowrap"></td>
					<td id="rank4-${play.key}" class="nowrap"></td>
					<td id="rank5-${play.key}" class="nowrap"></td>
				</tr>
				<c:forEach items="${play.value}" var="video" varStatus="status">
					<script type="text/javascript">
						var vItem = $("<span>");
						vItem.addClass("label");
						vItem.attr("data-opus", "${video.opus}");
						vItem.attr("onclick", "fnViewVideoDetail('${video.opus}')");
						vItem.attr("title", "${video.fullname}");
						$("#rank${video.rank}-${play.key}").append(vItem);
					</script>
				</c:forEach>
				</c:forEach>		
			</table>
		</article>
	</section>

	<section>
		<h3><s:message code="video.video-by-rank"/></h3>
		<article>
			<table class="video-table" style="background-color:lightgray">
				<tr>
					<th class="nowrap width80"><s:message code="video.rank"/></th>
					<th class="nowrap width60"><s:message code="video.length"/></th>
					<th class="nowrap"><s:message code="video.video"/></th>
				</tr>
				<c:forEach items="${rankMap}" var="rank" varStatus="status">
				<tr>
					<td class="nowrap">${rank.key} <span class="videoCount">${fn:length(rank.value)}</span></td>
					<td class="nowrap right">
						<c:set var="totalLength" value="0"/>
						<c:forEach items="${rank.value}" var="video" varStatus="status">
							<c:set var="totalLength" value="${totalLength + video.length}"/>
						</c:forEach>				
						<span class="videoSize"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></span>
					</td>
					<td class="nowrap">
						<c:forEach items="${rank.value}" var="video" varStatus="status">
							<jk:video video="${video}" view="label"/>
						</c:forEach>
					</td>
				</tr>
				</c:forEach>		
			</table>
		</article>
	</section>

	<section>
		<h3><s:message code="video.video-by-score"/></h3>
		<article>
			<table class="video-table" style="background-color:lightgray">
				<tr>
					<th class="nowrap width80"><s:message code="video.score"/></th>
					<th class="nowrap width60"><s:message code="video.length"/></th>
					<th class="nowrap width60"><s:message code="video.length.sum"/></th>
					<th class="nowrap"><s:message code="video.video"/></th>
				</tr>
				<c:set var="totalLength" value="0"/>
				<c:forEach items="${scoreMap}" var="score" varStatus="status">
					<c:set var="stepLength" value="0"/>
					<c:forEach items="${score.value}" var="video" varStatus="status">
						<c:set var="stepLength"  value="${stepLength + video.length}"/>
						<c:set var="totalLength" value="${totalLength + video.length}"/>
					</c:forEach>
				<tr>
					<td class="nowrap">${score.key} <span class="videoCount">${fn:length(score.value)}</span></td>
					<td class="nowrap right">
						<span class="videoSize"><fmt:formatNumber value="${stepLength / ONE_GB}" pattern="#,##0 GB"/></span>
					</td>
					<td class="nowrap right">
						<span class="videoSize"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></span>
					</td>
					<td class="nowrap">
						<c:forEach items="${score.value}" var="video" varStatus="status">
							<jk:video video="${video}" view="label" tooltip="
${video.scoreDesc}"/>
						</c:forEach>
					</td>
				</tr>
				</c:forEach>		
			</table>
		</article>
	</section>

	<section>
		<h3><s:message code="video.video-by-length"/></h3>
		<article>
			<table class="video-table" style="background-color:lightgray">
				<tr>
					<th class="nowrap width80"><s:message code="video.length"/></th>
					<th class="nowrap width50"><s:message code="video.length"/></th>
					<th class="nowrap"><s:message code="video.video"/></th>
				</tr>
				<c:set var="totalLength" value="0"/>
				<c:forEach items="${lengthMap}" var="length" varStatus="status">
				<tr>
					<td class="nowrap">${length.key} GB↓ <span class="videoCount">${fn:length(length.value)}</span></td>
					<td class="nowrap right">
						<c:set var="totalLength" value="0"/>
						<c:forEach items="${length.value}" var="video" varStatus="status">
							<c:set var="totalLength" value="${totalLength + video.length}"/>
						</c:forEach>
						<span class="videoSize"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></span>
					</td>
					<td class="nowrap">
						<c:forEach items="${length.value}" var="video" varStatus="status">
							<jk:video video="${video}" view="label"/>
						</c:forEach>
					</td>
				</tr>
				</c:forEach>		
			</table>
		</article>
	</section>

	<section>
		<h3><s:message code="video.video-by-extension"/></h3>
		<article>
			<table class="video-table" style="background-color:lightgray">
				<tr>
					<th class="nowrap width80"><s:message code="video.extension"/></th>
					<th class="nowrap width50"><s:message code="video.length"/></th>
					<th class="nowrap"><s:message code="video.video"/></th>
				</tr>
				<c:set var="totalLength" value="0"/>
				<c:forEach items="${extensionMap}" var="extension" varStatus="status">
				<tr>
					<td class="nowrap">${extension.key} <span class="videoCount">${fn:length(extension.value)}</span></td>
					<td class="nowrap right">
						<c:set var="totalLength" value="0"/>
						<c:forEach items="${extension.value}" var="video" varStatus="status">
							<c:set var="totalLength" value="${totalLength + video.length}"/>
						</c:forEach>
						<span class="videoSize"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></span>
					</td>
					<td class="nowrap">
						<c:forEach items="${extension.value}" var="video" varStatus="status">
							<jk:video video="${video}" view="label"/>
						</c:forEach>
					</td>
				</tr>
				</c:forEach>		
			</table>
		</article>
	</section>

	<section>
		<h3><s:message code="video.total"/> <s:message code="video.video"/> : ${fn:length(videoList)}</h3>
		<article id="videoDiv" class="div-box">
			<c:forEach items="${videoList}" var="video" varStatus="status">
				<jk:video video="${video}" view="label"/>
			</c:forEach>
		</article>
	</section>

	<section>
		<h3><s:message code="video.total"/> <s:message code="video.studio"/> : ${fn:length(studioList)}</h3>
		<article id="studioDiv" class="div-box">
		<c:forEach var="studio" items="${studioList}">
			<jk:studio studio="${studio}" view="span"/>
		</c:forEach>
		</article>
	</section>

	<section>
		<h3><s:message code="video.total"/> <s:message code="video.actress"/> : ${fn:length(actressList)}</h3>
		<article id="actressDiv" class="div-box">
		<c:forEach items="${actressList}" var="actress">
			<jk:actress actress="${actress}" view="span"/>
		</c:forEach>
		</article>
	</section>
</div>

</body>
</html>