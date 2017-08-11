/**
 * 자바스크립트 모듈, 모듈 포맷, 모듈 로더와 모듈 번들러에 대한 10분 입문서
 * 	https://github.com/codepink/codepink.github.com/wiki/%EC%9E%90%EB%B0%94%EC%8A%A4%ED%81%AC%EB%A6%BD%ED%8A%B8-%EB%AA%A8%EB%93%88,-%EB%AA%A8%EB%93%88-%ED%8F%AC%EB%A7%B7,-%EB%AA%A8%EB%93%88-%EB%A1%9C%EB%8D%94%EC%99%80-%EB%AA%A8%EB%93%88-%EB%B2%88%EB%93%A4%EB%9F%AC%EC%97%90-%EB%8C%80%ED%95%9C-10%EB%B6%84-%EC%9E%85%EB%AC%B8%EC%84%9C
 */
// 만능 모듈 정의(UMD, Universal Module Definition) 
(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module. 비동기 모듈 정의(AMD, Asynchronous Module Definition)
        define(['jquery'], factory);
    } else if (typeof exports === 'object') {
        // Node. Does not work with strict CommonJS, but only CommonJS-like environments that support module.exports, like Node.
        module.exports = factory(require('jquery'));
    } else {
        // Browser globals (root is window)
        root.lightboxApp = factory(root.jQuery);
    }
}(this, function ($) {
	function LightboxApp() {
		this.imagepath = PATH + '/image/';
		this.imageCount;
		this.imageMap;
		this.playInterval = 10;
		this.playMode;
		this.init();
	}
	
	LightboxApp.prototype.init = function() {
		var self = this;
		$(document).ready(function() {
			self.enable();
			self.start();
		});
	};
	
	LightboxApp.prototype.enable = function() {
		var self = this;
		$(".form-control, .checkbox-inline, .radio-inline").on("change", function() {
			var changeOptionText;
			if (this.nodeName === 'LABEL')
				if (this.control.type === 'radio')
					changeOptionText = $(this.control).attr("name") + " = " + $('input:radio[name="' + $(this.control).attr("name") + '"]:checked').val();
				else if (this.control.type === 'checkbox')
					changeOptionText = $(this.control).attr("id") + " = " + $(this.control).is(":checked");
				else
					changeOptionText = "unknown change";
			else {
				changeOptionText = $(this).attr("id") + " = " + $(this).val();
				var id = $(this).attr("id");
				var val = $(this).val();
				$("#" + id + "-label").html(val);
			}
			self.setOption();

			showSnackbar(changeOptionText, 1000);
		});
		$(".btn-shuffle").on("click", function() {
			self.shuffle();
		});
		$(".btn-view").on("click", function() {
			self.view();
		});

		// play engine
		timerEngine.init(self.play, self.playInterval, "#progressWrapper", {}, "Play", self.playCallback);

	};
	
	LightboxApp.prototype.start = function() {
		var self = this;
		this.shuffle(1);
		$.getJSON(this.imagepath + "data.json" ,function(data) {
			self.imageCount = data['imageCount'];
			self.imageMap = data['imageNameMap'];
			
			$(".imageCount").html(self.imageCount);
			
			var $imageset = $('#imageset');
			for (var i=0; i<self.imageCount; i++) {
				$("<a>").attr({
					'href': self.imagepath + i,
					'data-lightbox': 'lightbox-set',
					'data-title': "<a href='" + self.imagepath + i + "' target='image-" + i + "'>" + self.imageMap[i] + "</a>",
					"data-index": i
				}).appendTo($imageset);
			}
			
			self.view();
		});
	};

	LightboxApp.prototype.prev = function() {
		lightbox.prevImage();
	};
	LightboxApp.prototype.next = function() {
		lightbox.nextImage();
	};
	LightboxApp.prototype.view = function(selectedNumber) {
		console.log("LightboxApp.prototype.view START", selectedNumber);
		if (!selectedNumber || typeof selectedNumber === 'object')
			selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(1, this.imageCount))) + 1;

		$("#imageset a:nth-child(" + selectedNumber + ")").click();
		
		console.log("LightboxApp.prototype.view END", selectedNumber);
	};
	LightboxApp.prototype.random = function() {
		console.log("LightboxApp.prototype.random");
		lightbox.changeImage(getRandomInteger(1, this.imageCount));
	};
	LightboxApp.prototype.play = function() {
		var self = this.lightboxApp;
		console.log("LightboxApp.prototype.play START", self.playMode);
		if (self.playMode === 'r') {
			self.random();
		}
		else {
			self.next();
		}
	};
	LightboxApp.prototype.playCallback = function(status) {
		console.log("LightboxApp.prototype.playCallback");
		var self = this.lightboxApp;
		if (status) { // start
			self.view();
			$("body").css({backgroundColor: randomColor('r')});
			$(".lightboxOverlay").css({opacity: 1});
			$(".progress").css("background", "linear-gradient(to bottom,#403a3a 0,#2f2626 100%)");
			$(".progress-bar").css("background", "#000");
		}
		else { // stop
			$("body").css({backgroundColor: "#fff"});
			$(".lightboxOverlay").css({opacity: 0.8});
			$(".progress").css("background", "linear-gradient(to bottom,#ebebeb 0,#f5f5f5 100%)");
			$(".progress-bar").css("background", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
		}
	};
	
	LightboxApp.prototype.setOption = function() {
		console.log("LightboxApp.prototype.shuffle.setOption");
		lightbox.option({
			'albumLabel': 				  $("#albumLabel").val(),
			'showDataLabel': 			  $("#showDataLabel").is(":checked"),
			'showImageNumberLabel': 	  $("#showImageNumberLabel").is(":checked"),
			'resizeDuration':	 parseInt($("#resizeDuration").val()),
	      	'fadeDuration': 	 parseInt($("#fadeDuration").val()),
	      	'imageFadeDuration': parseInt($("#imageFadeDuration").val()),
	      	'randomImageEffect':    	  $("#randomImageEffect").is(":checked"),
	      	'wrapAround': 				  $("#wrapAround").is(":checked"),
	      	'positionFromTop': 	 parseInt($("#positionFromTop").val()),
	      	'sanitizeTitle': false,
	      	disableScrolling: true
	    });
		this.playInterval = parseInt($("#playInterval").val());
		this.playMode = $('input:radio[name="playMode"]:checked').val();
		timerEngine.setTime(this.playInterval);
	};
	
	LightboxApp.prototype.shuffle = function(maxShuffle) {
		var self = this;
		var count = 0;
		maxShuffle = maxShuffle || getRandomInteger(3, 9);
		console.log("LightboxApp.prototype.shuffle", maxShuffle);

		function shuffleOnce() {
			console.log("LightboxApp.prototype.shuffle.once");
			$("#showDataLabel").prop("checked", getRandomBoolean());
			$("#showImageNumberLabel").prop("checked", getRandomBoolean());
			$("#resizeDuration").val(getRandomInteger(1, 10)*100);
			$("#fadeDuration").val(getRandomInteger(1, 10)*100);
			$("#imageFadeDuration").val(getRandomInteger(1, 10)*100);
			$("#randomImageEffect").prop("checked", getRandomBoolean());
			$("#wrapAround").prop("checked", getRandomBoolean());
			$("#playInterval").val(getRandomInteger(5, 20));
			$($("input:radio[name='playMode']")[getRandomInteger(0, 1)]).prop("checked", true);

			$(   "#resizeDuration-label").html($(   "#resizeDuration").val());
			$(     "#fadeDuration-label").html($(     "#fadeDuration").val());
			$("#imageFadeDuration-label").html($("#imageFadeDuration").val());
			$(     "#playInterval-label").html($(     "#playInterval").val());
		};
		
	 	showSnackbar("shuffle start", 1000);
		var shuffler = setInterval(function() {
			shuffleOnce();
			if (++count > maxShuffle) {
			 	clearInterval(shuffler);
			 	self.setOption();
			 	showSnackbar("shuffle completed. try " + maxShuffle, 1000);
			}
		}, 500);
	};
	
	return new LightboxApp();
}));

bgContinue = false;
