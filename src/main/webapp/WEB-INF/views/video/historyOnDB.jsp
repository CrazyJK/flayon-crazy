<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<title><s:message code="video.video"/> <s:message code="video.history"/> On DB</title>
<style type="text/css">
table {
	font-size: 12px;
}
.id {
	text-align: right;
	min-width: 30px;
}
.date {
	width: 150px;
}
.opus {
	min-width: 100px;
}
.desc {
	max-width: 500px;
}
td {
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
}
</style>
<script type="text/javascript" src="<c:url value="/js/jquery.jsontotable.js"/>"></script>
<script type="text/javascript">
$(document).ready(function() {
	restCall(PATH + '/rest/video/historyOnDB', {}, function(data) {
		$(".history-count").html(data.length);
		$("#historyTable").jsontotable(data, {
			dateColumn: ['date'], 
			hideColumn: ['video'],
			createdRow: function(row, data, index) {
				$("td", row).eq(2).empty().append(
	        			$("<a>").addClass("pointer").html(data.opus).on("click", function() {
	        				fnVideoDetail(data.opus);
	    	        	})		
	        	);
			}
		});
	}); 
	restCall(PATH + '/rest/noti/list', {}, function(data) {
		$(".noti-count").html(data.length);
		$("#notiTable").jsontotable(data, {
			dateColumn: ['date']
		});
	}); 
});
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label class="title">
			Today History
		</label>
	</div>
	
	<div id="content_div" class="box row">
		<div class="col-lg-6">
			<h5 class="title">Video History <span class="history-count">0</span></h5>
			<table id="historyTable" class="table table-hover table-condensed"></table>
		</div>
		<div class="col-lg-6">
			<h5 class="title">Noti List <span class="noti-count">0</span></h5>
			<table id="notiTable" class="table table-hover table-condensed"></table>
		</div>
	</div>
	  
</div>
</body>
</html>
