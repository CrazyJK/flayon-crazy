<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"     tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title>Archive [${video.opus}] ${video.title}</title>
<script type="text/javascript">
bgContinue = false;
$(document).ready(function() {
	$("body")
		.css("background-image","url('<c:url value="/video/${video.opus}/cover" />')")
		.css("background-size", "100%")
		.css("background-position", "left top");
});
</script>
</head>
<body>
<div class="container-fluid">
	<dl class="dl-detail">
		<dt><jk:video video="${video}" view="title"     mode="l"/></dt>
		<dd><jk:video video="${video}" view="studio"    mode="l"/></dd>
		<dd><jk:video video="${video}" view="opus"      mode="l"/></dd>
		<dd><jk:video video="${video}" view="actress"   mode="l"/></dd>
		<dd><jk:video video="${video}" view="release"   mode="l"/></dd>
		<dd><jk:video video="${video}" view="subtitles" mode="l"/></dd>
		<dd><jk:video video="${video}" view="overview"  mode="l"/></dd>
	</dl>
</div>
</body>
</html>
