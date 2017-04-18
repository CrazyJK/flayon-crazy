<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Navigator Object Properties</title>
<script type="text/javascript">
var browser;
var MSIE    = 'MSIE';
var CHROME  = 'Chrome';
var FIREFOX = 'Firefox';
var SAFARI  = 'Safari';

var agent = navigator.userAgent.toLowerCase();
if (/trident/.test(agent) || /msie/.test(agent))
	browser = MSIE;
else if (/chrome/.test(agent))
	browser = CHROME;
else if (/firefox/.test(agent))
	browser = FIREFOX;
else if (/safari/.test(agent))
	browser = SAFARI;
else 
	browser = 'Unknown';

var system;
var WINDOWS = 'Windows';
var LINUX   = 'Linux';
var MAC     = 'Macintosh';
var IPHONE  = 'iPhone';
var IPAD    = 'iPad';
var ANDROID = 'Android';

if (/Windows/.test(agent))
	system = WINDOWS;
else if (/windows/.test(agent))
	system = WINDOWS;
else if (/linux/.test(agent))
	system = LINUX;
else if (/macintosh/.test(agent))
	system = MAC;
else if (/iphone/.test(agent))
	system = IPHONE;
else if (/ipad/.test(agent))
	system = IPAD;
else if (/android/.test(agent))
	system = ANDROID;
else
	system = 'Unknown';

/* Navigator Object Properties
	appCodeName 	Returns the code name of the browser
	appName 		Returns the name of the browser
	appVersion 		Returns the version information of the browser
	cookieEnabled 	Determines whether cookies are enabled in the browser
	geolocation 	Returns a Geolocation object that can be used to locate the user's position
	language 		Returns the language of the browser
	onLine 			Determines whether the browser is online
	platform 		Returns for which platform the browser is compiled
	product 		Returns the engine name of the browser
	userAgent 		Returns the user-agent header sent by the browser to the server
	javaEnabled() 	Specifies whether or not the browser has Java enabled
	taintEnabled() 	Removed in JavaScript version 1.2. Specifies whether the browser has data tainting enabled
 */
var navigatorProperties =  [["appCodeName", "Returns the code name of the browser"], 
							["appName", "Returns the name of the browser"], 
							["appVersion", "Returns the version information of the browser"], 
							["cookieEnabled", "Determines whether cookies are enabled in the browser"], 
							["geolocation", "Returns a Geolocation object that can be used to locate the user's position"], 
							["language", "Returns the language of the browser"], 
							["onLine", "Determines whether the browser is online"], 
							["platform", "Returns for which platform the browser is compiled"], 
							["product", "Returns the engine name of the browser"], 
							["userAgent", "Returns the user-agent header sent by the browser to the server"],
							["javaEnabled()", "Specifies whether or not the browser has Java enabled"], 
							["taintEnabled()", "Removed in JavaScript version 1.2. Specifies whether the browser has data tainting enabled"]];

window.onload = function() {
	for (var i=0; i<navigatorProperties.length; i++) {
		var propertyName = navigatorProperties[i][0];
		var propertyDesc = navigatorProperties[i][1];
		var propertyValue = new Object();
		try {
			if (propertyName === 'geolocation') {
				propertyValue = '<span class="text-warning">Not available</span>';
				if (navigator.geolocation) {
					navigator.geolocation.getCurrentPosition(function(position) {
						$('#geolocation').next().html('Latitude: ' + position.coords.latitude + ', Longitude: ' + position.coords.longitude);
					});
				} 
				else {
					propertyValue = '<span class="text-warning">is not supported by this browser.</span>';
				}
			} 
			else {
				propertyValue = eval('navigator.' + propertyName);
			}
		} 
		catch (e) {
			propertyValue = '<span class="text-danger">' + e + '</span>';
		}

		$('<tr>').append(
			$('<td>').attr({id: propertyName, title: propertyDesc}).addClass('text-primary').css({minWidth: '130px'}).html(propertyName)
		).append(
			$('<td>').addClass('text-success').html(propertyValue)
		).appendTo($('.table > tbody'));
	}

	$('.browser').html(browser);
	$('.system').html(system);

}
</script>
</head>
<body>

	<div class="container">
		
		<div class="page-header">
			<h1><strong class="browser text-primary"></strong> <small>browser on</small> <strong class="system text-primary"></strong></h1>
		</div>

		<h3>Navigator Object Properties</h3>
		<table class="table table-striped table-bordered table-condensed">
			<thead class="bg-primary">
				<tr>
					<th>Property name</th>
					<th>Property value</th>
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>

	</div>

</body>
</html>
