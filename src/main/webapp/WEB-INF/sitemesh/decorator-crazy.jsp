<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<link rel="shortcut icon" type="image/x-icon" href="<c:url value="/img/favicon-crazy.ico" />"/>
<title><sitemesh:write property='title'>Title goes here</sitemesh:write> - Crazy</title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap-theme.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/video-deco.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/bootstrap-crazy.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/scrollbar.css"/>"/>
<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
<!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/jquery.crazy.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/common.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/video.js"/>"></script>
<script type="text/javascript">
var context = '<c:url value="/"/>';
var videoPath = '<c:url value="/video"/>';
var imagePath = '<c:url value="/image"/>';
var locationPathname = window.location.pathname;
var currBGImageNo = 0;
var bgImageCount = parseInt(${bgImageCount});
/** content_div에 이미지를 보여줄지 여부 */
var bgContinue = true;
var urlSearchVideo = '${urlSearchVideo}';
var urlSearchActress = '${urlSearchActress}';
var urlSearchTorrent = '${urlSearchTorrent}';

$(document).ready(function() {

	//set rank color
 	$('input[type="range"]').each(function() {
 		fnRankColor($(this));
 	});

	// Add listener : if labal click, empty input text value
	$("label").bind("click", function(){
		var id = $(this).attr("for");
		$("#" + id).val("");
	});

 	showNav();
 	
	$(window).bind("resize", resizeDivHeight);

	resizeDivHeight();

	if (bgContinue) {
		setBackgroundImage();
		setInterval(
				function() {
					setBackgroundImage();
				}, 
				60*1000);
	}
	loading(false);
	// bootstrap tooltip initialize
	$('[data-toggle="tooltip"]').tooltip(); 
	
//	$(".box").randomBG(0.2);
//	$("nav#deco_nav").randomBG(0.3);
});

/**
 * 현재 url비교하여 메뉴 선택 효과를 주고, 메뉴 이외의 창에서는 nav를 보이지 않게
 */
function showNav() {
	var found = false;
	$("nav#deco_nav ul li a").each(function() {
		if ($(this).attr("href") == locationPathname) {
			$(this).parent().addClass("active");
			found = true;
		}
	});
	if(!found)
		$("nav#deco_nav").css("display", "none");
}
/**
 * post 액션
 */
function actionFrame(reqUrl, method, msg, interval) {
	$.ajax({
		type : method ? method : "POST",
		url : reqUrl,
		beforeSend : function() {
			loading(true, msg ? msg : "Loading...");
		}
	}).done(function(data) {
		loading(true, msg + " Done", interval ? interval : 2000);
	}).fail(function(jqXHR, textStatus, errorThrown) {
		errorHtml = $.parseHTML(jqXHR.responseText);
		parsed = $('<div/>').append(errorHtml);
		context = parsed.find(".container").html();

		loading(true, "fail : " + reqUrl + " [" + textStatus + "] "+ errorThrown, 0, context);
	}).always(function(data_jqXHR, textStatus, jqXHR_errorThrown) {
//		console.log("actionFrame data_jqXHR", data_jqXHR);
//		console.log("actionFrame textStatus", textStatus);
//		console.log("actionFrame jqXHR_errorThrown", jqXHR_errorThrown);
	});
	/*
	var actionFrm = document.forms['actionFrm'];
	actionFrm.action = url;
	if (method)
		$("#hiddenHttpMethod").val(method);
	actionFrm.submit();
	*/
}
function loading(show, msg, interval, detail) {
	if (show)
		$("#loading").css("display", "table");
	else
		$("#loading").hide();
	if (msg)
		$("#loading-msg").html(msg);
	if (interval)
		$("#loading").fadeOut(interval);
	if (detail) {
		var loadingMsgDetail = $("<div>").attr("id", "loading-msg-detail").addClass("box").html(detail);
		$("#loading-content").append(loadingMsgDetail);
	}
}
var bgToggle = 0;
function toogleBody() {
	$(".container-fluid, .container").animate({
		"opacity": bgToggle % 2
	}, 1000);
	++bgToggle;
	$("#bgActionGroup").toggle({
		duration: 1000
	});
}
</script>

<sitemesh:write property="head" />

</head>
<body>

	<div id="loading">
		<div id="loading-content">
			<div class="loader"></div>
			<span id="loading-msg" class="label"  onclick="loading(false);">Loading</span>
		</div>
	</div>
	<script type="text/javascript">
	loading(true, "Loading...");
	</script> 

	<nav id="deco_nav">
		<ul class="nav nav-pills">
			<li><a onclick="toogleBody()" 			       		><s:message code="video.background.title"/></a>
			<li><a onclick="fnReloadVideoSource()" 	       		><s:message code="video.reload.title"/></a>
			<li><a href="<c:url value="/video"/>"        		><s:message code="video.main"/></a>
			<li><a href="<c:url value="/video/search"/>"		><s:message code="video.search"/></a>
			<li><a href="<c:url value="/video/history/graph"/>"	><s:message code="video.history"/></a>
			<li><a href="<c:url value="/video/list"/>"			><s:message code="video.video"/></a>
			<li><a href="<c:url value="/video/actress"/>"		><s:message code="video.actress"/></a>
			<li><a href="<c:url value="/video/studio"/>"		><s:message code="video.studio"/></a>
			<li><a href="<c:url value="/image"/>"				><s:message code="video.image"/></a>
			<li><a href="<c:url value="/image/canvas"/>"		><s:message code="video.canvas"/></a>
			<li><a href="<c:url value="/image/slides"/>"		><s:message code="video.slides"/></a>
			<li><a href="<c:url value="/video/briefing"/>"		><s:message code="video.briefing"/></a>
			<li><a href="<c:url value="/video/torrent"/>"		><s:message code="video.torrent"/></a>
			<li><a href="<c:url value="/video/parseToTitle"/>"	><s:message code="video.parseToTitle"/></a>
			<li><a href="<c:url value="/video/gravia"/>"		><s:message code="video.gravia"/></a>
			<li><a href="<c:url value="/video/archive"/>"		><s:message code="video.archive"/></a>
			<li><a href="<c:url value="/"/>"					><s:message code="default.home"/></a>
		</ul>
	</nav>

	<sitemesh:write property="body">Body goes here. Blah blah blah.</sitemesh:write>
	
	<form id="actionFrm" name="actionFrm" target="ifrm" method="post"><input type="hidden" name="_method" id="hiddenHttpMethod"/></form>
	<iframe id="actionIframe" name="ifrm" style="display:none; width:100%;"></iframe>

	<div id="bgActionGroup" class="text-center" style="display:none; position: fixed; bottom: 0px; width:100%; padding: 10px; margin: 0 auto;">
		<span class="btn btn-xs btn-success float-right" onclick="setBackgroundImage();">NEXT</span>
		<span class="btn btn-xs btn-info text-center" onclick="fnBGImageView();">VIEW</span>
		<span class="btn btn-xs btn-danger float-left" onclick="fnBGImageDELETE();">DELETE</span>
	</div>

</body>
</html>