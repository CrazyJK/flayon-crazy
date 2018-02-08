<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s"    uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Profile : ${user.name}</title>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>User Profile ...</h1>
	</div>
	
	<form:form commandName="user" method="post" class="form-horizontal" role="form">
		<form:input path="id"   type="hidden"/>
		<form:input path="name" type="hidden"/>
		<form:input path="role" type="hidden"/>
		<div class="form-group">
			<form:label class="col-sm-2 control-label" path="name">Name</form:label>
      		<div class="col-sm-10">
				<p class="form-control-static">${user.name}</p>
			</div>
		</div>
		<s:bind path="password">
		<div class="form-group ${status.error ? 'has-error' : ''}">
			<form:label class="col-sm-2 control-label" path="password">Password</form:label>
      		<div class="col-sm-6">
				<form:input type="password" path="password" placeholder="password" cssClass="form-control"/>
			</div>
      		<form:errors path="password" cssClass="col-sm-4 form-control-static has-error"/>
		</div>
		</s:bind>
		<div class="form-group">
			<form:label class="col-sm-2 control-label" path="role">Role</form:label>
      		<div class="col-sm-6">
				<p class="form-control-static">${user.role.name}</p>
			</div>
		</div>
		<div class="form-group">        
      		<div class="col-sm-offset-2 col-sm-10">
				<button type="submit" class="btn btn-sm btn-success">Update</button>
      		</div>
      	</div>
	</form:form>

</div>
</body>
</html>