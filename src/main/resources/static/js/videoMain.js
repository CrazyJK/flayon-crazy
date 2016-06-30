$(document).ready(function(){
	
	// Add listener : implement checkbox element
	$('span[id^="checkbox"]')
		.css("cursor", "pointer")
		.bind("click", function() {
			var hiddenCheckbox = $("#" + $(this).attr("id").split("-")[1]);
			$(this).swapClass("label-success", "label-default", hiddenCheckbox.is(":checked"));
		})
		.each(function() {
			var hiddenCheckbox = $("#" + $(this).attr("id").split("-")[1]);
			$(this).swapClass("label-success", "label-default", !hiddenCheckbox.is(":checked"));
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

	// Add listener : video box click. set active
	$("li[id^='opus-']").click(function() {
		$(this).toggleClass("active");
	});
	
	// Add listener : addCond click if its child clicked
 	$('span[id^="checkbox-exist"]').bind("click", function(){
 		if(!$("#addCond1").is(":checked")) {
 			$("#checkbox-addCond1").click();
 		}
	});

	$(".nonExist").attr("onclick", "");
});
