/**
 * image canvas
 */

var canvasApp = (function() {

	var canvas, context, tool;
	var selectedNumber = 0;
	var imageCount;
	var imageMap;

	var imageRatio = 1.0, originalImageRatio = 1.0;
	var xPositionOffset = 0;
	var yPositionOffset = 0;
	
	var tool_pencil = function() {
	    var tool = this;
	    this.started = false;
	    var pencil = null, diameter = null, color = null;
	    // 마우스를 누르는 순간 그리기 작업을 시작 한다. 
	    this.mousedown = function(ev) {
	    	pencil = $(':radio[name="pencil"]:checked').val();
	    	diameter = $(':text[name="diameter"]').val();
	    	color = $(':text[name="color"]').val();
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
		imageRatio = 1.0;
		var preImage = new Image();
		preImage.src = image.url();
		preImage.onload = function(){
			var canW = canvas.width;
			var canH = canvas.height;
			var imgW = parseInt(preImage.width);
			var imgH = parseInt(preImage.height);
			var xRatio = 1.0;
			var yRatio = 1.0;
			if(canW < imgW){
				xRatio = canW / imgW;
				imgH = parseInt(imgH * xRatio);
			}
			if(canH < imgH){
				yRatio = canH / imgH;
			}
			imageRatio = Math.min(xRatio, yRatio).toFixed(1);
			originalImageRatio = imageRatio;
			drawImage(preImage);
		};
	};
	
	var imgLandscape = function() {
		xPositionOffset = 0;
		yPositionOffset = 0;
		imageRatio = 1.0;
		var preImage = new Image();
		preImage.src = image.url();
		preImage.onload = function(){
			var canW = canvas.width;
			var canH = canvas.height;
			var imgW = parseInt(preImage.width);
			var imgH = parseInt(preImage.height);
			var landscape = false;
			if(canW < imgW){
				imageRatio = canW / imgW;
				imgH = parseInt(imgH * imageRatio);
			}
			if(canH < imgH){
				landscape = true;
			}
			drawImage(preImage, landscape);
		};
	};
	
	var drawImage = function(image, landscape) {
		var imgW = parseInt(image.width * imageRatio);
		var imgH = parseInt(image.height * imageRatio);

		var xPos = parseInt((canvas.width  - imgW) / 2 + xPositionOffset);
		var yPos = parseInt((canvas.height - imgH) / 2 + yPositionOffset);
		if (landscape) {
			yPositionOffset = -yPos;
			yPos = 0;
		}

		canvas.width = canvas.width;        
		context.drawImage(image, xPos, yPos, imgW, imgH);

		/*
		var debug = "x:" + xPos + " y:" + yPos + " w:" + imgW + " h:" + imgH 
			+ " R:" + imageRatio + " xOff:" + xPositionOffset + " yOff:" + yPositionOffset;
		context.font = "20px '맑은 고딕'";
		context.fillText(debug, 10 , 760);
		*/
		$(':text[name="ratio"]').val(imageRatio);
		
		displayImageNav();
	};

	var displayImageNav = function() {
		$("#imageName").html(imageMap[selectedNumber]);
		$("#goNumber").val(selectedNumber+1);
		var ul = $("#navUL");
		ul.empty();

		var startIdx = 0;
		var endIdx = 13;
		if (selectedNumber >= 7) {
			startIdx = selectedNumber - 6;
			endIdx = selectedNumber + 7;
		}
		if (endIdx > imageCount) {
			startIdx = imageCount - 13;
			if (startIdx < 0) startIdx = 0;
			endIdx = imageCount;
		}
		ul.append("<li><a onclick='viewPrevImage();'>Prev</a></li>");
		ul.append("<li><a onclick='loadImage(0);'>First</a></li>");
		for (var i=startIdx; i<endIdx; i++) {
			ul.append("<li><a onclick='loadImage(" + i + ");' " + (i==selectedNumber ? "class='selected'" : "") + ">" + (i+1) + "</a></li>");
		}
		ul.append("<li><a onclick='loadImage(" + (imageCount-1) + ");'>Last</a></li>");
		ul.append("<li><a onclick='viewNextImage();'>Next</a></li>");

	};
	
	var container = {
			resize: function() {
				var windowWidth  = $(window).width();
				var windowHeight = $(window).height();
				var imgNavHeight = $("#img-nav").outerHeight();
				console.log("container", windowWidth, windowHeight, imgNavHeight);
				$("#cv").attr("width", windowWidth);
				$("#cv").attr("height", windowHeight - imgNavHeight - 25);
			},
			init: function() {
				// Pencil tool 객체를 생성 한다.
				tool = new tool_pencil();
			
				canvas = document.getElementById("cv");
				context = canvas.getContext("2d");

				container.resize();
			},
			canvasEvent: function(e) {
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
	};
	
	var number = {
			prev: function() {
				return selectedNumber == 0 ? imageCount - 1 : selectedNumber - 1;
			},
			next: function() {
				return selectedNumber == imageCount -1 ? 0 : selectedNumber + 1;
			},
			random: function() {
				return Math.floor(Math.random() * imageCount);
			}
	};
	
	var image = {
			prev: function() {
				selectedNumber = number.prev();
				imgOriginView();
			},
			next: function() {
				if (nextMethod.value == 0) {
					selectedNumber = number.next();
				}
				else {
					selectedNumber = number.random();
				}
				imgOriginView();
			},
			goto: function() {
				var pNo = $("#goNumber").val();
				if (pNo > 0 || pNo < imageCount + 1) {
					selectedNumber = pNo - 1;
					imgOriginView();
				}
			},
			zoomIn: function() {
				imageRatio = imageRatio + 0.1;
				image.load();
			},
			zoomOut: function() {
				imageRatio = imageRatio - 0.1;
				image.load();
			},
			zoomFit: function() {
				xPositionOffset = 0;
				yPositionOffset = 0;
				imageRatio = originalImageRatio;
				image.load();
			},
			moveCenter: function() {
				xPositionOffset = 0;
				yPositionOffset = 0;
				image.load();
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
			load: function(nextNumber) {
				if (parseInt(nextNumber) > -1)
					selectedNumber = parseInt(nextNumber);
				var image = new Image();
				image.src = PATH + "/image/" + selectedNumber;
				image.onload = function(){
					drawImage(image, true);
				};
			},
			nav: function(signal) {
				console.log("canvas.image.nav", signal);
				switch (signal) {
				case 96: // numpad 0
					image.zoomFit();
					return true;
				case 98: // numpad 2
					image.moveDown(); 
					return true;
				case 100: // numpad 4
					image.moveLeft(); 
					return true;
				case 101: // numpad 5
					image.moveCenter();
					return true;
				case 102: // numpad 6
					image.moveRight(); 
					return true;
				case 103: // numpad 7
					return true;
				case 104: // numpad 8
					image.moveUp(); 
					return true;
				case 105: // numpad 9
					imgLandscape(); 
					return true;
				case 107: // numpad +
					image.zoomIn(); 
					return true;
				case 109: // numpad -
					image.zoomOut();
					return true;
				case 46: // delete
					fnDelete();
					return true;
				default:
					return false;
				}
			},
			popup: function() {
				popupImage(image.url());
			},
			url: function() {
				setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, selectedNumber);
				return PATH + "/image/" + selectedNumber + "?_t=" + new Date().getTime();
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
			},
			init: function(data) {
				imageCount = data['imageCount'];
				imageMap = data['imageNameMap'];

				selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(0, imageCount)));

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

function fnDelete() {
	window.location.href = '<s:url value="/image/canvas" />?d=' + selectedNumber;
}
