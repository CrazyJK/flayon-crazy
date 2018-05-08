package jk.kamoru.flayon.test;

import org.apache.commons.text.similarity.CosineDistance;
import org.apache.commons.text.similarity.HammingDistance;
import org.apache.commons.text.similarity.JaccardDistance;
import org.apache.commons.text.similarity.JaccardSimilarity;
import org.apache.commons.text.similarity.JaroWinklerDistance;
import org.apache.commons.text.similarity.LevenshteinDetailedDistance;
import org.apache.commons.text.similarity.LevenshteinDistance;
import org.apache.commons.text.similarity.LongestCommonSubsequence;
import org.apache.commons.text.similarity.LongestCommonSubsequenceDistance;

public class StringDistanceTest {

	public static void main(String[] args) {
		String s1 = "qwer tyui";
		String s2 = "qwer tyuo";
		
		JaroWinklerDistance jaro = new JaroWinklerDistance();
		JaccardSimilarity jaccard = new JaccardSimilarity();
		LongestCommonSubsequence longest = new LongestCommonSubsequence();
		CosineDistance cosine = new CosineDistance();
		HammingDistance hamming = new HammingDistance();
		JaccardDistance haccard2 = new JaccardDistance();
		LevenshteinDetailedDistance levenshtein = new LevenshteinDetailedDistance();
		LevenshteinDistance levenshtein2 = new LevenshteinDistance();
		LongestCommonSubsequenceDistance longest2 = new LongestCommonSubsequenceDistance();
		
		System.out.println(jaro.apply(s1, s2));
		System.out.println(jaccard.apply(s1, s2));
		System.out.println(longest.apply(s1, s2));
		System.out.println();
		System.out.println(cosine.apply(s1, s2));
		System.out.println(hamming.apply(s1, s2));
		System.out.println(haccard2.apply(s1, s2));
		System.out.println(levenshtein.apply(s1, s2));
		System.out.println(levenshtein2.apply(s1, s2));
		System.out.println(longest2.apply(s1, s2));

	}
}
