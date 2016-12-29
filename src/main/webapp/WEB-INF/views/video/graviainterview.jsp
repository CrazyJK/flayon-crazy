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
div#content_div ul li a {
	font-size: 12px;
    padding: 5px;
    margin: 0 3px 5px;
    border: 1px solid rgb(51, 122, 183);
}
div#content_div ol li {
	font-size: 12px;
}

</style>
<script type="text/javascript">
bgContinue = false;
function resizeSecondDiv() {
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
	</div>

	<div id="content_div" class="box row" style="overflow:auto;">
		<nav id="crazyScrollspy" class="col-sm-3">
			<ul class="nav nav-pills nav-stacked" data-spy="affix" data-offset-top="0">
				<c:forEach items="${tistoryItemList}" var="item" varStatus="itemStat">
			    <li style="max-width:200px;"><a class="nowrap" href="#item-${itemStat.count}">${item.title} ${item.titles.size()}</a></li>
				</c:forEach>
			</ul>
		</nav>
		<div class="col-sm-9">
			<c:forEach items="${tistoryItemList}" var="item" varStatus="itemStat">
			<div id="item-${itemStat.count}" class="box">
				<h5 class="text-info">${item.title} ${item.titles.size()}</h5>
				<ol>
					<c:forEach items="${item.titles}" var="title" varStatus="titleStat">
					<li>${title}</li>
					</c:forEach>
				</ol>
			</div>
			</c:forEach>
		</div>
	</div>

</div>
</body>
</html>