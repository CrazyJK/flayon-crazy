package jk.kamoru.flayon.crazy.util;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.commons.text.similarity.JaroWinklerDistance;

import jk.kamoru.flayon.base.util.StopWatch;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;

/**
 * 배우 이름의 유사도 결정.<br>
 * Jara-Winkler Distance algorithm
 * @author kamoru
 * @see JaroWinklerDistance
 */
@Slf4j
public class NameDistanceChecker {

	private static final double LIMIT = 0.9;

	public static JaroWinklerDistance jaroWinklerDistance = new JaroWinklerDistance();

	/**
	 * {@link #LIMIT}을 넘는 유사도의 이름을 반환
	 * @param actressList
	 * @return
	 */
	public static List<CheckResult> check(List<Actress> actressList) {
		return check(actressList, LIMIT);
	}
	
	/**
	 * limit을 넘는 유사도의 이름을 반환
	 * @param actressList
	 * @param limit
	 * @return
	 */
	public static List<CheckResult> check(List<Actress> actressList, double limit) {
		StopWatch stopWatch = new StopWatch("NameDistanceChecker");
		List<CheckResult> result = new ArrayList<>();
		long count = 0;

		stopWatch.start();
		for (int i = 0; i < actressList.size(); i++) {
			Actress actress1 = actressList.get(i);
			for (int j = i+1; j < actressList.size(); j++) {
				Actress actress2 = actressList.get(j);
			
				count++;
				double score = ActressUtils.equalsBySort(actress1.getName(), actress2.getName())
						? 1.0
						: jaroWinklerDistance.apply(actress1.getName(), actress2.getName());
				
				if (score > limit) {
					result.add(new CheckResult(actress1, actress2, score));
				}
			}
		}
		stopWatch.stop();
		
		log.info("names {}. limit {}. checking {} times. {} result. Elapsed {} ms", actressList.size(), limit, count, result.size(), stopWatch.getTotalTimeMillis());
		return result.stream().sorted((r1, r2) -> CrazyUtils.compareTo(r2.getScore(), r1.getScore())).collect(Collectors.toList());
	}
	
	/**
	 * 유사도 결과
	 * @author kamoru
	 */
	@Data
	@AllArgsConstructor
	public static class CheckResult {
		Actress actress1;
		Actress actress2;
		double score;
	}
	
}
