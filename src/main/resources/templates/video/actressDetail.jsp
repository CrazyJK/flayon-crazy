<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"      uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title>${actress.name}</title>
<script type="text/javascript">
$(document).ready(function(){
	
	var queryUrl = context + 'image/google.json?q=${actress.name}'; 
	$.getJSON(queryUrl ,function(data) {
		$('#foundList').empty();
		
		var videoRow = data['URLList'];
		$.each(videoRow, function(entryIndex, entry) {
			var url = entry;
			var li  = $("<li>");
			li.css("display", "inline-block");
			var img = $("<img>");
			img.attr("src", url);
			img.attr("width", "200px;");
			img.bind("click", function() {
				popupImage(url);
			});
			li.append(img);
			$('#foundList').append(li);
		});
	});
	
});

/**
 * @deprecated
 */
function fnRenameTo() {
	var actressForm = document.forms['actressForm'];
	actressForm.action = "<s:url value="/video/actress/${actress.name}/renameTo/"/>" + $("#newName").val();
	actressForm.submit();
}

function fnSaveActressInfo() {
	loading(true, "Saving...");
	var actressForm = document.forms['actressForm'];
	actressForm.action = "<s:url value="/video/actress/${actress.name}"/>";
	actressForm.submit();
	if (opener) {
		if (opener.location.href.indexOf("video/actress") > -1) 
			opener.location.reload();
	}
}
function toogleFavorite(dom) {
	var favorite = $("#favorite").val() == 'true';
	$("#favoriteTEXT").html(favorite ? '☆' : '★');
	$("#favorite").val(!favorite);
	if (opener) {
		// TODO 메인의 배우 정보 업데이트 해야함
	}
}
</script>
</head>
<body>

<form id="actressForm" action="<s:url value="/video/actress/${actress.name}"/>" method="post">
<input type="hidden" name="_method" id="hiddenHttpMethod" value="post"/>
<input type="hidden" name="name" value="${actress.name}"/>
<input type="hidden" name="favorite" id="favorite" value="${actress.favorite}"/>
<dl class="dl-detail">
	<dt class="label-large center">
		<span id="favoriteTEXT" onclick="toogleFavorite()">${actress.favorite ? '★' : '☆'}</span>
		<input class="actressInfo" type="text" name="newname"   value="${actress.name}"      id="newName" />
		<input class="actressInfo" type="text" name="localname" value="${actress.localName}" />
		<img src="<c:url value="/res/img/magnify${status.count%2}.png"/>" width="12px" title="<s:message code="video.find-info.actress"/>"
			onclick="popup('<s:eval expression="@prop['url.search.actress']"/>${actress.reverseName}', 'infoActress', 800, 600)"/>
		<span>Score ${actress.score}</span>
		<%-- <span  class="button" style="float:right" onclick="fnRenameTo()">Rename</span> --%>
	</dt>
	<dd style="text-align:center;">
		<div id="actressImageContainer">
			<ul id="foundList" class="items"></ul>
		</div>
		<%-- <c:forEach items="${actress.webImage}" var="url">
			<img src="${url}" width="190px" onclick="popupImage('${url}')"/>
		</c:forEach> --%>
	</dd>
	<dd>
		<span class="label-title">Birth : <input class="actressInfo" type="text" name="birth"    value="${actress.birth}"    /></span>
		<span class="label-title">Size :  <input class="actressInfo" type="text" name="bodySize" value="${actress.bodySize}" /></span>
		<span class="label-title">Height :<input class="actressInfo" type="text" name="height"   value="${actress.height}"   /></span>
		<span class="label-title">Debut : <input class="actressInfo" type="text" name="debut"    value="${actress.debut}"    /></span>
		<span class="button" style="/*float:right*/" onclick="fnSaveActressInfo()">Save</span>
	</dd>
	<dd>
		<span class="label-title">Studio(${fn:length(actress.studioList)})</span>
	</dd>
	<dd>
		<div style="padding-left:60px;">
		<c:forEach items="${actress.studioList}" var="studio">
			<span class="label" onclick="fnViewStudioDetail('${studio.name}')">
				${studio.name}(${fn:length(studio.videoList)}), Score ${studio.score} </span>
		</c:forEach>
		</div>
	</dd>
	<dd>
		<span class="label-title">Video(${fn:length(actress.videoList)})</span>
	</dd>
	<dd>
		<div style="padding-left:60px;">
		<ul>
			<c:forEach items="${actress.videoList}" var="video">
			<%@ include file="/WEB-INF/views/video/videoCard.jspf" %>
			</c:forEach>
		</ul>
		</div>
	</dd>
</dl>
</form>

<div style="padding-left:60px;">
</div>
</body>
</html>
