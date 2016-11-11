<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" 	 uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>Source RSS</title>
</head>
<body>
<div class="container-fluid" role="main">

<form method="post" onsubmit="loading(true, 'Parsing...')">

	<div id="header_div" class="box form-inline">
		<a class="btn btn-xs btn-default" onclick="toggleInputDiv()" id="hideBtn">hide</a>
		<a class="btn btn-xs btn-default" onclick="document.forms[0].submit();">Parse <i class="badge">${tistoryItemList.size()}</i></a>	
		<input type="search" id="query" class="form-control input-sm" placeholder="Opus Actress Torrent"/>
			<div class="btn-group">
				<a class="btn btn-xs btn-default" onclick="fnSearchOpus()"    title="<s:message code="video.find-info.opus"/>"><s:message code="video.opus"/></a>
				<a class="btn btn-xs btn-default" onclick="fnSearchActress()" title="<s:message code="video.find-info.actress"/>"><s:message code="video.actress"/></a>
				<a class="btn btn-xs btn-default" onclick="fnSearchTorrent()" title="<s:message code="video.find-info.torrent"/>"><s:message code="video.torrent"/></a>
			</div>
	</div>

	<div id="content_div" class="box" style="overflow:auto;">
	
		<ul class="nav nav-tabs">
			<c:forEach items="${tistoryItemList}" var="item" varStatus="itemStat">
		    <li class="${itemStat.index == 0 ? 'active' : ''}">
		    	<a data-toggle="tab" href="#item${itemStat.count}">
		    		${item.title}
			    	<i class="badge">${item.titles.size()}</i>
		    	</a>
		    </li>
			</c:forEach>
		</ul>
	
		<div class="tab-content">
			<c:forEach items="${tistoryItemList}" var="item" varStatus="itemStat">
			<section id="item${itemStat.count}" class="tab-pane fade ${itemStat.index == 0 ? 'in active' : ''}">
				<ul class="list-inlinex">
					<c:forEach items="${item.titles}" var="title" varStatus="titleStat">
					<li>
						<div class="box box-small">
							${title}
						</div>
					</li>
					</c:forEach>
				</ul>
			</section>
			</c:forEach>
		</div>
	</div>

</form>

</div>
</body>
</html>