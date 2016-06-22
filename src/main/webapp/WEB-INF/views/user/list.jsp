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
	<p>
		<a href="#" data-th-href="@{/user/0}" class="btn btn-xs btn-info">New User</a>
	</p>
	<div class="row">
		<div class="col-md-8">
			<table class="table table-striped">
				<thead>
					<tr>
						<th>#</th>
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
						<td>${userStat.count}</td>
					    <td><a href="<c:url value="/user/${user.id}"/>">${user.name}</a></td>
					    <td>${user.password}</td>
					    <td>${user.role}</td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</div>
	</div>

</div>
</body>
</html>