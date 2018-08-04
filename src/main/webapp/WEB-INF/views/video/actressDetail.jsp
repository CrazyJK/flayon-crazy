<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"      uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"	tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title>${actress.name}</title>
<link rel="stylesheet" href="${PATH}/css/videoCard-Detail.css"/>
<style type="text/css">
input[type=file] {
    background-color: rgba(47, 187, 140, 0.5);
    border-color: rgba(47, 187, 140, 1);
    color: #fff;
}
</style>
<script type="text/javascript">
bgContinue = ${empty actress.image};
var archive = ${actress.archive};
var bgUrl = '${PATH}/cover/actress/${actress.name}';

$(document).ready(function() {
	!bgContinue && $("body").css({
		background: "url('" + bgUrl + "') center top repeat fixed #fff"
	});	
	archive && $("#favoriteTEXT, .btn").hide();

	// catch input file event
	$("#imageFile").on("change", function(e) {
		e.preventDefault();
		savePicture();
	});
});

function saveActressInfo() {
	restCall(PATH + '/rest/actress', {
		method: "PUT", 
		data: $("form#actressForm").serialize(), 
		title: "Save actress info"
	}, function() {
		location.href = PATH + "/video/actress/" + $("#newName").val();
	});
}
function searchActressInfo() {
	var name = $("#newName").val();
	var localName = $("#localName").val();
	popup('<c:url value="${urlSearchActress}"/>' + (localName != '' ? localName : name), 'infoActress', 1400, 900);
}
function savePicture() {
	var formData =  new FormData($("#pictureUploadForm")[0]);
	$.ajax({
		type: "POST",
		enctype: "multipart/form-data",
		url: "/rest/actress/${actress.name}/picture",
		data: formData,
		processData: false,
		contentType: false,
		cache: false,
		timeout: 600000,
		success: function(data) {
			console.log('success to save uploaded file', data);
			bgContinue = false;
			$("body").css({
				background: "url('" + bgUrl + "?_t=" + new Date().getTime() + "') center top repeat fixed #fff"
			});
		},
		error: function(e) {
			displayNotice('Fail to Save uploaded', e.responseText);
		}
	});
}
function searchActressPicture() {
	popup('https://www.google.co.kr/search?tbm=isch&q=${actress.name}', 'searchActressPicture', 900, 600);
}
</script>
</head>
<body>
<br/>
<div class="container">
	<form id="actressForm" role="form" class="form-horizontal" onsubmit="return false;">
		<input type="hidden" name="NAME" value="${actress.name}"/>
		<input type="hidden" name="FAVORITE" id="favorite" value="${actress.favorite}"/>
		<div class="form-group">
			<div class="col-sm-2 text-right">
				<span id="favoriteTEXT" onclick="fnFavorite(this, '${actress.name}')" class="glyphicon glyphicon-star${actress.favorite ? ' favorite' : '-empty'} text-danger lead"></span>
			</div>
			<div class="col-sm-4">
				<input class="form-control" type="text" name="NEWNAME" value="${actress.name}" id="newName"/>
			</div>
			<div class="col-sm-4">
				<input class="form-control" type="text" name="LOCALNAME" value="${actress.localName}" placeholder="local name" id="localName"/>
			</div>
			<div class="col-sm-1">
				<button class="btn btn-default btn-circle" onclick="searchActressInfo()"><span class="glyphicon glyphicon-search"></span></button>
			</div>
			<div class="col-sm-1">
				<span class="label label-primary">Score ${actress.score}</span>
			</div>		
		</div>
		<div class="form-group">
			<div class="col-sm-3">
				<input class="form-control" type="text" name="BIRTH"    value="${actress.birth}"    placeholder="Birth"/>
			</div>
			<div class="col-sm-3">
				<input class="form-control" type="text" name="BODYSIZE" value="${actress.bodySize}" placeholder="Body size"/>
			</div>
			<div class="col-sm-2">
				<input class="form-control" type="text" name="HEIGHT"   value="${actress.height}"   placeholder="Height"/>
			</div>
			<div class="col-sm-2">
				<input class="form-control" type="text" name="DEBUT"    value="${actress.debut}"    placeholder="Debut"/>
			</div>
			<div class="col-sm-2 text-right">
				<button class="btn btn-default" onclick="saveActressInfo()">Save</button>
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-12">
				<textarea class="form-control" rows="1" name="COMMENT">${actress.comment}</textarea>
			</div>
		</div>
	</form>
	
	<div class="row">
		<div class="col-sm-9">
			<form id="pictureUploadForm" method="POST" enctype="multipart/form-data">
				<input type="file" name="image" id="imageFile" class="form-control"/>
			</form>
		</div>
		<div class="col-sm-3">
			<button class="btn btn-default btn-block" onclick="searchActressPicture()">Search picture</button>
		</div>
	</div>
	
	
	<h4>
		<span class="label label-plain" onclick="$('.studio-list').toggleClass('hide')">Studio</span><span class="badge badge-plain">${fn:length(actress.studioList)}</span>
		<span class="label label-plain">Video</span><span class="badge badge-plain">${fn:length(actress.videoList)}</span>
	</h4>
	<div class="form-group hide studio-list" style="padding-left:0px;">
		<ul class="list-inline">
			<c:forEach items="${actress.studioList}" var="studio">
				<li>
					<div class="box box-small">
						<jk:studio studio="${studio}" view="detail"/>
					</div>
				</li>
			</c:forEach>
		</ul>
	</div>
</div>
<div class="container container-video-card">
	<div class="form-group text-center box" style="margin:0;">
		<c:if test="${actress.name ne 'Amateur'}">
			<ul class="list-inline">
				<c:forEach items="${actress.videoList}" var="video">
					<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
				</c:forEach>
			</ul>
		</c:if>
	</div>
</div>

</body>
</html>
