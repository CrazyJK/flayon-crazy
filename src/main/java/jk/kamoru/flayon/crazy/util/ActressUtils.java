package jk.kamoru.flayon.crazy.util;

import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.ActressSort;

public class ActressUtils {

	public static int compareActress(Actress a1, Actress a2, ActressSort sort, boolean reverse) {
		int result = 0;
		switch (sort) {
		case NAME:
			result = CrazyUtils.compareTo(a1.getName(), a2.getName());
		case BIRTH:
			result = CrazyUtils.compareTo(a1.getBirth(), a2.getBirth());
		case BODY:
			result = CrazyUtils.compareTo(a1.getBodySize(), a2.getBodySize());
		case HEIGHT:
			result = CrazyUtils.compareTo(a1.getHeight(), a2.getHeight());
		case DEBUT:
			result = CrazyUtils.compareTo(a1.getDebut(), a2.getDebut());
		case VIDEO:
			result = CrazyUtils.compareTo(a1.getVideoList().size(), a2.getVideoList().size());
		case SCORE:
			result = CrazyUtils.compareTo(a1.getScore(), a2.getScore());
		case FAVORITE:
			result = CrazyUtils.compareTo(a1.getFavorite(), a2.getFavorite());
		default:
			result = CrazyUtils.compareTo(a1.getName(), a2.getName());
		}
		return result * (reverse ? -1 : 1); 
	}

	public static String refineName(String name) {
		name = StringUtils.remove(name, "외");
		name = StringUtils.stripToEmpty(name);
		return name;
	}

}
