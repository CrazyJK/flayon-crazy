bgContinue = false;
/**
 * image canvas
 */
var canvasApp = (function() {

	var canvas, context, pencil;
	var imageIndex = 0, imageCount, imageNameMap;
	var coverIndex = 0, coverCount, coverNameMap;

	var xPositionOffset = 0, yPositionOffset = 0;
	var imagePercent = 100, loadedImage;
	
	var image = {
			canvas: {
				pencil: {
					type: {
						circle: function() {
							$(":radio[name=pencil][value=circle]").click();
						},
						rubber: function() {
							$(":radio[name=pencil][value=rubber]").click();
						}
					},
					init: function() {
						var pencilType = null, diameter = null, color = null;
					    this.started = false;
					    // 마우스를 누르는 순간 그리기 작업을 시작 한다. 
					    this.mousedown = function(ev) {
					    	pencilType = $('input[name="pencil"]:checked').val();
					    	color      = $("#color").val();
					    	diameter   = $("#diameter").val();
					    	//console.log("color", color, "diameter", diameter);
					    	context.strokeStyle = color;
					    	context.fillStyle = color;
					        context.beginPath();
				        	pencil.started = true;
					    };
					    // 마우스가 이동하는 동안 계속 호출하여 Canvas에 Line을 그려 나간다
					    this.mousemove = function(ev) {
					        if (pencil.started) {
					            if (pencilType == 'circle')
						            context.arc(ev._x, ev._y, diameter/2, 0, 2*Math.PI, true);
					            else if (pencilType == 'rubber')
					            	context.clearRect(ev._x - diameter/2, ev._y - diameter/2, diameter, diameter);

					            context.closePath();
					            //context.lineWidth = 5;
					            context.fill();
					        }
					    };
					    // 마우스 떼면 그리기 작업을 중단한다
					    this.mouseup = function(ev) {
					    	if (pencil.started) {
					    		pencil.mousemove(ev);
					    		pencil.started = false;
					    	}
					    };
					}
				},
				resize: function() {
					image.canvas.info();
					var margin = 4;
					$("#cv").attr("width",  $(window).width() - margin * 2);
					$("#cv").attr("height", $(window).height() - $("#img-nav").outerHeight() - margin * 3);
				},
				popup: function() {
					if (imageSource.value == 0)
						popupImage(image.canvas.url());
					else
						fnVideoDetail(coverNameMap[coverIndex]);
				},
				url: function() {
					return imageSource.value == 0 ? PATH + "/image/" + imageIndex : PATH + "/video/" + coverNameMap[coverIndex] + "/cover";
				},
				event: function(e) {
					if (e.which == 1) {
					    if (e.layerX || e.layerX == 0) {   	// Firefox 브라우저
					      	e._x = e.layerX;
					      	e._y = e.layerY;
					    } 
					    else if (e.offsetX || e.offsetX == 0) { // Opera 브라우저
					      	e._x = e.offsetX;
					      	e._y = e.offsetY;
					    }
					    // tool의 이벤트 핸들러를 호출한다.
					    var func = pencil[e.type];        
					    if (func) {
					        func(e);
					    }
					}
					else if (e.which == 2) {
						image.move.center();
					}
					else if (e.which == 3) {
						// nothing
					}
				},
				load: function() {
					xPositionOffset = 0;
					yPositionOffset = 0;
					imagePercent = 100;
					
					loadedImage = new Image();
					loadedImage.onload = function(){
						var canW = canvas.width;
						var canH = canvas.height;
						var imgW = parseInt(loadedImage.width);
						var imgH = parseInt(loadedImage.height);
						var xRatio = 100;
						var yRatio = 100;
						if (canW < imgW) {
							xRatio = parseInt(canW / imgW * 100);
						}
						if (canH < imgH) {
							yRatio = parseInt(canH / imgH * 100);
						}
						//console.log("image.load xRatio", xRatio, "yRatio", yRatio);
						imagePercent = Math.min(xRatio, yRatio);

						image.canvas.draw();
					};
					loadedImage.src = image.canvas.url();
				},
				draw: function() {
					var imgW = parseInt(loadedImage.width * imagePercent / 100);
					var imgH = parseInt(loadedImage.height * imagePercent / 100);

					var xPos = parseInt((canvas.width  - imgW) / 2 + xPositionOffset);
					var yPos = parseInt((canvas.height - imgH) / 2 + yPositionOffset);

					canvas.width = canvas.width; // canvas clear
					context.drawImage(loadedImage, xPos, yPos, imgW, imgH);

					/*
					var debug = "x:" + xPos + " y:" + yPos + " w:" + imgW + " h:" + imgH + " P:" + imagePercent + " xOff:" + xPositionOffset + " yOff:" + yPositionOffset;
					context.font = "20px D2Coding";
					context.fillText(debug, 10 , 50);
					*/
					if (imageSource.value == 0)
						setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, imageIndex);
					else
						setLocalStorageItem(THUMBNAMILS_COVER_INDEX, coverIndex);
					
					image.canvas.info();
				},
				info: function() {
					var currentIndex = imageSource.value == 0 ? imageIndex : coverIndex;
					var currentCount = imageSource.value == 0 ? imageCount : coverCount;
					
					$("#imageName").html(imageSource.value == 0 ? imageNameMap[imageIndex] : coverNameMap[coverIndex]);
					$("#imagePercent").html(imagePercent + "%");
					$("#goto").val(currentIndex + 1);

					var ul = $("#navUL");
					ul.empty();

					var range = parseInt($(window).width() / 70 / 2);
					var startIdx = currentIndex - range;
					var   endIdx = currentIndex + range + 1;
					if (startIdx < 0) 
						startIdx = 1;
					if (endIdx > currentCount)
						endIdx = currentCount - 1;

					var pagingNo = [1];
					for (var i = startIdx; i < endIdx; i++)
						pagingNo.push(i + 1);
					pagingNo.push(currentCount);
					
					for (var k in pagingNo) {
						ul.append(
								$("<li>", {"class": pagingNo[k] == currentIndex+1 ? "selected" : ""}).append(
										$("<a>").html(pagingNo[k])
								).on("click", function() {
									image.go.to(null, $(this).children().html());
								})
						);
					}
				},
				nav: function(signal) {
					//console.log("canvas.image.nav", signal);
					switch (signal) {
					case 97: // numpad 1
						image.move.leftDown(); 
						return true;
					case 98: // numpad 2
						image.move.down(); 
						return true;
					case 99: // numpad 3
						image.move.rightDown();
						return true;
					case 100: // numpad 4
						image.move.left(); 
						return true;
					case 101: // numpad 5
						image.move.center();
						return true;
					case 102: // numpad 6
						image.move.right(); 
						return true;
					case 103: // numpad 7
						image.move.leftUp();
						return true;
					case 104: // numpad 8
						image.move.up(); 
						return true;
					case 105: // numpad 9
						image.move.rightUp();
						return true;
					case 107: // numpad +
						image.zoom.in(); 
						return true;
					case 109: // numpad -
						image.zoom.out();
						return true;
					case 46: // Delete
						image.canvas.pencil.type.circle();
						return true;
					case 35: // End
						image.canvas.pencil.type.rubber();
						return true;
					case 34: // PageDown
						return true;
					default:
						return false;
					}
				},
				init: function() {
					image.canvas.resize();
					
					canvas  = document.getElementById("cv");
					context = canvas.getContext("2d");
					pencil  = new image.canvas.pencil.init();
					
					$("#color").val("#" + getRandomHex(0, 255).zf(2) + getRandomHex(0, 255).zf(2) + getRandomHex(0, 255).zf(2));
				}
			},
			number: {
				prev: function() {
					if (imageSource.value == 0)
						imageIndex = imageIndex == 0 ? imageCount - 1 : imageIndex - 1;
					else
						coverIndex = coverIndex == 0 ? coverCount - 1 : coverIndex - 1;
				},
				next: function() {
					if (imageSource.value == 0)
						imageIndex = imageIndex == imageCount -1 ? 0 : imageIndex + 1;
					else
						coverIndex = coverIndex == coverCount -1 ? 0 : coverIndex + 1;
				},
				random: function() {
					if (imageSource.value == 0)
						imageIndex = Math.floor(Math.random() * imageCount);
					else
						coverIndex = Math.floor(Math.random() * coverCount);
				}
			},
			go: {
				prev: function() {
					image.number.prev();
					image.canvas.load();
				},
				next: function() {
					if (nextMethod.value == 0)
						image.number.next();
					else
						image.number.random();
					image.canvas.load();
				},
				to: function(e, idx) {
					var pNo;
					if (idx) {
						pNo = idx;
					}
					else if (e) {
						if (e.type === 'keyup') {
							if (e.keyCode == 13) {
								pNo = $("#goto").val();
							}
						}
						else if (e.type === 'click') {
							pNo = $("#goto").val();
						} 
					}
					
					if (imageSource.value == 0) {
						if (pNo > 0 || pNo < imageCount + 1) {
							imageIndex = pNo - 1;
							image.canvas.load();
						}
					}
					else {
						if (pNo > 0 || pNo < coverCount + 1) {
							coverIndex = pNo - 1;
							image.canvas.load();
						}
					}
				}
			},
			zoom: {
				in: function() {
					imagePercent = imagePercent + 10;
					image.canvas.draw();
				},
				out: function() {
					imagePercent = imagePercent - 10;
					image.canvas.draw();
				}
			},
			move: {
				center: function() {
					image.canvas.load();
				},
				up: function() {
					yPositionOffset = yPositionOffset - 100;
					image.canvas.draw();
				},
				down: function() {
					yPositionOffset = yPositionOffset + 100;
					image.canvas.draw();
				},
				left: function() {
					xPositionOffset = xPositionOffset - 100;
					image.canvas.draw();
				},
				right: function() {
					xPositionOffset = xPositionOffset + 100;
					image.canvas.draw();
				},
				leftDown: function() {
					xPositionOffset = xPositionOffset - 100;
					yPositionOffset = yPositionOffset + 100;
					image.canvas.draw();
				},
				rightDown: function() {
					xPositionOffset = xPositionOffset + 100;
					yPositionOffset = yPositionOffset + 100;
					image.canvas.draw();
				},
				leftUp: function() {
					xPositionOffset = xPositionOffset - 100;
					yPositionOffset = yPositionOffset - 100;
					image.canvas.draw();
				},
				rightUp: function() {
					xPositionOffset = xPositionOffset + 100;
					yPositionOffset = yPositionOffset - 100;
					image.canvas.draw();
				}
			}
	};
	
  	var fn = {
			prev: function() {
				image.go.prev();
			},
			next: function() {
				image.go.next();
			},
			playCallback: function(status) {
			},
			nav: function(signal) {
				return image.canvas.nav(signal);
			},
			eventListener: function() {
				$(window).on("resize", image.canvas.resize);
				$("#cv").on("mousedown mousemove mouseup", image.canvas.event);
				$("#imageName" ).on("click", image.canvas.popup);
				$("#goto"      ).on("keyup", image.go.to);
				$(".move-up"   ).on("click", image.move.up);
				$(".move-down" ).on("click", image.move.down);
				$(".move-left" ).on("click", image.move.left);
				$(".move-right").on("click", image.move.right);
				$(".zoom-in"   ).on("click", image.zoom.in);
				$(".zoom-out"  ).on("click", image.zoom.out);
			},
			init: function(data) {
				imageCount   = data['imageCount'];
				imageNameMap = data['imageNameMap'];
				coverCount   = data['coverCount'];
				coverNameMap = data['coverNameMap'];

				imageIndex = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(0, imageCount))) - 1;
				coverIndex = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, getRandomInteger(0, coverCount))) - 1;

				image.canvas.init();
			}
	};
	
	return {
		init: function() {
			config.init("#img-section", fn.prev, fn.next, fn.playCallback, fn.nav, fn.eventListener, fn.init);
		}
	};
	
}());

$(document).ready(function() {
	canvasApp.init();
});
