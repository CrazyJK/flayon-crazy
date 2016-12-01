<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>Memory</title>
<style type="text/css">
thead > tr {
	background-color:rgba(255,165,0,.5);
}
tbody > tr:hover {
	background-color:rgba(255,165,0,.25);
}
</style>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>JVM Memory</h1>
	</div>

	<table class="table table-bordered">
		<thead>
			<tr>
				<th>Area</th>
				<th class="text-right">Init (MB)</th>
				<th class="text-right">Used (MB)</th>
				<th class="text-right">Commit (MB)</th>
				<th class="text-right">Max (MB)</th>
				<th class="text-right">Used(%)</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<th>Heap</th>
				<td class="text-right"><fmt:formatNumber value="${heap.init / 1024 / 1024}" pattern="#,###"/></td>
				<td class="text-right"><fmt:formatNumber value="${heap.used / 1024 / 1024}" pattern="#,###"/></td>
				<td class="text-right"><fmt:formatNumber value="${heap.committed / 1024 / 1024}" pattern="#,###"/></td>
				<td class="text-right"><fmt:formatNumber value="${heap.max / 1024 / 1024}" pattern="#,###"/></td>
				<td class="text-right"><fmt:formatNumber value="${heap.used / heap.max}" type="percent"/></td>
			</tr>
			<tr>
				<th>Non Heap</th>
	 			<td class="text-right"><fmt:formatNumber value="${nonHeap.init / 1024 / 1024}" type="number" maxFractionDigits="0"/></td>
				<td class="text-right"><fmt:formatNumber value="${nonHeap.used / 1024 / 1024}" type="number" maxFractionDigits="0"/></td>
				<td class="text-right"><fmt:formatNumber value="${nonHeap.committed / 1024 / 1024}" type="number" maxFractionDigits="0"/></td>
				<td class="text-right"><fmt:formatNumber value="${nonHeap.max / 1024 / 1024}" type="number" maxFractionDigits="0"/></td>
				<td class="text-right"><c:if test="${nonHeap.max > 0}"><fmt:formatNumber value="${nonHeap.used / nonHeap.max}" type="percent"/></c:if></td>
			</tr>
		</tbody>
	</table>

	<div class="well well-sm">
		<p>Heap : ${heap}</p>
		<p>Non-Heap : ${nonHeap}</p>
	</div>
</div>
</body>
</html>
