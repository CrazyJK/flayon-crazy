<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
Integer status = (Integer)request.getAttribute("status");
String error   = (String) request.getAttribute("error");
response.setHeader("error", "true");
response.setHeader("error.message", status + " : " + error);
response.setHeader("error.cause", "");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>Server Error</title>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap.min.css"/>"/>
<link rel="stylesheet" href="<c:url value="/webjars/bootstrap/3.3.6/dist/css/bootstrap-theme.min.css"/>"/>
<style type="text/css">
.affix {
	top: 0;
	width: 100%;
	z-index: 9999 !important;
}
.navbar {
	margin-bottom: 0px;
}
.affix ~ .container {
	position: relative;
	top: 50px;
}
#session, #request, #properties, #environment, #profiles {
	padding-top: 50px;
}
</style>
</style>
<script type="text/javascript" src="<c:url value="/webjars/jQuery/2.2.3/dist/jquery.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/webjars/bootstrap/3.3.6/dist/js/bootstrap.min.js"/>"></script>
<script type="text/javascript">
$(document).ready(function() {
	var height = $(".container-error").height();
//	console.log(height);
	$(".affix ~ .container").css({"top": height});
	$(".navbar").attr("data-offset-top", height);
});
</script>
</head>
<body data-spy="scroll" data-target=".navbar" data-offset="50">

	<div class="container container-error">
		<span class="text-info" style="float:right;"><fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss" value="${timestamp}"/></span>
	    <h1>${status} : ${error}</h1>
	    <p>${exception}</p>
	    <pre><c:out value="${message}" escapeXml="true"/></pre>
		<pre><c:out value="${requestScope['javax.servlet.error.exception']}" escapeXml="true"/></pre>
	</div>

	<c:if test="${status ne 404}">

		<nav class="navbar navbar-default" data-spy="affix" data-offset-top="50">
	  		<div class="container">
	    		<div class="navbar-header">
	        		<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
	          			<span class="icon-bar"></span>
	          			<span class="icon-bar"></span>
	          			<span class="icon-bar"></span>                        
	      			</button>
	      			<a class="navbar-brand" href="#">Web Attribute</a>
	    		</div>
	    		<div>
	      			<div class="collapse navbar-collapse" id="myNavbar">
	        			<ul class="nav navbar-nav">
	          				<li><a href="#session">Session attributes</a></li>
	          				<li><a href="#request">Request attributes</a></li>
	          				<li><a href="#properties">System properties</a></li>
	          				<li><a href="#environment">Environment</a></li>
	          				<li><a href="#profiles">Spring profiles</a></li>
	        			</ul>
	      			</div>
	    		</div>
	  		</div>
		</nav>    
	
	   	<div id="session" class="container">
			<section class="panel panel-info">
				<header class="panel-heading">
					<h3 class="panel-title">Session attributes</h3>
				</header>
				<div class="panel-body">
					<ol>
					<%	@SuppressWarnings("rawtypes")
						java.util.Enumeration sessionAttributeNames = session.getAttributeNames();
						while (sessionAttributeNames.hasMoreElements()) {
							String name = (String) sessionAttributeNames.nextElement();
							Object value = session.getAttribute(name);
							String clazz = value.getClass().getName(); %>
						<li>
							<dl>
								<dt><%=name%></dt>
								<dd><%=value%></dd>
								<dd><code><%=clazz%></code></dd>
							</dl>
						</li>
					<%	} %>
					</ol>
				</div>
			</section>
		</div>
		<div id="request" class="container">
			<section class="panel panel-info">
				<header class="panel-heading">
					<h3 class="panel-title">Request attributes</h3>
				</header>
				<div class="panel-body">
					<ol>
					<%	java.util.Enumeration requestAttributeNames = request.getAttributeNames();
						while (requestAttributeNames.hasMoreElements()) {
							String name = (String) requestAttributeNames.nextElement();
							Object value = request.getAttribute(name);
							String clazz = value.getClass().getName(); %>
						<li>
							<dl>
								<dt><%=name%></dt>
								<dd class="text-nowrap"><%=value%></dd>
								<dd><code><%=clazz%></code></dd>
							</dl>
						</li>
					<%	} %>
					</ol>
				</div>
			</section>
		</div>
	   	<div id="properties" class="container">
			<section class="panel panel-info">
				<header class="panel-heading">
					<h3 class="panel-title">System properties</h3>
				</header>
				<div class="panel-body">
					<ol>
					<%	for (java.util.Map.Entry<Object, Object> entry : System.getProperties().entrySet()) { %>
						<li>
							<dl>
								<dt><%=entry.getKey()%></dt>
								<dd class="text-nowrap"><%=entry.getValue()%></dd>
								<dd><code><%=entry.getValue().getClass().getName()%></code></dd>
							</dl>
						</li>
					<%	} %>
					</ol>
				</div>
			</section>
		</div>
	   	<div id="environment" class="container">
			<section class="panel panel-info">
				<header class="panel-heading">
					<h3 class="panel-title">Environment</h3>
				</header>
				<div class="panel-body">
					<ol>
					<%	java.util.Map<String, String> envMap = System.getenv();
						for (java.util.Map.Entry<String, String> entry : envMap.entrySet()) { %>
						<li>
							<dl>
								<dt><%=entry.getKey()%></dy>
								<dd class="text-nowrap"><%=entry.getValue()%></dd>
							</dl>
						</li>
					<%	} %>
					</ol>
				</div>
			</section>
		</div>
	   	<div id="profiles" class="container">
			<section class="panel panel-info">
				<header class="panel-heading">
					<h3 class="panel-title">Spring profiles</h3>
				</header>
				<div class="panel-body">
					<ol>
						<c:forEach items="${profiles}" var="profile">
						<li>
							<dl>
								<dt>${profile}</dy>
							</dl>
						</li>
						</c:forEach>
					</ol>
				</div>
			</section>
		</div>
		<script type="text/javascript">
	//	$(".panel-heading").hide();
		</script>

	</c:if>

</body>
</html>
