/**
 * image view configuration
 */

var config = (function() {
	var IMAGE_SOURCE         = "image.source",
		IMAGE_SHOW_METHOD    = "image.show.method",
		IMAGE_SHOW_SPECIFIC  = "image.show.specific",
		IMAGE_ROTATE_DEGREE  = "image.rotate.degree",
		IMAGE_NEXT_METHOD    = "image.next.method",
		IMAGE_PLAY_INTERVAL  = "image.play.interval",
		IMAGE_HIDE_METHOD    = "image.hide.method",
		IMAGE_HIDE_SPECIFIC  = "image.hide.specific",
		IMAGE_TABLET_DISPLAY = "image.tablet.display.method",
		JQUERY_UI_EFFECTs = ["blind", "bounce", "clip", "drop", "explode", "fade", "fold", "puff", "pulsate", "scale", "shake", "size", "slide"],
		effect = {
			name: "", options: {}, duration: 500
		},
		app = {
			selector: "",
			prev: null,
			next: null,
			playCallback: null,
			nav: null,
			eventListener: null,
			init: null
		};
	
	var fn = {
			display: function() {
				$(".imageSource"  ).html(imageSource.value == 0 ? "Image" : "Cover");
				$(".showMethod"   ).html(showMethod.value == 0 ? "Specific[" + $("#effectShowTypes option:selected").val() + "]" : "Radndom[" + effect.name + "]");
				$(".rotateDegree" ).html(rotateDegree.value + '˚');
				$(".nextMethod"   ).html(nextMethod.value == 0 ? "Sequencial" : "Random");
				$(".playInterval" ).html(playInterval.value + 's');
				$(".hideMethod"   ).html(hideMethod.value == 0 ? "Effect[" + $("#effectHideTypes option:selected").val() + "]" : "Remove");
				$(".displayMethod").html(displayMethod.value == 0 ? "Tablet" : "Tile");
			},
			save: function() {
				setLocalStorageItem(IMAGE_SOURCE,           imageSource.value);
				setLocalStorageItem(IMAGE_SHOW_METHOD,       showMethod.value);
				setLocalStorageItem(IMAGE_HIDE_METHOD,       hideMethod.value);
				setLocalStorageItem(IMAGE_ROTATE_DEGREE,   rotateDegree.value);
				setLocalStorageItem(IMAGE_NEXT_METHOD,       nextMethod.value);
				setLocalStorageItem(IMAGE_PLAY_INTERVAL,   playInterval.value);
				setLocalStorageItem(IMAGE_TABLET_DISPLAY, displayMethod.value);
				setLocalStorageItem(IMAGE_SHOW_SPECIFIC,  $("#effectShowTypes option:selected").val());
				setLocalStorageItem(IMAGE_HIDE_SPECIFIC,  $("#effectHideTypes option:selected").val());
				
				timerEngine.setTime(playInterval.value);
				fn.display();
			},
			setEffect: function setEffect() {
				if (showMethod.value == 0) {
					effect.name = $("#effectShowTypes option:selected").val();
					effect.duration = 500;
				}
				else {
					effect.name = JQUERY_UI_EFFECTs[getRandomInteger(0, JQUERY_UI_EFFECTs.length-1)];
					effect.duration = getRandomInteger(100, 2000);
				}
				if (effect.name === "scale")
					effect.options = { percent: getRandomInteger(10, 50) };
				else if (effect.name === "size")
					effect.options = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
				else
					effect.options = {};
				fn.display();
			},
			toggleImageSource: function() {
				$("#imageSource").val(imageSource.value == 0 ? 1 : 0).trigger("click");
			},
			toggleShowEffect: function() {
				$("#showMethod").val(showMethod.value == 0 ? 1 : 0).trigger("click");
			},
			setRotateDegree: function(deg) {
				var val;
				if (typeof deg === 'number')
					val = deg;
				else if (deg === '-')
					val = parseInt($("#rotateDegree").val()) - 1;
				else if (deg === '+')
					val = parseInt($("#rotateDegree").val()) + 1;
				else 
					val = 0;
				$("#rotateDegree").val(val).trigger("click");
			},
			toggleNextMethod: function() {
				$("#nextMethod").val(nextMethod.value == 0 ? 1 : 0).trigger("click");
			},
			togglePlayInterval: function(sec) {
				var val;
				if (typeof sec === 'number')
					val = sec;
				else if (sec === '-')
					val = parseInt($("#playInterval").val()) - 1;
				else if (sec === '+')
					val = parseInt($("#playInterval").val()) + 1;
				else 
					val = 0;
				$("#playInterval").val(val).trigger("click");
			},
			toggleHideMethod: function() {
				$("#hideMethod").val(hideMethod.value == 0 ? 1 : 0).trigger("click");
			},
			toggleDisplayMethod: function() {
				$("#displayMethod").val(displayMethod.value == 0 ? 1 : 0).trigger("click");
			},
			eventListener: function() {
				$("#configModal").on({
					"hidden.bs.modal": function() {
						$(".delete-image").toggle(imageSource.value == 0);
					},
					"shown.bs.modal": function() {}
				});
				$(".label-switch").on('click', function() { // switch label
					var target = $(this).attr("data-target");
					var value  = $(this).attr("data-value");
					var text   = $(this).text();
					$("#" + target).val(value);
					$("." + target).html(text);
					$("[data-target='" + target + "']").removeClass("active-switch");
					$(this).addClass("active-switch");
					fn.save();
				});
				$(".config-switch-range").on('click keyup', function(e) { // range for switch 
					var value = $(this).val();
					var target = $(this).attr("id");
					$("[data-target='" + target + "'][data-value='" + value + "']").click();
					stopEvent(e);
				});
				$(".config-range").on('click keyup', function(e) {
					var value = $(this).val();
					var target = $(this).attr("id");
					$("." + target).html(value);
					fn.save();
					stopEvent(e);
				});
				$(".config-select").on("change", function() {
					fn.save();
				});
				$(".btn-shuffle").on("click", function() {
					var shuffleOnce = function shuffleOnce() {
						$("#imageSource"  ).val(getRandomInteger(0, 1)).trigger("click");
						$("#showMethod"   ).val(getRandomInteger(0, 1)).trigger("click");
						$("#hideMethod"   ).val(getRandomInteger(0, 1)).trigger("click");
						$("#nextMethod"   ).val(getRandomInteger(0, 1)).trigger("click");
						$("#displayMethod").val(getRandomInteger(0, 1)).trigger("click");
						$("#rotateDegree" ).val(getRandomInteger(0, 360)).trigger("click");
						$("#playInterval" ).val(getRandomInteger(5, 20)).trigger("click");
					};
					showSnackbar("shuffle start", 1000);
					var count = 0, maxShuffle = getRandomInteger(3, 9);
					var shuffler = setInterval(function() {
						shuffleOnce();
						if (++count > maxShuffle) {
						 	clearInterval(shuffler);
						 	showSnackbar("shuffle completed. try " + maxShuffle, 1000);
						}
					}, 500);
				});
				
				$(app.selector).navEvent(fn.nav);

				app.eventListener();
			},
			initiate: function() {
				var imageSource        = getLocalStorageItem(IMAGE_SOURCE,         getRandomInteger(0, 1));
				var showMethod         = getLocalStorageItem(IMAGE_SHOW_METHOD,    getRandomInteger(0, 1));
				var hideMethod         = getLocalStorageItem(IMAGE_HIDE_METHOD,    getRandomInteger(0, 1));
				var rotateDegree       = getLocalStorageItem(IMAGE_ROTATE_DEGREE,  getRandomInteger(0, 360));
				var nextMethod         = getLocalStorageItem(IMAGE_NEXT_METHOD,    getRandomInteger(0, 1));
				var playInterval       = getLocalStorageItem(IMAGE_PLAY_INTERVAL,  getRandomInteger(5, 20));
				var displayMethod      = getLocalStorageItem(IMAGE_TABLET_DISPLAY, getRandomInteger(0, 1));
				var showSpecificEffect = getLocalStorageItem(IMAGE_SHOW_SPECIFIC,  JQUERY_UI_EFFECTs[getRandomInteger(0, JQUERY_UI_EFFECTs.length-1)]);
				var hideSpecificEffect = getLocalStorageItem(IMAGE_HIDE_SPECIFIC,  JQUERY_UI_EFFECTs[getRandomInteger(0, JQUERY_UI_EFFECTs.length-1)]);

				$("#imageSource"  ).val(imageSource  ).trigger("click");
				$("#showMethod"   ).val(showMethod   ).trigger("click");
				$("#hideMethod"   ).val(hideMethod   ).trigger("click");
				$("#nextMethod"   ).val(nextMethod   ).trigger("click");
				$("#displayMethod").val(displayMethod).trigger("click");
				$("#playInterval" ).val(playInterval ).trigger("click");
				$("#rotateDegree" ).val(rotateDegree ).trigger("click");
				
				for (var i in JQUERY_UI_EFFECTs) {
					$("#effectShowTypes, #effectHideTypes").append(
							$("<option>", {value: JQUERY_UI_EFFECTs[i]}).html(capitalize(JQUERY_UI_EFFECTs[i]))
					);
				}
				$("#effectShowTypes").val(showSpecificEffect).prop("selected", true).trigger("change");
				$("#effectHideTypes").val(hideSpecificEffect).prop("selected", true).trigger("change");
				
				timerEngine.init(fn.next, playInterval, "#progressWrapper", {width: 136, margin: 0}, "Play", app.playCallback);

			},
			prev: function() {
				fn.setEffect();	
				app.prev(effect.name, effect.options, effect.duration);
			},
			next: function() {
				fn.setEffect();	
				app.next(effect.name, effect.options, effect.duration);
			},
			play: function() {
				timerEngine.toggle(app.playCallback);
			},
			nav: function(signal) {
				console.log("config.fn.nav signal", signal);
				switch(signal) {
				case 1 : // mousewheel : up
				case 37: // key : left
				case 38: // key : up
					fn.prev();
					break;
				case -1 : // mousewheel : down
				case 39: // key : right
				case 40: // key : down
					fn.next();
					break;
				case 32: // key : space
					fn.play();
					break;
				case 67 : // key : c
					$("#configModal").modal("toggle");
					break;
				case 70 : // key : f
					$(".btn-shuffle").trigger("click");
					break;
				case 45 : // key : Insert
					fn.toggleImageSource();
					break;
				case 36 : // key : Home
					fn.toggleShowEffect();
					break;
				case 33 : // key : PageUp
					fn.toggleNextMethod();
					break;
				case 35 : // key : End
					fn.toggleHideMethod();
					break;
				case 34 : // key : PageDown
					fn.toggleDisplayMethod();
					break;
				case 48 : // key : 0
					fn.setRotateDegree(0);
					break;
				case 189 : // key : -
					fn.setRotateDegree('-');
					break;
				case 187 : // key : +
					fn.setRotateDegree('+');
					break;
				case 97 : // key : keypad 1
					fn.togglePlayInterval(1);
					break;
				case 98 : // key : keypad 2 
					fn.togglePlayInterval(2);
					break;
				case 99 : // key : keypad 3
					fn.togglePlayInterval(3);
					break;
				case 100 : // key : keypad 4 
					fn.togglePlayInterval(4);
					break;
				case 101 : // key : keypad 5 
					fn.togglePlayInterval(5);
					break;
				case 102 : // key : keypad 6 
					fn.togglePlayInterval(6);
					break;
				case 103 : // key : keypad 7 
					fn.togglePlayInterval(7);
					break;
				case 104 : // key : keypad 8 
					fn.togglePlayInterval(8);
					break;
				case 105 : // key : keypad 9 
					fn.togglePlayInterval(9);
					break;
				case 109 : // key : keypad - 
					fn.togglePlayInterval('-');
					break;
				case 107 : // key : keypad + 
					fn.togglePlayInterval('+');
					break;
				default:
					app.nav(signal);
				}
			},
			start: function() {
				restCall(PATH + '/rest/image/data', {}, function(data) {
					app.init(data);
					fn.next();
				});
			}
	};
	
	return {
		/* sample
		  	var fn = {
				prev: function(showEffect, showOptions, showDuration) {
				},
				next: function(showEffect, showOptions, showDuration) {
				},
				playCallback: function(status) {
				},
				nav: function(signal) {
				},
				eventListener: function() {
				},
				init: function(data) {
				}
			};
			config.init("#imageDiv", fn.prev, fn.next, fn.playCallback, fn.nav, fn.eventListener, fn.init);
		 */
		init : function(selector, prev, next, playCallback, nav, eventListener, init) {
			$("#configModal").appendTo($("body"));
			
			app.selector = selector;
			app.prev = prev;
			app.next = next;
			app.playCallback = playCallback;
			app.nav = nav;
			app.eventListener = eventListener;
			app.init = init;
			
			fn.eventListener();
			fn.initiate();
			fn.start();
		}
	};
	
}());


