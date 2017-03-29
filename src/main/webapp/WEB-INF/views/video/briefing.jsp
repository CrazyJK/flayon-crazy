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
<script type="text/javascript">
$(document).ready(function(){

	$(".btn-group-viewType").children().bind("click", function() {
		var viewType = $(this).attr("data-viewType");
		$("[data-opus]").each(function() {
			if (viewType == 'n') {
				$(this).html($(this).attr("data-opus"));
			}
			else {
				$(this).html('O');
			}
		});
	});
	// set initial view
	$('[data-viewType="s"]').click();
	$('[href="#${tab}"]').click();
	
	$('.btn-group-tabs > .btn').addClass('btn-primary');
});

function fsOpen(folder) {
	actionFrame('/flayon/openFolder', {'folder' : folder}, 'POST', 'Open folder ' + folder);
}
</script>
</head>
<body>
<div class="container-fluid">

<div id="header_div" class="box form-inline text-center">
	<label class="title float-left">
		<s:message code="video.briefing"/>
	</label>

	<div class="btn-group btn-group-xs btn-group-viewType float-left" data-toggle="buttons">
		<a role="button" class="btn btn-default" data-viewType="n"><input type="radio"/>Normal</a>
		<a role="button" class="btn btn-default" data-viewType="s"><input type="radio"/>Simple</a>
	</div>

	<div role="group" class="btn-group btn-group-xs btn-group-tabs" data-toggle="buttons">
	    <a role="button" class="btn" data-toggle="tab" href="#folder"    ><input type="radio"/><s:message code="video.video-by-folder"/></a>
	    <a role="button" class="btn" data-toggle="tab" href="#date"	     ><input type="radio"/><s:message code="video.video-by-date"/></a>
	    <a role="button" class="btn" data-toggle="tab" href="#play"	     ><input type="radio"/><s:message code="video.video-by-play"/></a>
		<a role="button" class="btn" data-toggle="tab" href="#rank"	     ><input type="radio"/><s:message code="video.video-by-rank"/></a>
		<a role="button" class="btn" data-toggle="tab" href="#score"     ><input type="radio"/><s:message code="video.video-by-score"/></a>
		<a role="button" class="btn" data-toggle="tab" href="#length"    ><input type="radio"/><s:message code="video.video-by-length"/></a>
		<a role="button" class="btn" data-toggle="tab" href="#extension" ><input type="radio"/><s:message code="video.video-by-extension"/></a>
		<a role="button" class="btn" data-toggle="tab" href="#studio"    ><input type="radio"/><s:message code="video.studio" /> ${studioList.size()}</a>
		<a role="button" class="btn" data-toggle="tab" href="#actress"   ><input type="radio"/><s:message code="video.actress"/> ${actressList.size()}</a>
		<a role="button" class="btn" data-toggle="tab" href="#tags"      ><input type="radio"/><s:message code="video.tags"   /> ${tagList.size()}</a>
	</div>

	<div class="float-right">
		<span class="label label-default">Max : <fmt:formatNumber value="${maxEntireVideo}"/> GB</span>
	</div>

</div>

<div id="content_div" class="box" style="overflow:auto;">
	<div class="tab-content">
		<section id="folder" class="tab-pane fade">
			<table class="table table-condensed table-hover">
				<thead>
					<tr>
						<th><s:message code="video.folder"/></th>
						<th class="text-right"><s:message code="video.size"/></th>
						<th class="text-right"><s:message code="video.length"/></th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${pathMap}" var="path" varStatus="status">
					<c:choose>
						<c:when test="${path.key ne 'Total'}">
					<tr>
						<td><a href="javascript:fsOpen('${fn:replace(path.key, '\\', '/')}')" title="open this folder">${path.key}</a></td>
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
				</tbody>
				<tfoot>
					<tr>
						<td><s:message code="video.total"/></td>
						<td class="text-right"><fmt:formatNumber value="${totalSize}" type="NUMBER"/></td>
						<td class="text-right"><fmt:formatNumber value="${totalLength / ONE_GB}" pattern="#,##0 GB"/></td>
					</tr>
				</tfoot>
			</table>
		</section>

		<section id="date" class="tab-pane fade">
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
								vItem.attr("onclick", "fnVideoDetail('${video.opus}')");
								vItem.attr("title", "${video.fullname}");
								$("#rank${video.rank}-${date.key}").append(vItem).append("&nbsp;");
							</script>
						</c:forEach>
					</c:forEach>		
				</tbody>
			</table>
		</section>

		<section id="play" class="tab-pane fade">
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
								vItem.attr("onclick", "fnVideoDetail('${video.opus}')");
								vItem.attr("title", "${video.fullname}");
								$("#rank${video.rank}-${play.key}").append(vItem).append("&nbsp;");
							</script>
						</c:forEach>
					</c:forEach>
				</tbody>
			</table>
		</section>

		<section id="rank" class="tab-pane fade">
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
						<td style="width: 80px;">${rank.key} <span class="badge float-right">${fn:length(rank.value)}</span></td>
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

		<section id="score" class="tab-pane fade">
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

		<section id="length" class="tab-pane fade">
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

		<section id="extension" class="tab-pane fade">
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
		<section id="studio" class="tab-pane fade">
			<ul class="list-inline">
				<c:forEach var="studio" items="${studioList}">
					<li><jk:studio studio="${studio}" view="span"/></li>
				</c:forEach>
			</ul>
		</section>

		<section id="actress" class="tab-pane fade">
			<ul class="list-inline">
				<c:forEach items="${actressList}" var="actress">
					<li><jk:actress actress="${actress}" view="span"/></li>
				</c:forEach>
			</ul>
		</section>

		<section id="tags" class="tab-pane fade">
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