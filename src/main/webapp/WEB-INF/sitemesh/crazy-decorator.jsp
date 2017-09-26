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
<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
<!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->
<script type="text/javascript" src="${PATH}/webjars/jQuery/2.2.3/dist/jquery.min.js"></script>
<script type="text/javascript" src="${PATH}/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"></script>
<script type="text/javascript" src="${PATH}/webjars/jquery-ui/1.12.1/jquery-ui.min.js"></script>
<script type="text/javascript" src="${PATH}/js/zeroclipboard/ZeroClipboard.js"></script>
<script type="text/javascript" src="${PATH}/js/flayon.common.js"></script>
<script type="text/javascript" src="${PATH}/js/crazy.decorator.js"></script>
<script type="text/javascript" src="${PATH}/js/crazy.jquery.js"></script>
<script type="text/javascript" src="${PATH}/js/crazy.video.fn.js"></script>
<script type="text/javascript" src="${PATH}/js/crazy.video.js"></script>
<script type="text/javascript">
var console = {}; console.log = function(){};
$(document).ready(function() {
    crazy.ready('${PATH}', '${bgImageCount}', '${urlSearchVideo}', '${urlSearchActress}', '${urlSearchTorrent}');
});
</script>
<sitemesh:write property="head" />
</head>
<body>

	<div id="loading">
		<div id="loading-content">
			<div id="loader">
				<span id="loading-timer" class="label label-danger lead"></span>
			</div>
			<span id="loading-msg" class="label" onclick="loading(false);">Loading</span>
		</div>
		<script type="text/javascript">
		loading(true, loadingText);
		</script> 
	</div>

 	<nav id="deco_nav">
		<ul class="nav nav-pills">
			<li><a class="noti"></a></li>
			<li><a href="${PATH}/video"        		      ><s:message code="video.front"           /></a></li>
			<li id="backMenu"><a onclick="toogleBody()"   ><s:message code="video.background.title"/></a></li>
			<li><a href="${PATH}/video/main"      	      ><s:message code="video.main"            /></a></li>
			<li><a onclick="viewInnerSearchPage()"	      ><s:message code="video.search"          /></a></li>
			<li><a href="${PATH}/video/list_spa"	      ><s:message code="video.video"           /></a></li>
			<li><a href="${PATH}/video/actress"		      ><s:message code="video.actress"         /></a></li>
			<li><a href="${PATH}/video/studio"		      ><s:message code="video.studio"          /></a></li>
			<li class="dropdown">
    			<a class="dropdown-toggle" data-toggle="dropdown" style="cursor:pointer">Image<span class="caret"></span></a>
    			<ul class="dropdown-menu">
					<li><a href="${PATH}/image"			  ><s:message code="video.image"           /></a></li>
					<li><a href="${PATH}/image/aperture"  ><s:message code="video.aperture"        /></a></li>
					<li><a href="${PATH}/image/canvas"	  ><s:message code="video.canvas"          /></a></li>
					<li><a href="${PATH}/image/slides"	  ><s:message code="video.slides"          /></a></li>
					<li><a href="${PATH}/image/lightbox"  ><s:message code="video.lightbox"        /></a></li>
					<li><a href="${PATH}/image/thumbnails"><s:message code="video.thumbnails"      /></a></li>
					<li><a href="${PATH}/image/tablet"    >Tablet</a></li>
    			</ul>
  			</li>
			<li><a href="${PATH}/video/briefing"	      ><s:message code="video.briefing"        /></a></li>
			<li><a href="${PATH}/video/gravia"		      ><s:message code="video.gravia"          /></a></li>
			<li><a href="${PATH}/video/archive"		      ><s:message code="video.archive"         /></a></li>
			<li><a href="${PATH}/video/history/graph"     ><s:message code="video.history"         /></a></li>
			<li><a href="${PATH}/"					      ><s:message code="default.home"          /></a></li>
			<li class="dropdown">
    			<a class="dropdown-toggle" data-toggle="dropdown" style="cursor:pointer">Theme<span class="caret"></span></a>
    			<ul class="dropdown-menu">
					<li><a id="themeSwitchNormal" class="theme-switch-btn">Normal</a></li>
					<li><a id="themeSwitchPlain"  class="theme-switch-btn">Plain</a></li>
    			</ul>
  			</li>
		</ul>
	</nav>

	<sitemesh:write property="body">Body goes here. Blah blah blah.</sitemesh:write>
	
	<div class="hide">
		<form id="actionFrm" name="actionFrm" target="ifrm" method="post"><input type="hidden" name="_method" id="hiddenHttpMethod"/></form>
		<iframe id="actionIframe" name="ifrm" style="display:none; width:100%;"></iframe>
	</div>
	<div id="bgActionGroup" class="text-center" style="display:none; position: fixed; bottom: 0px; width:100%; padding: 10px; margin: 0 auto;">
		<span class="blink-1 float-left"  onclick="fnBGImageDELETE();">DELETE</span>
		<span class="blink-2 float-right" onclick="setBackgroundImage();">NEXT</span>
		<span class="blink-3" onclick="fnBGImageView();">VIEW</span>
		<span class="blink-4"><input id="bgChangeInterval" style="background-color: rgba(0,0,0,0); border: 0; width: 20px; text-align: right; color: cyan;"/>s</span>
	</div>
	<div id="innerSearchPage" class="box">
		<iframe></iframe>
	</div>
	<div id="error" title="Error" style="display:none;">
		<p></p>
	</div>
	<div id="snackbar">
		<strong>message...</strong>
	</div>
	<div role="dynamicStyleWrapper" class="hide">
		<div id="plainStyle"></div>
		<div id="cover-size-style"></div>
	</div>

</body>
</html>
