## Javascript : function review


함수는 first-class object, first-class citizen, first-class value 다
    first-class object는 변수에 저장할 수 있어야 합니다.
    first-class object는 함수의 파라미터로 전달할 수 있어야 합니다.
    first-class object는 함수의 반환값으로 사용할 수 있어야 합니다.
    first-class object는 자료 구조에 저장할 수 있어야 합니다.


함수 정의 방법
    Function 객체 사용한 정의 : 많이 사용되지 않음
    function 연산자 이용한 함수 정의 : 함수선언식(function declaration)과 함수표현식(function expression)으로 구분

        1. 함수선언식(function declaration)
        function company() {  
            /* 실행코드 */
        }
        함수선언식 함수는 인터프리터가 스크립트 로딩시점에 바로 초기화하고 VO(variable object)에 저장
        함수선언식 함수가 많은 대규모에선 인터프리터가 저장해야할 VO가 많아 성능저하의 단점이 있다. 

        2. 함수표현식(function expression);

        // 기명 함수표현식(named function expression) 
        var company = function company() {  
            /* 실행코드 */
        }; 
        함수 이름으로 호출되지 않지만, 에러 발생시 stack trace가 출력되어 에러 확인이 용이.

        // 익명 함수표현식(anonymous function expression)
        var company = function() {  
            /* 실행코드 */
        };

        // 기명 즉시실행함수(named immediately-invoked function expression)
        (function company() {
            /* 실행코드 */
        }());

        // 익명 즉시실행함수(immediately-invoked function expression)
        // Javascript 대가이신 더글라스 클락포트의 권장 표기법
        (function() {
            /* 실행코드 */
        }());

        // 익명 즉시실행함수(immediately-invoked function expression)
        (function() {
            /* 실행코드 */
        })();
        
        함수표현식 함수는 runtime시에 해석/실행된다. 

            notHoisted(); // TypeError: notHoisted is not a function
             
            var notHoisted = function() {
               console.log("bar");
            };


즉시실행함수(Immediately-invoked function expression)
    한번의 실행만 필요로 하는 초기화 코드 부분에 많이 사용
    // 즉시실행함수
    (function() {
        console.log('함수 호출'); // "함수 호출" 출력
    }());
        
    변수를 선언하고 이 변수에 즉시실행함수를 할당
        var app = (function() {  
            var privateVar = 'private';
            return {
                prop : privateVar
            };
        }());
        console.log(app.prop); // "private" 출력  
        외부에서 함수내 변수 접근 통제. 글로벌 네임스페이스에 변수 추가하지 않아도 되므로, 플러그인이나 라이브러리 만들때 사용

    파라미터 전달 방식
        var buyCar = function(carName) {  
            // "내가 구매한 차는 sonata입니다." 출력
            console.log('내가 구매한 차는 ' + carName + '입니다.');
        };
        buyCar('sonata');

        (function(carName) {
            // "내가 구매한 차는 sonata입니다." 출력
            console.log('내가 구매한 차는 ' + carName + '입니다.');
        }('sonata'));

    jQuery, Prototype에서 $ 사용 충돌 예방
        (function($) {
            // 함수 스코프 내에서 $는 jQuery Object임. Prototype의 $ 변수에 대한 overwritting을 예방
            console.log($);
        }(jQuery));

모듈 패턴(Module Pattern)
    자바스크립트 함수의 특징을 이용한 모듈화 : 대규모 애플리케이션이나 데스크탑 애플리케이션의 모습을 닮아가는 형태(Rich Internet Application)에서 복잡성, 유지보수 이슈
    즉시실행함수는 우리가 작성한 코드들 뿐만 아니라 함께 사용하는 외부 라이브러리와도 충돌없이 구동하는 샌드박스(sandbox)를 제공
    특징과 단위기능별로 작성된 코드를 분리된 개별 파일 형태로 유지한다면 모듈화를 위한 조건 해결

    var clerk = (function() {  
        var name = 'Teo';
        var sex = '남자';
        var position = '수석 엔지니어';
        // salary private
        var salary = 2000;
        var taxSalary = 200;
        var totalBonus = 100;
        var taxBonus = 10;

        var paySalary = function() {
            return salary - taxSalary;
        };
        var payBonus = function() {
            totalBonus = totalBonus - taxBonus;
            return totalBonus;
        };

        // Public 속성, 메소드
        return {
            name : name,
            sex : sex,                 
            position : position,
            paySalary : paySalary,
            payBonus : payBonus
        };
    }());
    즉시실행함수의 반환값이 clerk변수에 저장!
    // name 속성은 public
    console.log(clerk.name); // 'Teo' 출력  
    // salary 변수는 즉시실행함수 내부 변수이므로 private
    console.log(clerk.salary); // undefined 출력

    // paySalary 메소드는 public
    console.log(clerk.paySalary()); // 1800 출력

    // payBonus 메소드는 public
    console.log(clerk.payBonus()); // 90 출력  
    console.log(clerk.payBonus()); // 80 출력  
    totalBouns 변수의 값이 업데이트

    모듈 작성시 코드 순서
        1. 모듈 스코프 내에서 사용할 변수 작성
        2. 유틸리티 메소드 작성
        3. DOM 조작 메소드 작성
        4. 이벤트 핸들러 작성
        5. Public 메소드 작성
            // SPA 모듈 작성 순서 예시
            var app = (function() {

                // 1. 모듈 스코프 내에서 사용할 변수 작성
                var scopeVar = {};
                var utilMethod;
                var manipulateDom;
                var eventHandle;
                var initModule;

                // 2. 유틸리티 메소드 작성
                utilMethod = function() {
                    // 실행코드
                };

                // 3. DOM 조작 메소드 작성
                manipulateDom = function() {
                    // 실행코드
                };

                // 4. 이벤트 핸들러 작성
                eventHandle = function() {
                    // 실행코드
                };

                // Public 메소드 작성
                initModule = function() {
                    // 실행코드
                };

                return {
                    init : initModule
                };
            }());

    라이브러리를 모듈화하는 코딩기법
    
        /**
         * Library 모듈화를 위한 코딩기법 1
         * call 함수 이용
         */
        (function() {
            'use strict';
            var root = this;
            var version = '1.0';
            var Module1;
            if(typeof exports !== 'undefined') {
                Module1 = exports;
            } else {
                Module1 = root.Module1 = {};
            }
            Module1.getVersion = function() {
                return version;
            }
        }).call(this);
        console.log(Module1.getVersion());

        /**
         * Library 모듈화를 위한 코딩기법 2
         * 글로벌 객체를 파라미터로 전달
         */
        (function(global) {
            var root = global;
            var version = '1.0';
            var Module2;
            if(typeof exports !== 'undefined') {
                Module2 = exports;
            } else {
                Module2 = root.Module2 = {};
            }
            Module2.getVersion = function() {
                return version;
            }
        }(this));
        console.log(Module2.getVersion());

        /**
         * Library 모듈화를 위한 코딩기법 3
         * 즉시실행함수 내부에서 글로벌 객체를 내부 변수에 할당
         */
        (function() {
            var root = this;
            var version = '1.0';
            var Module3;
            if(typeof exports !== 'undefined') {
                Module3 = exports;
            } else {
                Module3 = root.Module3 = {};
            }
            Module3.getVersion = function() {
                return version;
            }
        }());
        console.log(Module3.getVersion());

        /**
         * Library 모듈화를 위한 코딩기법 4
         * apply 함수 이용
         */
        (function() {
            var root = this;
            var version = '1.0';
            var Module4;
            if(typeof exports !== 'undefined') {
                Module4 = exports;
            } else {
                Module4 = root.Module4 = {};
            }
            Module4.getVersion = function() {
                return version;
            }
        }).apply(this) ;
        console.log(Module4.getVersion());

        /**
         * Library 모듈화를 위한 코딩기법 5
         * 기명 즉시실행함수 이용
         */
        var Module5 = (function() {  
            var root = this;
            var version = '1.0';
            var Module;
            if(typeof exports !== 'undefined') {
                Module = exports;
            } else {
                Module = root.Module = {};
            }
            Module.getVersion = function() {
                return version;
            }
            return Module;
        }());
        console.log(Module5.getVersion()); 

    로딩 순서에 따른 실행 시기

    $(document).ready(function() { ... }); == $(function() { ... });
	    DOM만 생성 완료 후 실행.
    window.onload = function() {...}; == $(window).load(function() { ... });
	    DOM + 리소스 로딩 완료 후 실행.


