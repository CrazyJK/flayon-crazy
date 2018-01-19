/**
 *image/thumbnails module
 */

var thumbnails = (function() {

	var currentIndex = 0;
	var coverCount = 0, coverMap;
	var lastPage = false;
	var imageSizePerPage = 30;
	var displayCount = 0;
	var mode;
	var scrollBottomChecker;
	var pathInfos, pathInfo, pathIndex;
	var onMagnify = false;
	var imgWidth, imgHeight;

	var fn = {
			event: function() {
				$("input:radio[name='mode']").on('change', fn.toggleMode);
				$("#paths").on("change", fn.toggleMode);
				$("#img-width, #img-height").on("change", fn.resizeImage);
				$("#magnify").on("click", function() {
					onMagnify = $(this).data("checked");
					setLocalStorageItem(THUMBNAMILS_BTN_MAGNIFY, onMagnify);
				});
				$("#content_div").scroll(function() {
					if (fn.isScrollBottom())
						fn.render();
				});
			},
			initiate: function() {
				mode      = getLocalStorageItem(THUMBNAMILS_MODE, "image");
				onMagnify = getLocalStorageItemBoolean(THUMBNAMILS_BTN_MAGNIFY, false);
				
				$("input:radio[name='mode'][value='" + mode + "']").attr("checked", true).parent().addClass("active");
				onMagnify && $("#magnify").click();
				fn.setLightBoxOption();
			},
			start: function() {
				restCall(PATH + '/rest/image/data', {}, function(data) {
					coverCount = data['coverCount'];
					coverMap   = data['coverNameMap'];

					restCall(PATH + '/rest/image/pathInfo', {}, function(infos) {
						pathInfos = infos;
						$.each(pathInfos, function(idx, info) {
							$("#paths").append(
									$("<option>").attr("value", info.index).html(info.path + " [" + info.size + "]")
							);
							info.current = 0;
						});
						//console.log("pathInfos", pathInfos);
						var pathIndex = getLocalStorageItem(IMAGE_PATH_INDEX, '-1');
						$("#paths").val(pathIndex).prop("selected", true);
						
						fn.toggleMode();
					});
				});
			},
			toggleMode: function() {
				mode = $("input:radio[name='mode']:checked").val();
				setLocalStorageItem(THUMBNAMILS_MODE, mode);

				if (mode === 'cover') {
					$("#paths").hide();
					currentIndex  = getLocalStorageItemInteger(THUMBNAMILS_COVER_INDEX, getRandomInteger(0, coverCount-1));
					imgWidth      = getLocalStorageItemInteger(THUMBNAMILS_COVER_WIDTH, 100);
					imgHeight     = getLocalStorageItemInteger(THUMBNAMILS_COVER_HEIGHT, 100);
				}
				else { // image
					$("#paths").show();
					currentIndex = 0;
					imgWidth  = getLocalStorageItemInteger(THUMBNAMILS_IMAGE_WIDTH, 100);
					imgHeight = getLocalStorageItemInteger(THUMBNAMILS_IMAGE_HEIGHT, 100);
					pathIndex = parseInt($("#paths option:selected").val());
					pathInfo  = pathInfos[pathIndex + 1];
					setLocalStorageItem(IMAGE_PATH_INDEX, pathIndex);
				}
				
				$("#img-width").val(imgWidth);
				$("#img-height").val(imgHeight);
				$(".addon-width" ).html("W " + imgWidth);
				$(".addon-height").html("H " + imgHeight);

				$("ul#thumbnailUL").empty();
				displayCount = 0;
				lastPage = false;
				fn.render();

				clearInterval(scrollBottomChecker);
				scrollBottomChecker = setInterval(function() {
					if (fn.isScrollBottom())
						fn.render();
				}, 3000);
			},
			render: function() {
				$(".current-index").html("I " + currentIndex);
				$(".debug").html("render..." + currentIndex).show().hide("fade", {}, 2000);

				var $thumbnailUL = $("ul#thumbnailUL");
				var bgColor = getRandomColor(.1);
				var start = currentIndex;
				var end   = start + imageSizePerPage;
				for (var i = start; i < end; i++) {

					var imgSrc = "";
					var imgTitle = "";
					var imgName = "";
					if (mode === 'cover') {
						imgName = coverMap[i];
						imgSrc = PATH + "/video/" + imgName + "/cover";
						imgTitle = '<a onclick="fnVideoDetail(\'' + imgName + '\')" href="#">' + imgName + '</a>';
					}
					else {
						if (pathInfo.current == pathInfo.size) {
							pathInfo.current = 0;
							lastPage = true;
							console.log("image all shown", pathInfo);
							break;
						}
						else {
							imgSrc = PATH + "/image/byPath/" + pathIndex + "/" + pathInfo.current;
							currentIndex = pathInfo.current;
							pathInfo.current++;
							imgTitle = '<a href="' + imgSrc + '" target="image-' + imgSrc + '">Popup</a>' + "&nbsp;&nbsp;&nbsp;" +
									   '<a onclick="fnDeleteImage(\'' + imgSrc + '\', ' + i + ')" href="#" style="color:#a94442;">Delete</a>';
						}
					}
						
					$("<li>").append(
							$("<a>", {
								'href': imgSrc,
								'rel': 'lightboxSet',
								'data-index': i,
								'class': 'img-thumbnail'
							}).data("title", imgTitle).css({
								backgroundColor: bgColor
							}).hover(
								function(event) {
									if (onMagnify) $(this).addClass("box-hover");
								}, function() {
									if (onMagnify) $(this).removeClass("box-hover");
								}
							).append(
									$("<div>").css({
										backgroundImage: "url('" + imgSrc + "')",
										width: imgWidth, 
										height: imgHeight
									})
							)
					).appendTo($thumbnailUL);
					
					displayCount++;
					currentIndex = i;
					if (mode === 'cover') {
						if ((currentIndex + 1) >= coverCount) {
							console.log("approached last page", i);
							currentIndex = -1;
							break;
						}
					}
				}
				
				currentIndex++;
				if (mode === 'cover') {
					setLocalStorageItem(THUMBNAMILS_COVER_INDEX, currentIndex);
					$(".total-count").html(displayCount + " / " + coverCount);
				}
				else {
					$(".total-count").html(displayCount + " / " + pathInfo.size);
				}
			},
			isScrollBottom: function() {
				var containerHeight    = $("#content_div").height();
				var containerScrollTop = $("#content_div").scrollTop();
				var documentHeight     = $("#thumbnailUL").height();
				var scrollMargin       = $("#thumbnailUL > li").height();
				//console.log("fnIsScrollBottom", containerHeight + ' + ' + containerScrollTop + ' = ' + (containerHeight + containerScrollTop), ' > ', documentHeight + ' - ' + scrollMargin + ' = ' + (documentHeight - scrollMargin), "lastPage=", lastPage);
				return (containerHeight + containerScrollTop > documentHeight - scrollMargin) && !lastPage;
			},
			resizeImage: function() {
				imgWidth  = $("#img-width").val();
				imgHeight = $("#img-height").val();
				$(".img-thumbnail > div").css({
					width: imgWidth,
					height: imgHeight
				});
				$(".debug").html("Size : " + imgWidth + " x " + imgHeight).show().hide("fade", {}, 3000);
				$(".addon-width" ).html("W " + imgWidth);
				$(".addon-height").html("H " + imgHeight);

				if (mode === 'cover') {
					setLocalStorageItem(THUMBNAMILS_COVER_WIDTH,  imgWidth);
					setLocalStorageItem(THUMBNAMILS_COVER_HEIGHT, imgHeight);
				}
				else { // image
					setLocalStorageItem(THUMBNAMILS_IMAGE_WIDTH,  imgWidth);
					setLocalStorageItem(THUMBNAMILS_IMAGE_HEIGHT, imgHeight);
				}
			},
			setLightBoxOption: function() {
				lightbox.option({
					showImageNumberLabel: true,
					resizeDuration: 300,
			      	fadeDuration: 300,
			      	imageFadeDuration: 300,
			      	randomImageEffect: false,
			      	disableScrolling: true
			    });
			}
	};
	
	return {
		init: function() {
			fn.event();
			fn.initiate();
			fn.start();
		}
	};
	
}());

var fnDeleteImage = function(imgSrc, imgIdx) {
	if (confirm('Delete this image\n' + imgSrc)) {
		restCall(imgSrc, {method: "DELETE", title: "this image delete"}, function() {
			$("[data-index=" + imgIdx + "]").parent().remove(); //hide("fade", {}, 500);
			lightbox.nextImage();
		});
	}
}
