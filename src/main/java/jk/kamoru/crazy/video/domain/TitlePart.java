package jk.kamoru.crazy.video.domain;

import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;

import jk.kamoru.crazy.CrazyException;
import jk.kamoru.crazy.Utils;
import jk.kamoru.crazy.video.util.VideoUtils;
import lombok.Data;

@Data
public class TitlePart implements Comparable<TitlePart> {
	String studio;
	String opus;
	String title;
	String actress;
	String releaseDate;

	Boolean check;
	String checkDesc;
	String checkDescShort;
	
	final String regexKorean = ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*";
	final String regexSimple = "\\d{4}.\\d{2}.\\d{2}";
	final String regexDate = "^((19|20)\\d\\d).(0?[1-9]|1[012]).(0?[1-9]|[12][0-9]|3[01])$";
	
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
		this.studio = studio;
		// 값이 없으면
		if (StringUtils.isBlank(studio)) {
			this.check = true;
			this.checkDesc += "Studio ";
			this.checkDescShort += "S ";
		}
	}

	/**
	 * @param opus the opus to set
	 */
	public void setOpus(String opus) {
		this.opus = opus;
		// 공백이 포함되어 있으면
		if (StringUtils.containsWhitespace(opus)) {
			this.check = true;
			this.checkDesc += "Opus ";
			this.checkDescShort += "O ";
		}
	}

	/**
	 * @param title the title to set
	 */
	public void setTitle(String title) {
		this.title = Utils.removeInvalidFilename(title);
		// 값이 없으면
		if (StringUtils.isBlank(title)) {
			this.check = true;
			this.checkDesc += "Title ";
			this.checkDescShort += "T ";
		}
	}

	/**
	 * @param actress the actress to set
	 */
	public void setActress(String actress) {
		String[] array = StringUtils.split(actress);
		if (array != null) {
			actress = "";
			for (String name : array) {
				actress += StringUtils.capitalize(name.toLowerCase()) + " ";
			}
			actress = actress.trim();
		}
		this.actress = actress;
		// 한글이 포함되어 있으면
		if (Pattern.matches(regexKorean, actress)) {
			this.check = true;
			this.checkDesc += "Actress ";
			this.checkDescShort += "A ";
		}
	}

	/**
	 * @param releaseDate the releaseDate to set
	 */
	public void setReleaseDate(String releaseDate) {
		this.releaseDate = releaseDate;
		// 값이 없으면
		if (StringUtils.isBlank(releaseDate)) {
			this.check = true;
			this.checkDesc += "Date ";
			this.checkDescShort += "D ";
		}
		else {
			// 패턴이 틀리면 
			if (!Pattern.matches(regexSimple, releaseDate)) {
				this.check = true;
				this.checkDesc += "Date ";
				this.checkDescShort += "D ";
			}
			else if (!Pattern.matches(regexDate, releaseDate)) {
				this.check = true;
				this.checkDesc += "Date ";
				this.checkDescShort += "D ";
			}
		}
	}

	@Override
	public String toString() {
		return String.format("[%s][%s][%s][%s][%s]", 
				studio, opus, title, actress, releaseDate);
	}

	@Override
	public int compareTo(TitlePart o) {
		return Utils.compareTo(this.toString(), o.toString());
	}

	public void setSeen() {
		this.check = true;
		this.checkDesc += "Seen ";
		this.checkDescShort += "Seen ";
	}
}