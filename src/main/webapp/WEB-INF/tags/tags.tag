<%@ tag language="java" pageEncoding="UTF-8" body-content="tagdependent"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>

<%@ attribute name="tag"    required="true" type="jk.kamoru.flayon.crazy.video.domain.VTag"%>
<%@ attribute name="view"   required="true"%>
<%@ attribute name="count"  required="false"%>

<%
	String itemCssClass = "item";
	int size = tag.getVideoList().size();
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

	if (view.equalsIgnoreCase("label")) {
%>
<label
	class="item <%=itemCssClass %>" 
	title="${tag.description}">
	<form:checkbox path="selectedTag" id="selectedTag${count}" value="${tag.id}" cssClass="sr-only"/>
	<span class="label label-default" style="padding: 5px; margin: 5px;" 
		id="checkbox-selectedTag${count}">${tag.name} <i>${tag.videoList.size()}</i></span>
</label>
<%
	} else if (view.equalsIgnoreCase("span")) {
%>
<span style="background-color:#fff;" data-toggle="tooltip" class="item <%=itemCssClass %> box box-small" title="${tag.description}">
	<span onclick="fnViewTagDetail('${tag.id}')">${tag.name}</span> 
	<small>${tag.videoList.size()}</small> 
	<span onclick="fnDeleteTag(${tag.id}, this)" title="Delete">&times;</span>
</span>
<%
	} else {
%>
${view} is undefined
<%
	}
%>

