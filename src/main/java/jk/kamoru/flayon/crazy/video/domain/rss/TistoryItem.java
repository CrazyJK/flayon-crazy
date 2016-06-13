package jk.kamoru.flayon.crazy.video.domain.rss;

import java.io.Serializable;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;
import org.jsoup.Jsoup;
import org.jsoup.select.Elements;
import org.w3c.dom.Element;

import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Slf4j
public class TistoryItem implements Serializable {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private static final String TITLE_SEPARATOR = "  ";
	
	public static final SimpleDateFormat tistoryDateFormat = new SimpleDateFormat("E, d MMM yyyy HH:mm:ss Z", Locale.ENGLISH);

	private String title;
	private URL link;
	private URL guid;
	private Date pubDate;
	private String description;
	private List<Title> titles;
	
	public TistoryItem(Element eElement) throws Exception {
		title = eElement.getElementsByTagName("title").item(0).getTextContent();
		link = new URL(getContent(eElement, "link"));
		guid = new URL(getContent(eElement, "guid"));
		pubDate = tistoryDateFormat.parse(getContent(eElement, "pubDate"));
		description = getContent(eElement, "description");
		titles = new ArrayList<>();
		
		int debugStart = 1;
		int debugMax = 10;
		
		org.jsoup.nodes.Document document = Jsoup.parse(description);
		Elements trs = document.select("table.txc-table tbody tr");
		for (org.jsoup.nodes.Element tr : trs) {
			Elements tds = tr.getElementsByTag("td");
            for (org.jsoup.nodes.Element td : tds) {
            	Elements ps = td.select("p");
            	if (ps.size() == 4) {
                	Title title = new Title();
                	title.setRowData(td.text());
            		// p 1 : img
            		org.jsoup.nodes.Element img = ps.get(0).select("img").first();
            		if (img != null)
                		title.setImgSrc(img.attr("src"));
            		// p 2 : opus, actress, release
            		String text = ps.get(1).text();
//            		String html = ps.get(1).html();
            		if (debugStart < debugMax) log.info("  text = {}", text);
//            		if (debugStart < debugMax) log.info("  html = {}", ps.get(1).html());
            		if (StringUtils.isNotBlank(text)) {
        				String[] strings = StringUtils.splitByWholeSeparator(text, "  ");
                		if (debugStart < debugMax) {
                			for (String str : strings)
                				log.info("  - [{}]", str);
                		}
                		if (strings.length == 3) {
            				title.setOpus(strings[0]);
            				title.setActress(strings[1]);
            				title.setRelease(strings[2]);
                		}
                		else if (strings.length == 2) {
                			String[] _str = StringUtils.split(strings[0].trim(), " ", 2);
                			if (_str.length > 1) {
                				title.setOpus(_str[0]);
                				title.setActress(_str[1]);
                			}
                			else {
                				title.setOpus(strings[0]);
                			}
            				title.setRelease(strings[1]);
                		}
            		}
            		// p 3 : title
            		title.setTitle(ps.get(2).text());
            		titles.add(title);
            		if (debugStart < debugMax) {
            			log.info("   {}", title);
            		}
            		debugStart++;
            	}
            }
		}
		log.info("{} found {}", title, titles.size());
	}
	
	private String getContent(Element eElement, String name) {
		return eElement.getElementsByTagName(name).item(0).getTextContent();
	}

	@Data
	static class Title {
		
		final String regexKorean = ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*";
		final String regexSimple = "\\d{4}.\\d{2}.\\d{2}";
		final String regexDate = "^((19|20)\\d\\d).(0?[1-9]|1[012]).(0?[1-9]|[12][0-9]|3[01])$";

		String studio;
		String opus;
		String actress;
		String title;
		String release;
		String imgSrc;
		
		String rowData;

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

		@Override
		public String toString() {
			return String.format("[%s][%s][%s][%s][%s]", studio, opus, title, actress, release);
		}
	}
	
	public static void main(String[] args) {
		String text = "eyon-065 &nbsp;Natsuko Mishima&nbsp;&nbsp;2016.06.13";
		System.out.println(StringUtils.containsIgnoreCase(text, TITLE_SEPARATOR));
		String[] strings = StringUtils.splitByWholeSeparator(text, TITLE_SEPARATOR);
		for (String str : strings) {
			System.out.println(str);
		}
		
		text = "eyon-065 Natsuko Mishima  2016.06.13";
		strings = StringUtils.splitByWholeSeparator(text, "  ");
		for (String str : strings) {
			System.out.println(str);
		}
	}
}
