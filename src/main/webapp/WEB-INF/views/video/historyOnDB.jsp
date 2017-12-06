<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<title><s:message code="video.video"/> <s:message code="video.history"/> On DB</title>
<style type="text/css">
th {
	text-transform: capitalize;
}
</style>
<script type="text/javascript" src="<c:url value="/js/jquery.jsontotable.js"/>"></script>
<script type="text/javascript">

$(document).ready(function() {
	restCall(PATH + '/rest/video/historyOnDB', {}, function(data) {
		$("#content_div").jsontotable(data, {
			header: true, className: 'table table-hover', dateColumn: ['date'], hideColumn: ['video']
		});
	});
});

</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label class="title">Today History</label>
	</div>
	
	<div id="content_div" class="box">
	</div>
	  
</div>
</body>
</html>
