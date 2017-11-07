<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<title><s:message code="video.video"/> <s:message code="video.history"/></title>
<style type="text/css">
@import url(http://fonts.googleapis.com/css?family=Covered+By+Your+Grace);
#chartDiv {
	width:100%; 
	height:100%; 
	margin:0 auto; 
 	/* background: rgba(0, 0, 0, 0.3) url('http://www.amcharts.com/lib/3/patterns/chalk/bg.jpg'); */ 
	background-color: rgba(0, 0, 0, 0);
	color: #fff;
	border-radius: 10px;
}
</style>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/amcharts.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/serial.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/themes/chalk.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/themes/black.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/themes/dark.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/themes/light.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/themes/patterns.js"/>"></script>
<script type="text/javascript">
var chart;
var chartData;
var pathToImages = '<c:url value="/webjars/amcharts/3.15.2/dist/amcharts/images/"/>';
var historyFormat = 'yyyy-MM-dd';
var chartFormat = historyFormat.toUpperCase();
var currentStartIndex = 3;
var theme = "chalk";

function toggleBG() {
	if ($("#chartDiv").css("background-image") == 'none')
		$("#chartDiv").css("background-image", "url(<c:url value="/img/bg/chalk-bg.png"/>)");
	else
		$("#chartDiv").css("background-image", "");
}

$(document).ready(function() {
	$("#zoom" + currentStartIndex).addClass("active");
	requestData();
	toggleBG();
});

function requestData() {
	restCall(PATH + '/rest/video/history/' + historyFormat, {}, function(data) {
		chartData = data;
		renderChart();
	});
}

function renderChart() {

	chart = AmCharts.makeChart("chartDiv", {
	    "type": "serial",
	    "theme": theme,
	    "marginRight": 40,
	    "marginLeft": 40,
	    "autoMarginOffset": 20,
	    "mouseWheelZoomEnabled": true,
	    "dataDateFormat": chartFormat,
	    "startDuration": 0,
	    "dataProvider": chartData,
	    "legend": {
	        "equalWidths": false,
	        "useGraphSettings": true,
	        "valueAlign": "left",
	        "valueWidth": 120
	    }, 
	    "valueAxes": [{
	        "axisAlpha": 0.2,
	        "dashLength": 1,
	        "position": "left"
	    }],
	    "graphs": [{
	        "id": "playTime",
	        "type" : "column",
	        "fillAlphas": 0.8,
	        "lineAlpha": 0,
	        "lineThickness": 0,
	        "title": "Play video",
	        "valueField": "play",
	        "balloonText": "[[value]]",
	        "legendPeriodValueText": "Total: [[value.sum]] played",
	        "legendValueText": "[[category]]: [[value]] played",
	    }],
	    "chartCursor": {
	        "limitToGraph": "playTime",
	        "fullWidth": true,
	        "cursorAlpha": .25
	    },
	    "chartScrollbar": {
	        "autoGridCount": true,
	        "graph": "playTime",
	        "scrollbarHeight": 40,
	    },
	    "valueScrollbar":{
	      	"oppositeAxis": false,
	      	"offset": 50,
	      	"scrollbarHeight": 5
	    },
	    "categoryField": "date",
	    "categoryAxis": {
	    	"dateFormats": [{
	            "period": "DD",
	            "format": "DD"
	        }, {
	            "period": "WW",
	            "format": "MMM DD"
	        }, {
	            "period": "MM",
	            "format": "MMM"
	        }, {
	            "period": "YYYY",
	            "format": "YYYY"
	        }],
	        "parseDates": true,
	        "dashLength": 1,
	        "minorGridEnabled": true
	    },
	    "export": {
	        "enabled": true
	    }
	});
	
	chart.addListener("rendered", zoomChart);
	
	try {
		zoomChart(currentStartIndex);
	} catch (e) {
		console.log('zoomChart error', e);
	}
}

function zoomChart(month) {
    // different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
	//	chart.zoomToIndexes(chartData.length - 10, chartData.length - 1);
    console.log("zoomChart : month = ", month);
    if (month) {
    	if (typeof month === 'object') {
        	if (chartFormat == 'YYYY-MM-DD')
        		currentStartIndex = 3;
        	else if (chartFormat == 'YYYY-MM')
        		currentStartIndex = 12;
        	else
        		currentStartIndex = 4 * 12;
            console.log("zoomChart : object -> currentStartIndex = " + currentStartIndex);
    	}
    	else {
	    	currentStartIndex = month;
	        console.log("zoomChart : month => currentStartIndex = " + currentStartIndex);
    	}
    }

    var toDay = new Date();
    var fromDay = new Date();
    fromDay.setMonth(toDay.getMonth() - currentStartIndex);
	chart.zoomToDates(fromDay, toDay);
	$("[id^=zoom]").removeClass("active");
	$("#zoom" + currentStartIndex).addClass("active");

    console.log("zoomChart : currentStartIndex = " + currentStartIndex, "[" + fromDay,"] -> [" + toDay + "]");
	
	// hide amcharts. sorry!
	$("div.amcharts-chart-div > a").html("");

}

function changeFormat(format) {
	historyFormat = format;
	chartFormat = format.toUpperCase();
	requestData();
	console.log("changeFormat : historyFormat=" + historyFormat + ", chartFormat=" + chartFormat);
}

function changeTheme(_theme) {
	theme = _theme;
	renderChart();
	console.log("changeTheme : theme=" + theme);
}
</script>
</head>
<body>
<div class="container-fluid">

<div id="header_div" class="box form-inline">
	<label class="title">History Graph</label>
	&nbsp;
	<div class="btn-group" data-toggle="buttons">
		<a id="zoom1"  class="btn btn-xs btn-default" onclick="zoomChart(1)"><input type="radio"/>M-1</a>
		<a id="zoom2"  class="btn btn-xs btn-default" onclick="zoomChart(2)"><input type="radio"/>M-2</a>
		<a id="zoom3"  class="btn btn-xs btn-default active" onclick="zoomChart(3)"><input type="radio"/>M-3</a>
		<a id="zoom6"  class="btn btn-xs btn-default" onclick="zoomChart(6)"><input type="radio"/>M-6</a>
		<a id="zoom12" class="btn btn-xs btn-default" onclick="zoomChart(12)"><input type="radio"/>Y-1</a>
		<a id="zoom48" class="btn btn-xs btn-default" onclick="zoomChart(48)"><input type="radio"/>Y-4</a>
	</div>
	&nbsp;
	<div class="btn-group" data-toggle="buttons">
		<a class="btn btn-xs btn-default" onclick="changeFormat('yyyy')"><input type="radio"/>Year</a>
		<a class="btn btn-xs btn-default" onclick="changeFormat('yyyy-MM')"><input type="radio"/>Month</a>
		<a class="btn btn-xs btn-default active" onclick="changeFormat('yyyy-MM-dd')"><input type="radio"/>Day</a>
	</div>
	&nbsp;
	<div class="btn-group" data-toggle="buttons">
		<a class="btn btn-xs btn-default" onclick="changeTheme('light')"><input type="radio"/>Light</a>
		<a class="btn btn-xs btn-default" onclick="changeTheme('dark')"><input type="radio"/>Dark</a>
		<a class="btn btn-xs btn-default active" onclick="changeTheme('chalk')"><input type="radio"/>Chalk</a>
		<a class="btn btn-xs btn-default" onclick="changeTheme('black')"><input type="radio"/>Black</a>
		<a class="btn btn-xs btn-default" onclick="changeTheme('patterns')"><input type="radio"/>Patterns</a>
		<a class="btn btn-xs btn-default" onclick="changeTheme('none')"><input type="radio"/>default</a>
	</div>
	&nbsp;
	<div class="btn-group" data-toggle="buttons">
		<button type="button" class="btn btn-xs btn-default" onclick="toggleBG()">BG</button>
	</div>

</div>

<div id="content_div" class="box">
	<div id="chartDiv"></div>
</div>
  
</div>
</body>
</html>
