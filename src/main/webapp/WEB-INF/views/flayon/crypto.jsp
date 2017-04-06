<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<title>Crypto Encrypt / Decrypt</title>
<script type="text/javascript">
$(document).ready(function() {
	$("button").on('click', function() {
		var method = $(this).attr("data-method");
		var direction = $(this).attr("data-direction");
		console.log("btn click", method, direction);
	});
});

</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Crypto Encrypt / Decrypt</h1>
 	</div>

	<form class="row">
		<div class="col-sm-5">
			<h3 class="text-center">Plain text</h3>
			<textarea class="form-control" rows="24" cols="" name="plain"></textarea>
		</div>
		<div class="col-sm-2 text-center">
			<h3 class="text-center">Method</h3>
			<hr>
			<c:forEach items="${cryptoMethods}" var="cryptoMethod">
				<div class="btn-group-vertical btn-group-sm btn-block" data-toggle="buttons">
					<c:forEach items="${cryptoMethod.value}" var="crypto">
						<button class="btn btn-success" data-method="${crypto.key}" data-direction="${crypto.value}">
							<span class="glyphicon glyphicon-chevron-${crypto.value eq 'encrypt' ? 'right' : 'left'}" style="float:${crypto.value eq 'encrypt' ? 'right' : 'left'};"></span>
							${fn:replace(crypto.key, 'crypt', '')}
							<input type="radio" name="${cryptoMethod.key}"/>
						</button>
					</c:forEach>			
				</div>
				<hr>
			</c:forEach>
		</div>
		<div class="col-sm-5">
			<h3 class="text-center">Encryption</h3>
			<textarea class="form-control" rows="24" cols="" name="encrypt"></textarea>
		</div>
	</form>

</div>

</body>
</html>