<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"      uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"	tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title>${actress.name}</title>
<style type="text/css">
#actressForm .form-control {
	background-color: rgba(255,255,255,.75);
}
#favoriteTEXT {
	text-shadow: 0px 0px 5px #0c0c0c;
}
body {
    background-repeat: repeat;
    background-position: center top;
	background-size: initial;
}
input[type='text'].form-control {
	text-align: center;
}
@media (min-width: 1200px) {
	.container-video-card {
    	width: 100%;
	}
	.container-video-card li {
		transform: scale(1.7, 1.7);
		margin: 65px 100px;
	}
	.video-card {
		background-color: rgb(171, 116, 91);
    }
	.video-card:hover {
		background-color: rgb(209, 125, 148);
    	transform: none;
    }
}
.video-box:hover {
    transform: none;
}
</style>
<script type="text/javascript">
bgContinue = ${empty actress.image};
var archive = ${actress.archive};
$(document).ready(function() {
	!bgContinue && $("body").css({
		background: "url('${PATH}/video/actress/${actress.name}/cover') center top repeat fixed #fff"
	});	
	if (archive) {
		$("#favoriteTEXT").hide();
		$(".btn").hide();
	}
});
function saveActressInfo() {
	restCall(PATH + '/rest/actress', {method: "PUT", data: $("form#actressForm").serialize(), title: "Save actress info"}, function() {
//		if (opener) {
//			if (opener.location.href.indexOf("video/actress") > -1) 
//				opener.location.reload();
//		}
		location.href = PATH + "/video/actress/" + $("#newName").val();
	});
}
function searchActressInfo() {
	var name = '${actress.name}';
	var localName = $("#localName").val();
	if (localName != '') {
		name = localName;
	}
	popup('<c:url value="${urlSearchActress}"/>' + name, 'infoActress', 1400, 900);
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
				<span id="favoriteTEXT" onclick="fnFavorite(this, '${actress.name}')" class="text-danger lead">${actress.favorite ? '★' : '☆'}</span>
			</div>
			<div class="col-sm-4">
				<input class="form-control" type="text" name="NEWNAME" value="${actress.name}" id="newName"/>
			</div>
			<div class="col-sm-4">
				<input class="form-control" type="text" name="LOCALNAME" value="${actress.localName}" placeholder="local name" id="localName"/>
			</div>
			<div class="col-sm-1">
				<img src="<c:url value="/img/magnify${status.count%2}.png"/>" width="12px" title="<s:message code="video.find-info.actress"/>" onclick="searchActressInfo()"/>
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
	
	<%-- <h3>
		<span class="label label-plain">Studio <small class="badge badge-black">${fn:length(actress.studioList)}</small></span>
	</h3> --%>
	<div class="form-group" style="padding-left:0px;">
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

	<h4>
		<span class="label label-plain">Video <small class="badge badge-black">${fn:length(actress.videoList)}</small></span>
	</h4>
</div>
<div class="container container-video-card">
	<div class="form-group text-center box" style="margin:0;">
		<c:if test="${actress.name ne 'Amateur'}">
			<ul class="list-inline">
				<c:forEach items="${actress.videoList}" var="video">
					<li><%@ include file="/WEB-INF/views/video/videoBoxForActress.jspf" %></li>
				</c:forEach>
			</ul>
		</c:if>
	</div>
</div>

</body>
</html>
