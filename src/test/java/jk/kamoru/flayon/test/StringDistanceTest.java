package jk.kamoru.flayon.test;

import com.wcohen.ss.BasicStringWrapper;
import com.wcohen.ss.JaroWinkler;
import com.wcohen.ss.api.StringDistance;
import com.wcohen.ss.api.StringWrapper;

public class StringDistanceTest {

	public static void main(String[] args) {
		JaroWinkler jaro = new JaroWinkler();
		StringDistance distanceChecker = jaro.getDistance();

		StringWrapper string1 = new BasicStringWrapper("abcd efgh");
		StringWrapper string2 = new BasicStringWrapper("abcd eigh");
		double similarity =  distanceChecker.score(string1, string2);
		
		System.out.println(similarity);
		System.out.println(distanceChecker.explainScore(string1, string2));
	}
}
