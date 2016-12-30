<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" 	 uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>Source RSS</title>
<style type="text/css">
.affix-top, .affix {
	position: fixed;
	top: 80px;
}
div#content_div ul.nav li a {
	font-size: 12px;
    padding: 5px;
    margin: 0 3px 5px;
    border: 1px solid rgb(51, 122, 183);
}
div#content_div ol li {
	font-size: 12px;
	display: inline-flex;
    border-radius: 6px;
    border: 1px solid #eee;
    width: 180px;
    height: 230px;
    background-position: center center;
    background-size: contain;
}
div#content_div ol li div {
	width: 100%;
	font-weight: 700;
	vertical-align: bottom;
	text-align: center;
	margin-top: 150px;
}
div#content_div ol li div span {
	background-color: rgba(255, 255, 255, 0.5);
}
</style>
<script type="text/javascript">
bgContinue = false;
function resizeSecondDiv() {
	markOffsetData();
}
$(document).ready(function() {

	markOffsetData();
	lazyLoading();
	
	$("#content_div").scroll(function() {
		lazyLoading();
	});

});
function lazyLoading() {
	var scrollTop = $("#content_div").scrollTop();
//	console.log(scrollTop);
	
	$("div#content_div ol li").each(function() {
		var offsetTop = $(this).data("offsetTop");
		
		if (scrollTop < offsetTop && offsetTop < scrollTop + 900) {
//			console.log("offset.top=" + offsetTop, "scrollTop=" + scrollTop, $(this).attr("id"));
			if ($(this).css("background-image") == 'none') {
				var imgSrc = $(this).attr("data-imgSrc");
//				$(this).css("background-image", "url(" + imgSrc + ")");
			}
		}
	});
}
function markOffsetData() {
	$("div#content_div ol li").each(function() {
		var cord = $(this).offset();
		var id = $(this).attr("id");
		$(this).data("offsetTop", cord.top);
		// $("#span-" + id).html(cord.top + " : " + id);
	});
}
</script>
</head>
<body>

<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
		<label class="title">
			GraviaInterview source
		</label>
		<input type="search" id="query" class="form-control input-sm" placeholder="Opus Actress Torrent"/>
		<div class="btn-group">
			<a class="btn btn-xs btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"><s:message code="video.opus"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
			<a class="btn btn-xs btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
		</div>
		<a href="?mode=text">Text</a>
		<a href="?mode=image">Image</a>
		
	</div>

	<div id="content_div" class="box row" style="overflow:auto;">
		<nav id="crazyScrollspy" class="col-sm-2">
			<ul class="nav nav-pills nav-stacked" data-spy="affix" data-offset-top="0">
				<c:forEach items="${tistoryGraviaItemList}" var="item" varStatus="itemStat">
			    <li style="max-width:150px;"><a class="nowrap" href="#item-${itemStat.count}">${item.title} ${item.titles.size()}</a></li>
				</c:forEach>
			</ul>
		</nav>
		<div class="col-sm-10">
			<c:forEach items="${tistoryGraviaItemList}" var="item" varStatus="itemStat">
			<div id="item-${itemStat.count}" class="box">
				<h5 class="text-info">${item.title} ${item.titles.size()}</h5>
				<ol>
					<c:forEach items="${item.titles}" var="title" varStatus="titleStat">
					<li id="item-${itemStat.count}-${titleStat.count}" data-imgSrc="${title.imgSrc}">
						<div class="${title.check ? 'text-danger' : 'text-primary'}">
							<span>
								${title.opus}<br/>
								${title.actress}<br/>
								${title.release}<br/>
								${title.title}<br/><br/>
							</span>
							<%-- <span id="span-item-${itemStat.count}-${titleStat.count}" class="label label-info"></span> --%>
						</div>
					</li>
					</c:forEach>
				</ol>
			</div>
			</c:forEach>
		</div>
	</div>

</div>
</body>
</html>