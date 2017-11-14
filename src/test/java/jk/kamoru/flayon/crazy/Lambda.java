package jk.kamoru.flayon.crazy;
import java.util.Arrays;
import java.util.List;
import java.util.function.Consumer;
import java.util.stream.Collectors;

import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.crazy.util.VideoUtils;

@SuppressWarnings("unused")
public class Lambda {

	List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6);

	{
		numbers.forEach(new Consumer<Integer>() {

			@Override
			public void accept(Integer t) {
				System.out.println(t);
			}
		});

		numbers.forEach((Integer v) -> System.out.println(v));

		numbers.forEach(value -> System.out.println(value));

		numbers.forEach(System.out::println);

		numbers.stream()
			.filter(v -> isEven(v))
			.map(v -> doubleIt(v))
			.filter(v -> isGreaterThan5(v))
			.findFirst().get();
		
		/*
		 * ( parameters ) -> expression body
		 * ( parameters ) -> { expression body }
		 * () -> { expression body }
		 * () -> expression body
		 */
		
		/*
		 * 단일 메서드를 가진 인터페이스
		 */
		new Thread(new Runnable() {

			@Override
			public void run() {
				System.out.println("Hello world");
			}
			
		}).start();
		
		new Thread(() -> {
			System.out.println("Hello world, Rambda");
		});
		
		Func add = (int a, int b) -> a + b;
		add.calc(1, 2);
		
		Func sub = (int a, int b) -> a - b;
		Func add2 = (int a, int b) -> {return a + b;};
		
		int result = add.calc(1, 2) + add2.calc(3, 4);
		
		/*
		 * 컬렉션 처리
		 */
		Arrays.asList(1, 2, 3, 4, 5).stream()
			.map(i -> i*i)
			.forEach(System.out::println);
		
		Arrays.asList(1, 3, 5).stream()
			.skip(1)
			.limit(3)
			.filter(i -> 2 > i)
			.forEach(System.out::println);

		Arrays.asList(Arrays.asList(1,2), Arrays.asList(3, 4), Arrays.asList(5, 6)).stream()
			.flatMap(i -> i.stream())
			.forEach(System.out::println);
		
		Arrays.asList(1,2,3).stream()
			.reduce((a,b) -> a-b)
			.get();
		
		Arrays.asList(1,2,3).stream()
			.collect(Collectors.toList());
		
		Arrays.asList(1,2,3).stream()
			.iterator();
	}

	public boolean isEven(int number) {
		return number % 2 == 0;
	}

	public int doubleIt(int number) {
		return number * 2;
	}

	public boolean isGreaterThan5(int number) {
		return number > 5;
	}

	public static void main(String[] args) {
		List<V> vList= Arrays.asList(new V("a"), new V("b"), new V("c"), new V("d"));
		vList.stream()
			.map(v -> v.setSort("e"))
			.forEach(v -> System.out.println(v.getSort()));
		
		System.out.println(StringUtils.containsIgnoreCase("Asuka Kirara", "asu kirara"));

		System.out.println(VideoUtils.containsActress("Asuka Kirara", "kirara asu"));

		Arrays.asList(Arrays.asList(1,2), Arrays.asList(3, 4), Arrays.asList(1, 5, 6)).stream()
		.flatMap(i -> i.stream())
		.forEach(System.out::println);

	}
	
}


class V {
	String sort = "A";
	
	public V(String s) {
		this.sort = s;
	}

	public String getSort() {
		return sort;
	}

	public V setSort(String sort) {
		this.sort = sort;
		return this;
	}
	
	
}

@FunctionalInterface
interface Func {
	public int calc(int a, int b);
}