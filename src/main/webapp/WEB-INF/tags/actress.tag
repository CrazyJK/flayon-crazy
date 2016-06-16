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

	if (view.equalsIgnoreCase("label")) {
%>
<label
	class="item <%=itemCssClass %>" 
	title="${actress.localName} ${actress.birth} ${actress.bodySize} ${actress.height} ${actress.debut}">
	<form:checkbox path="selectedActress" id="selectedActress${count}" value="${actress.name}" cssClass="sr-only"/>
	<span class="label label-default" id="checkbox-selectedActress${count}">${actress.name}(${fn:length(actress.videoList)})</span>
</label>
<%
	} else if (view.equalsIgnoreCase("span")) {
%>
<span style="padding: 5px; margin: 5px;" data-toggle="tooltip"
	onclick="fnViewActressDetail('${actress.name}')" 
	class="item <%=itemCssClass %> box nowarp" 
	title="${actress.localName} ${actress.birth} ${actress.bodySize} ${actress.height} ${actress.debut}">
	${actress.name}(${fn:length(actress.videoList)})
</span>
<%
	} else {
%>
${view} is undefined
<%
	}
%>

