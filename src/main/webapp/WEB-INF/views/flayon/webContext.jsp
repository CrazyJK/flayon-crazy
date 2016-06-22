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
<div class="container">

	<header class="page-header">
		<h1>Web Attribute List</h1>
	</header>

	<%@ include file="/WEB-INF/views/flayon/webAttribute.jspf" %>    

</div>
</body>
</html>