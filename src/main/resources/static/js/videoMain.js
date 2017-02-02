$(document).ready(function(){
	
	// Add listener : implement checkbox element
	$('span[id^="checkbox"]')
		.css("cursor", "pointer")
		.bind("click", function() {
			var isChecked = $("#" + $(this).attr("id").split("-")[1]).is(":checked");
			//console.log("checkbox click", $(this).attr("id"), isChecked);
			$(this).swapClass("label-success", "label-default", isChecked);
			$($(this).attr("data-toggle")).toggle(!isChecked).swapClass("hide", "", !isChecked);
		})
		.each(function() {
			var isChecked = $("#" + $(this).attr("id").split("-")[1]).is(":checked");
			$(this).swapClass("label-success", "label-default", !isChecked);
			$($(this).attr("data-toggle")).toggle(!isChecked).swapClass("hide", "", !isChecked);
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
	
	/* Add listener
	 * custom checkbox
	 * ex) <span class="label label-default" role="checkbox" data-role-value="false">Favorite</span> 
	 * */
	$("[role='checkbox']").each(function() {
		var checked = $(this).attr("data-role-value") === 'true';
		$(this).addClass('pointer').toggleClass("label-success", checked).data("checked", checked);
	}).on("click", function() {
		var checked = $(this).data("checked");
		$(this).toggleClass("label-success", !checked).data("checked", !checked);
	});

});
