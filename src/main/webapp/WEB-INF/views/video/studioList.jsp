<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.studio"/> <s:message code="video.list"/></title>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript">
var instance = reqParam.i != 'false';
var archive  = reqParam.a == 'true';

var convertDataForDataTable = function(json, columns, options) {

	var opts = $.extend({}, {
		dateColumn: []
	}, options);

	var dataSet = [];
	$.each(json, function(idx, row) {
		var record = [];
		for (var key in columns) {
			var column = columns[key];
			var value = row[column] == null ? "" : row[column];
			if (opts.dateColumn.includes(column)) {
				value = new Date(value).format('yyyy.MM.dd HH:mm:ss');
			}
			record.push(value);
		}
		dataSet.push(record);
	});
	return dataSet;
};

$(document).ready(function() {

	$("#viewBtn").on("click", function() {
		loading(true);
		location.href = location.pathname + "?i=" + $("#instance").is(":checked") + "&a=" + $("#archive").is(":checked");
	});

	restCall(PATH + "/rest/studio" + "?i=" + instance + "&a=" + archive, {}, function(json) {
		
		$(".list-count").html(json.length);
		
		var columnKeys = ["name", "company", "homepage", "videoCount", "actressCount", "score"];
		var columns = [];
		for (var i=0; i<columnKeys.length; i++) {
			columns.push({title: capitalize(columnKeys[i]).replace("count", "")});
		}

		var dataSet = convertDataForDataTable(json, columnKeys);
		
		var table = $("#list").DataTable({
	    	data: dataSet,
	    	columns: columns,
	    	order: [[3, 'desc']],
	        paging: false,
	        info: false,
	        initComplete: function() {
	        	//$("#list_wrapper").addClass("box");
	        	$(".row").css({margin: 0});
	        	$(".col-sm-12").css({padding: 0});
	        	$("#list").css({width: "100%"});
	        	$("label[for=search]").after(
	        			$("#list_filter").find("input").attr({id: "search", placeHolder: "Search"})[0]
	        	);
	        	$("#list_filter").empty();
	        },
	        createdRow: function(row, data, index) {
	        	$("td", row).eq(0).empty().append(
	        			$("<a>").addClass("pointer").html(data[0]).on("click", function() {
	    	        		fnViewStudioDetail(data[0]);
	    	        	})		
	        	);
	        	if (data[1] != "") {
		        	$("td", row).eq(1).empty().append(
		        			$("<a>", {href: data[1], target: "_blank"}).html(data[1])		
		        	);
	        	}
	        }
	    });
	});
	
    instance && $("#checkbox-instance").click();
    archive  && $("#checkbox-archive").click();
	
});
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search" class="title">
			<s:message code="video.studio"/> <span class="badge list-count">0</span>
		</label>
		 
		<label>
			<input type="checkbox" id="instance" name="i" class="sr-only"/>
			<span class="label" id="checkbox-instance">Instance</span>
		</label>
		<label>
			<input type="checkbox" id="archive" name="a" class="sr-only"/>
			<span class="label" id="checkbox-archive">Archive</span>
		</label>
		
		<button class="btn btn-xs btn-default" id="viewBtn">View</button>

	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<table id="list" class="table table-condensed table-hover">
		</table>
	</div>

</div>
</body>
</html>
