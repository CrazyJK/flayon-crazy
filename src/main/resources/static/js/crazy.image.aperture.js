bgContinue = false;

/**
 * aperture module
 */
var apertureApp = (function() {

	var currentIndex      = -1,
		selectedItemUrl   = "",
		selectedItemTitle = "",
		imageCount = 0,
		imageMap   = [],
		coverCount = 0,
		coverMap   = [];
		
	var	image = {
				prevNumber: function getPrevNumber() {
					return currentIndex == 0 ? image.maxCount(-1) : currentIndex - 1;
				},
				nextNumber: function getNextNumber() {
					if (nextMethod.value == 0) {
						return currentIndex == image.maxCount(-1) ? 0 : currentIndex + 1;
					}
					else {
						return getRandomInteger(0, image.maxCount(-1));
					}
				},
				maxCount: function(i) {
					i = i || 0;
					return imageSource.value == 0 ? imageCount + i : coverCount + i;
				},
				first: function fnFirstImageView() {
					image.view(0);
				},
				end: function fnEndImageView() {
					image.view(image.maxCount(-1));
				},
				view: function fnViewImage(current) {
					currentIndex = parseInt(current);

					if (imageSource.value == 0) { // image
						selectedItemUrl = PATH + "/image/" + currentIndex;
						selectedItemTitle = imageMap[currentIndex];
						setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, currentIndex);
					}
					else {
						selectedItemUrl = PATH + "/video/" + coverMap[currentIndex] + "/cover";
						selectedItemTitle = coverMap[currentIndex];
						setLocalStorageItem(THUMBNAMILS_COVER_INDEX, currentIndex);
					}
	
					$("#aperture .circle-img").css({
						backgroundImage: "url('" + selectedItemUrl + "')"
					});
					
					$("#currNo").html(currentIndex);
					$("#endNo").html(image.maxCount(-1));
					
					$("#imageTitle").html(selectedItemTitle);
				},
				resize: function resizeImage(playStatus) {
					if (typeof playStatus != 'boolean')
						playStatus = timerEngine.isOn();

					var windowHeight = $(window).height();
					var windowWidth  = $(window).width();
					var navHeight = $('div#navDiv').height();
					var progressMarginBottom = 5;
					var imageDivPadding = 15;
					var imageDivHeight = windowHeight - navHeight - imageDivPadding * 2 - progressMarginBottom;
					$("#imageDiv").height(imageDivHeight).css({padding: imageDivPadding});
					$("#aperture").aperture({
						src: selectedItemUrl,
						outerMargin: "auto",
						width: (windowWidth - imageDivPadding * 2) + "px",
						height: (imageDivHeight) + "px",
						outerRadius: "0",
						baseColor: (playStatus ? "#000" : "#fff"),
						color1: getRandomColor(0.5),
						color2: getRandomColor(0.5),
						color3: getRandomColor(0.5),
						color4: getRandomColor(0.5),
						innerCirclePadding: "0px",
						borderRadius: "50%"
					});
				},
				popup: function fnFullyImageView() {
					if (imageSource.value == 0) { // image
						popupImage(selectedItemUrl);
					}
					else {
						fnVideoDetail(coverMap[currentIndex]);
					}
				}
		};

  	var fn = {
			prev: function(showEffect, showOptions, showDuration) {
				image.view(image.prevNumber());
			},
			next: function(showEffect, showOptions, showDuration) {
				image.view(image.nextNumber());
			},
			playCallback: function(status) {
				if (status) {
					$("body, .progress-bar, .label").addClass("bg-black");
					$("#pagingArea, #effectInfoBox").hide();
					$(".circle").css({'background-color': '#000'});
				}
				else {
					$("body, .progress-bar, .label").removeClass("bg-black");
					$("#pagingArea, #effectInfoBox").show();
					$(".circle").css({'background-color': '#fff'});
				}
				image.resize(status);
			},
			nav: function(signal) {
			},
			eventListener: function() {
				$(window).on("resize", image.resize);

				$(".paging-first").on("click", image.first);
				$(".paging-end"  ).on("click", image.end);
				$("#imageTitle"  ).on("click", image.popup);
			},
			init: function(data) {
				imageCount = data['imageCount'];
				imageMap   = data['imageNameMap'];
				coverCount = data['coverCount'];
				coverMap   = data['coverNameMap'];

				if (imageSource.value == 0) { // image
					currentIndex = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, 0)) - 1;
					if (currentIndex >= imageCount)
						currentIndex = getRandomInteger(0, imageCount-1);
				}
				else { // cover
					currentIndex = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, 0)) - 1;
					if (currentIndex >= coverCount)
						currentIndex = getRandomInteger(0, coverCount-1);
				}

				image.resize();
			}
	};
		
	return {
		init: function() {
			config.init("#imageDiv", fn.prev, fn.next, fn.playCallback, fn.nav, fn.eventListener, fn.init);
		}
	};
	
}());

$(document).ready(apertureApp.init);
