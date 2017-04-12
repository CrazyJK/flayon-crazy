<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"   uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<title>Cryptography</title>
<style type="text/css">
.ui-effects-transfer { 
	border-radius: 4px; 
	border: 1px solid rgb(217,237,247);
	background-color: rgba(217,237,247,.5);
}
.ui-effects-transfer-danger { 
	border-radius: 4px; 
	border: 0px solid rgba(255, 128, 128, 1);
	background-color: rgba(255, 128, 128, 0.5);
}
#accordion button, #accordion a {
    width: 100%;
    border: 0;
    padding: 3px;
}
#accordion button:hover, #accordion a:hover {
	z-index: auto;
}
@media (min-width: 992px) {
	textarea.form-control {height: 400px;}
	.panel-heading {padding: 10px 15px;}
	.panel-heading > h3 {font-size: 24px; margin: 20px 0 10px;}
	#accordion {padding: 0;}
	#accordion .panel-heading {padding: 10px 15px;}
	.col-md-2 {padding: 0 3px;}
	.col-md-2 > .panel.panel-default {width: 100%; margin: 0 0 20px;}
	.panel-method > .panel-heading {display: block;}
	.panel-method > .panel-body {padding: 15px 0;}
}
@media (max-width: 991px) {
	textarea.form-control {height: 100px;}
	.panel-heading {padding: 5px 15px;}
	.panel-heading > h3 {font-size: 16px; margin: 0;}
	#accordion {padding: 0 15px;}
	#accordion .panel-heading {padding: 3px 5px;}
	.col-md-2 {padding: 0 15px;}
	.col-md-2 > .panel.panel-default {width: 50%; margin: 20px auto;}
	.panel-method > .panel-heading {display: none;}
	.panel-method > .panel-body {padding: 5px 0;}
}
</style>
<script type="text/javascript">
var effectTime = 500;
$(document).ready(function() {
	
	$(".crypto-btn").on('click', function() {
		var id          = $(this).attr("id");
		var method      = $(this).attr("data-method");
		var direction   = $(this).attr("data-direction");
		var  fromObject = direction === 'encrypt' ? "#decrypt" : "#encrypt";
		var    toObject = direction === 'encrypt' ? "#encrypt" : "#decrypt";
		var debugObject = ".debug";
		var text        = $.trim($(fromObject).val());

		if ($.trim(text) === '') {
			$(fromObject).effect("highlight", {color: "#f2dede"}, 500);
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
					$("#" + id).effect("transfer", { to: debugObject, className: "ui-effects-transfer-danger" }, effectTime, function() {
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
				$("#" + id).effect("transfer", { to: debugObject, className: "ui-effects-transfer-danger" }, effectTime, function() {
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
	
	$("[href='#collapseSeed']").click();

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

	<form class="row">
		<div class="col-md-5">
			<div class="panel panel-default">
	  			<div class="panel-heading">
					<h3 class="text-center">Plain text</h3>
				</div>
				<div class="panel-body">
					<textarea class="form-control" id="decrypt" placeholder="plain text to encrypt, or decrypted text"></textarea>
				</div>
			</div>
		</div>
		<div class="col-md-2 text-center">
			<div class="panel panel-default panel-method">
	  			<div class="panel-heading">
					<h3 class="text-center">Method</h3>
				</div>
				<div class="panel-body" style="margin:0 3px;">
					<div class="panel-group" id="accordion" style="margin:0;">
						<c:forEach items="${cryptoMethods}" var="cryptoMethod" varStatus="x">
							<div class="panel panel-default">
	      						<div class="panel-heading">
	        						<h4 class="panel-title">
	          							<a class="btn" data-toggle="collapse" data-parent="#accordion" href="#collapse${cryptoMethod.key}">${cryptoMethod.key}</a>
	        						</h4>
	      						</div>
	      						<div id="collapse${cryptoMethod.key}" class="panel-collapse collapse">
	        						<div class="panel-body" style="padding:3px;">
										<div class="btn-group-vertical btn-group-sm btn-block" data-toggle="buttons">
											<c:forEach items="${cryptoMethod.value}" var="crypto" varStatus="y">
												<a class="btn btn-info nowrap crypto-btn" id="${x.index}-${y.index}" data-method="${crypto.key}" data-direction="${crypto.value}">
													<span class="glyphicon glyphicon-chevron-left"  style="float:left;  ${crypto.value eq 'decrypt' ? '' : 'visibility: hidden;'}"></span>
													<span class="glyphicon glyphicon-chevron-right" style="float:right; ${crypto.value eq 'encrypt' ? '' : 'visibility: hidden;'}"></span>
													${fn:replace(crypto.key, 'crypt', '')}
												</a>
											</c:forEach>			
										</div>
									</div>
	    						</div>
							</div>
						</c:forEach>
					</div>
				</div>
			</div>
		</div>
		<div class="col-md-5">
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

	<div class="debug alert text-info text-center" style="border-radius:4px; padding:5px 15px;">Ready</div>

</div>

</body>
</html>