/**
 *image/thumbnails module
 */

var thumbnails = (function() {

	var IMAGE_PATH_INDEX = "image.path.index";
	var storageItemIndexName;
	var storageItemWidthName;
	var storageItemHeightName;
	var currentIndex = 0;
	var coverCount = 0;
	var coverMap;
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
				
				$("#content_div").scroll(function() {
					if (fn.isScrollBottom())
						fn.render();
				});

				$("#magnify").on("click", function() {
					onMagnify = $(this).data("checked");
					setLocalStorageItem(THUMBNAMILS_BTN_MAGNIFY, onMagnify);
				});
				
			},
			initiate: function() {
				mode      = getLocalStorageItem(THUMBNAMILS_MODE, "image");
				onMagnify = getLocalStorageItem(THUMBNAMILS_BTN_MAGNIFY, false) === 'true';
				
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
					storageItemIndexName  = THUMBNAMILS_COVER_INDEX;
					storageItemWidthName  = THUMBNAMILS_COVER_WIDTH;
					storageItemHeightName = THUMBNAMILS_COVER_HEIGHT;
					$("#paths").hide();
					currentIndex  = parseInt(getLocalStorageItem(storageItemIndexName, getRandomInteger(0, coverCount-1)));
				}
				else { // image
					storageItemIndexName  = THUMBNAMILS_IMAGE_INDEX;
					storageItemWidthName  = THUMBNAMILS_IMAGE_WIDTH;
					storageItemHeightName = THUMBNAMILS_IMAGE_HEIGHT;
					$("#paths").show();
					currentIndex = 0;
					pathIndex = parseInt($("#paths option:selected").val());
					pathInfo = pathInfos[pathIndex + 1];
					setLocalStorageItem(IMAGE_PATH_INDEX, pathIndex);
				}
				
				imgWidth  = getLocalStorageItem(storageItemWidthName, 100);
				imgHeight = getLocalStorageItem(storageItemHeightName, 100);
				
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

				imgWidth  = $("#img-width").val(); 
				imgHeight = $("#img-height").val();
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
						
					$("ul#thumbnailUL").append(
							$("<li>", {
								dataIndex: i,
								"class": "img-thumbnail"
							}).css({
								width: imgWidth, height: imgHeight
							}).hover(
								function(event) {
									if (onMagnify)
										$(this).addClass("box-hover");
								}, function() {
									if (onMagnify)
										$(this).removeClass("box-hover");
								}
							).append(
									$("<a>" ,{
										'href': imgSrc,
										'data-lightbox': 'lightbox-set',
										'data-title': imgTitle,
										'data-index': i,
									}).append(
										$("<div>").addClass("nowrap").css({
											backgroundImage: "url('" + imgSrc + "')"
										})
									)
							)
					);
					
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
					setLocalStorageItem(storageItemIndexName, currentIndex);
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
				$("#thumbnailUL > li").css({
					width: imgWidth,
					height: imgHeight
				});
				$(".debug").html("Size : " + imgWidth + " x " + imgHeight).show().hide("fade", {}, 3000);
				$(".addon-width" ).html("W " + imgWidth);
				$(".addon-height").html("H " + imgHeight);
				
				setLocalStorageItem(storageItemWidthName,  imgWidth);
				setLocalStorageItem(storageItemHeightName, imgHeight);
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
			$("[dataindex=" + imgIdx + "]").hide("fade", {}, 500);
			lightbox.nextImage();
		});
	}
}
