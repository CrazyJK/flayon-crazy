package jk.kamoru.flayon.crazy.video;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.video.domain.Sort;

public interface VIDEO extends CRAZY {
	
	public static final long WEBCACHETIME_SEC  = 86400 * 7l;

	public static final long WEBCACHETIME_MILI = WEBCACHETIME_SEC * 1000l;

	public static final Sort DEFAULT_SORTMETHOD = Sort.T;

	public static final String EXT_ACTRESS = "actress";

	public static final String EXT_STUDIO  = "studio";

	public static final String EXT_INFO    = "info";

	public static final String EXT_WEBP    = "webp";
	
	public static final String      DATE_PATTERN = "yyyy-MM-dd";

	public static final String      TIME_PATTERN = "HH:mm:ss";

	public static final String DATE_TIME_PATTERN = DATE_PATTERN + " " + TIME_PATTERN;

	public static final String         OS_SYSTEM_FILENAMES = ".DS_Store desktop.ini";

	public static final String       HISTORY_LOG_FILENAME  = "history.log";
	
	public static final String          TAG_DATA_FILENAME  = "tag.data";
	
	public static final String             WRONG_FILENAME  = "wrongFilenames.txt";

	public static final String   BACKUP_INSTANCE_FILENAME  = "flayon-instance.csv";
	
	public static final String    BACKUP_ARCHIVE_FILENAME  = "flayon-archive.csv";

	public static final String       BACKUP_INFO_FILENAME  = "flayon-info.zip";

	public static final String       BACKUP_FILE_FILENAME  = "flayon-file.zip";

}
