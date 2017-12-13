/**
 * for crazy-decorator.jsp
 */
'use strict';

var PATH = '',
	bgImageCount = 0,
	urlSearchVideo,
	urlSearchActress,
	urlSearchTorrent,
    locationPathname = window.location.pathname,
    currBGImageNo = 0,
    bgContinue = true,	// content_div에 이미지를 보여줄지 여부
    bgChangeInterval = 60,
    bgImageChanger,
    listViewType,
    windowWidth = 0,
    windowHeight = 0,
    pingInterval = 5000,
    themeSwitch,
    bgToggle = 0,
    isLoadedSearchPage = false,
    loadingText = 'Loading...',
    currBGImageUrl;

	/**
	 * div container 높이 조정
	 */
var	resizeDivHeight = function() {
		var offsetMargin = 20, headerHeight = $("#header_div").outerHeight();
		windowHeight = $(window).outerHeight();
		windowWidth  = $(window).width();
		calculatedDivHeight = windowHeight - headerHeight - offsetMargin;
		$("#content_div").outerHeight(calculatedDivHeight);
		//console.log("resizeDivHeight", calculatedDivHeight);
		
		$("#innerSearchPage").css({
			width: windowWidth - offsetMargin * 2, 
			height: windowHeight - offsetMargin * 2
		});
	
		try {
			resizeSecondDiv(); // if it exist
		} catch (e) {
			//console.log("resizeSecondDiv Error", e.message);
		}
	},
	/**
	 * post 액션
	actionFrame = function(reqUrl, reqData, method, msg, interval, callback) {
		console.log("actionFrame", reqUrl, reqData, method, msg, interval);
		var token = $('#csrfToken').val();
		var header = $('#csrfHeader').val();
		$.ajax({
			type: method ? method : "POST",
			url: reqUrl,
			data: reqData,
			beforeSend : function(xhr) {
				loading(true, msg ? msg : loadingText);
				xhr.setRequestHeader("Accept", "application/json");
			}
		}).done(function(data, textStatus, jqXHR) {
			if (jqXHR.getResponseHeader('error') === 'true') {
				var errorMessge = jqXHR.getResponseHeader('error.message');
				loading(true, 'Fail : ' + errorMessge, {danger: true});
			}
			else {
				loading(false);
				showSnackbar(msg + " Done", interval ? interval : 2000);
				if (callback)
					callback();
			}
		}).fail(function(jqXHR, textStatus, errorThrown) {
			var errorHtml = $.parseHTML(jqXHR.responseText);
			var parsed = $('<div/>').append(errorHtml);
			var context = parsed.find(".container").html();
			if (jqXHR.getResponseHeader('error') === 'true') {
				var errorMessge = jqXHR.getResponseHeader('error.message');
				context = context ? errorMessge + "<br>" + context : errorMessge;
			}
			loading(true, "fail : " + reqUrl + " [" + textStatus + "] "+ errorThrown, {detail: context, danger: true});
			console.log("actionFrame fail", jqXHR, textStatus, errorThrown);
		}).always(function(data_jqXHR, textStatus, jqXHR_errorThrown) {
			console.log("actionFrame called", data_jqXHR, textStatus, jqXHR_errorThrown);
		});
	},
	 */
	/**
	 * loading layer control
	 */
	tSec = 0,
	timer,
	loading = function(show, msg, options) {
		var defaults = {interval: 0, detail: "", danger: false},
			opts = $.extend({}, defaults, options),
			timerControl = function(start) {
				//console.log("loading timerControl", start, tSec);
				if (start)
					$("#loading-timer").html(tSec++);
				else
					clearInterval(timer);
			};
		//console.log("loading", show, msg, options, opts);

		if (show) {
			tSec = 1;
			timerControl(false);
			timer = setInterval(function() {
				timerControl(true);
			}, 1000);
			if (msg) $("#loading-msg").html(msg);
			$("#loading-msg-detail").toggleClass("hide", opts.detail === "").html(opts.detail); 
			$("#loading, #loader, #loading-timer, #loading-msg, #loading-msg-detail").toggleClass("red", opts.danger);
			$("#loading-timer").html(tSec);
			$("#loading").css("display", "table");
			if (opts.interval > 0) {
				console.log("loading will be disappear in ", opts.interval);
				$("#loading").fadeOut(opts.interval, function() {
					console.log("loading timerControl off");
					timerControl(false);
				});
			}
		}
		else {
			$("#loading").hide();
			timerControl(false);
		}
	},
	/**
	 * toggle body background image
	 */
	toggleBody = function() {
		if (bgContinue) {
		    $(".container-fluid, .container").animate({
		        "opacity": bgToggle++ % 2
		    }, 1000);
		    $("#bgActionGroup").css({"padding-top": windowHeight - 60}).toggle({
		        duration: 1000
		    });
		}
	},
	/**
	 * search page control
	 */
	viewInnerSearchPage = function() {
		if (!isLoadedSearchPage) {
			$("#innerSearchPage > iframe").attr({"src": PATH + "/video/search"});
			isLoadedSearchPage = true;
		}
		if (themeSwitch === 'plain')
			$("#innerSearchPage").css({boxShadow: "0 0 15px 10px rgba(0,0,0,.5)"}).toggle();
		else
			$("#innerSearchPage").css({boxShadow: "0 0 15px 10px " + getRandomColor(0.5)}).toggle();
	},
	/**
	 * background image set
	 * @param imgIdx
	 */
	setBackgroundImage = function(imgIdx) {
		currBGImageNo = typeof imgIdx === 'number' ? imgIdx : getRandomInteger(0, bgImageCount-1);
		currBGImageUrl = PATH + "/image/" + currBGImageNo;
		//console.log("setBackgroundImage", imgIdx, currBGImageNo, bgImageCount, currBGImageUrl);
		$("body").css("background-image", "url(" + currBGImageUrl + ")");
		setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, currBGImageNo);
	},
	/**
	 * snackbar control
	 */
	showSnackbar = function(message, time) {
		$("#snackbar").addClass("show").find("strong").html(message);
		setTimeout(function(){
			$("#snackbar").removeClass("show"); 
		}, time || 3000);
	},
	/**
	 * toggle theme
	 */
	toggleTheme = function(themeName) {
		var	propagateTheme = function() {
			if (isLoadedSearchPage) {
				$("#innerSearchPage > iframe").get(0).contentWindow.toggleTheme(themeSwitch);
			}
		};
		if (locationPathname.startsWith(PATH + '/image')) {
			if (locationPathname === PATH + '/image/thumbnails') {
				if (themeName === 'normal') {
					$("#plainStyle").empty();
					$("#header_div" ).css({backgroundImage: 'linear-gradient(to bottom, #fff 0, ' + getRandomColor(0.3) + ' 100%)'});
					$("#content_div").css({backgroundColor: getRandomColor(0.3)});
				}
				if (themeName === 'plain') {
					$("#plainStyle").empty().append(
						'<style>'
							+ ' #header_div, #content_div {background: transparent none !important; box-shadow: none !important;}'
						+ '</style>'
					);
				}
			}
		}
		else {
			if (themeName === 'normal') {
				if (bgContinue) {
					$("#bgChangeInterval").val(bgChangeInterval);
					setBackgroundImage();
					clearInterval(bgImageChanger);
					bgImageChanger = setInterval(setBackgroundImage, bgChangeInterval * 1000);
				}
				$("#header_div" ).css({backgroundImage: 'linear-gradient(to bottom, #fff 0, ' + getRandomColor(0.3) + ' 100%)'});
				$("#content_div").css({backgroundColor: getRandomColor(0.3)});
				$("#plainStyle").empty();
				$("#backMenu").parent().show();
			}
			if (themeName === 'plain') {
				clearInterval(bgImageChanger);
				$("#plainStyle").empty().append(
					'<style>'
						+ ' body {background: transparent none !important;}'
						+ ' #header_div, #content_div {background: transparent none !important; box-shadow: none !important;}'
						+ ' dl.box.box-small, div.box.box-small, #resultVideoDiv, #resultHistoryDiv {box-shadow: none !important; background-color: transparent !important;}'
						+ ' .btn {background: transparent none !important; color: #333;}'
					 	+ ' .table-hover > tbody > tr:hover, .table-hover > tbody > tr:focus {background-color: rgba(38, 90, 136, .1);}'
					 	+ ' .border-shadow {box-shadow: none;}'
						+ ' .btn:hover, .btn:focus, .btn-primary.active, .btn-primary.active:focus {color: #333 !important; box-shadow: 0 0 10px 0 rgba(38, 90, 136, .5) inset !important;}'
						+ ' .label-success, .label-info, .label-warning, .label-primary, .label-danger {background-color: rgba(38, 90, 136, .5) !important;}'
					 	+ ' .favorite {box-shadow: 0 0 10px 0 rgba(38, 90, 136, .5) inset !important;}'
					 	+ ' .jk-video-detail .label-plain.favorite {box-shadow: 0 3px 9px rgba(0,0,0,.3), 0 0 10px 0 rgba(38, 90, 136, .5) inset !important;}'
					+ '</style>'
				);
				$("#backMenu").parent().hide();
			}
		}
		themeSwitch = themeName;
		try {neonEffect()} catch(e) {}
		propagateTheme();
		setLocalStorageItem(CRAZY_DECORATOR_THEME, themeSwitch);
	},
	/**
	 * delete current backgroung image
	 */
	deleteBGImage = function() {
		confirm('delete ' + currBGImageUrl) && restCall(currBGImageUrl, {method: "DELETE", title: "this image delete"}, setBackgroundImage);
	},
	/**
	 * popup view background image
	 */
	popupBGImage = function() {
		popupImage(currBGImageUrl, "bg-image");
	},
	restCall = function(url, args, callback) {
		
		var defaults = {
				method: "GET",
				data: {},
				mimeType: "application/json",
				title: "Request",
				showLoading: true,
				beforeSend: function(xhr) {
					xhr.setRequestHeader("Accept", "application/json");
				}
		};
		var settings = $.extend({}, defaults, args);
		
		if (settings.showLoading)
			loading(true, settings.title);
		$.ajax(url, settings).done(function(data) {
			//console.log("restCall done", url, data);
			if (callback)
				callback(data);
		}).fail(function(jqXHR, textStatus, errorThrown) {
			console.log("restCall fail", '\njqXHR=', jqXHR, '\ntextStatus=', textStatus, '\nerrorThrown=', errorThrown);
			if (jqXHR.getResponseHeader('error')) {
				displayNotice('Error', 
						'Message: ' + jqXHR.getResponseHeader('error.message') + "<br>" + 
						'Cause: '   + jqXHR.getResponseHeader('error.cause'));
			}
			else if (jqXHR.responseJSON) {
				displayNotice('Error', 
						'Error: '     + jqXHR.responseJSON.error + '<br>' + 
						'Exception: ' + jqXHR.responseJSON.exception + '<br>' +
						'Message: '   + jqXHR.responseJSON.message + '<br>' +
						'Timestamp: ' + jqXHR.responseJSON.timestamp + '<br>' +
						'Status: '    + jqXHR.responseJSON.status + '<br>' + 
						'Path: '      + jqXHR.responseJSON.path);
			}
			else {
				displayNotice('Error', textStatus + "<br>" + errorThrown);
			}
		}).always(function(data_jqXHR, textStatus, jqXHR_errorThrown) {
			if (settings.showLoading)
				loading(false);
		});

	},
	displayNotice = function(title, desc) {
	    $("#notice > p").html(desc);
	    $("#notice").attr("title", title).dialog();
	};

var	crazy = (function() {
		
		var 
	    /**
	     * add event listener
	     */
		crazy_listener = (function() {
			var resize = function() {
					//console.log("crazy_listener : resize listener start");
					$(window).on("resize", resizeDivHeight).trigger("resize");
				},
				pageMove = function() {
					//console.log("crazy_listener : pageMove listener start");
					$("#deco_nav a[href]").on("click", function() {
						console.log("nav click...");
						loading(true, 'new request call');
					});
					$("#header_div form").submit(function(event) {
						console.log("form submit...");
						loading(true, "form submit");
					});
				},
				background = function() {
					//console.log("crazy_listener : background listener start");
					$("#backMenu"  ).on("click", toggleBody);
					$("#deleteBgBtn").on("click", deleteBGImage);
					$("#nextBgBtn" ).on("click", setBackgroundImage);
					$("#popupBgBtn").on("click", popupBGImage);
					bgContinue && $("#bgChangeInterval").on("keyup", function() {
						bgChangeInterval = parseInt($(this).val());
						clearInterval(bgImageChanger);
//						setBackgroundImage();
						bgImageChanger = setInterval(setBackgroundImage, bgChangeInterval * 1000);
						//console.log("bgChangeInterval", bgChangeInterval, bgImageChanger);
					}).val(bgChangeInterval).trigger("keyup");
				},
				searchPage = function() {
					$("#searchMenu").on("click", viewInnerSearchPage);
				},
				checkbox = function() {
					//console.log("crazy_listener : implement checkbox element");
					$('span[id^="checkbox"]')
						.css("cursor", "pointer")
						.on("click", function() {
							var isChecked = $("#" + $(this).attr("id").split("-")[1]).is(":checked");
							console.log("checkbox click", "#" + $(this).attr("id"), !isChecked);
							$(this).swapClass("label-success", "label-default", isChecked);
							$($(this).attr("data-toggle")).toggle(!isChecked).swapClass("hide", "", !isChecked);
						})
						.each(function() {
							var isChecked = $("#" + $(this).attr("id").split("-")[1]).is(":checked");
							$(this).swapClass("label-success", "label-default", !isChecked);
							$($(this).attr("data-toggle")).toggle(!isChecked).swapClass("hide", "", !isChecked);
						});
				},
				radioBtn = function() {
					//console.log("crazy_listener : implement radio element");
					$('span[id^="radio"]')
						.on("click", function() {
							var idArr = $(this).attr("id").split("-");
							console.log('span[id^="radio"]', idArr);
							$("#" + idArr[1]).val(idArr[2]);
							$('span[id^="radio-' + idArr[1] + '"]').removeClass("radio-on");
							$(this).addClass("radio-on");
						})
						.each(function() {
							var idArr = $(this).attr("id").split("-");
							if($("#" + idArr[1]).val() == idArr[2]) {
								$(this).addClass("radio-on");
							} else {
								$(this).removeClass("radio-on");
							}
						});
				},
				/* Add listener
				 * custom checkbox
				 * ex) <span class="label label-default" role="checkbox" data-role-value="false">Favorite</span> 
				 * */
				checkbox_role = function() {
					//console.log("crazy_listener : implement role=checkbox");
					$("[role='checkbox']").each(function() {
						var checked = $(this).attr("data-role-value") === 'true';
						$(this).addClass('pointer').toggleClass("label-success", checked).data("checked", checked);
					}).on("click", function() {
						var checked = $(this).data("checked");
						$(this).toggleClass("label-success", !checked).data("checked", !checked);
						console.log("checkbox_role click : ", "#" + $(this).attr("id"), !checked);
					});
				},
				themeSwitch = function() {
					$("#themeSwitchNormal").on("click", function() {
						toggleTheme('normal');
					});
					$("#themeSwitchPlain").on("click", function() {
						toggleTheme('plain');
					});
				},
				blind = function() {
					$(window).on({
						"keyup": function(e) {
							if (e.keyCode == 27) {
								console.log("blind toggle");
								$("#blinders").toggleClass("blind");
							}
						}
					});
				};
				
			return {
				init : function() {
					resize();
					pageMove();
					background();
					searchPage();
					checkbox();
					radioBtn();
					checkbox_role();
					themeSwitch();
					blind();
				}
			};
		}()),
		/**
		 * manipillate dom
		 */
		crazy_manipulateDom = (function() {
		
			var 
			rankColor = function() {
				//console.log("crazy_manipulateDom : set rank color");
			 	$('input[type="range"].rank-range').each(function() {
					var opus = $(this).attr("data-opus");
					fnRankColor($(this), $("#Rank-" + opus + "-label"));
			 	});
			},
			/**
			 * 현재 url비교하여 메뉴 선택 효과를 주고, 메뉴 이외의 창에서는 nav를 보이지 않게
			 */
			showNavigation = function() {
				//console.log("crazy_manipulateDom : show navigation")
				var found = false;
				$("nav#deco_nav ul li a").each(function() {
					//console.log($(this).attr("href"), locationPathname);
					var href = $(this).attr("href");
					if (href === locationPathname || href + '/' === locationPathname) {
						$(this).parent().addClass("active");
						found = true;
					}
				});
				!found && $("nav#deco_nav").hide();
				
				if (locationPathname.startsWith(PATH + '/image')) {
					console.log("current " + locationPathname + " background, theme menu hide");
					$("#backMenu, #themeMenu").parent().hide();
				}
			},
			/**
			 * data-lazy-class="w3-animate-opacity, 3000"
			 * 3초후에 클래스를 추가한다.
			 */
			lazyLoadCssClass = function() {
				//console.log("crazy_manipulateDom : lazyLoadCssClass");
				$("[data-lazy-class]").each(function() {
					var $self = $(this);
					var lazy = $self.attr("data-lazy-class").split(",");
					setTimeout(function() {
						$self.show().removeClass("hide").css({visibility: 'visible'}).addClass(lazy[0]);
					}, parseInt(lazy[1]));
				});
			};
		
			return {
				init : function() {
					rankColor();
					showNavigation();
					lazyLoadCssClass();
				}
			};
		}()),
		/**
		 * start ping
		 */
		ping = function() {
			if (locationPathname !== (PATH + '/video/search')) {
				setInterval(function() {
					$.getJSON({
						method: 'GET',
						url: PATH + '/rest/ping.json',
						data: {},
						cache: false
					}).done(function(noti) {
						if (noti.message !== "") {
							$(".noti").html(noti.message).show().hide("highlight", {color: "#ff0000"}, pingInterval);
							console.log("ping noti :", noti.message);
						}
					}).fail(function(jqxhr, textStatus, error) {
						console.log("ping : fail", textStatus + ", " + error);
					}).always(function() {
					});	
				}, pingInterval);
			}
		};
		
		return {
			ready : function(path, imageCount, searchVideoURL, searchActressURL, searchTorrentURL) {
				PATH = path;
				bgImageCount = parseInt(imageCount);
				urlSearchVideo   = searchVideoURL;
				urlSearchActress = searchActressURL;
				urlSearchTorrent = searchTorrentURL;
				
				themeSwitch = getLocalStorageItem(CRAZY_DECORATOR_THEME,  'normal');
				
			    crazy_listener.init();
			    crazy_manipulateDom.init();
			    ping();
			    toggleTheme(themeSwitch);
			    loading(false);
			}
		};
	}());

window.onerror = function(e) {
    console.error('Error', e);
    displayNotice('Error', e);
    loading(false);
};

/*
// 페이지 로드시 새로 캐쉬받아야 하는지 확인.
window.addEventListener('load', function(e) {

  window.applicationCache.addEventListener('updateready', function(e) {
    if (window.applicationCache.status == window.applicationCache.UPDATEREADY) {
      // 브라우저가 새 앱 캐시를 다운받는다. 
      // 캐시를 교체하고, 따끈따끈한 새 파일을 받기위해 페이지 리로드.
      window.applicationCache.swapCache();
      if (confirm('A new version of this site is available. Load it?')) {
        window.location.reload();
      }
    } else {
      // 메니페스트 파일이 바뀐게 없다. 제공할 새로운게 없음.
    }
  }, false);

}, false);
*/


