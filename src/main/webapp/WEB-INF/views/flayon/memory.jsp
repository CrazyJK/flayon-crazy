<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>Memory</title>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>JVM Memory</h1>
	</div>

	<table class="table table-bordered">
		<tr>
			<th>Area</th>
			<th>Init (MB)</th>
			<th>Used (MB)</th>
			<th>Commit (MB)</th>
			<th>Max (MB)</th>
			<th>Used(%)</th>
		</tr>
		<tr>
			<td>Heap</td>
			<td class="text-right"><fmt:formatNumber value="${heap.init / 1024 / 1024}" pattern="#,###"/></td>
			<td class="text-right"><fmt:formatNumber value="${heap.used / 1024 / 1024}" pattern="#,###"/></td>
			<td class="text-right"><fmt:formatNumber value="${heap.committed / 1024 / 1024}" pattern="#,###"/></td>
			<td class="text-right"><fmt:formatNumber value="${heap.max / 1024 / 1024}" pattern="#,###"/></td>
			<td class="text-right"><fmt:formatNumber value="${heap.used / heap.max}" type="percent"/></td>
		</tr>
		<tr>
			<td>Non Heap</td>
 			<td class="text-right"><fmt:formatNumber value="${nonHeap.init / 1024 / 1024}" type="number" maxFractionDigits="0"/></td>
			<td class="text-right"><fmt:formatNumber value="${nonHeap.used / 1024 / 1024}" type="number" maxFractionDigits="0"/></td>
			<td class="text-right"><fmt:formatNumber value="${nonHeap.committed / 1024 / 1024}" type="number" maxFractionDigits="0"/></td>
			<td class="text-right"><fmt:formatNumber value="${nonHeap.max / 1024 / 1024}" type="number" maxFractionDigits="0"/></td>
			<td class="text-right"><fmt:formatNumber value="${nonHeap.used / nonHeap.max}" type="percent"/></td>
		</tr>
	</table>

	<div>Heap : ${heap}</div>
	<div>Non-Heap : ${nonHeap}</div>
</div>
</body>
</html>
