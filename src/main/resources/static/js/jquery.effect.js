/**
 * 
 */
// 함수 정의의 시작 부준에 세미콜론(;)을 추가하는 것은
// 다른 개발자들이 개발한 라이브러리의 종료 부분에 세미콜론이 누락된 상황을 대비하기 위한 것이다.
;(function($) {
	$.fn.pulse = function(options) {

		var opts = $.extend({}, $.fn.pulse.defaults, options);
		// jQuery.extend( target [, object1] [, objectN] ) Returns : Object
		// 두개 이상의 객체를 합치기 위해 $.extend() 함수를 사용한다.
		// 이 과정에서 같은 이름의 프로퍼티가 있을땐 가장 나중에 병합되는 오브젝트가 우선권을 갖는다. 즉, 덮어쓰게 된다.

		// jQuery.extend( target [, object1] [, objectN] )
		// target : 합쳐지는 추가 객체의 속성을 받을 객체 또는 유일한 인자일 경우 jQuery 네임스페이스로 확장될 객체
		// object1 : 합쳐질 때 기준이 될 객체
		// objectN : 기준 객체에 합쳐질 추가 객체

		// jQuery.extend( [deep], target, object1 [, objectN] )
		// deep true 라면, 깊은 수준 복사가 된다.

		// 참고 사이트 : https://api.jquery.com/jquery.extend/

		// 개별 요소에 접근할 필요가 있다면 .each() 활용
		// 흔히 아래와 같이 return this.each(function() {})로 사용함
		return this.each(function() {
			// Pulse 기능이 시작된다.
			for (var i = 0; i < opts.pulses; i++) {
				$(this).fadeTo(opts.speed, opts.fadeLow).fadeTo(opts.speed, opts.fadeHigh);
			}
			// 원래의 상태로 재설정한다.
			$(this).fadeTo(opts.speed, 1);
		});
		// return을 해서 체인으로 사용가능하도록 한다.
	}

	// Pulse 플러그인의 기본 옵션들이다.
	$.fn.pulse.defaults = {
		speed : "slow",
		pulses : 2,
		fadeLow : 0.2,
		fadeHigh : 1
	};

})(jQuery);
// 플러그인에서 $ 단축표현 사용하기
// jQuery는 jQuery 개체를 위한 사용자 정의 별칭으로써 $ 함수를 사용하고 있다.
// 하지만 jQuery가 호환성 모드로 설정되면 jQuery는 $을 정의하고 있는 다른 라이브러리에게로 $ 별칠에 대한 제어권을 양보한다.
// 플러그인도 동일한 기법을 사용하도록 작성될 수 있다.

// function ( $ ) { ... }( jQuery )); 사이에 넣어 스코프 형성
// 다음과 같이 익명함수로 자신의 플러그인을 둘러싼뒤 곧바로 그함수를 실행하는 방식으로 $ 단축표현을 플러그인 내부에서 유지되게 할 수 있다.
// 물론 플러그인 외부 코드에서도 $를 사용할 수는 있지만 플러그인 코드 내부에 있는 $만이 jQuery 개체를 참조할 것이다.

/* 사용 예시
$(function() {
	$('button').click(function() {
		$('p').pulse();
	});
});
*/