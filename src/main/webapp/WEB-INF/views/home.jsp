<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<security:authorize access="isAuthenticated()" var="isAuth"/>
<c:if test="${isAuth}">
    <security:authentication property="principal.username" var="username"/>
</c:if>
<html>
<head>
<title><s:message code="default.home"/></title>
<style type="text/css">
body {
    /* background: #000 url("<c:url value="/img/bg/mountain.jpg"/>") no-repeat fixed top center; */
    background: url("<c:url value="/img/bg/mountain.jpg"/>") no-repeat fixed top center, url("<c:url value="/img/bg/chalk-bg.png"/>");
 	transition: background .5s linear;
 	overflow: hidden;
}
div.container, footer.nav, select {
	background-color: transparent !important;
	background-image: none;
}
div.jumbotron {
	background: url("<c:url value="/img/bg/chalk-bg.png"/>") repeat center top;
	background-size: cover;
	margin: 15px auto;
    padding: 10px;
	width: calc(100% - 350px);
	min-height: 260px;
    color: #f0f0f0;
    line-height: 1.40em;
    text-shadow: #000 0px 1px 0px;
    box-shadow: rgba(0, 0, 0, 0.8) 0px 20px 70px;
    transition: height 0.5s, min-height .5s;
}
div.jumbotron h1 {
	height: 80px;
}
p.text-body {
	text-align: left;
	line-height: 27px;
}
div.modal-dialog {
	width: 650px;
    height: 250px;
    margin-top: 380px;
}
div.modal-content {
 	background-color: rgba(0, 0, 0, 0);
    color: #eee;
}
div.modal-header, div.modal-footer {
	border: 0;
}
div.modal-body {
	padding: 0 15px;
}
div.modal-body table.table {
	margin: 0;
}
div.modal-body .checkbox {
	margin-top: 0;
}
div.modal-footer {
	padding: 0;
}
form input.form-control {
    background-color: transparent !important;
    color: #eee !important;
    border: 0;
}
form .input-group {
	margin-bottom: 15px;
	padding-top: 10px;
}
form .input-group-addon {
	background-color: transparent;
    color: #eee;
    border: 0;
}
form button[type='submit'], form button[type='submit']:hover {
/* 	border: 1px solid #eee; */
    border: 0;
	border-radius: 4px;
}
div.modal-content .btn-link, div.modal-content a, div.modal-content .btn-link:hover, div.modal-content a:hover {
	color: #eee;
	text-decoration: none;
}
.life-timer {
	font-weight: bold;
	font-size: 34px;
	color: #4d6371;
    text-shadow: #000 0px 1px 0px;
    position: fixed;
    bottom: 0;
    text-align: center;
    padding-bottom: 20px;
    width: 100%;
}
.life-timer div {
	display: inline-block;
	margin: 0 3px;
}
.hour-timer, .minute-timer, .second-timer {
	width: 40px;
}
.timer-delimiter {
	color: #eee;
}
.life-timer-on {
    border-radius: 4px;
    background: #111;
    color: #eee;   
}
</style>
</head>
<body>

	<div class="container text-center">
		<div class="jumbotron">
			<h1 class="no-effect">
				<b id="hello"></b>
				<span id="name"></span>
			</h1>
			<p class="text-body">
				<span id="wording"></span>
			</p>
		</div>
	</div>

	<div class="life-timer">
		<div class="day-timer"></div><span class="timer-delimiter">D</span>
		<div class="hour-timer"></div>
		<span class="timer-delimiter">:</span>
		<div class="minute-timer"></div>
		<span class="timer-delimiter">:</span>
		<div class="second-timer"></div>
	</div>

	<div id="loginModal" class="modal fade">
		<div class="modal-dialog modal-sm">
			<div class="modal-content">
				<div class="modal-header">
					<a class="close" data-dismiss="modal">&times;</a>
					<h3 class="modal-title">
						<b id="login-welcome">Welcome to FlayOn</b>
					</h3>
				</div>
				<div class="modal-body">
					<table class="table">
						<tr>
							<td>
								<div id="aperture"></div>
							</td>
							<td>
								<form method="post" class="form center-block" action="<c:url value="/login"/>">
									<div class="input-group">
      									<span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
										<input type="text" name="username" class="form-control" placeholder="Your name" required="required" autofocus="autofocus"/>
									</div>
									<div class="input-group">
      									<span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
										<input type="password" name="password" class="form-control" placeholder="Password" required="required"/>
									</div>
									<div class="checkbox">
			              				<label><input type="checkbox" name="remember-me"/>Remember me</label>
			            			</div>
									<div>
										<button class="btn btn-link btn-block" type="submit">Login</button>
									</div>
								</form>
							</td>
						</tr>
					</table>
				</div>
	      		<div class="modal-footer"></div>
			</div>
		</div>
	</div>

<script type="text/javascript">
var viewLoginForm = function() {
    $("#aperture").aperture({
        src: "<c:url value="/img/kamoru_crazy_artistic_t.png"/>",
        duration: "3s",
        baseColor: "rgba(0,0,0,0.1)",
        color: "rgba(0,0,0,0.5)",
        backgroundColor: "transparent",
        width: "150px",
        outerRadius: "0"
    });
    $("#loginModal").modal();
};

var homeApp = (function($) {
	var isLogin  = '${isAuth}' == 'true',
	    username = '${username}',
	    DEADLINE = 'Apr 28 2031 00:00:00 GMT+0900',
	    WORDING1 = '<s:message code="home.favorites.wording1"/>',
	    WORDING2 = '<s:message code="home.favorites.wording2"/>';
	    
	var showTimer = function() {
        var SECOND = 1000,
            MINUTE = SECOND * 60, // 1000 * 60
            HOUR   = MINUTE * 60, // 1000 * 60 * 60
            DAY    = HOUR   * 24, // 1000 * 60 * 60 * 24
            countDownDate = new Date(DEADLINE).getTime();
            // life remaining display timer
		var lifeTimer = setInterval(function() {
            var now = new Date().getTime(),
                timeRemaining = countDownDate - now;
            if (timeRemaining < 0) {
                clearInterval(lifeTimer);
                $(".life-timer").html("EXPIRED!!!").effect("puff", {}, 1000);
                return;
            }
            
            var days    = Math.floor(timeRemaining / DAY),
                hours   = Math.floor(timeRemaining % DAY / HOUR),
                minutes = Math.floor(timeRemaining % HOUR / MINUTE),
                seconds = Math.floor(timeRemaining % MINUTE / SECOND);
            
            if (seconds == 0) {
                setFonts();
                $(".life-timer").jkEffect({duration: 500});
            }
            
            $(   ".day-timer").html(days);
            $(  ".hour-timer").html(pad(hours, 2));
            $(".minute-timer").html(pad(minutes, 2));
            $(".second-timer").html(pad(seconds, 2));
        }, 1000);

        $(".life-timer > div").attr({"title": DEADLINE.substr(0, 11)}).tooltip({
            position: {at: "center"},
            classes: {"ui-tooltip": "life-timer-on"}
        });
    };
    
	var setFonts = function() {
        !isLogin && $("#headerNav").css({fontFamily: randomFont()});
        $("h1, #wording, #loginModal, #login-welcome, .life-timer").each(function(index) {
            $(this).css({fontFamily: randomFont()});
        });
    };
    
	var start = function() {
        $("#hello").html("FlayOn");
        isLogin && $("#name").html(username);
        $("h1").jkEffect();
        setTimeout(function() {
            $("#wording").typed({
                strings: [WORDING1 + "<br/>" + WORDING2],
                //stringsElement: $('#wordings'),
                typeSpeed: getRandomInteger(10, 50),
                backDelay: 500,
                loop: false,
                contentType: 'html', // or text
                // defaults to false for infinite loop
                loopCount: false,
                callback: function() {
                    $("#wording").next(".typed-cursor").hide();
                    $(".jumbotron").draggable();
                }
            });
        }, 1000);
	};
    
    return {
    	init: function() {
    		$(document).ready(function() {
    		    setFonts();
    		    showTimer();
    		});
    		$(window).load(function() {
    			start();
    		});
    	}
    };
    
}(jQuery));

homeApp.init();
</script>
</body>
</html>
