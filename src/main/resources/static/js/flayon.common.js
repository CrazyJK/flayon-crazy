var agent = navigator.userAgent.toLowerCase(),
	MSIE    = 'MSIE',
	CHROME  = 'Chrome',
	FIREFOX = 'Firefox',
	SAFARI  = 'Safari',
	browser = /trident/.test(agent) || /msie/.test(agent) ? MSIE :
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
			windowScreenHeight = window.screen.height,
			left, top, position;
		name = name.replace(/-/gi, '');
		width = width || windowScreenWidth / 2;
		height = height || windowScreenHeight / 2;
		try {
			positionMethod && positionMethod === 'Mouse' 
				? (position = {left: event.screenX, top: event.screenY})
				: (position = {left: (windowScreenWidth  - width) / 2, top: (windowScreenHeight - height) / 2});
		} catch(e) {
			console.log("[popup] warn event.screen", e);
		}
		specs = "width=" + width + ",height=" + height + ",top=" + position.top + ",left=" + position.left + "," + (specs || DEFAULT_SPECS);
	
		try {
			//console.log("[popup] open param", url, name, specs);
			var popupWindow = window.open(url, name, specs);
			popupWindow.focus();
		} catch (e) {
			console.log("[popup] error", e);
			window.open(url, name, specs);
		}
	},
	popupImage = function(url, name, event) {
		//console.log("[popupImage]", url, name, event);
		var img = new Image();
		img.src = url;
		img.onload = function() {
			popup(url, name || url, this.width + 20, this.height + 20, 'Center');
		}
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
	getRandomBoolean = function() {
		return getRandomInteger(1, 2) === 1;
	},
	getRandom = function(start, end) {
		return Math.random() * (end - start) + start;
	},
	randomFont = function(selectedFont) {
		var GOOGLE_WEBFONTS = ['clipregular', 'Bahiana', 'Barrio', 'Caveat Brush', 'Indie Flower', 'Lobster', 'Gloria Hallelujah', 'Pacifico', 'Shadows Into Light', 'Baloo', 'Dancing Script', 'VT323', 'Acme', 'Alex Brush', 'Allura', 'Amatic SC', 'Architects Daughter', 'Audiowide', 'Bad Script', 'Bangers', 'BenchNine', 'Boogaloo', 'Bubblegum Sans', 'Calligraffitti', 'Ceviche One', 'Chathura', 'Chewy', 'Cinzel', 'Comfortaa', 'Coming Soon', 'Cookie', 'Covered By Your Grace', 'Damion', 'Economica', 'Freckle Face', 'Gochi Hand', 'Great Vibes', 'Handlee', 'Homemade Apple', 'Josefin Slab', 'Just Another Hand', 'Kalam', 'Kaushan Script', 'Limelight', 'Lobster Two', 'Marck Script', 'Monoton', 'Neucha', 'Nothing You Could Do', 'Oleo Script', 'Orbitron', 'Pathway Gothic One', 'Patrick Hand', 'Permanent Marker', 'Pinyon Script', 'Playball', 'Poiret One', 'Rajdhani', 'Rancho', 'Reenie Beanie', 'Righteous', 'Rock Salt', 'Sacramento', 'Satisfy', 'Shadows Into Light Two', 'Source Code Pro', 'Special Elite', 'Tangerine', 'Teko', 'Ubuntu Mono', 'Unica One', 'Yellowtail', 'Aclonica', 'Aladin', 'Allan', 'Allerta Stencil', 'Annie Use Your Telescope', 'Arizonia', 'Berkshire Swash', 'Bilbo Swash Caps', 'Black Ops One', 'Bungee Inline', 'Bungee Shade', 'Cabin Sketch', 'Chelsea Market', 'Clicker Script', 'Crafty Girls', 'Creepster', 'Diplomata SC', 'Ewert', 'Fascinate Inline', 'Finger Paint', 'Fontdiner Swanky', 'Fredericka the Great', 'Frijole', 'Give You Glory', 'Grand Hotel', 'Hanuman', 'Herr Von Muellerhoff', 'Italianno', 'Just Me Again Down Here', 'Knewave', 'Kranky', 'Kristi', 'La Belle Aurore', 'Leckerli One', 'Life Savers', 'Love Ya Like A Sister', 'Loved by the King', 'Merienda', 'Merienda One', 'Modak', 'Montez', 'Mountains of Christmas', 'Mouse Memoirs', 'Mr Dafoe', 'Mr De Haviland', 'Norican', 'Oregano', 'Over the Rainbow', 'Parisienne', 'Petit Formal Script', 'Pompiere', 'Press Start 2P', 'Qwigley', 'Raleway Dots', 'Rochester', 'Rouge Script', 'Schoolbell', 'Seaweed Script', 'Slackey', 'Sue Ellen Francisco', 'The Girl Next Door', 'UnifrakturMaguntia', 'Unkempt', 'Waiting for the Sunrise', 'Walter Turncoat', 'Wire One', 'Yesteryear', 'Zeyada', 'Aguafina Script', 'Akronim', 'Averia Sans Libre', 'Bilbo', 'Bungee Hairline', 'Bungee Outline', 'Cedarville Cursive', 'Codystar', 'Condiment', 'Cormorant Upright', 'Dawning of a New Day', 'Delius Unicase', 'Dorsa', 'Dynalight', 'Eagle Lake', 'Engagement', 'Englebert', 'Euphoria Script', 'Faster One', 'Flamenco', 'Glass Antiqua', 'Griffy', 'Henny Penny', 'Irish Grover', 'Italiana', 'Jolly Lodger', 'Joti One', 'Julee', 'Kenia', 'Kite One', 'Kumar One Outline', 'League Script', 'Lemonada', 'Londrina Outline', 'Lovers Quarrel', 'Meddon', 'MedievalSharp', 'Medula One', 'Meie Script', 'Miniver', 'Molle:400i', 'Monofett', 'Monsieur La Doulaise', 'Montserrat Subrayada', 'Mrs Saint Delafield', 'Mystery Quest', 'New Rocker', 'Nosifer', 'Nova Mono', 'Piedra', 'Quintessential', 'Ribeye', 'Ruthie', 'Rye', 'Sail', 'Sancreek', 'Sarina', 'Snippet', 'Sofia', 'Stalemate', 'Sunshiney', 'Swanky and Moo Moo', 'Titan One', 'Trade Winds', 'Tulpen One', 'UnifrakturCook:700', 'Vampiro One', 'Vast Shadow', 'Vibur', 'Wallpoet', 'Almendra Display', 'Almendra SC', 'Arbutus', 'Astloch', 'Aubrey', 'Bigelow Rules', 'Bonbon', 'Butcherman', 'Butterfly Kids', 'Caesar Dressing', 'Devonshire', 'Diplomata', 'Dr Sugiyama', 'Eater', 'Elsie Swash Caps', 'Fascinate', 'Felipa', 'Flavors', 'Gorditas', 'Hanalei', 'Hanalei Fill', 'Jacques Francois Shadow', 'Jim Nightshade', 'Lakki Reddy', 'Londrina Shadow', 'Londrina Sketch', 'Macondo Swash Caps', 'Miltonian', 'Miltonian Tattoo', 'Miss Fajardose', 'Mr Bedfort', 'Mrs Sheppards', 'Nova Script', 'Original Surfer', 'Princess Sofia', 'Ravi Prakash', 'Ribeye Marrow', 'Risque', 'Romanesco', 'Ruge Boogie', 'Sevillana', 'Sirin Stencil', 'Smokum', 'Snowburst One', 'Underdog'],
		selectedFont = selectedFont || GOOGLE_WEBFONTS[getRandomInteger(0, GOOGLE_WEBFONTS.length)];
		var link  = document.createElement('link');
	    link.rel  = 'stylesheet';
	    link.href = 'https://fonts.googleapis.com/css?family=' + selectedFont;
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
		return "rgba(" + getRandomInteger(0,255) + "," + getRandomInteger(0,255) + "," + getRandomInteger(0,255) + "," + (alpha ? alpha : alpha === 'r' ? getRandom(0, 1) : 1) + ")";
	},
	setLocalStorageItem = function(itemName, itemValue) {
		typeof(Storage) !== "undefined" && localStorage.setItem(itemName, itemValue);
	},
	getLocalStorageItem = function(itemName, notfoundDefault) {
		return typeof(Storage) !== "undefined" && (localStorage.getItem(itemName) || notfoundDefault);
	/*	if (typeof(Storage) !== "undefined") {
			var _value = localStorage.getItem(itemName);
			if (_value == null || _value === 'NaN' || _value === 'undefined')
				return notfoundDefault;
			return _value;
		}
		else {
			return notfoundDefault;
		} */
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
	}, {});

!String.prototype.startsWith && (String.prototype.startsWith = function(searchString, position) {
		return this.substr(position || 0, searchString.length) === searchString;
});