<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"   tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.studio"/> <s:message code="video.list"/></title>
<link rel="stylesheet" href="<c:url value="/css/crazy-angular.css"/>"/>
<script type="text/javascript" src="<c:url value="/webjars/angular/1.6.6/angular.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/angular-animate/1.6.6/angular-animate.min.js"/>"></script>
<script type="text/javascript">
var instance = reqParam.i != 'false';
var archive  = reqParam.a == 'true';

var app = angular.module("studioApp", ["ngAnimate"]);
app.controller("studioController", function($scope, $http) {
	$scope.predicate = 'name';
	$scope.reverse = false;
	$scope.order = function(predicate) {
	    $scope.reverse = ($scope.predicate === predicate) ? !$scope.reverse : false;
	    $scope.predicate = predicate;
	};
	$scope.list = [];
	$scope.videoDetail = function(opus) {
		fnVideoDetail(opus);
	}; 
	$scope.studioDetail = function(name) {
		fnViewStudioDetail(name);
	};
	$scope.reload = function() {
		$route.reload();
	}

	$http({
		url: PATH + "/rest/studio" + "?i=" + instance + "&a=" + archive
	}).then(function(response) {
		$scope.list = response.data;
		$(".list-count").html(response.data.length);
	}, function(response) {
		console.log("Error", response);
	});

});

$(document).ready(function() {
    instance && $("#checkbox-instance").click();
    archive  && $("#checkbox-archive").click();
	
	$("#viewBtn").on("click", function() {
		loading(true);
		location.href = location.pathname + "?i=" + $("#instance").is(":checked") + "&a=" + $("#archive").is(":checked");
	});
});
</script>
</head>
<body>
<div class="container-fluid">

	<div id="header_div" class="box form-inline">
		<label for="search" class="title">
			<s:message code="video.studio"/> <span class="badge list-count">0</span>
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

	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<div id="studio-list" data-ng-app="studioApp">
			<table id="list" class="table table-condensed table-hover" data-ng-controller="studioController">
				<thead>
					<tr>
						<th data-ng-click="order('name')"    >Name     <i class="sortorder" data-ng-show="predicate === 'name'"     data-ng-class="{reverse:reverse}"></i></th>
						<th class="number" style="max-width: 80px;" data-ng-click="order('actress')">Actress <i class="sortorder" data-ng-show="predicate === 'actress'" data-ng-class="{reverse:reverse}"></i></th>
						<th class="number" style="max-width: 80px;" data-ng-click="order('video')"  >Video   <i class="sortorder" data-ng-show="predicate === 'video'"   data-ng-class="{reverse:reverse}"></i></th>
						<th class="number" style="max-width: 80px;" data-ng-click="order('score')"  >Score   <i class="sortorder" data-ng-show="predicate === 'score'"   data-ng-class="{reverse:reverse}"></i></th>
						<th data-ng-click="order('homepage')">Homepage <i class="sortorder" data-ng-show="predicate === 'homepage'" data-ng-class="{reverse:reverse}"></i></th>
						<th data-ng-click="order('company')" >Company  <i class="sortorder" data-ng-show="predicate === 'company'"  data-ng-class="{reverse:reverse}"></i></th>
					</tr>
				</thead>
				<tbody>
					<tr class="nowrap" data-ng-repeat="studio in list | orderBy:predicate:reverse">
						<td><a data-ng-click="studioDetail(studio.name)">{{studio.name}}</a></td>
						<td class="number">{{studio.actressCount}}</td>
						<td class="number">{{studio.videoCount}}</td>
						<td class="number">{{studio.score}}</td>
						<td><a href="{{studio.homepage}}" target="_blank">{{studio.homepage}}</a></td>
						<td>{{studio.company}}</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>

</div>
</body>
</html>
