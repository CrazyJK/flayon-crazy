package jk.kamoru.flayon.crazy.util;

import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.StudioSort;

public class StudioUtils {

	public static int compareStudio(Studio s1, Studio s2, StudioSort sort, boolean reverse) {
		int result = 0;
		switch (sort) {
		case NAME:
			result = CrazyUtils.compareTo(s1.getName(), s2.getName());
		case HOMEPAGE:
			result = CrazyUtils.compareTo(s1.getHomepage(), s2.getHomepage());
		case COMPANY:
			result = CrazyUtils.compareTo(s1.getCompany(), s2.getCompany());
		case VIDEO:
			result = CrazyUtils.compareTo(s1.getVideoList().size(), s2.getVideoList().size());
		case SCORE:
			result = CrazyUtils.compareTo(s1.getScore(), s2.getScore());
		default:
			result = CrazyUtils.compareTo(s1.getName(), s2.getName());
		}
		return result * (reverse ? -1 : 1);
	}

}
