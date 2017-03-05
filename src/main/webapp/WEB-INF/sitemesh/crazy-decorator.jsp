<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%--  manifest="<c:url value="/crazy.appcache"/>" --%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<link rel="shortcut icon" type="image/x-icon" href="<c:url value="/img/favicon-crazy.ico" />"/>
<title><sitemesh:write property='title'>Title goes here</sitemesh:write> - Crazy [${profiles}] [<%=System.getenv("COMPUTERNAME")%>]</title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap-theme.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/base-scrollbar.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/crazy-deco.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/crazy-common.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/crazy-bootstrap.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/neon.css"/>" type="text/css" media="screen"/>
<link rel="stylesheet" href="<c:url value="/css/aperture.css"/>" type="text/css" media="screen"/>
<link rel="stylesheet" href="<c:url value="/jquery-ui/1.12.1/jquery-ui.min.css"/>"/>
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
<script type="text/javascript" src="<c:url value="/js/videoMain.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/jquery.crazy.aperture.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/zeroclipboard/ZeroClipboard.js"/>"></script>
<script type="text/javascript" src="<c:url value="/jquery-ui/1.12.1/jquery-ui.min.js"/>"></script>
<script type="text/javascript">
var context = '<c:url value="/"/>';
var videoPath = '<c:url value="/video"/>';
var imagePath = '<c:url value="/image"/>';
var locationPathname = window.location.pathname;
var currBGImageNo = 0;
var bgImageCount = parseInt('${bgImageCount}');
/** content_div에 이미지를 보여줄지 여부 */
var bgContinue = true;
var urlSearchVideo = '${urlSearchVideo}';
var urlSearchActress = '${urlSearchActress}';
var urlSearchTorrent = '${urlSearchTorrent}';
var tSec = 1;
var timer;
var neon = '${param.neon}' === 'true' ? true : false;
var bgChangeInterval = 60;
var bgImageChange;
var listViewType;
var windowWidth = 0;
var windowHeight = 0;
var pingInterval = 5000;

window.onerror = function (e) {
	console.log('Error: ', e);
	$("#error > p").html('Error: ' + e);
	$("#error").dialog();
	loading(false);
};

$(document).ready(function() {

	$("#header_div").css("background-image", "linear-gradient(to bottom, #fff 0, " + randomColor(0.3) + " 100%)");
	$("#content_div").css("background-color", randomColor(0.3));
	
	//set rank color
 	$('input[type="range"].input-range').each(function() {
		var opus = $(this).attr("data-opus");
		fnRankColor($(this), $("#Rank-"+opus+"-label"));
 	});

	// Add listener : if labal click, empty input text value
	$("label").bind("click", function(){
		var id = $(this).attr("for");
		$("#" + id).val("");
	});

 	showNav();
 	
	$("#deco_nav a[href]").on("click", function() {
		loading(true, "Loading");
	});
	$("#header_div form").submit(function(event) {
		console.log("form submit...");
		loading(true, "form submit");
	});
	
	$(window).bind("resize", resizeDivHeight);

	resizeDivHeight();

	if (bgContinue) {
		$("#bgChangeInterval").val(bgChangeInterval);
		setBackgroundImage();
		bgImageChange = setInterval(setBackgroundImage, bgChangeInterval * 1000);
	}
	
	$("#bgChangeInterval").on("keyup", function() {
		bgChangeInterval = parseInt($(this).val());
		clearInterval(bgImageChange);
		setBackgroundImage();
		bgImageChange = setInterval(setBackgroundImage, bgChangeInterval * 1000);
		console.log("bgChangeInterval", bgChangeInterval, bgImageChange);
	});
	
	// bootstrap tooltip initialize
	$('[data-toggle="tooltip"]').tooltip(); 

	if (neon) {
		// add neon for nav
//		$("#deco_nav li.active").addClass("blink-4");
//		$("#deco_nav a[href]").not(".blink-4").each(function() {
//			$(this).addClass("blink-" + getRandomInteger(1, 3)).css("color", "#eee");
//		});
		$("#deco_nav a").each(function() {
			$(this).addClass("blink-" + getRandomInteger(1, 10)).css({color: "#fff"});
		});
		$("#deco_nav").css({backgroundColor: "rgba(0, 0, 0, .5)"});
		/* add neon for each */
		var styles = {color: "#eee", fontWeight: "bold", backgroundColor: "rgba(0, 0, 0, .5)"};
		$(".title, #loading-msg, #loading-timer").each(function() {
			$(this).addClass("blink-" + getRandomInteger(1, 10)).css(styles);
		});
		/*
	 	var selectors1 = ".label, .btn, label, h4, .item, th, .slidesjs-navigation, .slidesjs-pagination-item, select, input[type=text], input[type=search]";
	 	var selectors2 = "#header_div input[type=text], #header_div input[type=search], #header_div .label, #header_div select, #header_div .btn, #header_div label";
		$(selectors1).each(function() {
			$(this).addClass("blink-" + getRandomInteger(1, 10)).css("color", "#eee").css("font-weight", "bold");
		});
		$("#header_div .label").not("[id^='checkbox']").css("background-color", "rgba(0, 0, 0, .5)");
		$("#header_div .btn").css("background-color", "rgba(0, 0, 0, .5)").removeClass("btn-default");
		$("#header_div select").css("font-family", "'clipregular', sans-serif").css("background-color", "rgba(0, 0, 0, .5)");
		$("#header_div input[type=text], #header_div input[type=search]").css("background-color", "rgba(0, 0, 0, .5)").css("color", "#eee");
		*/
	}	

	loading(false);

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
	
});

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
	
	if (locationPathname.startsWith("/image")) {
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
			loading(true, msg ? msg : "Loading...");
		}
	}).done(function(data, textStatus, jqXHR) {
		loading(false);
		if (jqXHR.getResponseHeader('error') == 'true') {
			var errorMessge = jqXHR.getResponseHeader('error.message');
			loading(true, 'Fail : ' + errorMessge, 10000);
		}
		else {
//			loading(true, msg + " Done", interval ? interval : 2000);
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

var bgToggle = 0;
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
var isLoadedSearchPage = false;
function viewInnerSearchPage() {
	if (!isLoadedSearchPage) {
		$("#innerSearchPage > iframe").attr({"src": "<c:url value="/video/search"/>"});
		isLoadedSearchPage = true;
	}
	$("#innerSearchPage").css({"box-shadow": "0 0 15px 10px " + randomColor(0.5)}).toggle();
	
}

function showSnackbar(message, time) {
	var x = document.getElementById("snackbar")
	x.innerHTML = message;
    x.className = "show";
    if (!time) time = 3000; 
    setTimeout(function(){ x.className = x.className.replace("show", ""); }, time);
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
	</div>
	<script type="text/javascript">
	loading(true, "Loading...");
	</script> 

 	<nav id="deco_nav">
		<ul class="nav nav-pills">
			<li><a class="noti text-danger"></a></li>
			<li><a href="<c:url value="/video"/>"        		><s:message code="video.front"/></a>
			<li id="backMenu"><a onclick="toogleBody()" 			       		><s:message code="video.background.title"/></a>
			<%-- <li><a onclick="fnReloadVideoSource()" 		><s:message code="video.reload.title"/></a> --%>
			<li><a href="<c:url value="/video/main"/>"      	><s:message code="video.main"/></a>
			<%-- <li><a href="<c:url value="/video/search"/>"	><s:message code="video.search"/></a> --%>
			<li><a onclick="viewInnerSearchPage()"	            ><s:message code="video.search"/></a>
			<%-- <li><a href="<c:url value="/video/list"/>"			><s:message code="video.video"/></a> --%>
			<li><a href="<c:url value="/video/list_spa"/>"		><s:message code="video.video"/></a>
			<li><a href="<c:url value="/video/actress"/>"		><s:message code="video.actress"/></a>
			<li><a href="<c:url value="/video/studio"/>"		><s:message code="video.studio"/></a>
			<li class="dropdown">
    			<a class="dropdown-toggle" data-toggle="dropdown" style="cursor:pointer">Image<span class="caret"></span></a>
    			<ul class="dropdown-menu">
					<li><a href="<c:url value="/image"/>"				><s:message code="video.image"/></a>
					<li><a href="<c:url value="/image/aperture"/>"		>Aperture</a>
					<li><a href="<c:url value="/image/canvas"/>"		><s:message code="video.canvas"/></a>
					<li><a href="<c:url value="/image/slides"/>"		><s:message code="video.slides"/></a>
					<li><a href="<c:url value="/image/lightbox"/>"		>Lightbox</a>
					<li><a href="<c:url value="/image/thumbnails"/>"	>Thumbnails</a>
    			</ul>
  			</li>
			<li><a href="<c:url value="/video/briefing"/>"		><s:message code="video.briefing"/></a>
			<%-- <li><a href="<c:url value="/video/torrent"/>"		><s:message code="video.torrent"/></a> --%>
			<%-- <li><a href="<c:url value="/video/parseToTitle"/>"	><s:message code="video.parseToTitle"/></a> --%>
			<li><a href="<c:url value="/video/gravia"/>"		><s:message code="video.gravia"/></a>
			<li><a href="<c:url value="/video/archive"/>"		><s:message code="video.archive"/></a>
			<li><a href="<c:url value="/video/history/graph"/>"	><s:message code="video.history"/></a>
			<li><a href="<c:url value="/"/>"					><s:message code="default.home"/></a>
		</ul>
	</nav>

	<sitemesh:write property="body">Body goes here. Blah blah blah.</sitemesh:write>
	
	<form id="actionFrm" name="actionFrm" target="ifrm" method="post"><input type="hidden" name="_method" id="hiddenHttpMethod"/></form>
	<iframe id="actionIframe" name="ifrm" style="display:none; width:100%;"></iframe>

	<div id="bgActionGroup" class="text-center" style="display:none; position: fixed; bottom: 0px; width:100%; padding: 10px; margin: 0 auto;">
		<span class="blink-1 float-right" onclick="setBackgroundImage();">NEXT</span>
		<span class="blink-2 text-center" onclick="fnBGImageView();">VIEW</span>
		<span class="blink-4">
			<input id="bgChangeInterval" style="background-color: rgba(0,0,0,0); border: 0; width: 20px; text-align: right; color: cyan;"/>s
		</span>
		<span class="blink-3 float-left" onclick="fnBGImageDELETE();">DELETE</span>
	</div>

	<div id="innerSearchPage" class="box">
		<iframe></iframe>
	</div>

	<div id="error" title="Error" style="display:none;">
		<p></p>
	</div>

	<div id="snackbar">Some text some message..</div>

</body>
</html>