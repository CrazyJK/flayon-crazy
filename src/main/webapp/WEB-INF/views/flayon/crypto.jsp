<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<title>Cryptography</title>
<style type="text/css">
.ui-effects-transfer { 
	border: 1px solid #ccc;
	background-color: #d9edf7; 
}
</style>
<script type="text/javascript">
var effectTime = 500;
$(document).ready(function() {
	
	$(".col-sm-5 textarea").height($(".col-sm-2 .panel-body").height() - 14);
	
	$("button").on('click', function() {
		var id          = $(this).attr("id");
		var method      = $(this).attr("data-method");
		var direction   = $(this).attr("data-direction");
		var  fromObject = direction === 'encrypt' ? "#decrypt" : "#encrypt";
		var    toObject = direction === 'encrypt' ? "#encrypt" : "#decrypt";
		var debugObject = ".debug";
		var text        = $(fromObject).val();

		if ($.trim(text) === '') {
			$(fromObject).effect("pulsate", {}, 300);
			return;
		}

		$(debugObject).html("&nbsp;");
		$(fromObject).effect("transfer", { to: "#" + id, className: "ui-effects-transfer" }, effectTime, function() {
			$.ajax({
				method: "POST",
				url: "${PATH}/flayon/crypto.text",
				data: {method: method, value: text},
				dataType: "text",
				beforeSend: function(xhr) {
				    xhr.overrideMimeType("text/plain; charset=UTF-8");
				//	console.log("btn click method:", method, ", direction:", direction, ", text:", text);
				}
			}).done(function(data, textStatus, jqXHR) {
				console.log("done", textStatus);
				if (jqXHR.getResponseHeader('error') == 'true') {
					$("#" + id).effect("transfer", { to: debugObject, className: "ui-effects-transfer" }, effectTime, function() {
						var errorMessge = jqXHR.getResponseHeader('error.message');
						var errorCause  = jqXHR.getResponseHeader('error.cause');
						printDebug('<strong class="text-danger">' + errorMessge + '</strong>&nbsp;' + errorCause);
					});
				}
				else {
					$("#" + id).effect("transfer", { to: toObject, className: "ui-effects-transfer" }, effectTime, function() {
						if (direction === 'encrypt') {
							$("#encrypt").val(data);
						} 
						else {
							$("#decrypt").val(data);
						}
						printDebug(direction + " by <strong>" + method + "</strong");
					});
				}
			}).fail(function(jqXHR, textStatus, errorThrown) {
				$("#" + id).effect("transfer", { to: debugObject, className: "ui-effects-transfer" }, effectTime, function() {
					errorHtml = $.parseHTML(jqXHR.responseText);
					parsed = $('<div>').append(errorHtml);
					context = parsed.find("body > div.container").html();
					printDebug(context);
				});
			}).always(function(data_jqXHR, textStatus, jqXHR_errorThrown) {
			//	console.log("crypto : data_jqXHR", data_jqXHR);
			//	console.log("crypto : textStatus", textStatus);
			//	console.log("crypto : jqXHR_errorThrown", jqXHR_errorThrown);
			});
		});

	});
});

function printDebug(msg) {
	$(".debug").html(msg).fadeIn(500);
}
</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Cryptography</h1>
 	</div>

	<div class="text-info debug text-right" style="height:22px;">Ready</div>

	<form class="row">
		<div class="col-sm-5">
			<div class="panel panel-default">
	  			<div class="panel-heading">
					<h3 class="text-center">Plain text</h3>
				</div>
				<div class="panel-body">
					<textarea class="form-control" id="decrypt" placeholder="plain text to encrypt, or decrypted text"></textarea>
				</div>
			</div>
		</div>
		<div class="col-sm-2 text-center">
			<div class="panel panel-default">
	  			<div class="panel-heading">
					<h3 class="text-center">Method</h3>
				</div>
				<div class="panel-body">
					<c:forEach items="${cryptoMethods}" var="cryptoMethod" varStatus="x">
						<div class="btn-group-vertical btn-group-sm btn-block" data-toggle="buttons">
							<c:forEach items="${cryptoMethod.value}" var="crypto" varStatus="y">
								<button class="btn btn-default nowrap" id="${x.index}-${y.index}" data-method="${crypto.key}" data-direction="${crypto.value}">
									<span class="glyphicon glyphicon-chevron-left"  style="float:left;  ${crypto.value eq 'decrypt' ? '' : 'visibility: hidden;'}"></span>
									<span class="glyphicon glyphicon-chevron-right" style="float:right; ${crypto.value eq 'encrypt' ? '' : 'visibility: hidden;'}"></span>
									${fn:replace(crypto.key, 'crypt', '')}
								</button>
							</c:forEach>			
						</div>
						${x.last ? '' : '<hr>'}
					</c:forEach>
				</div>
			</div>
		</div>
		<div class="col-sm-5">
			<div class="panel panel-default">
	  			<div class="panel-heading">
					<h3 class="text-center">Cipher text</h3>
				</div>
				<div class="panel-body">
					<textarea class="form-control" id="encrypt" placeholder="encrypted text"></textarea>
				</div>
			</div>
		</div>
	</form>

</div>

</body>
</html>