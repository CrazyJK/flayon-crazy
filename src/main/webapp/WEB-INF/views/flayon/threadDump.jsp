<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Thread dump</title>
<style type="text/css">
p {
	margin:0 10px;
}
.input-group-addon {
	background-color: #fff;
}
</style>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Thread Info ... <span class="badge">${threadInfos.size()}</span></h1>
	</div>
	
	<section class="panel panel-default">
		<header class="panel-heading">
			<form:form method="get" commandName="paramInfo" cssClass="form-inline">
				<div class="input-group input-group-sm">
      				<span class="input-group-addon" title="Show only what thread name starts with">thread name starts with</span>
					<form:input path="name" cssClass="form-control"/>
				</div> 
				<div class="input-group input-group-sm">
					<span class="input-group-addon" title="thread state">thread state is</span>
					<form:select path="state" cssClass="form-control">
						<option value="">All</option>
		 				<form:options items="${threadStates}"/>
					</form:select>
				</div>
				<button type="submit" class="btn btn-sm btn-default" style="float:right">View</button>
			</form:form>
		</header>
		<div class="panel-body">
			<div class="list-group">
				<c:forEach items="${threadInfos}" var="threadInfo">
				<div class="list-group-item">
					<h4 class="list-group-item-heading text-nowrap">
						<b>${threadInfo.threadName} ${threadInfo.threadState}</b> - 
						<a href="?threadId=${threadInfo.threadId}">${threadInfo.threadId}</a>
					</h4>
					<div class="list-group-item-text">
						<c:forEach items="${threadInfo.stackTrace}" var="stackTrace">
						<p>${stackTrace}</p>
						</c:forEach>
					</div>
				</div>
				</c:forEach>
			</div>
		</div>
	</section>

</div>
</body>
</html>