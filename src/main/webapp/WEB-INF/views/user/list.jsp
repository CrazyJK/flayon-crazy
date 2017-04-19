<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>Users</title>
</head>
<body>
<div class="container">
      
	<div class="page-header">
		<h1>User list ...<span class="badge">${userList.size()}</span></h1>
	</div>
	<div style="padding:15px;">
		<table class="table table-striped">
			<thead class="bg-primary">
				<tr>
					<th>Id</th>
					<th>Name</th>
					<th>Password</th>
					<th>Role</th>
				</tr>
			</thead>
			<tbody>
				<c:if test="${empty userList}">
				<tr>
					<td colspan="4">No data</td>
				</tr>
				</c:if>
				<c:forEach items="${userList}" var="user" varStatus="userStat">
				<tr>
					<td>${user.id}</td>
				    <td><a href="<c:url value="/user/${user.id}"/>">${user.name}</a></td>
				    <td>${user.password}</td>
				    <td>${user.role}</td>
				</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>
	<div class="text-right">
		<a href="${PATH}/user/0" class="btn btn-sm btn-info">New User</a>
	</div>

</div>
</body>
</html>