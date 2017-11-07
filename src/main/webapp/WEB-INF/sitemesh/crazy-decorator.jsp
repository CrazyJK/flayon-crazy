<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%--  manifest="<c:url value="/crazy.appcache"/>" --%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title><sitemesh:write property='title'>Title goes here</sitemesh:write> - Crazy [${profiles}] [<%=System.getenv("COMPUTERNAME")%>]</title>
<link rel="shortcut icon" type="image/x-icon" href="${PATH}/img/flayon/favicon-crazy.ico"/>
<link rel="stylesheet" href="${PATH}/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>
<link rel="stylesheet" href="${PATH}/webjars/bootstrap/3.3.6/dist/css/bootstrap-theme.min.css"/>
<link rel="stylesheet" href="${PATH}/webjars/jquery-ui/1.12.1/themes/base/jquery-ui.min.css"/>
<link rel="stylesheet" href="${PATH}/css/base-scrollbar.css"/>
<link rel="stylesheet" href="${PATH}/css/crazy-deco.css"/>
<link rel="stylesheet" href="${PATH}/css/crazy-common.css"/>
<link rel="stylesheet" href="${PATH}/css/crazy-bootstrap.css"/>
<link rel="stylesheet" href="${PATH}/css/videoMain.css"/>
<link rel="stylesheet" href="${PATH}/css/neon.css"/>
<link rel="stylesheet" href="${PATH}/css/aperture.css"/>
<link rel="stylesheet" href="${PATH}/css/range.css"/>
<script type="text/javascript" src="${PATH}/webjars/jQuery/2.2.3/dist/jquery.min.js"></script>
<script type="text/javascript" src="${PATH}/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"></script>
<script type="text/javascript" src="${PATH}/webjars/jquery-ui/1.12.1/jquery-ui.min.js"></script>
<script type="text/javascript" src="${PATH}/js/zeroclipboard/ZeroClipboard.js"></script>
<script type="text/javascript" src="${PATH}/js/flayon.common.js"></script>
<script type="text/javascript" src="${PATH}/js/crazy.decorator.js"></script>
<script type="text/javascript" src="${PATH}/js/crazy.jquery.js"></script>
<script type="text/javascript" src="${PATH}/js/crazy.video.fn.js"></script>
<script type="text/javascript">
//var console = {}; console.log = function(){};
$(document).ready(function() {
    crazy.ready('${PATH}', '${bgImageCount}', '${urlSearchVideo}', '${urlSearchActress}', '${urlSearchTorrent}');
});
</script>
<sitemesh:write property="head">HEAD element area</sitemesh:write>
</head>
<body>

	<div id="loading-wrapper">
		<div id="loading">
			<div id="loading-content">
				<div id="loader">
					<span id="loading-timer">0</span>
				</div>
				<span id="loading-msg" class="box label" onclick="loading(false);">Loading</span>
				<br><br>
				<div id="loading-msg-detail" class="box hide"></div>
			</div>
		</div>
		<script type="text/javascript">loading(true, 'Page initiate');</script> 
	</div>

 	<nav id="deco_nav">
		<ul class="nav nav-pills">
			<li><a class="noti"></a></li>
			<li><a href="${PATH}/video"        	><s:message code="video.front"           /></a></li>
			<li><a id="backMenu" 				><s:message code="video.background.title"/></a></li>
			<li><a href="${PATH}/video/main"    ><s:message code="video.main"            /></a></li>
			<li><a id="searchMenu" 	    		><s:message code="video.search"          /></a></li>
			<li><a href="${PATH}/video/list_spa"><s:message code="video.video"           /></a></li>
			<li><a href="${PATH}/video/actress"	><s:message code="video.actress"         /></a></li>
			<li><a href="${PATH}/video/studio"	><s:message code="video.studio"          /></a></li>
			<li class="dropdown">
    			<a class="dropdown-toggle" data-toggle="dropdown"><s:message code="video.image"/><span class="caret"></span></a>
    			<ul class="dropdown-menu">
					<li><a href="${PATH}/image"			  ><s:message code="video.image"     /></a></li>
					<li><a href="${PATH}/image/aperture"  ><s:message code="video.aperture"  /></a></li>
					<li><a href="${PATH}/image/canvas"	  ><s:message code="video.canvas"    /></a></li>
					<li><a href="${PATH}/image/slides"	  ><s:message code="video.slides"    /></a></li>
					<li><a href="${PATH}/image/lightbox"  ><s:message code="video.lightbox"  /></a></li>
					<li><a href="${PATH}/image/thumbnails"><s:message code="video.thumbnails"/></a></li>
					<li><a href="${PATH}/image/tablet"    ><s:message code="video.tablet"    /></a></li>
    			</ul>
  			</li>
			<li><a href="${PATH}/video/briefing"	 ><s:message code="video.briefing"/></a></li>
			<li><a href="${PATH}/video/gravia"		 ><s:message code="video.gravia"  /></a></li>
			<li><a href="${PATH}/video/archive"		 ><s:message code="video.archive" /></a></li>
			<li><a href="${PATH}/video/history"      ><s:message code="video.history" /></a></li>
			<li><a href="${PATH}/"					 ><s:message code="default.home"  /></a></li>
			<li class="dropdown">
    			<a class="dropdown-toggle" data-toggle="dropdown"><s:message code="default.theme"/><span class="caret"></span></a>
    			<ul class="dropdown-menu">
					<li><a id="themeSwitchNormal"><s:message code="default.theme.normal"/></a></li>
					<li><a id="themeSwitchPlain" ><s:message code="default.theme.plain"/></a></li>
    			</ul>
  			</li>
		</ul>
	</nav>

	<sitemesh:write property="body">Body goes here. Blah blah blah.</sitemesh:write>

	<div>
		<div id="actionForm">
			<form id="actionFrm" name="actionFrm" target="ifrm" method="post">
				<input type="hidden" name="_method" id="hiddenHttpMethod"/>
			</form>
			<iframe id="actionIframe" name="ifrm"></iframe>
		</div>
		<div id="bgActionGroup">
			<span class="blink-1 pull-left"  id="deleteBgBtn">DELETE</span>
			<span class="blink-2 pull-right" id="nextBgBtn"  >NEXT</span>
			<span class="blink-3"            id="popupBgBtn" >VIEW</span>
			<span class="blink-4"><input id="bgChangeInterval"/>s</span>
		</div>
		<div id="innerSearchPage" class="box">
			<iframe></iframe>
		</div>
		<div id="notice" title="Error">
			<p></p>
		</div>
		<div id="snackbar">
			<strong>message...</strong>
		</div>
		<div id="dynamicStyleWrapper">
			<div id="plainStyle"></div>
			<div id="coverSizeStyle"></div>
		</div>
	</div>

</body>
</html>
