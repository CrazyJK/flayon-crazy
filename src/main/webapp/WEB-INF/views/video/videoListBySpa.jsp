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
	   		<span class="label label-checkbox" id="favorite" role="checkbox" title="only favorite">Fav</span>
	   		<span class="label label-checkbox" id="novideo"  role="checkbox" title="only no video">NoV</span>
	   		<span class="label label-checkbox" id="tags"     role="checkbox" title="filter by tags">Tags</span>
			<span class="label label-info pointer status" id="request">0 / 0</span>
			<span class="label label-warning videoCount" title="video count">0</span>
			<span class="label label-primary candidate" title="candidate count">0</span>
		</div>
		<div style="display: inline-block;" id="checkbox-rank-group">
	   		<span class="label label-checkbox on" id="check-rank0"  role="checkbox">0</span>
	   		<span class="label label-checkbox" id="check-rank1"  role="checkbox">1</span>
	   		<span class="label label-checkbox" id="check-rank2"  role="checkbox">2</span>
	   		<span class="label label-checkbox" id="check-rank3"  role="checkbox">3</span>
	   		<span class="label label-checkbox" id="check-rank4"  role="checkbox">4</span>
	   		<span class="label label-checkbox" id="check-rank5"  role="checkbox">5</span>
		</div>
      	<div class="float-right">
			<div class="btn-group btn-group-xs">
		      	<button class="btn btn-info"    data-toggle="tab" data-target="#table">Table</button>
		      	<button class="btn btn-default" data-toggle="tab" data-target="#box">Box</button>
			</div>
			<div class="btn-group btn-group-xs btn-group-sort"></div>
      	</div>
      	<div class="float-right forTable">
	   		<span class="label label-checkbox" id="torrent"  role="checkbox" title="view torrent">T</span>
	   		<span class="label label-checkbox" id="cover"    role="checkbox" title="view cover">Cover</span>
      	</div>
      	<div class="float-right forBox">
	   		<input type="range" id="img-width" class="form-control input-sm" min="290" max="790" value="290" step="100"/>
	   		<span class="label label-checkbox" id="magnify"  role="checkbox" title="active magnify">Magnify</span>
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
