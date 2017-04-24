<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Access Log</title>
<style type="text/css">
table {
	font-size: 0.8em;
}
td {
	font-family: "나눔고딕코딩";
}
* [onclick] {
	cursor:pointer;
}
* [onclick]:hover {
	color:orange; 
	text-decoration:none; 
	text-shadow:1px 1px 1px black;
}
.selected {
	color: blue;
}
.row {
    margin-right: -20px;
    margin-left: -20px;
}
.form-control {
	display: initial;
	width: initial;
}
.input-xs {
	padding: 2px;
	height: 22px;
	font-size: 12px;
	line-height: 1.2;
	width: 100%;
}
</style>
<script type="text/javascript">
var useAccesslogRepository = ${useAccesslogRepository};
$(document).ready(function() {

	$(".input-xs").on("keyup", function(e) {
		var event = window.event || e;
		if (event.keyCode == 13) {
			go(parseInt('${pageImpl.number}'));
		}
	});
	
	$(window).bind("resize", function() {
		$(".isHide").toggleClass("hide", $(window).width() < 960);
	}).trigger("resize");

	$("#list").fadeIn(2000);
});

function go(page) {
	var size = $("#size").val();
	var remoteAddr = $("#remoteAddr").val();
	var requestURI = $("#requestURI").val();
	this.location.href = "?size=" + size + "&page=" + page + "&sort=id,desc&requestURI=" + requestURI + "&remoteAddr=" + remoteAddr;
}
</script>
</head>
<body>

	<div class="container">
		<div class="page-header">
			<h1>Access Log
				<small class="badge"><fmt:formatNumber type="number" pattern="#,##0" value="${pageImpl.totalElements}" /></small>
			</h1>
	 	</div>
		<ul class="pager" style="margin:5px 0;">
		    <c:if test="${!pageImpl.first}">
		    <li class="previous">
		        <a href="?page=${pageImpl.number-1}">&larr; Prev Page</a>
		    </li>
		    </c:if>
		    <c:if test="${!pageImpl.last}">
		    <li class="next">
		        <a href="?page=${pageImpl.number+1}">Next Page &rarr;</a>
		    </li>
		    </c:if>
		</ul>
	</div>

	<div id="list" class="container-fluid" style="display:none;">
		<table class="table table-condensed">
			<thead class="bg-primary">
				<tr>
					<th class="text-center">No</th>
					<th class="hide">ID</th>
					<th>Access Date</th>
					<th>RemoteAddr</th>
					<th>User</th>
					<th>Method</th>
					<th>RequestURI</th>
					<th class="isHide" style="text-align:right">ContentType</th>
					<th style="text-align:right">Elapsed</th>
					<th class="isHide">HandlerInfo</th>
					<th class="isHide">ExceptionInfo</th>
					<th class="hide">ModelAndViewInfo</th>
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${pageImpl.content}" var="accessLog" varStatus="accessLogStat">
				<tr>
					<td align="center">${accessLogStat.count + (pageImpl.number * pageImpl.size)}</td>
					<td class="hide"  >${accessLog.id}</td>
					<td align="left"  ><fmt:formatDate pattern="yy-MM-dd hh:mm:ss" value="${accessLog.accessDate}" /></td>
					<td align="left"  >${accessLog.remoteAddr}</td>
					<td align="left"  >${accessLog.user.name}</td>
					<td align="left"  >${accessLog.method}</td>
					<td align="left"  >${accessLog.requestURI}</td>
					<td class="isHide" align="right" >${fn:replace(accessLog.contentType, ';charset=UTF-8', '')}</td>
					<td align="right" ><fmt:formatNumber type="number" pattern="#,##0 ms" value="${accessLog.elapsedTime}" /></td>
					<td class="isHide" align="left"  >${fn:replace(accessLog.handlerInfo, 'org.springframework.web.servlet.mvc.', '')}</td>
					<td class="isHide" align="left"  ><c:out value="${accessLog.exceptionInfo}"></c:out></td>
					<td class="hide" align="left">${accessLog.modelAndViewInfo}</td>
				</tr>
				</c:forEach>
				<c:if test="${!useAccesslogRepository}">
				<tr>
					<td colspan="12"><div class="text-center text-danger lead">No repository</div></td>
				</tr>
				</c:if>
			</tbody>
			<tfoot class="bg-primary">
				<tr>
					<td></td>
					<td class="hide"></td>
					<td></td>
					<td><input id="remoteAddr" name="remoteAddr" placeholder="remoteAddr" value="${param.remoteAddr}" class="form-control input-xs"/></td>
					<td></td>
					<td></td>
					<td><input id="requestURI" name="requestURI" placeholder="requestURI" value="${param.requestURI}" class="form-control input-xs"/></td>
					<td class="isHide"></td>
					<td></td>
					<td class="isHide"></td>
					<td class="isHide"></td>
					<td class="hide"></td>
				</tr>
			</tfoot>
		</table>
	
		<div class="pagination-container text-center">
			<ul class="pagination" style="margin:0;">
				<c:forEach var="i" begin="0" end="${pageImpl.totalPages-1}" step="1">
					<c:if test="${i == 0 or i == pageImpl.totalPages-1 or (pageImpl.number - i < 5 and i - pageImpl.number < 5)}">
					  	<li class="${i eq pageImpl.number ? 'active' : ''}">
					  		<a href="javascript:go(${i})">
					  			${i == 0 ? 'First ' : ''}
					  			${i == pageImpl.totalPages-1 ? 'Last ' : ''}
					  			${i+1}
					  		</a>
					  	</li>
					</c:if>
				</c:forEach>
			</ul>
		</div>
		<div class="text-center text-info">
			<c:if test="${useAccesslogRepository}">
				<button onclick="renderAccessDateChart()" class="btn btn-default btn-xs">Access chart</button>
			</c:if>
			totalElements: ${pageImpl.totalElements},
			totalPages: ${pageImpl.totalPages},
			first: ${pageImpl.first},
			last: ${pageImpl.last},
			number: ${pageImpl.number},
			size: <input id="size" size="2" placeholder="Line size" title="Line size" value="${pageImpl.size}" class="text-center form-control input-xs" style="width:initial;"/>
			numberOfElements: ${pageImpl.numberOfElements}
			<c:if test="${useAccesslogRepository}">
				<button onclick="renderRequestURIChart()" class="btn btn-default btn-xs">URI chart</button>
			</c:if>
		</div>
	</div>
	
	<div class="container">
		<div id="accessDate-chartdiv" style="width:100%; font-size:11px;"></div>
		<div id="requestURI-chartdiv" style="width:100%; font-size:11px;"></div>
	</div>
	
<%-- 	
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/amcharts.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/serial.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/themes/light.js"/>"></script>
 --%>
<script src="https://www.amcharts.com/lib/3/amcharts.js"></script>
<script src="https://www.amcharts.com/lib/3/serial.js"></script>
<script src="https://www.amcharts.com/lib/3/themes/light.js"></script>
<script type="text/javascript">
var chart;

function renderRequestURIChart() {
	
	$("#requestURI-chartdiv").append(
			$("<img>").attr({src: "${PATH}/img/loading.gif"}).addClass("w3-display-center")	
	).css({height: "400px"});
	$("body").scrollTop($(document).height());

	$.getJSON("${PATH}/flayon/accesslog/groupby/requestURI.json" ,function(data) {
		
		var EXCLUDE_URI = ["/login", "/image/random", "/video/randomVideoCover"];
		var chartData = new Array();
		for (var i=0; i<data.length; i++) {
			
			if (!EXCLUDE_URI.includes(data[i].requestURI) && data[i].total > 100) {
				
				if (data[i].requestURI.startsWith(requestURI.value)) {
					chartData.push(data[i]);
				}
			}
		}
		
		chart = AmCharts.makeChart("requestURI-chartdiv", {
			"type": "serial",
			"theme": "light",
			"marginRight": 40,
			"marginLeft": 40,
			"gridAboveGraphs": true,
			"autoMarginOffset": 20,
			"startDuration": 0,
			"mouseWheelZoomEnabled":true,
//			"dataDateFormat": "YYYY-MM-DD",
			"dataProvider": chartData,
			"balloon": {
				"borderThickness": 1,
				"shadowAlpha": 0
			},
			"graphs": [{
				"id": "g1",
				"balloon":{
					"drop":true,
					"adjustBorderColor":false,
					"color":"#ffffff"
				},
				"balloonText": "[[value]]",
				"fillAlphas": 0.8,
				"lineAlpha": 0.2,
				"type": "column",
				"valueField": "total",
				"lineThickness": 2,
				"title": "access date",
				"useLineColorForBulletBorder": true,
			}],
			"categoryField": "requestURI",
			"categoryAxis": {
//				"parseDates": true,
				"dashLength": 1,
				"minorGridEnabled": true,
				"gridPosition": "start",
				"gridAlpha": 0,
				"tickPosition": "start",
				"tickLength": 20
			},
			"chartScrollbar": {
				"graph": "g1",
				"oppositeAxis":false,
				"offset":30,
				"scrollbarHeight": 40,
				"backgroundAlpha": 0,
				"selectedBackgroundAlpha": 0.1,
				"selectedBackgroundColor": "#888888",
				"graphFillAlpha": 0,
				"graphLineAlpha": 0.5,
				"selectedGraphFillAlpha": 0,
				"selectedGraphLineAlpha": 1,
				"autoGridCount":true,
				"color":"#AAAAAA"
			},
			"chartCursor": {
				"pan": true,
				"categoryBalloonEnabled": true,
				"valueLineEnabled": false,
				"valueLineBalloonEnabled": false,
				"cursorAlpha":1,
				"cursorColor":"#258cbb",
				"limitToGraph":"g1",
				"valueLineAlpha":0.2,
				"valueZoomable":true
			},
		});
		
		chart.addListener("rendered", zoomChart);

		zoomChart();

	});
}

function zoomChart() {
    chart.zoomToIndexes(chart.dataProvider.length - 40, chart.dataProvider.length - 1);
}

var accessDateChart;

function renderAccessDateChart() {

	$("#accessDate-chartdiv").append(
			$("<img>").attr({src: "${PATH}/img/loading.gif"}).addClass("w3-display-center")
	).css({height: "400px"});
	$("body").scrollTop($(document).height());

	$.getJSON("${PATH}/flayon/accesslog/groupby/accessDate.json" ,function(data) {

		accessDateChart = AmCharts.makeChart("accessDate-chartdiv", {
			"type": "serial",
			"theme": "light",
			"marginRight": 40,
			"marginLeft": 40,
			"gridAboveGraphs": true,
			"autoMarginOffset": 20,
			"startDuration": 0,
			"mouseWheelZoomEnabled":true,
			"dataDateFormat": "YYYY-MM-DD",
			"dataProvider": data,
			"balloon": {
				"borderThickness": 1,
				"shadowAlpha": 0
			},
			"graphs": [{
				"id": "g1",
				"balloon":{
					"drop":true,
					"adjustBorderColor":false,
					"color":"#ffffff"
				},
				"balloonText": "<span style='font-size:11px;'>[[value]]</span>",
				"fillAlphas": 0.8,
				"lineAlpha": 0.2,
				"type": "column",
				"valueField": "total",
				"lineThickness": 2,
				"title": "access date",
				"useLineColorForBulletBorder": true,
			}],
			"categoryField": "accessDate",
			"categoryAxis": {
				"parseDates": true,
				"dashLength": 1,
				"minorGridEnabled": true,
				"gridPosition": "start",
				"gridAlpha": 0,
				"tickPosition": "start",
				"tickLength": 20
			},
			"chartScrollbar": {
				"graph": "g1",
				"oppositeAxis":false,
				"offset":30,
				"scrollbarHeight": 40,
				"backgroundAlpha": 0,
				"selectedBackgroundAlpha": 0.1,
				"selectedBackgroundColor": "#888888",
				"graphFillAlpha": 0,
				"graphLineAlpha": 0.5,
				"selectedGraphFillAlpha": 0,
				"selectedGraphLineAlpha": 1,
				"autoGridCount":true,
				"color":"#AAAAAA"
			},
			"chartCursor": {
				"pan": true,
				"categoryBalloonEnabled": true,
				"valueLineEnabled": false,
				"valueLineBalloonEnabled": false,
				"cursorAlpha":1,
				"cursorColor":"#258cbb",
				"limitToGraph":"g1",
				"valueLineAlpha":0.2,
				"valueZoomable":true
			},
		});

		accessDateChart.addListener("rendered", accessDateZoomChart);

		accessDateZoomChart();

	});	
}

function accessDateZoomChart() {
	accessDateChart.zoomToIndexes(accessDateChart.dataProvider.length - 30, accessDateChart.dataProvider.length - 1);
}
</script>	

</body>
</html>