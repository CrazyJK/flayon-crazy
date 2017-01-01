package jk.kamoru.flayon.crazy.video.domain;

import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.util.VideoUtils;
import lombok.Data;

@Data
public class TitlePart {
	String studio;
	String opus;
	String title;
	String actress;
	String releaseDate;
	
	String imgSrc;
	String rowData;

	boolean check;
	String checkDesc;
	String checkDescShort;
	
	private boolean exist;
	
	public TitlePart() {
		this.checkDesc = "";
		this.checkDescShort = "";
	}
	
	public TitlePart(String title) {
		String[] parts = StringUtils.split(title, "]");
		if (parts != null)
			for (int i = 0; i < parts.length; i++) {
				setDate(i, VideoUtils.removeUnnecessaryCharacter(parts[i]));
			}
		else
			throw new CrazyException(String.format("parsing error : %s", title));
	}

	private void setDate(int i, String data) {
		switch (i) {
		case 0:
			studio = data;
			break;
		case 1:
			opus = data.toUpperCase();
			break;
		case 2:
			title = data;
			break;
		case 3:
			actress = data;
			break;
		case 4:
			releaseDate = data;
			break;
		default:
			throw new CrazyException(String.format("invalid title data. %s : %s", i, data));
		}
	}

	/**
	 * @param studio the studio to set
	 */
	public void setStudio(String studio) {
		this.studio = VideoUtils.trimBlank(studio);
		// valid check
		if (invalidStudio(studio)) {
			this.studio = "";
			this.check = true;
			this.checkDesc += "Studio ";
			this.checkDescShort += "S ";
		}
	}

	/**
	 * @param opus the opus to set
	 */
	public void setOpus(String opus) {
		// valid check
		if (invalidOpus(opus)) {
			this.check = true;
			this.checkDesc += "Opus ";
			this.checkDescShort += "O ";
		}
		else {
			this.opus = VideoUtils.trimBlank(opus).toUpperCase();
		}
	}

	/**
	 * @param title the title to set
	 */
	public void setTitle(String title) {
		this.title = VideoUtils.trimBlank(Utils.removeInvalidFilename(title));
		// valid check
		if (invalidTitle(title) || warningTitle(title)) {
			this.check = true;
			this.checkDesc += "Title ";
			this.checkDescShort += "T ";
		}
	}

	/**
	 * @param actress the actress to set
	 */
	public void setActress(String actress) {
		String[] array = StringUtils.split(StringUtils.removeEnd(actress.trim(), "외"));
		if (array != null) {
			actress = "";
			for (String name : array) {
				actress += StringUtils.capitalize(name.toLowerCase()) + " ";
			}
			actress = VideoUtils.trimBlank(actress);
		}
		this.actress = actress;
		// valid check
		if (invalidActress(actress)) {
			this.check = true;
			this.checkDesc += "Actress ";
			this.checkDescShort += "A ";
		}
	}

	/**
	 * @param releaseDate the releaseDate to set
	 */
	public void setReleaseDate(String releaseDate) {
		this.releaseDate = VideoUtils.trimBlank(releaseDate);
		// valid check
		if (invalidReleaseDate(releaseDate)) {
			this.check = true;
			this.checkDesc += "Date ";
			this.checkDescShort += "D ";
		}
	}

	public String getStyleString() {
		return String.format("[%s][%s][%s][%s][%s]", studio, opus, title, actress, releaseDate);
	}

	@Override
	public String toString() {
		return getStyleString();
	}

	public String toFullLowerName() {
		return toString().toLowerCase();
	}
	
	public void setSeen() {
		this.check = true;
		this.checkDesc += "Seen ";
		this.checkDescShort += "Seen ";
	}
	
	
	/**
	 * 스튜디오 검증. 값이 있어야 한다.
	 * @param studioText
	 * @return 틀리면 <code>true</code>
	 */
	public static boolean invalidStudio(String studioText) {
		return StringUtils.isBlank(studioText);
	}
	
	/**
	 * 품번 검증. 값이 있고, 공백이 포함되어 있으면 안된다.
	 * @param opusText
	 * @return 틀리면 <code>true</code>
	 */
	public static boolean invalidOpus(String opusText) {
		return StringUtils.isBlank(opusText) || StringUtils.containsWhitespace(opusText);
	}
	
	/**
	 * 제목 검증. 값이 있어야 한다
	 * @param titleText
	 * @return 틀리면 <code>true</code>
	 */
	public static boolean invalidTitle(String titleText) {
		return StringUtils.isBlank(titleText);
	}
	
	/**
	 * 영어가 포함되면 의심.
	 * @param titleText
	 * @return
	 */
	public static boolean warningTitle(String titleText) {
		return Pattern.matches(CRAZY.REGEX_ENGLISH, titleText);
	}
	
	/**
	 * 배우이름 검증. 한글이 포함되어 있으면 안된다.
	 * @param actressName
	 * @return 틀리면 <code>true</code>
	 */
	public static boolean invalidActress(String actressText) {
		return Pattern.matches(CRAZY.REGEX_KOREAN, actressText);
	}
	
	/**
	 * 날자 검증. 값이 있고, 날자 형식이 맞아야 한다. 
	 * @param releaseDate
	 * @return 틀리면 <code>true</code>
	 */
	public static boolean invalidReleaseDate(String releaseText) {
		return StringUtils.isBlank(releaseText) || !Pattern.matches(CRAZY.REGEX_DATE, releaseText);
	}

	/**
	 * 전체 이름 검증
	 * @param studioText
	 * @param opusText
	 * @param titleText
	 * @param actressText
	 * @param releaseText
	 * @return 틀리면 <code>true</code>
	 */
	public static boolean invalid(String studioText, String opusText, String titleText, String actressText, String releaseText) {
		return invalidStudio(studioText) || invalidOpus(opusText) || invalidTitle(titleText) || invalidActress(actressText) || invalidReleaseDate(releaseText);
	}

}