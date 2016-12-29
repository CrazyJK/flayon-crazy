package jk.kamoru.flayon.crazy.video.domain;

import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.crazy.Utils;
import lombok.Data;

@Data
public class TistoryGraviaTitle {

	final String regexKorean = ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*";
	final String regexSimple = "\\d{4}.\\d{2}.\\d{2}";
	final String regexDate = "^((19|20)\\d\\d).(0?[1-9]|1[012]).(0?[1-9]|[12][0-9]|3[01])$";

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
		this.studio = StringUtils.trim(studio);
	}
	
	public void setOpus(String opus) {
		this.opus = StringUtils.trim(opus);
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
		if (Pattern.matches(regexKorean, actress)) {
			this.check = true;
			this.checkDesc += "Actress ";
			this.checkDescShort += "A ";
		}
	}

	public void setTitle(String title) {
		this.title = Utils.removeInvalidFilename(title);
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
		if (StringUtils.isBlank(this.release)) {
			this.check = true;
			this.checkDesc += "Date ";
			this.checkDescShort += "D ";
		}
		else {
			// 패턴이 틀리면 
			if (!Pattern.matches(regexSimple, this.release)) {
				this.check = true;
				this.checkDesc += "Date ";
				this.checkDescShort += "D ";
			}
			else if (!Pattern.matches(regexDate, this.release)) {
				this.check = true;
				this.checkDesc += "Date ";
				this.checkDescShort += "D ";
			}
		}
	}

	public String toStyleString() {
		return String.format("[%s][%s][%s][%s][%s]", studio, opus, title, actress, release);
	}

}
