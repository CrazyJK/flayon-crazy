<%@ tag language="java" pageEncoding="UTF-8" body-content="tagdependent"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>

<%@ attribute name="studio" required="true" type="jk.kamoru.flayon.crazy.video.domain.Studio"%>
<%@ attribute name="view"   required="true"%>
<%@ attribute name="count"  required="false"%>

<%
	String itemCssClass = "item";
	int size = studio.getVideoList().size();
	if (size >= 100)
		itemCssClass += "100";
	else if (size >= 50)
		itemCssClass += "50";
	else if (size >= 30)
		itemCssClass += "30";
	else if (size >= 10)
		itemCssClass += "10";
	else if (size >= 5)
		itemCssClass += "5";
	else
		itemCssClass += "1";

	if (view.equalsIgnoreCase("checkbox")) {
%>
	<label class="item <%=itemCssClass %>" title="${studio.homepage} ${studio.company} Actress:${fn:length(studio.actressList)}">
		<form:checkbox path="selectedStudio" id="selectedStudio${count}" value="${studio.name}" cssClass="sr-only"/>
		<span class="label label-default item" style="padding: 5px; margin: 5px;" id="checkbox-selectedStudio${count}">
			${studio.name} <i>${fn:length(studio.videoList)}</i>
		</span>
	</label>
<%
	} else if (view.equalsIgnoreCase("span")) {
%>
	<div style="background-color:#fff;" class="box box-small">
		<span class="item <%=itemCssClass %>" onclick="fnViewStudioDetail('${studio.name}')" title="${studio.homepage} ${studio.company} Actress:${fn:length(studio.actressList)}">${studio.name}</span> 
		<small>${fn:length(studio.videoList)}</small>
	</div>		
<%
	} else if (view.equalsIgnoreCase("detail")) {
%>
	<span class="label label-plain" title="${studio}" onclick="fnViewStudioDetail('${studio.name}')">${studio.name}</span>
	<span class="label label-plain">Video ${fn:length(studio.videoList)}</span>
	<span class="label label-plain">Score ${studio.score}</span>
	
<%
	} else {
%>
	${view} is undefined
<%
	}
%>

