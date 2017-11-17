package jk.kamoru.flayon.crazy.util;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import com.wcohen.ss.JaroWinkler;
import com.wcohen.ss.api.StringDistance;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class NameDistanceChecker {

	private static final double LIMIT = 0.9d;
	public static JaroWinkler jaro = new JaroWinkler();
	public static StringDistance distanceChecker = jaro.getDistance();

	public static List<CheckResult> check(List<String> names) {
		return check(names, LIMIT);
	}
	
	public static List<CheckResult> check(List<String> names, double limit) {
		long count = 0;
		List<CheckResult> result = new ArrayList<>();
		for (int i = 0; i < names.size(); i++) {
			String name1 = names.get(i);
			for (int j = i+1; j < names.size(); j++) {
				String name2 = names.get(j);
			
				count++;
				double score = distanceChecker.score(name1, name2);
				if (score > limit) {
					result.add(new CheckResult(name1, name2, score));
				}
			}
		}
		log.info("names {}. limit {}. checking {} times. {} result", names.size(), limit, count, result.size());
		return result.stream().sorted((s1, s2) -> CrazyUtils.compareTo(s2.getScore(), s1.getScore())).collect(Collectors.toList());
	}
	
	@Data
	@AllArgsConstructor
	public static class CheckResult {
		String name1;
		String name2;
		double score;
	}
}
