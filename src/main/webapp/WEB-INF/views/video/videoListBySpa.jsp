<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>Video list</title>
<link rel="stylesheet" href="<c:url value="/css/videoListBySpa.css"/>"/>
</head>
<body>
<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
		<div style="display: inline-block;">
	   		<input class="form-control input-sm search" placeholder="Search..."/>
			<span class="label label-info count pointer">Initialize...</span>
			<span class="label label-warning videoCount" title="video count"></span>
			<span class="label label-primary candidate" title="candidate count"></span>
	   		<span class="label label-default" id="favorite" role="checkbox" data-role-value="false" title="only favorite">Favorite</span>
	   		<span class="label label-default" id="novideo"  role="checkbox" data-role-value="false" title="only no video">NoVideo</span>
	      	<span class="label label-danger status"></span>
		</div>
      	<div class="float-right">
	   		<span class="label label-default" id="torrent"  role="checkbox" data-role-value="false" title="view torrent">T</span>
	   		<span class="label label-default" id="cover"    role="checkbox" data-role-value="false" title="view cover">Cover</span>
	   		<span class="label label-default" id="magnify"  role="checkbox" data-role-value="false" title="active magnify">Magnify</span>
			<div class="btn-group">
		      	<button class="btn btn-xs btn-info"    data-toggle="tab" href="#table">Table</button>
		      	<button class="btn btn-xs btn-default" data-toggle="tab" href="#box">Box</button>
			</div>
			<div class="btn-group btn-group-sort"></div>
			<button class="btn btn-xs btn-primary" onclick="getAllTorrents()" title="get all torrent">All T</button>
      	</div>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<%-- <ul class="nav nav-tabs">
			<li class="active"><a data-toggle="tab" href="#table">TABLE</a></li>
			<li class=""><a data-toggle="tab" href="#box">BOX</a></li>
			<li class="float-right">
				<span class="label label-info videoCount"></span>
				<span class="label label-primary candidate"></span>
				<span class="label label-warning torrents"></span>
				<span class="label label-success sorted hide"></span>
			</li>
		</ul> --%>
		<div class="tab-content">
			<section id="box" class="tab-pane fade">
				<ul class="list-group list-inline vbox"></ul>
			</section>
			<section id="table" class="tab-pane fade table-responsive">
				<table class="table table-condensed table-hover table-bordered" style="margin-bottom:0;">
					<tbody></tbody>
				</table>
			</section>
		</div>
		<p class="more text-center"><button class="btn btn-warning" onclick="render()">View More</button></p>
	</div>

</div>

<script type="text/javascript" src="<c:url value="/js/videoMain.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/video-prototype.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/videoListBySpa.js"/>"></script>
</body>
</html>
