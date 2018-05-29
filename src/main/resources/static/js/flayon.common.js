var agent = navigator.userAgent.toLowerCase(),
	MSIE    = 'MSIE',
	EDGE    = 'Edge',
	CHROME  = 'Chrome',
	FIREFOX = 'Firefox',
	SAFARI  = 'Safari',
	browser = /trident/.test(agent) || /msie/.test(agent) ? MSIE :
		/edge/.test(agent) ? EDGE : 
			/chrome/.test(agent) ? CHROME :
				/firefox/.test(agent) ? FIREFOX :
					/safari/.test(agent) ? SAFARI :'Unknown',
	WINDOWS = 'Windows',
	LINUX   = 'Linux',
	MAC     = 'Macintosh',
	IPHONE  = 'iPhone',
	IPAD    = 'iPad',
	ANDROID = 'Android',
	system = /Windows/.test(agent) ? WINDOWS :
		/linux/.test(agent) ? LINUX :
			/macintosh/.test(agent) ? MAC :
				/iphone/.test(agent) ? IPHONE :
					/ipad/.test(agent) ? IPAD :
						/android/.test(agent) ? ANDROID : 'Unknown',
	DEFAULT_SPECS = "toolbar=0,location=0,directories=0,titlebar=0,status=0,menubar=0,scrollbars=1,resizable=1",
	/**
	 * 팝업창을 띄운다. 
	 * @param url
	 * @param name '-'글자는 ''으로 바뀜
	 * @param width if null, 화면 절반 크기
	 * @param height if null, 화면 절반 크기
	 * @param positionMethod if null, default is <code>Window.Center</code>. 1.<code>Window.Center</code> 화면 가운데 2.<code>Mouse</code> 마우스 위치. 
	 * @param specs if null, default is <code>toolbar=0,location=0,directories=0,titlebar=0,status=0,menubar=0,scrollbars=1,resizable=1</code>
	 */
	popup = function(url, name, width, height, positionMethod, specs, event) {
		//console.log("[popup] Call popup : ", url, name, width, height, positionMethod, specs, event);
		var windowScreenWidth  = window.screen.width,
			windowScreenHeight = window.screen.height;
		var	left, top;
		
		name = name.replace(/-/gi, '');
		width = width || windowScreenWidth / 2;
		height = height || windowScreenHeight / 2;
		if (positionMethod && positionMethod === 'Mouse') {
			left = event.screenX; 
			top  = event.screenY;
		} else {
			left = (windowScreenWidth  - width) / 2; 
			top  = (windowScreenHeight - height) / 2;
		}
		specs = "width=" + width + ",height=" + height + ",top=" + top + ",left=" + left + "," + (specs || DEFAULT_SPECS);
	
		var popupWindow = window.open(url, name, specs);
		if (popupWindow) {
			popupWindow.focus();
		}
	},
	popupImage = function(url, name, event) {
		var img = new Image();
		img.onload = function() {
			popup(PATH + '/html/image/image.html?src=' + url, name || url, this.naturalWidth, this.naturalHeight, 'Center');
		};
		img.src = url;
	},
	popupImageByNo = function(no, name) {
		var img = new Image();
		img.onload = function() {
			popup(PATH + '/html/image/image.html?p=' + PATH + '&no=' + no, name || 'image' + no, this.naturalWidth, this.naturalHeight, 'Center');
		};
		img.src = PATH + '/image/' + no;
	},
	/**
	 * @return 1 : wheel up, -1 : wheel down, 0 : undetermined
	 * <pre>
	 * E = event.originalEvent;
	 * [E.wheelDelta]
	 * IE : up 120, dn -120
	 * Chrome : up 120, dn -120
	 * Safari : up -12, dn 12   when 스크롤방향 자연스럽게 일 경우.
	 * 
	 * [E.detail]
	 * Firefox : up undefined -3, dn undefined 3
	 * </pre>
	 */
	mousewheel = function(event) {
	/*	console.log("event", event);
		console.log(navigator.userAgent.toLowerCase());
		console.log("event.originalEvent", event.originalEvent);
		console.log("event.originalEvent.wheelDelta", event.originalEvent.wheelDelta);
		console.log("event.originalEvent.detail", event.originalEvent.detail); 
	 */
	//	var E = event.originalEvent;
		return browser == MSIE || browser == CHROME ? event.originalEvent.wheelDelta / 120 :
			browser == SAFARI ? event.originalEvent.wheelDelta / -12 :
				browser == FIREFOX ? event.originalEvent.detail / -3 : 0;
	/*	var delta = 0;
		if (browser == MSIE || browser == CHROME) {
			delta = E.wheelDelta / 120;
		} else if (browser == SAFARI) {
			delta = E.wheelDelta / -12;
		} else if (browser == FIREFOX) {
			delta = E.detail / -3;
		}
		//console.log(delta);
		return delta; */
	},
	/**
	 * mouse click event wrapper
	 * @param event
	 * @returns left = 1001, middle = 1002, right = 1003 
	 */
	mouseClick = function(event) {
		return event.which + 1000;
	},
	/**
	 * start부터 end사이의 random 정수 반환
	 * @param start
	 * @param end
	 * @returns
	 */
	getRandomInteger = function(start, end) {
		return Math.round(getRandom(start, end));
	},
	getRandomHex = function(start, end) {
		return getRandomInteger(start, end).toString(16);
	},
	getRandomBoolean = function() {
		return getRandomInteger(1, 2) === 1;
	},
	getRandom = function(start, end) {
		return Math.random() * (end - start) + start;
	},
	getRandomFont = function(selectedFont) {
		var GOOGLE_FONTAPI = 'https://fonts.googleapis.com/css?family=',
			GOOGLE_WEBFONTS = ['clipregular', 'Bahiana', 'Barrio', 'Caveat Brush', 'Indie Flower', 'Lobster', 'Gloria Hallelujah', 'Pacifico', 'Shadows Into Light', 'Baloo', 'Dancing Script', 'VT323', 'Acme', 'Alex Brush', 'Allura', 'Amatic SC', 'Architects Daughter', 'Audiowide', 'Bad Script', 'Bangers', 'BenchNine', 'Boogaloo', 'Bubblegum Sans', 'Calligraffitti', 'Ceviche One', 'Chathura', 'Chewy', 'Cinzel', 'Comfortaa', 'Coming Soon', 'Cookie', 'Covered By Your Grace', 'Damion', 'Economica', 'Freckle Face', 'Gochi Hand', 'Great Vibes', 'Handlee', 'Homemade Apple', 'Josefin Slab', 'Just Another Hand', 'Kalam', 'Kaushan Script', 'Limelight', 'Lobster Two', 'Marck Script', 'Monoton', 'Neucha', 'Nothing You Could Do', 'Oleo Script', 'Orbitron', 'Pathway Gothic One', 'Patrick Hand', 'Permanent Marker', 'Pinyon Script', 'Playball', 'Poiret One', 'Rajdhani', 'Rancho', 'Reenie Beanie', 'Righteous', 'Rock Salt', 'Sacramento', 'Satisfy', 'Shadows Into Light Two', 'Source Code Pro', 'Special Elite', 'Tangerine', 'Teko', 'Ubuntu Mono', 'Unica One', 'Yellowtail', 'Aclonica', 'Aladin', 'Allan', 'Allerta Stencil', 'Annie Use Your Telescope', 'Arizonia', 'Berkshire Swash', 'Bilbo Swash Caps', 'Black Ops One', 'Bungee Inline', 'Bungee Shade', 'Cabin Sketch', 'Chelsea Market', 'Clicker Script', 'Crafty Girls', 'Creepster', 'Diplomata SC', 'Ewert', 'Fascinate Inline', 'Finger Paint', 'Fontdiner Swanky', 'Fredericka the Great', 'Frijole', 'Give You Glory', 'Grand Hotel', 'Hanuman', 'Herr Von Muellerhoff', 'Italianno', 'Just Me Again Down Here', 'Knewave', 'Kranky', 'Kristi', 'La Belle Aurore', 'Leckerli One', 'Life Savers', 'Love Ya Like A Sister', 'Loved by the King', 'Merienda', 'Merienda One', 'Modak', 'Montez', 'Mountains of Christmas', 'Mouse Memoirs', 'Mr Dafoe', 'Mr De Haviland', 'Norican', 'Oregano', 'Over the Rainbow', 'Parisienne', 'Petit Formal Script', 'Pompiere', 'Press Start 2P', 'Qwigley', 'Raleway Dots', 'Rochester', 'Rouge Script', 'Schoolbell', 'Seaweed Script', 'Slackey', 'Sue Ellen Francisco', 'The Girl Next Door', 'UnifrakturMaguntia', 'Unkempt', 'Waiting for the Sunrise', 'Walter Turncoat', 'Wire One', 'Yesteryear', 'Zeyada', 'Aguafina Script', 'Akronim', 'Averia Sans Libre', 'Bilbo', 'Bungee Hairline', 'Bungee Outline', 'Cedarville Cursive', 'Codystar', 'Condiment', 'Cormorant Upright', 'Dawning of a New Day', 'Delius Unicase', 'Dorsa', 'Dynalight', 'Eagle Lake', 'Engagement', 'Englebert', 'Euphoria Script', 'Faster One', 'Flamenco', 'Glass Antiqua', 'Griffy', 'Henny Penny', 'Irish Grover', 'Italiana', 'Jolly Lodger', 'Joti One', 'Julee', 'Kenia', 'Kite One', 'Kumar One Outline', 'League Script', 'Lemonada', 'Londrina Outline', 'Lovers Quarrel', 'Meddon', 'MedievalSharp', 'Medula One', 'Meie Script', 'Miniver', 'Molle:400i', 'Monofett', 'Monsieur La Doulaise', 'Montserrat Subrayada', 'Mrs Saint Delafield', 'Mystery Quest', 'New Rocker', 'Nosifer', 'Nova Mono', 'Piedra', 'Quintessential', 'Ribeye', 'Ruthie', 'Rye', 'Sail', 'Sancreek', 'Sarina', 'Snippet', 'Sofia', 'Stalemate', 'Sunshiney', 'Swanky and Moo Moo', 'Titan One', 'Trade Winds', 'Tulpen One', 'UnifrakturCook:700', 'Vampiro One', 'Vast Shadow', 'Vibur', 'Wallpoet', 'Almendra Display', 'Almendra SC', 'Arbutus', 'Astloch', 'Aubrey', 'Bigelow Rules', 'Bonbon', 'Butcherman', 'Butterfly Kids', 'Caesar Dressing', 'Devonshire', 'Diplomata', 'Dr Sugiyama', 'Eater', 'Elsie Swash Caps', 'Fascinate', 'Felipa', 'Flavors', 'Gorditas', 'Hanalei', 'Hanalei Fill', 'Jacques Francois Shadow', 'Jim Nightshade', 'Lakki Reddy', 'Londrina Shadow', 'Londrina Sketch', 'Macondo Swash Caps', 'Miltonian', 'Miltonian Tattoo', 'Miss Fajardose', 'Mr Bedfort', 'Mrs Sheppards', 'Nova Script', 'Original Surfer', 'Princess Sofia', 'Ravi Prakash', 'Ribeye Marrow', 'Risque', 'Romanesco', 'Ruge Boogie', 'Sevillana', 'Sirin Stencil', 'Smokum', 'Snowburst One', 'Underdog'],
		selectedFont = selectedFont || GOOGLE_WEBFONTS[getRandomInteger(0, GOOGLE_WEBFONTS.length-1)];
		var link  = document.createElement('link');
	    link.rel  = 'stylesheet';
	    link.href = GOOGLE_FONTAPI + selectedFont;
	    document.getElementsByTagName('head')[0].appendChild(link);
	    return selectedFont;
	},
	getRandomColor = function(alpha) {
		/*if (!alpha)
			alpha = 1;
		else if (alpha === 'r')
			alpha = getRandom(0, 1);
		alpha 
			? 1 
			: alpha === 'r' 
				? getRandom(0, 1) 
				: alpha */
		if (alpha)
			return "rgba(" 
					+ getRandomInteger(0,255) + "," 
					+ getRandomInteger(0,255) + "," 
					+ getRandomInteger(0,255) + "," 
					+ (alpha === 'r' ? getRandom(0, 1) : alpha) + ")";
		else
			return "#" + getRandomHex(0, 255).zf(2) + getRandomHex(0, 255).zf(2) + getRandomHex(0, 255).zf(2);
	},
	setLocalStorageItem = function(itemName, itemValue) {
		typeof(Storage) !== "undefined" && localStorage.setItem(itemName, itemValue);
	},
	getLocalStorageItem = function(itemName, notfoundDefault) {
		return typeof(Storage) !== "undefined" && (localStorage.getItem(itemName) || notfoundDefault);
	},
	getLocalStorageItemInteger = function(itemName, notfoundDefault) {
		return parseInt(getLocalStorageItem(itemName, notfoundDefault));
	},
	getLocalStorageItemBoolean = function(itemName, notfoundDefault) {
		return getLocalStorageItem(itemName, notfoundDefault.toString()) === 'true';
	},
	/**
	 * ref. http://ohgyun.com/340
	  1. 'f' + : 'f' 문자열에 뒤의 것을 더할 건데, // f
	  2. Math.random() : 0~1 사이의 랜덤한 수 생성에  //  0.13190673617646098 
	  3. * (1 << 30) : 2의 30승을 곱하고, //  0.13190673617646098  *  1073741824  = 141633779.5
	  4. .toString(16) : 16진수로 문자열로 표현한 후에, // Number(141633779.9).toString(16) = 87128f3.8
	  5. .replace('.', '') : 문자열에서 닷(소수점)을 제거한다. // 'f' + 87128f38 = f87128f38
	 * @returns
	 */
	guid = function() {
		return 'f' + (Math.random() * (1<<30)).toString(16).replace('.', '');
	},
	compareTo = function(data1, data2, reverse) {
		return (typeof data1 === 'number' ? data1 - data2 :
			typeof data1 === 'string' ? data1.toLowerCase() > data2.toLowerCase() ? 1 : -1 :
				typeof data1 === 'boolean' ? data1 ? 1 : (data2 ? -1 : 0) :
					data1 > data2 ? 1 : -1) * (reverse ? -1 : 1) 
	/*	var result = 0;
		if (typeof data1 === 'number') {
			result = data1 - data2;
		} else if (typeof data1 === 'string') {
			result = data1.toLowerCase() > data2.toLowerCase() ? 1 : -1;
		} else if (typeof data1 === 'boolean') {
			result = data1 ? 1 : (data2 ? -1 : 0);
		} else {
			result = data1 > data2 ? 1 : -1;
		}
		return result * (reverse ? -1 : 1); */
	},
	pad = function(n, width) {
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
	},
	reqParam = location.search.split(/[?&]/).slice(1).map(function(paramPair) {
		return paramPair.split(/=(.+)?/).slice(0, 2);
	}).reduce(function(obj, pairArray) {
		obj[pairArray[0]] = pairArray[1];
		return obj;
	}, {}),
	stopEvent = function(event) {
		event.stopImmediatePropagation();
		event.preventDefault();
		event.stopPropagation();
	},
	capitalize = function(str) {
		return str.replace(/\w\S*/g, function(txt) {
			return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
		});
	},
	KB = 1024,
	MB = KB * KB,
	GB = MB * KB,
	TB = GB * KB,
	toFixed = function(num, x) {
		return num.toFixed(x);
	},
	formatFileSize = function(length) {
		if (typeof length === 'string')
			length = parseInt(length);
		if (length < KB)
			return length + " B";
		else if (length < MB)
			return toFixed(length / KB, 0) + " kB";
		else if (length < GB)
			return toFixed(length / MB, 1) + " MB";
		else if (length < TB)
			return toFixed(length / GB, 2) + " GB";
		else
			return length;
	};


!String.prototype.startsWith && (String.prototype.startsWith = function(searchString, position) {
	return this.substr(position || 0, searchString.length) === searchString;
});

/**
 * http://stove99.tistory.com/46
 */
Date.prototype.format = function(f) {
    if (!this.valueOf()) return " ";
 
    var weekName = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
    var d = this;
     
    return f.replace(/(yyyy|yy|MM|dd|E|hh|mm|ss|a\/p)/gi, function($1) {
        switch ($1) {
            case "yyyy": return d.getFullYear();
            case "yy": return (d.getFullYear() % 1000).zf(2);
            case "MM": return (d.getMonth() + 1).zf(2);
            case "dd": return d.getDate().zf(2);
            case "E": return weekName[d.getDay()];
            case "HH": return d.getHours().zf(2);
            case "hh": return ((h = d.getHours() % 12) ? h : 12).zf(2);
            case "mm": return d.getMinutes().zf(2);
            case "ss": return d.getSeconds().zf(2);
            case "a/p": return d.getHours() < 12 ? "오전" : "오후";
            default: return $1;
        }
    });
};
 
String.prototype.string = function(len){var s = '', i = 0; while (i++ < len) { s += this; } return s;};
String.prototype.zf = function(len){return "0".string(len - this.length) + this;};
Number.prototype.zf = function(len){return this.toString().zf(len);};
