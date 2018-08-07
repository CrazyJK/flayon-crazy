<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Video vertical view</title>
<link rel="stylesheet" href="${PATH}/css/app/video/videoVertical.css"/>
<script type="text/javascript" src="${PATH}/js/videoVertical.js"></script>
</head>
<body>
<div class="container-fluid container-vertical">
	<div id="header_div" class="box form-inline text-center">
		<div class="inline-block float-right">
			<button type="button" class="btn btn-link btn-sm" id="reload"><span class="glyphicon glyphicon-refresh"></span></button>
		</div>
		<div class="separator"></div>
		<div class="inline-block">
			<input type="search" id="query" class="form-control search" placeholder="Search..."/>
		</div>
		<div class="separator"></div>
		<div class="inline-block" id="checkbox-filter-group">
	   		<span class="label label-checkbox label-default" id="favorite"   role="checkbox" data-role-value="false" title="favorite actress">Fav</span>
			<div class="separator"></div>
	   		<span class="label label-checkbox label-default" id="video"      role="checkbox" data-role-value="true"  title="exist video">V</span>
	   		<span class="label label-checkbox label-default" id="subtitles"  role="checkbox" data-role-value="false" title="exist also subtitles">S</span>
		</div>
		<div class="separator"></div>
		<div class="inline-block" id="checkbox-rank-group">
	   		<span class="label label-checkbox label-default" id="check-rank0"  role="checkbox" data-role-value="true">0</span>
	   		<span class="label label-checkbox label-default" id="check-rank1"  role="checkbox" data-role-value="false">1</span>
	   		<span class="label label-checkbox label-default" id="check-rank2"  role="checkbox" data-role-value="false">2</span>
	   		<span class="label label-checkbox label-default" id="check-rank3"  role="checkbox" data-role-value="false">3</span>
	   		<span class="label label-checkbox label-default" id="check-rank4"  role="checkbox" data-role-value="false">4</span>
	   		<span class="label label-checkbox label-default" id="check-rank5"  role="checkbox" data-role-value="false">5</span>
		</div>
		<div class="separator"></div>
		<div class="inline-block" id="radio-sort" role="radio" data-role-value="M">
	   		<span class="label label-radio"    title="Studio"  >S</span>
	   		<span class="label label-radio"    title="Opus"    >O</span>
	   		<span class="label label-radio"    title="Title"   >T</span>
	   		<span class="label label-radio"    title="Actress" >A</span>
	   		<span class="label label-radio"    title="Release" >D</span>
	   		<span class="label label-radio on" title="Modified">M</span>
		</div>
		<div class="separator"></div>
		<div class="inline-block">
	   		<span class="label label-checkbox label-default" id="autoSlide" role="checkbox" data-role-value="false" title="auto Slide">R</span>
			<div class="inline-block" id="radio-autoSlideMode" role="radio" data-role-value="R">
		   		<span class="label label-radio"    title="slide Forward">F</span>
		   		<span class="label label-radio on" title="slide Random" >R</span>
		   	</div>
		</div>
	</div>
	
	<div id="content_div" class="box">
		<div class="video-wrapper text-center">
			<div class="info-wrapper">
				<dl>
					<dd><span class="label label-plain info-studio"></span></dd>
					<dd><span class="label label-plain info-opus"></span></dd>
					<dd><span class="label label-plain info-release"></span></dd>
					<dd><span class="label label-plain info-modified"></span></dd>
					<dd><span class="label label-plain info-video"></span></dd>
					<dd><span class="label label-plain info-subtitles"></span></dd>
					<dd><span class="label label-plain info-overview"></span>
						<input class="info-overview-input hide" placeholder="Overview"/></dd>
					<dd><div class="rank-wrapper form-inline">
							<div class="input-group rank-group">
								<input type="range" id="ranker" name="rankPoints" class="form-control rank-range" min="-1" max="5" value="0">
								<span id="ranker-label" class="input-group-addon rank-range-addon">0</span>
							</div>
						</div>
					</dd>
					<dt><span class="label label-plain info-title"></span></dt>
				</dl>
			</div>
			<div class="cover-wrapper">
				<div class="cover-wrapper-inner previous">
					<div class="cover-box previous"></div>
				</div>
				<div class="cover-wrapper-inner current">
					<div class="cover-box current"></div>
				</div>
				<div class="cover-wrapper-inner next">
					<div class="cover-box next"></div>
				</div>
			</div>
			<div class="info-wrapper">
				<dl>
					<dd class="info-wrapper-actress"><span class="label label-plain info-actress"></span></dd>
				</dl>
			</div>
			<div class="tag-wrapper">
				<div class="tag-list"></div>
				<div class="tag-new">
					<span class="label label-info label-tag-new">NEW</span>
					<div class="tag-form-wrapper">
						<div class="tag-form">
							<input id="newTag-name" class="form-control input-sm" placeholder="name"/>
							<input id="newTag-desc" class="form-control input-sm" placeholder="Description"/>
							<button class="btn btn-primary btn-xs btn-tag-save">Regist</button>
						</div>
					</div>
				</div>
			</div>
			<div class="position-bottom">
				<div class="navigation-wrapper">
					<ul class="pagination">
	  					<li><a href="#">1</a></li>
	  					<li class="active"><a href="#">2</a></li>
	  					<li><a href="#">3</a></li>
	  					<li><a href="#">4</a></li>
	  					<li><a href="#">5</a></li>
					</ul>
				</div>
			</div>
		</di>
	</div>
</div>
</body>
</html>