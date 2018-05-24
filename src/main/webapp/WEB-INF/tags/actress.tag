<%@ tag language="java" pageEncoding="UTF-8" body-content="tagdependent"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>

<%@ attribute name="actress" required="true" type="jk.kamoru.flayon.crazy.video.domain.Actress"%>
<%@ attribute name="view"    required="true"%>
<%@ attribute name="count"   required="false"%>

<%
	String itemCssClass = "item";
	int size = actress.getVideoList().size();
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
	<label
		class="item <%=itemCssClass %>" style="margin:0; padding:0;"
		title="${actress.localName} ${actress.birth} ${actress.bodySize} ${actress.height} ${actress.debut}">
		<form:checkbox path="selectedActress" id="selectedActress${count}" value="${actress.name}" cssClass="sr-only"/>
		<span class="label label-default item ${actress.favorite ? 'favorite' : ''}" style="padding: 5px; margin: 5px;" 
			id="checkbox-selectedActress${count}">${actress.name} <i>${fn:length(actress.videoList)}</i></span>
	</label>
<%
	} else if (view.equalsIgnoreCase("span")) {
%>
<div style="background-color:#fff;" class="box box-small">
	<span class="item <%=itemCssClass%> ${actress.favorite ? 'favorite' : ''}" onclick="fnViewActressDetail('${actress.name}')" 
		title="${actress.localName} ${actress.birth} ${actress.bodySize} ${actress.height} ${actress.debut}">${actress.name}</span>
	<small>${fn:length(actress.videoList)}</small>
</div>
<%
	} else if (view.equalsIgnoreCase("detail")) {
%>
	<span class="label label-plain ${actress.favorite ? 'favorite' : ''}" title="Favorite ${actress.favorite}" onclick="fnFavorite(this, '${actress.name}')">${actress.favorite ? '★' : '☆'}</span>
	<span class="label label-plain" onclick="fnViewActressDetail('${actress.name}')">${actress.name}</span>
	<span class="label label-plain" title="Local" >${actress.localName}</span> 
	<span class="label label-plain" title="Birth" >${actress.birth}</span> 
	<span class="label label-plain" title="Age"   >${actress.age}</span> 
	<span class="label label-plain" title="Body"  >${actress.bodySize}</span> 
	<span class="label label-plain" title="Height">${actress.height}</span> 
	<span class="label label-plain" title="Debut" >${actress.debut}</span> 
	<span class="label label-plain" title="Video" >${fn:length(actress.videoList)}v</span>
	<span class="label label-plain" title="<s:message code="video.find-info.actress"/>" onclick="fnSearchActress('${actress.name}')"><span class="glyphicon glyphicon-user"></span></span>
<%
	} else {
%>
	${view} is undefined
<%
	}
%>

