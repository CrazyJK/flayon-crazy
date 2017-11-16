<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"   tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.actress"/> <s:message code="video.list"/></title>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<style type="text/css">
.active {
	color: red;
}
</style>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript">
var table;
var resizeSecondDiv = function() {
	table.draw();
};
$(document).ready(function() {
	$("#viewBtn").on("click", function() {
		loading(true);
		location.href = location.pathname + "?i=" + $("#instance").is(":checked") + "&a=" + $("#archive").is(":checked");
	});
    table = $('#list').DataTable({
    	       scrollY: (calculatedDivHeight - 70),
        scrollCollapse: true,
                paging: false,
             searching: false,
            processing: true,
                  info: false,
                 order: [[2, 'desc']],
        fnDrawCallback: function(oSettings) {
        	$("#actress-list").css({visibility: 'visible'}).addClass("w3-animate-opacity");
        }
    });
    
    $("#nameCheckBtn").on("click", function() {
    	var limit = $("#limit").val();
    	var instance = $("#instance").is(":checked");
    	var archive = $("#archive").is(":checked");
    	restCall(PATH + '/rest/actress/namecheck', {data: {l: limit, i: instance, a: archive}}, function(json) {
    		displayNameCheckResult(json);
    	});
    });
});
function displayNameCheckResult(list) {
	var scoreToFixed = function(num) {
		return num.toFixed(3);	
	},
	renderActressName = function(name) {
		return 	$("<span>", {title: name, "class": "pointer"}).html(name).on("click", function() {
					fnViewActressDetail($(this).html())
				}).hover(
					function() {
						$("[title='" + $(this).attr("title") + "']").addClass("active");
					}, function() {
						$("[title='" + $(this).attr("title") + "']").removeClass("active");
					}
				)
	};
	
    $("#notice > p").empty().append(
	    	$("<table>", {"class": "table", id: "nameCheckResultTable"}).append(
		    		$("<thead>").append(
			    			$("<tr>").append(
				       				$("<th>").html("Name1"),		
				       				$("<th>").html("Name2"),		
				       				$("<th>").html("Score")
			    			)		
		    		),
		   			(function () {
			    		var tbody = $("<tbody>");
		    			$.each(list, function(idx, record) {
		    				$("<tr>").append(
			       					$("<td>").append(
		       							renderActressName(record.name1)
			       					),
			       					$("<td>").append(
		       							renderActressName(record.name2)
			       					),
			       					$("<td>").html(scoreToFixed(record.score))		
		    				).appendTo(tbody);
		    			});
		    			return tbody;
		    		}())
	    	)
    );
    $("#nameCheckResultTable").DataTable({
        order: [[2, 'desc']]
    });
    $("#notice").attr("title", "Name check result").css({overflowX: "hidden"}).dialog({height: 600, width: 600});
}
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search" class="title">
			<s:message code="video.actress"/> <span class="badge">${fn:length(actressList)}</span>
		</label>
		<input type="search" name="search" id="search" class="form-control input-sm" placeHolder="<s:message code="video.search"/>" onkeyup="searchContent(this.value)"/>
		
		<label>
			<input type="checkbox" id="instance" name="i" value="${instance}" ${instance ? 'checked=\"checked\"' : ''} class="sr-only"/>
			<span class="label" id="checkbox-instance">Instance</span>
		</label>
		<label>
			<input type="checkbox" id="archive" name="a" value="${archive}" ${archive ? 'checked=\"checked\"' : ''} class="sr-only"/>
			<span class="label" id="checkbox-archive">Archive</span>
		</label>
		
		<button class="btn btn-xs btn-default" id="viewBtn">View</button>
		
		<input type="number" id="limit" name="limit" value="0.9" class="form-control input-sm" style="width:50px !important;"/>
		<button class="btn btn-xs btn-primary" id="nameCheckBtn">Name check</button>
		
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<div id="actress-list">
			<table id="list" class="table table-condensed table-hover">
				<thead>
					<tr>
						<th style="max-width: 20px;">#</th>
						<c:forEach items="${sorts}" var="s">
						<th style="max-width: 50px;" title="<s:message code="actress.sort.${s}"/>"><s:message code="actress.sort.short.${s}"/></th>
						</c:forEach>
						<th style="max-width: 50px;" title="<s:message code="actress.sort.AGE"/>"><s:message code="actress.sort.short.AGE"/></th>
						<th style="max-width:150px;">Video</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach items="${actressList}" var="actress" varStatus="status">
					<tr class="nowrap">
						<td class="number">${status.count}</td>
						<td><a onclick="fnViewActressDetail('${actress.name}')" title="${actress.name}">${actress.name}</a></td>
						<td class="text-center">${actress.favorite ? '★' : ''}</td>
						<td>${actress.birth}</td>
						<td>${actress.bodySize}</td>
						<td class="number">${actress.height}</td>
						<td class="number">${actress.debut}</td>
						<td class="number">${fn:length(actress.videoList)}</td> 
						<td class="number">${actress.score}</td>
						<td class="number">${actress.age}</td>
						<td style="max-width:150px;">
							<div class="nowrap">
								<c:forEach items="${actress.videoList}" var="video">
								<jk:video video="${video}" view="opus"/>
								</c:forEach>
							</div>
						</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</div>
	</div>

</div>
</body>
</html>
