<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri='http://www.springframework.org/tags/form'%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>User : ${user.name}</title>
<script type="text/javascript">
$(document).ready(function() {
	$("input[type=radio]").parent().addClass("radio-inline");
	
	$("button.btn").on("click", function() {
		var method = $(this).attr("data-method");
		
		$.ajax({
			url: "/user" + (method === 'DELETE' ? "/" + id.value : ""),
			method: method,
			data: $("form").serialize(),
			beforeSend: function() {
				$(".has-error").removeClass("has-error");
			}
		}).done(function() {
			location.href = "/user/list";
		}).fail(function(jqXHR, textStatus, errorThrown) {
			if (jqXHR.responseJSON) {
				if (jqXHR.responseJSON.errors) {
					$.each(jqXHR.responseJSON.errors, function(idx, error) {
						$("label[for=" + error.field + "]").parent().addClass("has-error");
					});
				}
				else {
					displayNotice('Error', 
							'<b>Error:</b> '     + jqXHR.responseJSON.error + '<br>' + 
							'<b>Exception:</b> ' + jqXHR.responseJSON.exception + '<br>' +
							'<b>Message:</b> '   + jqXHR.responseJSON.message + '<br>' +
							'<b>Timestamp:</b> ' + jqXHR.responseJSON.timestamp + '<br>' +
							'<b>Status:</b> '    + jqXHR.responseJSON.status + '<br>' + 
							'<b>Path:</b> '      + jqXHR.responseJSON.path + '<br>' +
							'<b>Errors:</b> '    + function(errors) {
								var msg = "<br>";
								$.each(errors, function(idx, error) {
									msg += error.objectName + " on " + error.field + " : " + error.code + "<br>"; 
								});
								return msg;
							}(jqXHR.responseJSON.errors),
							600);
				}
			}
			else {
				alert(textStatus);
			}
			console.log(jqXHR, textStatus, errorThrown);
		});
	});
});

</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>${empty user.id ? 'New User' : 'User Info'} ...</h1>
	</div>

	<form:form modelAttribute="user" method="post" class="form-horizontal" role="form">
		<div class="form-group">
			<form:label class="control-label col-sm-2" path="id">Id</form:label>
      		<div class="col-sm-6">
				<form:input type="text" path="id" placeholder="user id" cssClass="form-control" readonly="true"/>
			</div>
		</div>
		<div class="form-group">
			<form:label class="control-label col-sm-2" path="name">Name</form:label>
      		<div class="col-sm-6">
				<form:input type="text" path="name" placeholder="log in name" cssClass="form-control"/>
			</div>
      		<div class="col-sm-4">
				<p class="form-control-static"><form:errors path="name" cssClass="text-danger"/></p>
      		</div>
		</div>
		<div class="form-group">
			<form:label class="control-label col-sm-2" path="password">Password</form:label>
      		<div class="col-sm-6">
				<form:input type="text" path="password" placeholder="password" cssClass="form-control"/>
			</div>
      		<div class="col-sm-4">
				<p class="form-control-static"><form:errors path="password" cssClass="text-danger"/></p>
			</div>
		</div>
		<div class="form-group">        
			<form:label class="control-label col-sm-2" path="role">Role</form:label>
      		<div class="col-sm-6">
				<form:radiobuttons path="role" items="${allRoles}" itemLabel="name"/>
			</div>
      		<div class="col-sm-4">
				<p class="form-control-static"><form:errors path="role" cssClass="text-danger"/></p>
			</div>
		</div>
		<div class="form-group">        
			<div class="col-sm-2 text-right">
				<a href="<c:url value="/user/list"/>" class="btn btn-sm btn-default">Users</a>
			</div>
			<div class="col-sm-10">
				<c:if test="${empty user.id}">
					<button data-method="POST"   class="btn btn-sm btn-success">Save</button>
				</c:if>
				<c:if test="${!empty user.id}">
					<button data-method="POST"   class="btn btn-sm btn-success">Update</button>
					<button data-method="DELETE" class="btn btn-sm btn-warning">Delete</button>
				</c:if>
			</div>
		</div>		
	</form:form>

</div>

</body>
</html>