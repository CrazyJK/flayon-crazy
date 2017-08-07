/**
 * 
 */

var slide = (function() {
	var SLIDE_SOURCE_MODE   = "slide.source.mode";
	var SLIDE_EFFECT_MODE   = "slide.effect.mode";
	var SLIDE_PLAY_MODE     = "slide.play.mode";
	var SLIDE_PLAY_INTERVAL = "slide.play.interval";

	var selectedNumber;
	var selectedItemUrl;
	var selectedItemTitle;
	var imageCount;
	var imageMap;
	var coverCount;
	var coverMap;
	var windowWidth  = $(window).width();
	var windowHeight = $(window).height();
	var playSlide = false;
	var playInterval = 10;
	var playSec = playInterval;
	var effects = ["blind", "bounce", "clip", "drop", "explode", "fade", "fold", "highlight", "puff", "pulsate", "scale", "shake", "size", "slide"];
	var hideEffect, hideDuration, hideOptions;
	var showEffect, showDuration, showOptions;

	var image = {
			setConfig: function() {
				setLocalStorageItem(SLIDE_SOURCE_MODE,   sourceMode.value);
				setLocalStorageItem(SLIDE_EFFECT_MODE,   effectMethod.value);
				setLocalStorageItem(SLIDE_PLAY_MODE,     playMode.value);
				setLocalStorageItem(SLIDE_PLAY_INTERVAL, interval.value);
			},
			nextEffect: function setNextEffect() {
				if (effectMethod.value == 1) {
					hideEffect   = effects[getRandomInteger(0, effects.length-1)];
					hideDuration = getRandomInteger(100, 1000);
					if (hideEffect === "scale")
						hideOptions = { percent: getRandomInteger(10, 50) };
					else if (hideEffect === "size")
						hideOptions = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
					else
						hideOptions = {};
					showEffect   = effects[getRandomInteger(0, effects.length-1)];
					showDuration = getRandomInteger(100, 2000);
					if (showEffect === "scale")
						showOptions = { percent: getRandomInteger(10, 50) };
					else if (showEffect === "size")
						showOptions = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
					else
						showOptions = {};

					$(".effectInfo").show().html(hideEffect + "(" + hideDuration + ") ▷ " + showEffect + "(" + showDuration + ")");
				}
				else {
					hideEffect = "fade";
					hideDuration = 500;
					hideOptions = {};
					showEffect = "fade";
					showDuration = 500;
					showOptions = {};
					$(".effectInfo").hide();
				}
			},
			prevNumber: function getPrevNumber() {
				return selectedNumber === 0 ? imageCount - 1 : selectedNumber - 1;
			},
			nextNumber: function getNextNumber() {
				return selectedNumber === imageCount -1 ? 0 : selectedNumber + 1;
			},
			view: function(current) {
				selectedNumber = parseInt(current);
				if (sourceMode.value == 0) { // image
					selectedItemUrl = "${PATH}/image/" + selectedNumber;
					selectedItemTitle = imageMap[selectedNumber];
					setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, selectedNumber);
				}
				else {
					selectedItemUrl = "${PATH}/video/" + coverMap[selectedNumber] + "/cover";
					selectedItemTitle = coverMap[selectedNumber];
					setLocalStorageItem(THUMBNAMILS_COVER_INDEX, selectedNumber);
				}

				$("#imageDiv").hide(hideEffect, hideOptions, hideDuration, function() {
					$("#leftNo").html(prevNumber());
					$("#currNo").val(selectedNumber);
					$("#rightNo").html(nextNumber());
					$(".title").html(selectedItemTitle);
					$(this).css({
						backgroundImage: "url('" + selectedItemUrl + "')"
					}).show(showEffect, showOptions, showDuration, nextEffect);

					if (!playSlide) {
						showThumbnail();
					}	
				});
			},
			first: function() {
				view(0);
			},
			prev: function() {
				view(prevNumber());
			},
			next: function() {
				view(nextNumber());
			},
			end: function() {
				view(imageCount-1);
			},
			random: function (no) {
				if (!no)
					no = Math.floor(Math.random() * imageCount);
				view(no);
			},
			resize: function() {
				windowHeight = $(window).height();
				if (!playSlide) {
					showThumbnail();
				}
				$("#imageDiv").height(windowHeight - $("#thumbnailDiv").outerHeight() - 35);
			},
			delete: function() {
				if (sourceMode.value == 0) { // image
					var imgSrc = selectedItemUrl;
					if (confirm('Delete this image\n' + imgSrc)) {
						actionFrame(imgSrc, {}, "DELETE", "this image delete");
						next();
					}
				}
			},
			popup: function() {
				if (sourceMode.value == 0) { // image
					popupImage(selectedItemUrl);
				}
				else {
					fnVideoDetail(coverMap[selectedNumber]);
				}
			},
			play: function() {
				playSlide = !playSlide;
				if (playSlide) { // start
					playSec = playInterval;
				}
				else { // stop
					showTimer(playInterval, "Play");
					showThumbnail();
				}
				if (playSlide) {
					$("body").css("background", "#000");
					$("#thumbnailDiv").css('height', '5px').hide();
					$(".progress").css("background", "linear-gradient(to bottom,#403a3a 0,#2f2626 100%)");
					$(".progress-bar").css("background", "#000");
					$(".label-info").css("background", "#000");
					$(".paging").hide();
					$("#navDiv").css("opacity", ".5");
					$("#title-area").addClass("left-bottom");
				}
				else {
					$("body").css("background", "#fff");
					$("#thumbnailDiv").css('height', '105px').show('fade', {}, 1000);
					$(".progress").css("background", "linear-gradient(to bottom,#ebebeb 0,#f5f5f5 100%)");
					$(".progress-bar").css("background", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
					$(".label-info").css("background", "linear-gradient(rgb(91, 192, 222) 0px, rgb(49, 176, 213) 100%)");
					$(".paging").show();
					$("#navDiv").css("opacity", "1");
					$("#title-area").removeClass("left-bottom");
				}
				$("#imageDiv").height(windowHeight - $("#thumbnailDiv").outerHeight() - 35);
			},
			showThumbnail: function fnDisplayThumbnail() {
				var itemCount = 0;
				if (sourceMode.value == 0) { // image
					itemCount = imageCount;
				}
				else {
					itemCount = coverCount;
				}
				windowWidth = $(window).width();
				var thumbnailRange = parseInt(windowWidth / (150 * 2));
				$("#thumbnailUL").empty();
				for (var current = selectedNumber - thumbnailRange; current <= selectedNumber + thumbnailRange; current++) {
					var thumbNo = current;
					if (thumbNo < 0 )
						thumbNo = itemCount + thumbNo;
					if (thumbNo >= itemCount)
						thumbNo = thumbNo - itemCount;
					var itemUrl = sourceMode.value == 0 ? "${PATH}/image/" + thumbNo : "${PATH}/video/" + coverMap[thumbNo] + "/cover";
					console.log("fnDisplayThumbnail", itemUrl);
					$("<li>").append(
							$("<div>")
								.addClass("img-thumbnail " + (thumbNo == selectedNumber ? "active" : ""))
								.css({backgroundImage: "url('" + itemUrl + "')"})
								.data("imgNo", thumbNo)
								.on("click", function() {
									fnViewImage($(this).data("imgNo"));
								})
					).appendTo($("ul#thumbnailUL"));
				}
			},
			showTimer: function showTimer(sec, text) {
				if (text)
					$("#timer").html(text);
				else
					$("#timer").html(sec + "s");
				$("#timerBar").attr("aria-valuenow", sec).css("width", sec/playInterval*100 + "%");
			}

	};
	
	var manipulateDom = function() {
		//function getConfig() {
		var slideSourceMode   = getLocalStorageItem(SLIDE_SOURCE_MODE,   getRandomInteger(0, 1));
		var slideEffectMode   = getLocalStorageItem(SLIDE_EFFECT_MODE,   getRandomInteger(0, 1));
		var slidePlayMode     = getLocalStorageItem(SLIDE_PLAY_MODE,     getRandomInteger(0, 1));
		var slidePlayInterval = getLocalStorageItem(SLIDE_PLAY_INTERVAL, getRandomInteger(5, 20));

		$("[data-target='sourceMode'][data-value='" + slideSourceMode + "']").click();
		$("[data-target='effectMethod'][data-value='" + slideEffectMode + "']").click();
		$("[data-target='playMode'][data-value='" + slidePlayMode + "']").click();
		$("#interval").val(slidePlayInterval).click();

	};
	
	var addEventListener = function() {

		$(window).on("mousewheel DOMMouseScroll", function(e) {
			var delta = mousewheel(e);
			if (delta > 0) 
				this.image.prev(); //alert("마우스 휠 위로~");
		    else 	
		    	this.image.next(); //alert("마우스 휠 아래로~");
		}).on("keyup", function(e) {
			var event = window.event || e;
			console.log("window keyup event", event.keyCode);
			switch(event.keyCode) {
			case 37: // left
			case 40: // down
				this.image.prev(); break;
			case 39: // right
			case 38: // up
				this.image.next(); break;
			case 32: // space
				this.image.random();
			case 13: // enter
				break;
			}
		}).on("resize", this.image.resize);

		$("[data-role='switch']").on('click', function() {
			var target = $(this).attr("data-target");
			var value  = $(this).attr("data-value");
			var text   = $(this).text();
			$("#" + target).val(value);
			$("." + target).html(text);
			$("[data-target='" + target + "']").removeClass("active-switch");
			$(this).addClass("active-switch");
			this.setConfig();
		});
		$("input[type='range'][role='switch']").on('click', function() {
			var value = $(this).val();
			var target = $(this).attr("id");
			$("[data-target='" + target + "'][data-value='" + value + "']").click();
		});
		$("#interval").on('click', function() {
			$(".interval").html($(this).val());
			playInterval = $(this).val();
			$("#timerBar").attr({
				"aria-valuemax": playInterval 
			});
			this.setConfig();
		});
		
		$("#currNo").on("keyup", function(e) {
			var event = window.event || e;
			event.stopPropagation();
			console.log("#currNo keyup event", event.keyCode);
			if (event.keyCode === 13) {
				fnRandomImageView($(this).val());
			}
		});
		$("#imageDiv").on("click", function(event){
			switch (event.which) {
			case 1: // left click
				fnNextImageView();
				break;
			case 2: // middle click
				fnRandomImageView();
				break;
			case 3: // right click
				break;
			}
			event.stopImmediatePropagation();
			event.preventDefault();
			event.stopPropagation();
		});

		$("#configModal").on("hidden.bs.modal", function() {
			//console.log("hidden.bs.modal", sourceMode.value);
			if (sourceMode.value == 0) {
				selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(0, imageCount)));
			}
			else { // cover
				selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, getRandomInteger(0, coverCount)));
			}
			fnViewImage(selectedNumber);
		});
		$(".btn-shuffle").on("click", function() {
			var shuffleOnce = function shuffleOnce() {
				$("[data-target='sourceMode'][data-value='" + getRandomInteger(0, 1) + "']").click();
				$("[data-target='effectMethod'][data-value='" + getRandomInteger(0, 1) + "']").click();
				$("[data-target='playMode'][data-value='" + getRandomInteger(0, 1) + "']").click();
				$("#interval").val(getRandomInteger(5, 20)).click();
			};
			var count = 0;
			var maxShuffle = getRandomInteger(3, 9);
		 	showSnackbar("shuffle start", 1000);
			var shuffler = setInterval(function() {
				shuffleOnce();
				if (++count > maxShuffle) {
				 	clearInterval(shuffler);
				 	showSnackbar("shuffle completed. try " + maxShuffle, 1000);
				 	setConfig();
				}
			}, 500);
		});
	};
	
	var initModule = function() {
		$.getJSON("${PATH}/image/" + "data.json" ,function(data) {
			imageCount = data['imageCount'];
			imageMap   = data['imageNameMap'];
			coverCount = data['coverCount'];
			coverMap   = data['coverNameMap'];

			$("#firstNo").html(0);
			if (sourceMode.value === 0) { // image
				$("#endNo").html(imageCount-1);
				selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(0, imageCount)));
			}
			else { // cover
				$("#endNo").html(coverCount-1);
				selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, getRandomInteger(0, coverCount)));
			}

			this.image.resize();
			this.image.nextEffect();
			if (selectedNumber > -1)
				this.image.view(selectedNumber);
			else
				this.image.random();

			setInterval(function() {
				if (playSlide) {
					if (--playSec % playInterval == 0) {
						if (playMode.value == 1) {
							this.image.random();
						}
						else { 
							this.image.next();
						}
						playSec = playInterval;
					}
					this.image.showTimer(playSec);
				}
			},	1000);
		});
		
	};
	
	var init = function() {
		this.manipulateDom();
		this.addEventListener();
		this.initModule();
	};
	
	return {
		init: init
	};
}());

