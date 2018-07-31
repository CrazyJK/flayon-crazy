package jk.kamoru.flayon.crazy;

import java.text.SimpleDateFormat;

import jk.kamoru.flayon.FLAYON;

public interface CRAZY extends FLAYON {

	public static final String SUFFIX_VIDEO 	 = "avi,mpg,mkv,wmv,mp4,mov,rmvb";
	public static final String SUFFIX_IMAGE 	 = "jpg,jpeg,png,gif,jfif,webp";
	public static final String SUFFIX_SUBTITLES  = "smi,srt,ass,smil";
	public static final String SUFFIX_TORRENT 	 = "torrent";

	public static final String PATH_STAGE 		 = "Stage";
	public static final String PATH_COVER 		 = "Cover";
	public static final String PATH_ARCHIVE 	 = "Archive";

	public static final String REGEX_DATE 		 = "^((19|20)\\d\\d).(0?[1-9]|1[012]).(0?[1-9]|[12][0-9]|3[01])$";
	public static final String REGEX_DATE_SIMPLE = "\\d{4}.\\d{2}.\\d{2}";
	public static final String REGEX_KOREAN 	 = ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*";
	public static final String REGEX_ENGLISH 	 = " ^[a-zA-Z]*$";

	public static final long WEBCACHETIME_SEC    = 86400 * 7l;
	public static final long WEBCACHETIME_MILI   = WEBCACHETIME_SEC * 1000l;

	public static final String PATTERN_DATE      = "yyyy-MM-dd";
	public static final String PATTERN_TIME      = "HH:mm:ss";
	public static final String PATTERN_DATE_TIME = PATTERN_DATE + " " + PATTERN_TIME;

	public static final SimpleDateFormat DateTimeFormat = new SimpleDateFormat(PATTERN_DATE_TIME);

}
