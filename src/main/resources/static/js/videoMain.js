$(document).ready(function(){
	
	// Add listener : implement checkbox element
	$('span[id^="checkbox"]')
		.bind("click", function(){
			var hiddenCheckbox = $("#" + $(this).attr("id").split("-")[1]);
//			alert(hiddenCheckbox.is(":checked"));
			if(hiddenCheckbox.is(":checked")) {
				//hiddenCheckbox.val("false");
				$(this).addClass("label-default");
				$(this).removeClass("label-success");
			} else {
				//hiddenCheckbox.val("true");
				$(this).addClass("label-success");
				$(this).removeClass("label-default");
			}
		})
		.each(function(){
			var hiddenCheckbox = $("#" + $(this).attr("id").split("-")[1]);
			//$("#debug2").html($(this).attr("id").split("-")[1] + " : " + hiddenCheckbox.val());
			if(hiddenCheckbox.is(":checked")) {
				$(this).addClass("label-success");
				$(this).removeClass("label-default");
			} else {
				$(this).addClass("label-default");
				$(this).removeClass("label-success");
			}
			$(this).css("cursor", "pointer");
		});
	
	// Add listener : implement radio element
	$('span[id^="radio"]')
		.bind("click", function(){
			var idArr = $(this).attr("id").split("-");
			$("#" + idArr[1]).val(idArr[2]);
			$('span[id^="radio-' + idArr[1] + '"]').removeClass("radio-on");
			$(this).addClass("radio-on");
		})
		.each(function(){
			var idArr = $(this).attr("id").split("-");
			if($("#" + idArr[1]).val() == idArr[2]) {
				$(this).addClass("radio-on");
			} else {
				$(this).removeClass("radio-on");
			}
		});

	// Add listener : video box click. add border, opacity
	$("li[id^='opus-']").click(function() {
		var clicked = $(this).attr("clicked");
		if (!clicked || clicked == 'false') {
			$(this).attr("clicked", "true");
			$(this).addClass("li-box-select");
//			$(this).children().animate({"height": "+=20px"}, "slow", function() {
//				$("#DEL-"+$(this).parent().attr("id")).css("display", "");
//				$(this).parent().addClass("li-box-select");
//			});
		}
		else {
			$(this).attr("clicked", "false");
			$(this).removeClass("li-box-select");
//			$(this).children().animate({"height": "-=20px"}, "slow", function() {
//				$("#DEL-"+$(this).parent().attr("id")).css("display", "none");
//				$(this).parent().removeClass("li-box-select");
//			});
		}
	});
	
	// Add listener : addCond click if its child clicked
 	$('span[id^="checkbox-exist"]').bind("click", function(){
 		if(!$("#addCond1").is(":checked")) {
 			$("#debug").html("addCond click");
 			$("#checkbox-addCond1").click();
 		}
	});

 	// Add listener : input text enter
 	$("input.schTxt").bind('keypress', function(e) {
 		if(e.which == 13) {
 			fnSearch();
 		}
 	});
	
	// for slide view
	if(listViewType == 'S' || listViewType == 'V') {
		$(function() {
			$('#slides').slidesjs({
				start: currentVideoIndex,
		        width: 800,
		        height: 550,
		        navigation: {active: true},
		        /* pagination: false, */
		        play: {active: true, interval:5000, auto: false},
		        callback: {
		        	loaded: function(number) {
//		        		console.log("loaded callback : " + number);	 
		        		rePagination();
		        	},
		        	start: function(number) {
//		        		console.log("start callback : " + number);	        
//		        		rePagination();
		        	},
		        	complete: function(number) {
		        		//console.log("complete callback : " + number);
		        		rePagination();
		        	}
		        }
			});
		});
		$(window).bind("mousewheel DOMMouseScroll", function(e) {
			var delta = 0;
			var event = window.event || e;
//			console.log("mouse event ", event);
			if (event.wheelDelta) {
				delta = event.wheelDelta/120;
				if (window.opera) delta = -delta;
			} 
			else if (event.detail)  
				delta = -event.detail/3;
			else
				delta = parseInt(event.originalEvent.wheelDelta || -event.originalEvent.detail);
//			console.log("mouse delta ", delta);
			if (delta) {
				if (delta > 0) 
					$(".slidesjs-previous").click(); //alert("마우스 휠 위로~");
			    else 	
			    	$(".slidesjs-next").click(); //alert("마우스 휠 아래로~");
			}
		});
		$(window).bind("keyup", function(e) {
			var event = window.event || e;
//			console.log("input key : ", event.keyCode);
			switch(event.keyCode) {
			case 37: // left
			case 40: // down
				$(".slidesjs-previous").click(); break;
			case 39: // right
			case 38: // up
				$(".slidesjs-next").click(); break;
//			case 32: // space
			case 34: // PageDown key
				fnRandomVideoView_Slide(); break;
			case 13: // enter
				break;
			}
		});
		$(window).on("mousedown", function(event) {
//			console.log("mousedown event ", event);
			switch (event.which) {
			case 1: // left click
				break;
			case 2: // middle click
				fnRandomPlay();
				break;
			case 3: // right click
				break;
			}
		});

	}
	if(listViewType == 'L') {
		
		fnShowVideoSlise();
		$("#video-slide-wrapper").bind("mousewheel DOMMouseScroll", function(e) {
			var delta = 0;
			var event = window.event || e;
			if (event.wheelDelta) {
				delta = event.wheelDelta/120;
				if (window.opera) delta = -delta;
			}
			else if (event.detail)  
				delta = -event.detail/3;
			else
				delta = parseInt(event.originalEvent.wheelDelta || -event.originalEvent.detail);
			if (delta) {
				if (delta > 0) 
					fnPrevVideoView(); //alert("마우스 휠 위로~");
			    else 	
					fnNextVideoView(); //alert("마우스 휠 아래로~");
			}
		});
		
		$(window).bind("keyup", function(e) {
			var event = window.event || e;
			//alert(event.keyCode);
			switch(event.keyCode) {
			case 37: // left
			case 40: // down
				fnPrevVideoView(); break;
			case 39: // right
			case 38: // up
				fnNextVideoView(); break;
//			case 32: // space
			case 34: // PageDown key
				fnRandomVideoView(); break;
			case 13: // enter
				break;
			}
		});
	}

	$(".nonExist").attr("onclick", "");
});
