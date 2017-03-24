var browser;
var MSIE    = 'MSIE';
var CHROME  = 'Chrome';
var FIREFOX = 'Firefox';
var SAFARI  = 'Safari';

var agent = navigator.userAgent.toLowerCase();
if (/trident/.test(agent) || /msie/.test(agent))
	browser = MSIE;
else if (/chrome/.test(agent))
	browser = CHROME;
else if (/firefox/.test(agent))
	browser = FIREFOX;
else if (/safari/.test(agent))
	browser = SAFARI;
else 
	browser = 'Unknown';

var system;
var WINDOWS = 'Windows';
var LINUX   = 'Linux';
var MAC     = 'Macintosh';
var IPHONE  = 'iPhone';
var IPAD    = 'iPad';
var ANDROID = 'Android';

if (/Windows/.test(agent))
	system = WINDOWS;
else if (/windows/.test(agent))
	system = WINDOWS;
else if (/linux/.test(agent))
	system = LINUX;
else if (/macintosh/.test(agent))
	system = MAC;
else if (/iphone/.test(agent))
	system = IPHONE;
else if (/ipad/.test(agent))
	system = IPAD;
else if (/android/.test(agent))
	system = ANDROID;
else
	system = 'Unknown';


var DEFAULT_SPECS = "toolbar=0,location=0,directories=0,titlebar=0,status=0,menubar=0,scrollbars=1,resizable=1";

if (!String.prototype.startsWith) {
	String.prototype.startsWith = function(searchString, position) {
		position = position || 0;
		return this.substr(position, searchString.length) === searchString;
	};
}

/**
 * 팝업창을 띄운다. 
 * @param url
 * @param name '-'글자는 ''으로 바뀜
 * @param width if null, 화면 절반 크기
 * @param height if null, 화면 절반 크기
 * @param positionMethod if null, default is <code>Window.Center</code>. 1.<code>Window.Center</code> 화면 가운데 2.<code>Mouse</code> 마우스 위치. 
 * @param specs if null, default is <code>toolbar=0,location=0,directories=0,titlebar=0,status=0,menubar=0,scrollbars=1,resizable=1</code>
 */
function popup(url, name, width, height, positionMethod, specs, event) {
//	console.log("[popup] Call popup : ", url, name, width, height, positionMethod, specs, event);
	
	var windowScreenWidth  = window.screen.width;
	var windowScreenHeight = window.screen.height;
//	console.log("[popup] window.screen", window.screen);
	
	var vUrl = url;
	var vName = name.replace(/-/gi, '');
	if (!width)
		width = windowScreenWidth / 2;
	if (!height)
		height = windowScreenHeight / 2;
	var left = (windowScreenWidth  - width) / 2;
	var top  = (windowScreenHeight - height) / 2;
	if (positionMethod) {
		if(positionMethod == 'Center') {
		} 
		else if (positionMethod == 'Mouse') {
			try {
				left = event.screenX;
				top  = event.screenY;
			} catch(e) {
				console.log("[popup] warn event.screen", e);
			}
		}
	}
	if (!specs) {
		specs = DEFAULT_SPECS;
	}
	specs = "width="+width+",height="+height+",top="+top+",left="+left + "," + specs;

	try {
//		console.log("[popup] open param", vUrl, vName, specs);
		var popupWindow = window.open(vUrl, vName, specs);
//		console.log("[popup] open result", popupWindow);
		popupWindow.focus();
	} catch (e) {
		window.open(vUrl, vName, specs);
		console.log("[popup] error", e);
	}
}

function popupImage(url, name, event) {
//	console.log("[popupImage] event", event);
	if (!name)
		name = url;
	var img = new Image();
	img.src = url;
	img.onload = function() {
		var imgWidth  = this.width + 20;
		var imgHeight = this.height + 20;
//		console.log("[popupImage] popupImage", url, name, imgWidth + " x " + imgHeight);
		popup(url, name, imgWidth, imgHeight, 'Center', DEFAULT_SPECS, event);
	}
}

function fnViewFullImage(image) {
	var img = $("<img />");
	img.hide();
	img.attr("src", image.src);
	img.bind('load', function(){
		var imgWidth  = $(this).width() + 20;
		var imgHeight = $(this).height() + 20;
		console.log("[fnViewFullImage] size : " + imgWidth + " x " + imgHeight);
		mw_image_window(image, imgWidth, imgHeight);
	});
}
/**
 * 이미지 팝업을 띄운다. 화면보다 큰 이미지는 마우스 드래그 가능하게 함.
 * FIXME safari에서 win.document 를 찾지 못하는 오류
 * @param img 이미지 객체
 * @param w 이미지 가로 길이
 * @param h 이미지 세로 길이
 */
function mw_image_window(img, w, h)
{
	if (!w || !h)
	{
        w = img.width; 
        h = img.height; 
	}

	var winl = (screen.width-w)/2; 
	var wint = (screen.height-h)/3; 

	if (w >= screen.width) { 
		winl = 0; 
		h = (parseInt)(w * (h / w)); 
	} 

	if (h >= screen.height) { 
		wint = 0; 
		w = (parseInt)(h * (w / h)); 
	} 

	var js_url = "<script language='JavaScript1.2'> \n"; 
		js_url += "<!-- \n"; 
		js_url += "var ie=document.all; \n"; 
		js_url += "var nn6=document.getElementById&&!document.all; \n"; 
		js_url += "var isdrag=false; \n"; 
		js_url += "var x,y; \n"; 
		js_url += "var dobj; \n"; 
		js_url += "function movemouse(e) \n"; 
		js_url += "{ \n"; 
		js_url += "  if (isdrag) \n"; 
		js_url += "  { \n"; 
		js_url += "    dobj.style.left = nn6 ? tx + e.clientX - x : tx + event.clientX - x; \n"; 
		js_url += "    dobj.style.top  = nn6 ? ty + e.clientY - y : ty + event.clientY - y; \n"; 
		js_url += "    return false; \n"; 
		js_url += "  } \n"; 
		js_url += "} \n"; 
		js_url += "function selectmouse(e) \n"; 
		js_url += "{ \n"; 
		js_url += "  var fobj      = nn6 ? e.target : event.srcElement; \n"; 
		js_url += "  var topelement = nn6 ? 'HTML' : 'BODY'; \n"; 
		js_url += "  while (fobj.tagName != topelement && fobj.className != 'dragme') \n"; 
		js_url += "  { \n"; 
		js_url += "    fobj = nn6 ? fobj.parentNode : fobj.parentElement; \n"; 
		js_url += "  } \n"; 
		js_url += "  if (fobj.className=='dragme') \n"; 
		js_url += "  { \n"; 
		js_url += "    isdrag = true; \n"; 
		js_url += "    dobj = fobj; \n"; 
		js_url += "    tx = parseInt(dobj.style.left+0); \n"; 
		js_url += "    ty = parseInt(dobj.style.top+0); \n"; 
		js_url += "    x = nn6 ? e.clientX : event.clientX; \n"; 
		js_url += "    y = nn6 ? e.clientY : event.clientY; \n"; 
		js_url += "    document.onmousemove=movemouse; \n"; 
		js_url += "    return false; \n"; 
		js_url += "  } \n"; 
		js_url += "} \n"; 
		js_url += "document.onmousedown=selectmouse; \n"; 
		js_url += "document.onmouseup=new Function('isdrag=false'); \n"; 
		js_url += "//--> \n"; 
		js_url += "</"+"script> \n"; 

	var settings;
	var g4_is_gecko = true;
	if (g4_is_gecko) {
		settings  ='width='+(w+20)+','; 
		settings +='height='+(h+20)+','; 
	} else {
		settings  ='width='+w+','; 
		settings +='height='+h+','; 
	}
	settings +='top='+wint+','; 
	settings +='left='+winl+','; 
	settings +='scrollbars=no,'; 
	settings +='resizable=yes,'; 
	settings +='status=no'; 

	var g4_charset = "UTF-8";
	var click;
	var titleTooltip;
	var size = w + " x " + h;
	if(w >= screen.width || h >= screen.height) { 
		titleTooltip = size+" \n\n 이미지 사이즈가 화면보다 큽니다. \n 왼쪽 버튼을 클릭한 후 마우스를 움직여서 보세요. \n\n 더블 클릭하면 닫혀요.";
		click = "ondblclick='window.close();' style='cursor:move' "; 
	} 
	else {
		titleTooltip = size+" \n\n 클릭하면 닫혀요.";
		click = "onclick='window.close();' style='cursor:pointer' ";
	}
	var title = img.src + " " + titleTooltip;

	
	
	var imgWin = window.open("","image_window",settings); 
	alert(imgWin);
	var doc = imgWin.document;
	alert(doc);
	doc.open(); 
	doc.write ("<html><head> \n<meta http-equiv='imagetoolbar' CONTENT='no'> \n<meta http-equiv='content-type' content='text/html; charset="+g4_charset+"'>\n"); 
	doc.write ("<title>"+title+"</title> \n");
	if(w >= screen.width || h >= screen.height) { 
		doc.write (js_url); 
	} 
	doc.write ("<style>.dragme{position:relative;}</style> \n"); 
	doc.write ("</head> \n\n"); 
	doc.write ("<body leftmargin=0 topmargin=0 bgcolor=#dddddd style='cursor:arrow;'> \n"); 
	doc.write ("<table width=100% height=100% cellpadding=0 cellspacing=0><tr><td align=center valign=middle><img src='"+img.src+"' width='"+w+"' height='"+h+"' border=0 class='dragme' "+click+"></td></tr></table>");
	doc.write ("</body></html>"); 
	doc.close(); 

	if(parseInt(navigator.appVersion) >= 4){win.window.focus();} 

}

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
function mousewheel(event) {
/*
	console.log("event", event);
	console.log(navigator.userAgent.toLowerCase());
	console.log("event.originalEvent", event.originalEvent);
	console.log("event.originalEvent.wheelDelta", event.originalEvent.wheelDelta);
	console.log("event.originalEvent.detail", event.originalEvent.detail);
*/
	var E = event.originalEvent;
	var delta = 0;
	if (browser == IE || browser == CHROME) {
		delta = E.wheelDelta / 120;
	} else if (browser == SAFARI) {
		delta = E.wheelDelta / -12;
	} else if (browser == FIREFOX) {
		delta = E.detail / -3;
	}
	//console.log(delta);
	return delta;
}

/**
 * start부터 end사이의 random 정수 반환
 * @param start
 * @param end
 * @returns
 */
function getRandomInteger(start, end) {
	return Math.round(getRandom(start, end));
}

function getRandomBoolean() {
	return getRandomInteger(0, 1) == 0;
}

function getRandom(start, end) {
	return Math.random() * parseInt(end - start) + parseInt(start);
}

function randomColor(alpha) {
	if (!alpha)
		alpha = 1;
	else if (alpha === 'r')
		alpha = getRandomInteger(1, 100)/100;
	return "rgba(" + getRandomInteger(0,255) + "," + getRandomInteger(0,255) + "," + getRandomInteger(0,255) + "," + alpha + ")";
}

var GOOGLE_WEBFONTS = ['clipregular', 'Bahiana', 'Barrio', 'Caveat Brush', 'Indie Flower', 'Lobster', 'Gloria Hallelujah', 'Pacifico', 'Shadows Into Light', 'Baloo', 'Dancing Script', 'VT323', 'Acme', 'Alex Brush', 'Allura', 'Amatic SC', 'Architects Daughter', 'Audiowide', 'Bad Script', 'Bangers', 'BenchNine', 'Boogaloo', 'Bubblegum Sans', 'Calligraffitti', 'Ceviche One', 'Chathura', 'Chewy', 'Cinzel', 'Comfortaa', 'Coming Soon', 'Cookie', 'Covered By Your Grace', 'Damion', 'Economica', 'Freckle Face', 'Gochi Hand', 'Great Vibes', 'Handlee', 'Homemade Apple', 'Josefin Slab', 'Just Another Hand', 'Kalam', 'Kaushan Script', 'Limelight', 'Lobster Two', 'Marck Script', 'Monoton', 'Neucha', 'Nothing You Could Do', 'Oleo Script', 'Orbitron', 'Pathway Gothic One', 'Patrick Hand', 'Permanent Marker', 'Pinyon Script', 'Playball', 'Poiret One', 'Rajdhani', 'Rancho', 'Reenie Beanie', 'Righteous', 'Rock Salt', 'Sacramento', 'Satisfy', 'Shadows Into Light Two', 'Source Code Pro', 'Special Elite', 'Tangerine', 'Teko', 'Ubuntu Mono', 'Unica One', 'Yellowtail', 'Aclonica', 'Aladin', 'Allan', 'Allerta Stencil', 'Annie Use Your Telescope', 'Arizonia', 'Berkshire Swash', 'Bilbo Swash Caps', 'Black Ops One', 'Bungee Inline', 'Bungee Shade', 'Cabin Sketch', 'Chelsea Market', 'Clicker Script', 'Crafty Girls', 'Creepster', 'Diplomata SC', 'Ewert', 'Fascinate Inline', 'Finger Paint', 'Fontdiner Swanky', 'Fredericka the Great', 'Frijole', 'Give You Glory', 'Grand Hotel', 'Hanuman', 'Herr Von Muellerhoff', 'Italianno', 'Just Me Again Down Here', 'Knewave', 'Kranky', 'Kristi', 'La Belle Aurore', 'Leckerli One', 'Life Savers', 'Love Ya Like A Sister', 'Loved by the King', 'Merienda', 'Merienda One', 'Modak', 'Montez', 'Mountains of Christmas', 'Mouse Memoirs', 'Mr Dafoe', 'Mr De Haviland', 'Norican', 'Oregano', 'Over the Rainbow', 'Parisienne', 'Petit Formal Script', 'Pompiere', 'Press Start 2P', 'Qwigley', 'Raleway Dots', 'Rochester', 'Rouge Script', 'Schoolbell', 'Seaweed Script', 'Slackey', 'Sue Ellen Francisco', 'The Girl Next Door', 'UnifrakturMaguntia', 'Unkempt', 'Waiting for the Sunrise', 'Walter Turncoat', 'Wire One', 'Yesteryear', 'Zeyada', 'Aguafina Script', 'Akronim', 'Averia Sans Libre', 'Bilbo', 'Bungee Hairline', 'Bungee Outline', 'Cedarville Cursive', 'Codystar', 'Condiment', 'Cormorant Upright', 'Dawning of a New Day', 'Delius Unicase', 'Dorsa', 'Dynalight', 'Eagle Lake', 'Engagement', 'Englebert', 'Euphoria Script', 'Faster One', 'Flamenco', 'Glass Antiqua', 'Griffy', 'Henny Penny', 'Irish Grover', 'Italiana', 'Jolly Lodger', 'Joti One', 'Julee', 'Kenia', 'Kite One', 'Kumar One Outline', 'League Script', 'Lemonada', 'Londrina Outline', 'Lovers Quarrel', 'Meddon', 'MedievalSharp', 'Medula One', 'Meie Script', 'Miniver', 'Molle:400i', 'Monofett', 'Monsieur La Doulaise', 'Montserrat Subrayada', 'Mrs Saint Delafield', 'Mystery Quest', 'New Rocker', 'Nosifer', 'Nova Mono', 'Piedra', 'Quintessential', 'Ribeye', 'Ruthie', 'Rye', 'Sail', 'Sancreek', 'Sarina', 'Snippet', 'Sofia', 'Stalemate', 'Sunshiney', 'Swanky and Moo Moo', 'Titan One', 'Trade Winds', 'Tulpen One', 'UnifrakturCook:700', 'Vampiro One', 'Vast Shadow', 'Vibur', 'Wallpoet', 'Almendra Display', 'Almendra SC', 'Arbutus', 'Astloch', 'Aubrey', 'Bigelow Rules', 'Bonbon', 'Butcherman', 'Butterfly Kids', 'Caesar Dressing', 'Devonshire', 'Diplomata', 'Dr Sugiyama', 'Eater', 'Elsie Swash Caps', 'Fascinate', 'Felipa', 'Flavors', 'Gorditas', 'Hanalei', 'Hanalei Fill', 'Jacques Francois Shadow', 'Jim Nightshade', 'Lakki Reddy', 'Londrina Shadow', 'Londrina Sketch', 'Macondo Swash Caps', 'Miltonian', 'Miltonian Tattoo', 'Miss Fajardose', 'Mr Bedfort', 'Mrs Sheppards', 'Nova Script', 'Original Surfer', 'Princess Sofia', 'Ravi Prakash', 'Ribeye Marrow', 'Risque', 'Romanesco', 'Ruge Boogie', 'Sevillana', 'Sirin Stencil', 'Smokum', 'Snowburst One', 'Underdog'];

function randomFont() {
	var selectedFont = GOOGLE_WEBFONTS[getRandomInteger(0, GOOGLE_WEBFONTS.length)];
	
	var head  = document.getElementsByTagName('head')[0];
    var link  = document.createElement('link');
    link.rel  = 'stylesheet';
    link.href = 'https://fonts.googleapis.com/css?family=' + selectedFont;
    head.appendChild(link);

    return selectedFont;
}

function setlocalStorageItem(itemName, itemValue) {
	if (typeof(Storage) !== "undefined") {
		localStorage.setItem(itemName, itemValue);
	}
	else {
		// do nothing
	}
}
function getlocalStorageItem(itemName, notfoundDefault) {
	if (typeof(Storage) !== "undefined") {
		var _value = localStorage.getItem(itemName);
		if (_value == null || _value === 'NaN')
			return notfoundDefault;
		return _value;
	}
	else {
		return notfoundDefault;
	}
}

/**
 * ref. http://ohgyun.com/340
  1. 'f' + : 'f' 문자열에 뒤의 것을 더할 건데, // f
  2. Math.random() : 0~1 사이의 랜덤한 수 생성에  //  0.13190673617646098 
  3. * (1 << 30) : 2의 30승을 곱하고, //  0.13190673617646098  *  1073741824  = 141633779.5
  4. .toString(16) : 16진수로 문자열로 표현한 후에, // Number(141633779.9).toString(16) = 87128f3.8
  5. .replace('.', '') : 문자열에서 닷(소수점)을 제거한다. // 'f' + 87128f38 = f87128f38
 * @returns
 */
function guid() {
	return 'f' + (Math.random() * (1<<30)).toString(16).replace('.', '');
}
