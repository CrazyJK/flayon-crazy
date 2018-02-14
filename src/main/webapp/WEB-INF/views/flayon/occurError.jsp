<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<c:url value="/video/throwError" var="throwError"/>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>occur Error</title>
<style type="text/css">
.box-frame {
	background-clip: padding-box;
	border: 1px solid #999;
	border: 1px solid rgba(0,0,0,.2);
	border-radius: 6px;
	outline: 0;
	-webkit-box-shadow: 0 3px 9px rgba(0,0,0,.5);
	box-shadow: 0 3px 9px rgba(0,0,0,.5);
	margin: 10px;
	padding: 10px;
}
</style>
<script type="text/javascript">
$(document).ready(function() {
	$("input:radio[name='accept']:input[value=h]").parent().click();

	$("a[data-href]").on("click", function() {
		var href = $(this).attr("data-href");
		var mode = $("input:radio[name='accept']:checked").val();
		console.log(href, mode);

		$(".box-frame").contents().find("body").empty();
		
		if (mode === 'h') {
			errorFrame.location.href = href;
		}
		else {
			$.ajax(href, {
				mimeType: "application/json",
				beforeSend: function(xhr) {
					xhr.setRequestHeader("Accept", "application/json");
				}
			}).done(function(data) {
				console.log("restCall done", data);
			}).fail(function(jqXHR, textStatus, errorThrown) {
				console.log("restCall fail", '\njqXHR=', jqXHR, '\ntextStatus=', textStatus, '\nerrorThrown=', errorThrown);
				if (jqXHR.getResponseHeader('error')) {
					console.log('Header',  jqXHR.status, 
						'\nerror',         jqXHR.getResponseHeader('error'), 
						'\nerror.message', jqXHR.getResponseHeader('error.message'), 
						'\nerror.cause',   jqXHR.getResponseHeader('error.cause'));
					displayJson('Error', 
							'Message: ' + jqXHR.getResponseHeader('error.message') + "<br>" + 
							'Cause: '   + jqXHR.getResponseHeader('error.cause'));
				}
				if (jqXHR.responseJSON) {
					console.log('JSON',    jqXHR.status,
							'\nerror',     jqXHR.responseJSON.error, 
							'\nexception', jqXHR.responseJSON.exception, 
							'\nmessage',   jqXHR.responseJSON.message, 
							'\ntimestamp', jqXHR.responseJSON.timestamp, 
							'\nStatus',    jqXHR.responseJSON.status, 
							'\nPath',      jqXHR.responseJSON.path);
					displayJson('Error', 
							'Error: '     + jqXHR.responseJSON.error + '<br>' + 
							'Exception: ' + jqXHR.responseJSON.exception + '<br>' +
							'Message: '   + jqXHR.responseJSON.message + '<br>' +
							'Timestamp: ' + jqXHR.responseJSON.timestamp + '<br>' +
							'Status: '    + jqXHR.responseJSON.status + '<br>' + 
							'Path: '      + jqXHR.responseJSON.path);
				}
			});
		}
	});
});

function displayJson(title, content) {
	$(".box-frame").contents().find("body").append(
			$("<h1>").append('JSON'),
			$("<h2>").append(title),
			$("<div>").append(content)
	);
}
</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Occur Error</h1>
	</div>

	<div class="text-center">
		<div class="btn-group btn-group-xs" data-toggle="buttons">
			<a class="btn btn-primary"><input type="radio" name="accept" value="h"/>Html</a>
			<a class="btn btn-primary"><input type="radio" name="accept" value="j"/>Json</a>
		</div>
		<div class="btn-group btn-group-xs" data-toggle="buttons">
			<a class="btn btn-default" target="errorFrame" data-href="/UnknownPage"><input type="radio"/>404</a>
			<a class="btn btn-default" target="errorFrame" data-href="?k=error"><input type="radio"/>error</a>
			<a class="btn btn-default" target="errorFrame" data-href="?k=runtime"><input type="radio"/>runtime</a>
			<a class="btn btn-default" target="errorFrame" data-href="?k=base"><input type="radio"/>base</a>
			<a class="btn btn-default" target="errorFrame" data-href="?k=flay1"><input type="radio"/>flay1</a>
			<a class="btn btn-default" target="errorFrame" data-href="?k=flay2"><input type="radio"/>flay2</a>
			<a class="btn btn-default" target="errorFrame" data-href="${throwError}?k=Crazy"><input type="radio"/>crazy</a>
			<a class="btn btn-default" target="errorFrame" data-href="${throwError}?k=Video"><input type="radio"/>video</a>
			<a class="btn btn-default" target="errorFrame" data-href="${throwError}?k=Image"><input type="radio"/>image</a>
			<a class="btn btn-default" target="errorFrame" data-href="${throwError}?k=VideoNotFound"><input type="radio"/>videoNotFound</a>
			<a class="btn btn-default" target="errorFrame" data-href="${throwError}?k=StudioNotFound"><input type="radio"/>studioNotFound</a>
			<a class="btn btn-default" target="errorFrame" data-href="${throwError}?k=ActressNotFound"><input type="radio"/>actressNotFound</a>
			<a class="btn btn-default" target="errorFrame" data-href="${throwError}?k=ImageNotFound"><input type="radio"/>imageNotFound</a>
		</div>
	</div>

	<iframe name="errorFrame" style="width:100%; height:500px;" class="box-frame"></iframe>
	
</div>
</body>
</html>