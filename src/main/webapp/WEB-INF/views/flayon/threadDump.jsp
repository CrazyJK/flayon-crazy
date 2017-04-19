<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Thread dump</title>
<style type="text/css">
.input-group-addon {
	background-color: #fff;
}
.dataTables_filter {
	float: right;
	margin: 5px 15px;
}
.dataTables_info {
	display: inline-block;
}
</style>
<link rel="stylesheet" href="<c:url value="/webjars/datatables/1.10.12/media/css/dataTables.bootstrap.min.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/jquery.dataTables.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/datatables/1.10.12/media/js/dataTables.bootstrap.min.js"/>"></script>
<script type="text/javascript">
$(document).ready(function() {
	var windowHeight = $(window).innerHeight();
	var tableHeight = windowHeight - 250;
	console.log(windowHeight, tableHeight);
	
	$(window).resize(function() {
		$(".dataTables_scrollBody").css("max-height", $(window).innerHeight() - 250);
	});
	
    var table = $('#thread-table').DataTable({
    	scrollY:        tableHeight + 'px',
        scrollCollapse: true,
        paging:         false,
        searching:      true,
        info:           true,
        columnDefs: [
            { "visible": false, "targets": 0 }
        ],
        order: [[ 0, 'asc' ]],
        drawCallback: function (settings) {
            var api = this.api();
            var rows = api.rows({page:'current'}).nodes();
            var last = null;
 
            api.column(0, {page:'current'}).data().each( function (group, i) {
                if (last !== group) {
                    $(rows).eq( i ).before(
                        '<tr class="group bg-primary"><td colspan="1" class="text-center">'+group+'</td></tr>'
                    );
                    last = group;
                }
            });
        },
		// dom: '<"top">rt<"bottom"fi><"clear">',
        dom: '<<t>if>',
    });
 	// Order by the grouping
    $('#thread-table tbody').on('click', 'tr.group', function () {
        var currentOrder = table.order()[0];
        console.log(currentOrder);
        if (currentOrder[0] === 0 && currentOrder[1] === 'asc' ) {
            table.order([0, 'desc']).draw();
        }
        else {
            table.order([0, 'asc']).draw();
        }
    } );
    
});
</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Thread Info ... <span class="badge">${threadInfos.size()}</span></h1>
	</div>
	
	<table class="table table-condensed" id="thread-table">
		<thead>
			<tr>
				<th>Thread State</th>
				<th>Thread Name</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${threadInfos}" var="threadInfo">
			<tr>
				<td class="text-info">${threadInfo.threadState}</td>
				<td><strong class="text-primary">${threadInfo.threadName}</strong>
					<button class="btn btn-xs float-right" data-toggle="collapse" data-target="#tid-${threadInfo.threadId}"><span class="glyphicon glyphicon-triangle-bottom"></span></button>
					<div id="tid-${threadInfo.threadId}" class="collapse">
						<c:forEach items="${threadInfo.stackTrace}" var="stackTrace">
						${stackTrace}<br/>
						</c:forEach>
					</div>
				</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>

</div>
</body>
</html>