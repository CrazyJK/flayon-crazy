bgContinue = false;
/**
 * image canvas
 */
var canvasApp = (function() {

	var canvas, context, tool;
	var selectedIndex = 0;
	var imageCount;
	var imageMap;

	var imagePercent = 100;
	var xPositionOffset = 0;
	var yPositionOffset = 0;
	
	var tool_pencil = function() {
	    var tool = this;
	    this.started = false;
	    var pencil = null, diameter = null, color = null;
	    // 마우스를 누르는 순간 그리기 작업을 시작 한다. 
	    this.mousedown = function(ev) {
	    	pencil   = $(':radio[name="pencil"]:checked').val();
	    	color    = $(':text[name="color"]').val();
	    	diameter = $(':text[name="diameter"]').val();
	    	context.strokeStyle = color;
	    	context.fillStyle = color;
	        context.beginPath();
	        if (pencil != 'cursor')
	        	tool.started = true;
	    };
	    // 마우스가 이동하는 동안 계속 호출하여 Canvas에 Line을 그려 나간다
	    this.mousemove = function(ev) {
	        if (tool.started) {
	            if (pencil == 'circle')
		            context.arc(ev._x, ev._y, diameter/2, 0, 2*Math.PI, true);
	            else if (pencil == 'rubber')
	            	context.clearRect(ev._x - diameter/2, ev._y - diameter/2, diameter, diameter);

	            context.closePath();
	            //context.lineWidth = 5;
	            context.fill();
	        }
	    };
	    // 마우스 떼면 그리기 작업을 중단한다
	    this.mouseup = function(ev) {
	    	if (tool.started) {
	            tool.mousemove(ev);
	            tool.started = false;
	    	}
	    };
	};
	
	var imgOriginView = function() {
		xPositionOffset = 0;
		yPositionOffset = 0;
		imagePercent = 100;
		
		var preImage = new Image();
		preImage.onload = function(){
			var canW = canvas.width;
			var canH = canvas.height;
			var imgW = parseInt(preImage.width);
			var imgH = parseInt(preImage.height);
			var xRatio = 100;
			var yRatio = 100;
			if (canW < imgW) {
				xRatio = parseInt(canW / imgW * 100);
			}
			if (canH < imgH) {
				yRatio = parseInt(canH / imgH * 100);
			}
			//console.log("imgOriginView xRatio", xRatio, "yRatio", yRatio);
			imagePercent = Math.min(xRatio, yRatio);

			drawImage(preImage);
		};
		preImage.src = image.url();
	};
	
	var drawImage = function(image) {
		var imgW = parseInt(image.width * imagePercent / 100);
		var imgH = parseInt(image.height * imagePercent / 100);

		var xPos = parseInt((canvas.width  - imgW) / 2 + xPositionOffset);
		var yPos = parseInt((canvas.height - imgH) / 2 + yPositionOffset);

		canvas.width = canvas.width; // canvas clear
		context.drawImage(image, xPos, yPos, imgW, imgH);

		/*
		var debug = "x:" + xPos + " y:" + yPos + " w:" + imgW + " h:" + imgH + " P:" + imagePercent + " xOff:" + xPositionOffset + " yOff:" + yPositionOffset;
		context.font = "20px D2Coding";
		context.fillText(debug, 10 , 50);
		*/
		
		displayImageNav();
	};

	var displayImageNav = function() {
		$("#imageName").html(imageMap[selectedIndex]);
		$("#goNumber").val(selectedIndex+1);
		$("#imagePercent").val(imagePercent + "%");

		var ul = $("#navUL");
		ul.empty();

		var range = parseInt($(window).width() / 70 / 2);
		var startIdx = selectedIndex - range;
		var   endIdx = selectedIndex + range + 1;
		if (startIdx < 0) 
			startIdx = 0;
		if (endIdx > imageCount)
			endIdx = imageCount;

		ul.append(
				$("<li>").append(
						$("<a>").html("First").on("click", function() {
							image.goto(null, 1);
						})
				)
		);
		for (var i = startIdx; i < endIdx; i++) {
			ul.append(
					$("<li>").append(
							$("<a>", {
								"class": (i == selectedIndex ? "selected" : ""), 
								imageNo: (i+1)
							}).html(i+1).on("click", function() {
								image.goto(null, $(this).attr("imageNo"));
							})
					)
			);
		}
		ul.append(
				$("<li>").append(
						$("<a>").html("Last").on("click", function() {
							image.goto(null, imageCount);
						})
				)
		);
	};
	
	var container = {
			resize: function() {
				displayImageNav();
				var margin = 4;
				$("#cv").attr("width",  $(window).width() - margin * 2);
				$("#cv").attr("height", $(window).height() - $("#img-nav").outerHeight() - margin * 3);
			},
			init: function() {
				container.resize();
				
				// Pencil tool 객체를 생성 한다.
				tool = new tool_pencil();
			
				canvas = document.getElementById("cv");
				context = canvas.getContext("2d");
			},
			canvasEvent: function(e) {
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
				    var func = tool[e.type];        
				    if (func) {
				        func(e);
				    }
				}
				else if (e.which == 2) {
					image.center();
				}
				else if (e.which == 3) {
					// nothing
				}
			} 
	};
	
	var number = {
			prev: function() {
				return selectedIndex == 0 ? imageCount - 1 : selectedIndex - 1;
			},
			next: function() {
				return selectedIndex == imageCount -1 ? 0 : selectedIndex + 1;
			},
			random: function() {
				return Math.floor(Math.random() * imageCount);
			}
	};
	
	var image = {
			prev: function() {
				selectedIndex = number.prev();
				imgOriginView();
			},
			next: function() {
				if (nextMethod.value == 0) {
					selectedIndex = number.next();
				}
				else {
					selectedIndex = number.random();
				}
				imgOriginView();
			},
			goto: function(e, idx) {
				var pNo;
				if (idx) {
					pNo = idx;
				}
				else if (e) {
					if (e.type === 'keyup') {
						if (e.keyCode == 13) {
							pNo = $("#goNumber").val();
						}
					}
					else if (e.type === 'click') {
						pNo = $("#goNumber").val();
					} 
				}
				
				if (pNo > 0 || pNo < imageCount + 1) {
					selectedIndex = pNo - 1;
					imgOriginView();
				}
			},
			zoomIn: function() {
				imagePercent = imagePercent + 10;
				image.load();
			},
			zoomOut: function() {
				imagePercent = imagePercent - 10;
				image.load();
			},
			center: function() {
				imgOriginView();
			},
			moveUp: function() {
				yPositionOffset = yPositionOffset - 100;
				image.load();
			},
			moveDown: function() {
				yPositionOffset = yPositionOffset + 100;
				image.load();
			},
			moveLeft: function() {
				xPositionOffset = xPositionOffset - 100;
				image.load();
			},
			moveRight: function() {
				xPositionOffset = xPositionOffset + 100;
				image.load();
			},
			moveLeftDown: function() {
				xPositionOffset = xPositionOffset - 100;
				yPositionOffset = yPositionOffset + 100;
				image.load();
			},
			moveRightDown: function() {
				xPositionOffset = xPositionOffset + 100;
				yPositionOffset = yPositionOffset + 100;
				image.load();
			},
			moveLeftUp: function() {
				xPositionOffset = xPositionOffset - 100;
				yPositionOffset = yPositionOffset - 100;
				image.load();
			},
			moveRightUp: function() {
				xPositionOffset = xPositionOffset + 100;
				yPositionOffset = yPositionOffset - 100;
				image.load();
			},
			load: function(nextNumber) {
				if (parseInt(nextNumber) > -1)
					selectedIndex = parseInt(nextNumber);
				var preImage = new Image();
				preImage.src = PATH + "/image/" + selectedIndex;
				preImage.onload = function() {
					drawImage(preImage);
				};
			},
			nav: function(signal) {
				console.log("canvas.image.nav", signal);
				switch (signal) {
				case 97: // numpad 1
					image.moveLeftDown(); 
					return true;
				case 98: // numpad 2
					image.moveDown(); 
					return true;
				case 99: // numpad 3
					image.moveRightDown();
					return true;
				case 100: // numpad 4
					image.moveLeft(); 
					return true;
				case 101: // numpad 5
					image.center();
					return true;
				case 102: // numpad 6
					image.moveRight(); 
					return true;
				case 103: // numpad 7
					image.moveLeftUp();
					return true;
				case 104: // numpad 8
					image.moveUp(); 
					return true;
				case 105: // numpad 9
					image.moveRightUp();
					return true;
				case 107: // numpad +
					image.zoomIn(); 
					return true;
				case 109: // numpad -
					image.zoomOut();
					return true;
				default:
					return false;
				}
			},
			popup: function() {
				popupImage(image.url());
			},
			url: function() {
				setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, selectedIndex);
				return PATH + "/image/" + selectedIndex + "?_t=" + new Date().getTime();
			}
	};
	
  	var fn = {
			prev: function(showEffect, showOptions, showDuration) {
				image.prev();
			},
			next: function(showEffect, showOptions, showDuration) {
				image.next();
			},
			playCallback: function(status) {
			},
			nav: function(signal) {
				return image.nav(signal);
			},
			eventListener: function() {
				$(window).on("resize", container.resize);
				$("#cv").on("mousedown mousemove mouseup", container.canvasEvent);
				$("#imageName").on("click", image.popup);
				$("#goNumber").on("keyup", image.goto);
				$(".btn-goto").on("click", image.goto);
				$(".move-up").on("click", image.moveUp);
				$(".move-down").on("click", image.moveDown);
				$(".move-left").on("click", image.moveLeft);
				$(".move-right").on("click", image.moveRight);
				$(".zoom-in").on("click", image.zoomIn);
				$(".zoom-out").on("click", image.zoomOut);
			},
			init: function(data) {
				imageCount = data['imageCount'];
				imageMap = data['imageNameMap'];

				selectedIndex = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(0, imageCount))) - 1;

				container.init();
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
