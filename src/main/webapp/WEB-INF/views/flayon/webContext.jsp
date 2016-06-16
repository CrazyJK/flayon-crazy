<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Web Contexts</title>
<style type="text/css">
.code-name {}
.code-value {}
.code-clazz {color:teal}
</style>
</head>
<body>

	<header class="page-header">
		<h1>Web Attribute List</h1>
	</header>

		${session}
		${application}

	<section class="panel panel-info">
		<header class="panel-heading">
			<h3 class="panel-title">Session attributes</h3>
		</header>
		<div class="panel-body">
			<ol><%
					@SuppressWarnings("rawtypes")
					Enumeration names = session.getAttributeNames();
					while (names.hasMoreElements()) {
						String name = (String) names.nextElement();
						Object value = session.getAttribute(name);
						String clazz = value.getClass().getName();
				%>
				<li>
					<dl>
						<dt class="code-name"><%=name%></dt>
						<dd class="code-value"><%=value%></dd>
						<dd class="code-clazz"><%=clazz%></dd>
					</dl>
				</li>
				<%
					}
				%>
			</ol>
		</div>
	</section>

	<section class="panel panel-info">
		<header class="panel-heading">
			<h3 class="panel-title">Request attributes</h3>
		</header>
		<div class="panel-body">
			<ol>
				<%
					names = request.getAttributeNames();
					while (names.hasMoreElements()) {
						String name = (String) names.nextElement();
						Object value = request.getAttribute(name);
						String clazz = value.getClass().getName();
				%>
				<li>
					<dl>
						<dt class="code-name"><%=name%></dt>
						<dd class="code-value"><%=value%></dd>
						<dd class="code-clazz"><%=clazz%></dd>
					</dl>
				</li>
				<%
					}
				%>
			</ol>
		</div>
	</section>

</body>
</html>