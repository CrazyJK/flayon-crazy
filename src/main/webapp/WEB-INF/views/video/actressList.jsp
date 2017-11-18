<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"   tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.actress"/> <s:message code="video.list"/></title>
<link rel="stylesheet" href="<c:url value="/css/crazy-angular.css"/>"/>
<style type="text/css">
.active {
	color: red;
}
.selected {
	color: blue;
}
</style>
<script type="text/javascript" src="<c:url value="/webjars/angular/1.6.6/angular.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/angular-animate/1.6.6/angular-animate.min.js"/>"></script>
<script type="text/javascript">
var instance = reqParam.i != 'false';
var archive  = reqParam.a == 'true';

var app = angular.module("actressApp", ["ngAnimate"]);
app.controller("actressController", function($scope, $http) {
	$scope.predicate = 'favorite';
	$scope.reverse = true;
	$scope.order = function(predicate) {
	    $scope.reverse = ($scope.predicate === predicate) ? !$scope.reverse : false;
	    $scope.predicate = predicate;
	};
	$scope.list = [];
	$scope.videoDetail = function(opus) {
		fnVideoDetail(opus);
	}; 
	$scope.actressDetail = function(actressName) {
		console.log(actressName);
		fnViewActressDetail(actressName);
	};
	$scope.reload = function() {
		consoloe.log("reload");
		$route.reload();
	}

	$http({
		url: PATH + "/rest/actress" + "?i=" + instance + "&a=" + archive
	}).then(function(response) {
		$scope.list = response.data;
		$(".list-count").html(response.data.length);
	}, function(response) {
		console.log("Error", response);
	});

});

var displayNameCheckResult = function(list) {
	var scoreToFixed = function(num) {
		return num.toFixed(3);	
	},
	renderActressName = function(actress, right) {
		return 	$("<span>", {title: actress.name, "class": "pointer"}).on("click", function() {
					fnViewActressDetail($(this).attr("title"));
					$("[title='" + $(this).attr("title") + "']").addClass("selected");
				}).hover(
					function() {
						$("[title='" + $(this).attr("title") + "']").addClass("active");
					}, function() {
						$("[title='" + $(this).attr("title") + "']").removeClass("active");
					}
				).append(right ? $("<span>", {"class": "label label-info"}).html(actress.localName) : actress.name + "&nbsp;")
				 .append(right ? "&nbsp;" + actress.name : $("<span>", {"class": "label label-info"}).html(actress.localName))
	};
	
    $("#notice > p").empty().append(
	    	$("<table>", {"class": "table", id: "nameCheckResultTable"}).append(
		    		$("<thead>").append(
			    			$("<tr>").append(
				       				$("<th>", {"class": "text-right"}).html("Name1"), $("<th>").html("Name2"), $("<th>").html("Score")
			    			)		
		    		),
		   			(function () {
			    		var tbody = $("<tbody>");
		    			$.each(list, function(idx, record) {
		    				$("<tr>").append(
			       					$("<td>", {"class": "text-right"}).append(renderActressName(record.actress1, true)),
			       					$("<td>").append(renderActressName(record.actress2)),
			       					$("<td>").html(scoreToFixed(record.score))
		    				).appendTo(tbody);
		    			});
		    			return tbody;
		    		}())
	    	)
    );
    var height = $("#content_div").height() - 100;
    $("#notice").attr("title", "Name check result : " + list.length).css({overflowX: "hidden"}).dialog({height: height, width: 600});
};

var resizeSecondDiv = function() {
    var height = $("#content_div").height() - 100;
	$("#notice").css({height: height});
};

$(document).ready(function() {

    instance && $("#checkbox-instance").click();
    archive  && $("#checkbox-archive").click();

	$("#viewBtn").on("click", function() {
		loading(true);
		location.href = location.pathname + "?i=" + $("#instance").is(":checked") + "&a=" + $("#archive").is(":checked");
	});

    $("#nameCheckBtn").on("click", function() {
    	var limit = $("#limit").val();
    	var _instance = $("#instance").is(":checked");
    	var _archive  = $("#archive").is(":checked");
    	restCall(PATH + '/rest/actress/namecheck', {data: {l: limit, i: _instance, a: _archive}}, function(json) {
    		displayNameCheckResult(json);
    	});
    });

});
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search" class="title">
			<s:message code="video.actress"/> <span class="badge list-count">0</span>
		</label>
		<input type="search" name="search" id="search" class="form-control input-sm" placeHolder="<s:message code="video.search"/>" onkeyup="searchContent(this.value)"/>
		
		<label>
			<input type="checkbox" id="instance" name="i" class="sr-only"/>
			<span class="label" id="checkbox-instance">Instance</span>
		</label>
		<label>
			<input type="checkbox" id="archive" name="a" class="sr-only"/>
			<span class="label" id="checkbox-archive">Archive</span>
		</label>
		
		<button class="btn btn-xs btn-default" id="viewBtn">View</button>
		
		<div class="float-right">
			<input type="number" id="limit" name="limit" value="0.95" class="form-control input-sm" style="width:55px !important;"/>
			<button class="btn btn-xs btn-primary" id="nameCheckBtn">Name check</button>
		</div>
		
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<div id="actress-list" data-ng-app="actressApp">
			<table id="list" class="table table-condensed table-hover" data-ng-controller="actressController">
				<thead>
					<tr>
						<th style="width: 90px;" data-ng-click="order('favorite')" >Favorite <i class="sortorder" data-ng-show="predicate === 'favorite'" data-ng-class="{reverse:reverse}"></i></th>
						<th data-ng-click="order('localName')">Local Name<i class="sortorder" data-ng-show="predicate === 'localName'" data-ng-class="{reverse:reverse}"></i></th>
						<th data-ng-click="order('name')"     >Name      <i class="sortorder" data-ng-show="predicate === 'name'"      data-ng-class="{reverse:reverse}"></i></th>
						<th style="max-width:200px;" data-ng-click="order('birth')"    >Birth  <i class="sortorder" data-ng-show="predicate === 'birth'"    data-ng-class="{reverse:reverse}"></i></th>
						<th style="max-width:200px;" data-ng-click="order('bodySize')" >Body   <i class="sortorder" data-ng-show="predicate === 'bodySize'" data-ng-class="{reverse:reverse}"></i></th>
						<th style="max-width: 80px;" data-ng-click="order('height')"   >Height <i class="sortorder" data-ng-show="predicate === 'height'"   data-ng-class="{reverse:reverse}"></i></th>
						<th style="max-width: 80px;" data-ng-click="order('debut')"    >Debut  <i class="sortorder" data-ng-show="predicate === 'debut'"    data-ng-class="{reverse:reverse}"></i></th>
						<th class="number" style="max-width: 80px;" data-ng-click="order('age')"  >Age   <i class="sortorder" data-ng-show="predicate === 'age'"   data-ng-class="{reverse:reverse}"></i></th>
						<th class="number" style="max-width: 80px;" data-ng-click="order('video')">Video <i class="sortorder" data-ng-show="predicate === 'video'" data-ng-class="{reverse:reverse}"></i></th>
						<th class="number" style="max-width: 80px;" data-ng-click="order('score')">Score <i class="sortorder" data-ng-show="predicate === 'score'" data-ng-class="{reverse:reverse}"></i></th>
					</tr>
				</thead>
				<tbody>
					<tr class="nowrap" data-ng-repeat="actress in list | orderBy:predicate:reverse">
						<td class="text-center">{{actress.favorite ? '★' : ''}}</td>
						<td>{{actress.localName}}</td>
						<td><a data-ng-click="actressDetail(actress.name)" title="{{actress.name}}">{{actress.name}}</a></td>
						<td>{{actress.birth}}</td>
						<td>{{actress.bodySize}}</td>
						<td>{{actress.height}}</td>
						<td>{{actress.debut}}</td>
						<td class="number">{{actress.age}}</td>
						<td class="number">{{actress.videoCount}}</td> 
						<td class="number">{{actress.score}}</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>

</div>
</body>
</html>
