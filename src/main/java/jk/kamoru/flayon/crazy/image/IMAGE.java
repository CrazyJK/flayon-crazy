package jk.kamoru.flayon.crazy.image;

import org.apache.commons.lang3.ArrayUtils;

import jk.kamoru.flayon.crazy.CRAZY;

public interface IMAGE extends CRAZY {

	public static final String[] SUFFIX_IMAGE_ARRAY = ArrayUtils.addAll(SUFFIX_IMAGE.toLowerCase().split(","), SUFFIX_IMAGE.toUpperCase().split(",")); 
	
}
