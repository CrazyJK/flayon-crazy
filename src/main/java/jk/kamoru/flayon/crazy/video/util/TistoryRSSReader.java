package jk.kamoru.flayon.crazy.video.util;

import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import jk.kamoru.flayon.crazy.video.domain.rss.TistoryItem;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class TistoryRSSReader {

	public static List<TistoryItem> get(URL rssUrl) {
		log.info("read rss ; {}", rssUrl);
		List<TistoryItem> items = new ArrayList<>();
		try (InputStream is = rssUrl.openConnection().getInputStream()) {
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document doc = builder.parse(is);
			doc.getDocumentElement().normalize();
			log.info("Root element :" + doc.getDocumentElement().getNodeName());
			
			NodeList nList = doc.getElementsByTagName("item");
			for (int temp = 0; temp < nList.getLength(); temp++) {
				Node nNode = nList.item(temp);
				if (nNode.getNodeType() == Node.ELEMENT_NODE) {
					items.add(new TistoryItem((Element) nNode));
				}
			}
			log.info("found item {}", items.size());
		} catch (Exception e) {
			log.error("Fail to Tistory Rss read", e);
		}
		return items;
	}
	
}
