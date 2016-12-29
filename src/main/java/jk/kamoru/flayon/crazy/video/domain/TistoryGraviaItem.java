package jk.kamoru.flayon.crazy.video.domain;

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

import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Gravia interview의 item 도메인. 각 페이지를 대표하며, List&lt;Title&gt; {@link #titles}에 {@link Title}을 사용 
 * @author kamoru
 *
 */
@AllArgsConstructor
@NoArgsConstructor
@Data
@Slf4j
public class TistoryGraviaItem implements Serializable {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private static final String regexSimple = "\\d{4}.\\d{2}.\\d{2}";

	public static final SimpleDateFormat tistoryDateFormat = new SimpleDateFormat("E, d MMM yyyy HH:mm:ss Z", Locale.ENGLISH);

	private String title;
	private URL link;
	private URL guid;
	private Date pubDate;
	private String description;
	private List<TistoryGraviaTitle> titles;
	
	public TistoryGraviaItem(Element eElement) throws Exception {
		title = eElement.getElementsByTagName("title").item(0).getTextContent();
		link = new URL(getContent(eElement, "link"));
		guid = new URL(getContent(eElement, "guid"));
		pubDate = tistoryDateFormat.parse(getContent(eElement, "pubDate"));
		description = getContent(eElement, "description");
		titles = new ArrayList<>();
		
		boolean debug = false;
		int debugStart = 1;
		int debugMax = 10;
		
		org.jsoup.nodes.Document document = Jsoup.parse(description);
		Elements trs = document.select("table.txc-table tbody tr");
		for (org.jsoup.nodes.Element tr : trs) {
			Elements tds = tr.getElementsByTag("td");
            for (org.jsoup.nodes.Element td : tds) {
            	Elements ps = td.select("p");
//        		if (debug && debugStart < debugMax) log.info("p html = [{}]", ps);
            	if (ps.size() == 4) {
            		TistoryGraviaTitle title = new TistoryGraviaTitle();

                	// p[1] : img
            		org.jsoup.nodes.Element img = ps.get(0).select("img").first();
            		if (img != null)
                		title.setImgSrc(img.attr("src"));
            		
            		// p[2] : opus, actress, release
            		String p1 = ps.get(1).text();
            		if (debug && debugStart < debugMax) log.info("p1 text = [{}]", p1);
            		if (StringUtils.isNotBlank(p1)) {
        				String[] strings = split2White(p1);
        				if (debug && debugStart < debugMax) log.info("p1 split {}", strings.length);
                		if (debug && debugStart < debugMax) {
                			for (String str : strings)
                				log.info("p1 split element  = [{}]", str);
                		}
                		if (strings.length == 3) {
            				title.setOpus(strings[0]);
            				title.setActress(strings[1]);
            				title.setRelease(strings[2]);
                		}
                		else if (strings.length == 2) {
            				title.setOpus(strings[0]);
            				if (Pattern.matches(regexSimple, strings[1])) {
            					title.setRelease(strings[1]);
            				}
            				else {
                				title.setActress(strings[1]);
            				}
                		}
            		}
            		
            		// p[3] : title
            		String p2 = ps.get(2).text();
            		if (debug && debugStart < debugMax) log.info("p2 text = [{}]", p2);
            		title.setTitle(p2);
            		
            		// set row data
                	title.setRowData(p1 + "  " + p2);

            		titles.add(title);
            		if (debug && debugStart < debugMax) log.info("StyleString = [{}], rowData = [{}]", title.toStyleString(), title.toString());

            		debugStart++;
            	}
            }
		}
		log.info("[{}] found {}", title, titles.size());
	}
	
	private String getContent(Element eElement, String name) {
		return eElement.getElementsByTagName(name).item(0).getTextContent();
	}
	
	private static String[] split2White(String text) {
//		System.out.println(text);
		
		List<String> list = new ArrayList<>();
		String str = "";
		boolean firstWhite = false;
		for (int i=0; i<text.length(); i++) {
			char ch = text.charAt(i);
			int chInt = (int)ch;
//			System.out.println("[" + ch + "] " + Character.getNumericValue(ch) + " " + chInt);
			
			if (chInt == 32 || chInt == 160) {
				if (firstWhite) {
//					System.out.println("    2 white! str=[" + str + "]");
					list.add(str.trim());
					str = "";
					firstWhite = false;
				}
				else {
//					System.out.println("    1 white! str=[" + str + "]");
					firstWhite = true;
					str += Character.toString(ch);
				}
			}
			else {
				firstWhite = false;
				str += Character.toString(ch);
//				System.out.println("    no white str=[" + str + "]");
			}
			
		}
		list.add(str.trim());
//		System.out.println("list : " + list);	
		return list.toArray(new String[]{});
	}
	/*
	public static void main(String[] args) {
		String text = "zizg-020  Shuri Atomi  2016.03.25";
		split2White(text);		
	}
	*/
}

