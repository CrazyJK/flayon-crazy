<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%
String lang = "ko";
try {
	lang = new org.springframework.web.servlet.support.RequestContext(request).getLocale().getLanguage();
} catch(Exception e) {}
%>

<!DOCTYPE html>
<html lang="<%=lang%>">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title><sitemesh:write property='title'>Title goes here</sitemesh:write> - FlayOn [<%=System.getProperty("os.name")%>]</title>
<link rel="shortcut icon" type="image/x-icon" href="<c:url value="/img/favicon-kamoru.ico"/>">
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap-theme.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/webjars/jquery-ui/1.12.1/themes/base/jquery-ui.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/base-scrollbar.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/flayon-common.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/typed.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/aperture.css"/>"/>
<link rel="stylesheet" href="<c:url value="/css/neon.css"/>"/>
<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
<!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/jquery-ui/1.12.1/jquery-ui.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/crazy.common.js" />"></script>
<script type="text/javascript" src="<c:url value="/js/crazy.effect.js" />"></script>
<script type="text/javascript" src="<c:url value="/js/crazy.ui.aperture.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/crazy.ui.typed.js" />"></script>
<script type="text/javascript">
var lang = '<%=lang%>';
var prevScrollTop = 0;

(function($) {
	$(document).ready(function() {
		//	$('h1').pulse();
		// titleEffect("h1:not(.no-effect), .title-effect");
		$("h1:not(.no-effect), .title-effect").jkEffect();
		
		// bootstrap tooltip, popover initialize
		$('[data-toggle="tooltip"]').tooltip(); 
		$('[data-toggle="popover"]').popover();

		$(document).scroll(function() {
			var currScrollTop = $(window).scrollTop();
			if (prevScrollTop == 0 || currScrollTop == 0) {
				$("#headerNav.navbar-default > .container").toggleClass("scrolling", currScrollTop > 0);
				prevScrollTop = currScrollTop
			}
			$(".scrollup").toggle(currScrollTop > 100);
		});
	
		$(".scrollup").on("click", function() {
			return $("html, body").animate({scrollTop: 0}, 600), !1;
		});
		
	});
})(jQuery);
</script>
<sitemesh:write property="head" />
</head>
<body role="document">
	
	<%@ include file="./flayon-header.jspf" %>

	<sitemesh:write property="body">Body goes here. Blah blah blah.</sitemesh:write>

	<%@ include file="./flayon-footer.jspf" %>

	<div class="scrollup-wrap">
		<a href="#" class="scrollup" style="display:none;">Back to the top</a>
	</div>
	
<form name="actionFrm" target="ifrm" method="post"><input type="hidden" name="_method" id="hiddenHttpMethod"/></form>
<iframe id="actionIframe" name="ifrm" style="display:none; width:100%;"></iframe>

</body>
</html>