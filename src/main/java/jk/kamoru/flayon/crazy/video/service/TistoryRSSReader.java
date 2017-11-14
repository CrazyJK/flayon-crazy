package jk.kamoru.flayon.crazy.video.service;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClientBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import jk.kamoru.flayon.crazy.video.domain.TistoryGraviaItem;
import lombok.extern.slf4j.Slf4j;

/**
 * Tistory RSS를 읽어 목록을 만든다
 * @author kamoru
 *
 */
@Slf4j
public class TistoryRSSReader {

	private static final String USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36";

	/**
	 * rss url을 읽어 item 태그(각 페이지)를 {@link jk.kamoru.flayon.crazy.video.domain.TistoryGraviaItem TistoryItem}의 생성자로 넣어 List 반환
	 * @param rssUrl
	 * @return
	 */
	public static List<TistoryGraviaItem> get(URL rssUrl, Map<String, String> studioMap, List<String> opusList) {
		log.info("read rss ; {}", rssUrl);
		List<TistoryGraviaItem> items = new ArrayList<>();
		
		HttpClient client = HttpClientBuilder.create().build();
		HttpGet request = new HttpGet(rssUrl.toString());

		// add request header
		request.addHeader("User-Agent", USER_AGENT);

		try {
			HttpResponse response = client.execute(request);
			
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document doc = builder.parse(response.getEntity().getContent());
			doc.getDocumentElement().normalize();
			log.debug("Root element :" + doc.getDocumentElement().getNodeName());
			
			NodeList nList = doc.getElementsByTagName("item");
			for (int temp = 0; temp < nList.getLength(); temp++) {
				Node nNode = nList.item(temp);
				if (nNode.getNodeType() == Node.ELEMENT_NODE) {
					items.add(new TistoryGraviaItem((Element) nNode, studioMap, opusList));
				}
			}
			log.info("found item {}", items.size());
		} catch (Exception e) {
			e.printStackTrace();
		}

		return items;
	}
	
}
