<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<title>Video list</title>
<link rel="stylesheet" type="text/css" href="<c:url value="/css/videoListBySpa.css"/>"/>
</head>
<body>
<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
		<div style="display: inline-block;">
	   		<input class="form-control input-sm search" placeholder="Search..." style="width:100px !important;"/>
	   		<span class="label label-default" id="favorite" role="checkbox" data-role-value="false" title="only favorite">Fav</span>
	   		<span class="label label-default" id="novideo"  role="checkbox" data-role-value="false" title="only no video">NoV</span>
	   		<span class="label label-default" id="tags"     role="checkbox" data-role-value="false" title="filter by tags">Tags</span>
			<span class="label label-info pointer status" id="request">0 / 0</span>
			<span class="label label-warning videoCount" title="video count">0</span>
			<span class="label label-primary candidate" title="candidate count">0</span>
		</div>
		<div style="display: inline-block;" id="checkbox-rank-group">
	   		<span class="label label-default" id="check-rank0"  role="checkbox" data-role-value="true">0</span>
	   		<span class="label label-default" id="check-rank1"  role="checkbox" data-role-value="false">1</span>
	   		<span class="label label-default" id="check-rank2"  role="checkbox" data-role-value="false">2</span>
	   		<span class="label label-default" id="check-rank3"  role="checkbox" data-role-value="false">3</span>
	   		<span class="label label-default" id="check-rank4"  role="checkbox" data-role-value="false">4</span>
	   		<span class="label label-default" id="check-rank5"  role="checkbox" data-role-value="false">5</span>
		</div>
      	<div class="float-right">
			<div class="btn-group btn-group-xs">
		      	<button class="btn btn-info"    data-toggle="tab" data-target="#table">Table</button>
		      	<button class="btn btn-default" data-toggle="tab" data-target="#box">Box</button>
			</div>
			<div class="btn-group btn-group-xs btn-group-sort"></div>
      	</div>
      	<div class="float-right forTable">
	   		<span class="label label-default" id="torrent"  role="checkbox" data-role-value="false" title="view torrent">T</span>
	   		<span class="label label-default" id="cover"    role="checkbox" data-role-value="false" title="view cover">Cover</span>
      	</div>
      	<div class="float-right forBox">
	   		<input type="range" id="img-width" class="form-control input-sm" min="290" max="790" value="290" step="100"/>
	   		<span class="label label-default" id="magnify"  role="checkbox" data-role-value="false" title="active magnify">Magnify</span>
	   	</div>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<div class="tab-content">
			<section id="box" class="tab-pane fade">
				<ul class="list-group list-inline vbox"></ul>
			</section>
			<section id="table" class="tab-pane fade table-responsive">
				<form>
				<table class="table table-condensed table-hover" style="margin-bottom:0;">
					<tbody></tbody>
				</table>
				</form>
			</section>
		</div>
		<p class="more text-center"><button class="btn btn-warning" id="viewMore">View More</button></p>
	</div>
	<script type="text/javascript" src="<c:url value="/js/crazy.video.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/js/crazy.video.list.js"/>"></script>
	<script type="text/javascript">$(function(){VideoList.init()})</script>
</div>

</body>
</html>
