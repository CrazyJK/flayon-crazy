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
<link rel="shortcut icon" type="image/x-icon" href="${PATH}/img/favicon-crazy.ico"/>
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
<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
<!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->
<script type="text/javascript" src="${PATH}/webjars/jQuery/2.2.3/dist/jquery.min.js"></script>
<script type="text/javascript" src="${PATH}/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"></script>
<script type="text/javascript" src="${PATH}/webjars/jquery-ui/1.12.1/jquery-ui.min.js"></script>
<script type="text/javascript" src="${PATH}/js/jquery.crazy.js"></script>
<script type="text/javascript" src="${PATH}/js/common.js"></script>
<script type="text/javascript" src="${PATH}/js/video.js"></script>
<script type="text/javascript" src="${PATH}/js/videoMain.js"></script>
<script type="text/javascript" src="${PATH}/js/jquery.crazy.aperture.js"></script>
<script type="text/javascript" src="${PATH}/js/zeroclipboard/ZeroClipboard.js"></script>
<script type="text/javascript">
var videoPath = '${PATH}/video';
var imagePath = '${PATH}/image';
var locationPathname = window.location.pathname;
var currBGImageNo = 0;
var bgImageCount = parseInt('${bgImageCount}');
var bgContinue = true;	/** content_div에 이미지를 보여줄지 여부 */
var urlSearchVideo   = '${urlSearchVideo}';
var urlSearchActress = '${urlSearchActress}';
var urlSearchTorrent = '${urlSearchTorrent}';
var tSec = 1;
var timer;
var bgChangeInterval = 60;
var bgImageChanger;
var listViewType;
var windowWidth = 0;
var windowHeight = 0;
var pingInterval = 5000;
var themeSwitch = getlocalStorageItem("crazy-decorator.theme-switch",  'normal');
var bgToggle = 0;
var isLoadedSearchPage = false;
var loadingText = 'Loading...';

window.onerror = function (e) {
	console.log('Error: ', e);
	$("#error > p").html('Error: ' + e);
	$("#error").dialog();
	loading(false);
};

$(document).ready(function() {
 	addLinkListener();
	addBGChangerListener();
	addResizeListener();

	ping();

	setRankColor();
 	showNav();
	resizeDivHeight();
	$('[data-toggle="tooltip"]').tooltip(); // bootstrap tooltip initialize 
	toogleTheme(themeSwitch);
	loading(false);
});

function addResizeListener() {
	$(window).bind("resize", resizeDivHeight);
}

function addLinkListener() {
	$("#deco_nav a[href]").on("click", function() {
		loading(true, loadingText);
	});
	$("#header_div form").submit(function(event) {
		console.log("form submit...");
		loading(true, "form submit");
	});
}

function addBGChangerListener() {
	$("#bgChangeInterval").on("keyup", function() {
		bgChangeInterval = parseInt($(this).val());
		clearInterval(bgImageChanger);
		setBackgroundImage();
		bgImageChanger = setInterval(setBackgroundImage, bgChangeInterval * 1000);
		console.log("bgChangeInterval", bgChangeInterval, bgImageChanger);
	});
}

function setRankColor() {
 	$('input[type="range"].rank-range').each(function() {
		var opus = $(this).attr("data-opus");
		fnRankColor($(this), $("#Rank-"+opus+"-label"));
 	});
}

/**
 * start ping
 */
function ping() {
	if (locationPathname != (videoPath + '/search')) {
		setInterval(function() {
			$.getJSON({
				method: 'GET',
				url: videoPath + '/ping.json',
				data: {},
				cache: false
			}).done(function(data) {
				if (data.exception) {
					console.log("ping : error", data.exception.message);
				}
				else {
					if (data.noti.length > 0) {
						$(".noti").html(data.noti).show().fadeOut(pingInterval);
						console.log("ping : ", data.noti);
					}
				}
			}).fail(function(jqxhr, textStatus, error) {
				console.log("ping : fail", textStatus + ", " + error);
			}).always(function() {
				//console.log("ping.json", new Date());
			});	
		}, pingInterval);
	}
}

/**
 * 현재 url비교하여 메뉴 선택 효과를 주고, 메뉴 이외의 창에서는 nav를 보이지 않게
 */
function showNav() {
	var found = false;
	$("nav#deco_nav ul li a").each(function() {
		// console.log($(this).attr("href"), locationPathname);
		if ($(this).attr("href") === locationPathname || $(this).attr("href") + '/' === locationPathname) {
			$(this).parent().addClass("active");
			found = true;
		}
	});
	if(!found)
		$("nav#deco_nav").hide();
	
	if (locationPathname.startsWith(imagePath)) {
		$("#backMenu").hide();
	}
}

/**
 * post 액션
 */
function actionFrame(reqUrl, reqData, method, msg, interval) {
	console.log("actionFrame", reqUrl, reqData, method, msg, interval);
	$.ajax({
		type: method ? method : "POST",
		url: reqUrl,
		data: reqData,
		beforeSend : function() {
			loading(true, msg ? msg : loadingText);
		}
	}).done(function(data, textStatus, jqXHR) {
		loading(false);
		if (jqXHR.getResponseHeader('error') == 'true') {
			var errorMessge = jqXHR.getResponseHeader('error.message');
			loading(true, 'Fail : ' + errorMessge, 10000);
		}
		else {
			loading(false);
			showSnackbar(msg + " Done", interval ? interval : 2000);
		}
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

/**
 * loading layer control
 */
function loading(show, msg, interval, detail) {
	console.log("loading", show, msg, interval, detail);
	if (show) {
		$("#loading").css("display", "table");
		tSec = 1;
		timer = setInterval(function() {loadingTimer(true)}, 1000);
	}
	else {
		$("#loading").hide();
		loadingTimer(false);
	}
	
	if (msg)
		$("#loading-msg").html(msg);
	
	if (interval)
		$("#loading").fadeOut(interval, function() {
			loadingTimer(false);
		});
	
	if (detail) {
		var loadingMsgDetail = $("<div>").attr("id", "loading-msg-detail").addClass("box").html(detail);
		$("#loading-content").append(loadingMsgDetail);
	}

	function loadingTimer(start) {
		console.log("loadingTimer", start, tSec);
		if (start) {
			$("#loading-timer").html(tSec++);
		}
		else {
			clearInterval(timer);
		}
	}
}

/**
 * toggle body background image
 */
function toogleBody() {
	$(".container-fluid, .container").animate({
		"opacity": bgToggle++ % 2
	}, 1000);
	$("#bgActionGroup").css({"padding-top": windowHeight - 60}).toggle({
		duration: 1000
	});
}
/*
// 페이지 로드시 새로 캐쉬받아야 하는지 확인.
window.addEventListener('load', function(e) {

  window.applicationCache.addEventListener('updateready', function(e) {
    if (window.applicationCache.status == window.applicationCache.UPDATEREADY) {
      // 브라우저가 새 앱 캐시를 다운받는다. 
      // 캐시를 교체하고, 따끈따끈한 새 파일을 받기위해 페이지 리로드.
      window.applicationCache.swapCache();
      if (confirm('A new version of this site is available. Load it?')) {
        window.location.reload();
      }
    } else {
      // 메니페스트 파일이 바뀐게 없다. 제공할 새로운게 없음.
    }
  }, false);

}, false);
*/

/**
 * search page control
 */
function viewInnerSearchPage() {
	if (!isLoadedSearchPage) {
		$("#innerSearchPage > iframe").attr({"src": "${PATH}/video/search"});
		isLoadedSearchPage = true;
	}
	if (themeSwitch === 'plain')
		$("#innerSearchPage").css({boxShadow: "0 0 15px 10px rgba(0,0,0,.5)"}).toggle();
	else
		$("#innerSearchPage").css({boxShadow: "0 0 15px 10px " + randomColor(0.5)}).toggle();
}

/**
 * snackbar control
 */
function showSnackbar(message, time) {
    if (!time) time = 3000; 
	$("#snackbar").addClass("show").find("strong").html(message);
	setTimeout(function(){
		$("#snackbar").removeClass("show"); 
	}, time);
}

/**
 * toggle theme
 */
function toogleTheme(themeName) {
	if (locationPathname.startsWith(imagePath)) {
		if (locationPathname === imagePath + '/thumbnails') {
			if (themeName === 'normal') {
				$("#plainStyle").empty();
				$("#header_div" ).css({backgroundImage: 'linear-gradient(to bottom, #fff 0, ' + randomColor(0.3) + ' 100%)'});
				$("#content_div").css({backgroundColor: randomColor(0.3)});
			}
			if (themeName === 'plain') {
				$("#plainStyle").empty().append(
					'<style>'
						+ ' #header_div, #content_div {background: transparent none !important; box-shadow: none !important;}'
					+ '</style>'
				);
			}
		}
		return;
	}
	else {
		if (themeName === 'normal') {
			if (bgContinue) {
				$("#bgChangeInterval").val(bgChangeInterval);
				setBackgroundImage();
				bgImageChanger = setInterval(setBackgroundImage, bgChangeInterval * 1000);
			}
			$("#header_div" ).css({backgroundImage: 'linear-gradient(to bottom, #fff 0, ' + randomColor(0.3) + ' 100%)'});
			$("#content_div").css({backgroundColor: randomColor(0.3)});
			$("#plainStyle").empty();
			$("#backMenu").show();
		}
		if (themeName === 'plain') {
			clearInterval(bgImageChanger);
			$("#plainStyle").empty().append(
				'<style>'
					+ ' body {background: transparent none !important;}'
					+ ' #header_div, #content_div {background: transparent none !important; box-shadow: none !important;}'
					+ ' dl.box.box-small, div.box.box-small, #resultVideoDiv, #resultHistoryDiv {box-shadow: none !important; background-color: transparent !important;}'
					+ ' .btn {background: transparent none !important; color: #333;}'
				 	+ ' .table-hover > tbody > tr:hover, .table-hover > tbody > tr:focus {background-color: rgba(38, 90, 136, .1);}'
				 	+ ' .border-shadow {box-shadow: none;}'
					+ ' .btn:hover, .btn:focus, .btn-primary.active, .btn-primary.active:focus {color: #333; box-shadow: 0 0 10px 0 rgba(38, 90, 136, .5) inset !important;}'
					+ ' .label-success, .label-info, .label-warning, .label-primary, .label-danger {background-color: rgba(38, 90, 136, .5);}'
				 	+ ' .favorite {box-shadow: 0 0 10px 0 rgba(38, 90, 136, .5) inset !important;}'
				+ '</style>'
			);
			$("#backMenu").hide();
		}
	}
	themeSwitch = themeName;
	try {neonEffect()} catch(e) {}
	propagateTheme();
	setlocalStorageItem("crazy-decorator.theme-switch", themeSwitch);
}

function propagateTheme() {
	if (isLoadedSearchPage) {
		$("#innerSearchPage > iframe").get(0).contentWindow.toogleTheme(themeSwitch);
	}
}
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
			<li><a class="noti text-danger"></a></li>
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
					<li><a onclick="toogleTheme('normal')">Normal</a></li>
					<li><a onclick="toogleTheme('plain')">Plain</a></li>
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
