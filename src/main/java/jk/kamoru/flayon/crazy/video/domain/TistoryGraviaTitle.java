package jk.kamoru.flayon.crazy.video.domain;

import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.base.util.IOUtils;
import jk.kamoru.flayon.crazy.CRAZY;
import lombok.Data;

@Data
@Deprecated
public class TistoryGraviaTitle {

	String studio = "";
	String opus = "";
	String actress = "";
	String title = "";
	String release = "";
	String imgSrc = "";
	
	String rowData = "";

	boolean check = false;
	String checkDesc = "";
	String checkDescShort = "";
	
	public void setStudio(String studio) {
		if (studio == null) {
			this.studio = "";
			this.check = true;
			this.checkDesc += "Studio ";
			this.checkDescShort += "S ";
		}
		else {
			this.studio = StringUtils.trim(studio);
		}
	}
	
	public void setOpus(String opus) {
		if (opus == null) {
			this.opus = " ";
		}
		else {
			this.opus = StringUtils.trim(opus).toUpperCase();
		}
		if (StringUtils.containsWhitespace(this.opus)) {
			this.check = true;
			this.checkDesc += "Opus ";
			this.checkDescShort += "O ";
		}
	}

	public void setActress(String actress) {
		String[] array = StringUtils.split(StringUtils.removeEnd(actress.trim(), "외"));
		if (array != null) {
			actress = "";
			for (String name : array) {
				actress += StringUtils.capitalize(name.toLowerCase()) + " ";
			}
			actress = actress.trim();
		}
		this.actress = actress;
		// 한글이 포함되어 있으면
		if (Pattern.matches(CRAZY.REGEX_KOREAN, actress)) {
			this.check = true;
			this.checkDesc += "Actress ";
			this.checkDescShort += "A ";
		}
	}

	public void setTitle(String title) {
		this.title = IOUtils.removeInvalidFilename(title).trim();
		// 값이 없으면
		if (StringUtils.isBlank(this.title)) {
			this.check = true;
			this.checkDesc += "Title ";
			this.checkDescShort += "T ";
		}
	}

	public void setRelease(String release) {
		this.release = StringUtils.trim(release);
		// 값이 없으면
		if (StringUtils.isBlank(this.release) || !Pattern.matches(CRAZY.REGEX_DATE, this.release)) {
			this.check = true;
			this.checkDesc += "Date ";
			this.checkDescShort += "D ";
		}
	}

	public String getStyleString() {
		return String.format("[%s][%s][%s][%s][%s]", studio, opus, title, actress, release);
	}

}
