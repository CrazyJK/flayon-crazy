package jk.kamoru.flayon.test;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import jk.kamoru.flayon.crazy.util.VideoUtils;

public class DateCompareTest {

	public static void main(String[] args) {
		List<String> dateList = Arrays.asList("2017.11.03", "2017.11.13", "2017.11.10");
		System.out.println(dateList.stream()
				.sorted((d1, d2) -> VideoUtils.compareToRelease(d1, d2))
				.collect(Collectors.toList()));
	}

}
