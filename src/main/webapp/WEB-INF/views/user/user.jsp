<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>User : ${user.name}</title>
<script type="text/javascript">
function fnDelete() {
	var hiddenMethod = document.getElementById("hiddenMethod");
	hiddenMethod.value = "DELETE";
	fnSubmit();	
}
function fnSave() {
	var hiddenMethod = document.getElementById("hiddenMethod");
	hiddenMethod.value = "POST";
	fnSubmit();	
}
function fnUpdate() {
	var hiddenMethod = document.getElementById("hiddenMethod");
	hiddenMethod.value = "POST";
	fnSubmit();	
}
function fnSubmit() {
	document.forms[0].submit();
}
</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>User Info ...</h1>
	</div>
	<p>
		<a href="<c:url value="/user"/>" class="btn btn-xs btn-default">Users</a>
		<c:if test="${empty user.id}">
			<button onclick="fnSave()"   class="btn btn-xs btn-success">Save</button>
		</c:if>
		<c:if test="${!empty user.id}">
			<button onclick="fnUpdate()" class="btn btn-xs btn-success">Update</button>
			<button onclick="fnDelete()" class="btn btn-xs btn-warning">Delete</button>
		</c:if>
	</p>

	<form:form commandName="user" method="post" class="form-horizontal" role="form">
		<input type="hidden" id="hiddenMethod" name="_method" value="PUT"/>
		<div class="form-group">
			<form:label class="control-label col-sm-2" path="name">Name</form:label>
      		<div class="col-sm-6">
				<form:input type="text" path="name" placeholder="log in name" cssClass="form-control"/>
			</div>
      		<div class="col-sm-4">
				<p class="form-control-static"><form:errors path="name" cssClass="text-danger" /></p>
      		</div>
		</div>
		<div class="form-group">
			<form:label class="control-label col-sm-2" path="password">Password</form:label>
      		<div class="col-sm-6">
				<form:input type="password" path="password" placeholder="password" cssClass="form-control"/>
			</div>
      		<div class="col-sm-4">
				<p class="form-control-static"><form:errors path="password" cssClass="text-danger" /></p>
			</div>
		</div>
		<div class="form-group">        
			<form:label class="control-label col-sm-2" path="role">Role</form:label>
      		<div class="col-sm-6">
				<form:radiobuttons path="role" items="${allRoles}"/>
			</div>
      		<div class="col-sm-4">
				<p class="form-control-static"><form:errors path="role" cssClass="text-danger" /></p>
			</div>
		</div>
	</form:form>

</div>
</body>
</html>