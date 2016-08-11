package jk.kamoru.flayon.crazy.video.service.webfile;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.NoSuchAlgorithmException;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.stereotype.Service;

import com.turn.ttorrent.client.SharedTorrent;
import com.turn.ttorrent.common.Torrent;

import jk.kamoru.flayon.crazy.CrazyException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service("sukebeiNyaaLookupService")
public class SukebeiNyaaLookupService implements WebFileLookupService {

	private static final String SUKEBEI_URL = "http://sukebei.nyaa.se";
	private static final String SUKEBEI_LIST_URL = SUKEBEI_URL + "/?page=search&cats=0_0&filter=0&term=";
	private static final String GiB = "GiB";
	private static final String MiB = "MiB";
	
//	public static void main(String[] args) throws IOException {
//		new SukebeiNyaaLookupService().get("SCOP-121", "제목2", "/home/kamoru/workspace");
//	}

	@Override
	public CompletableFuture<File> get(String opus, String title, String saveLocation) {
		log.info("Look up {} torrent at {}", opus, SUKEBEI_URL);
		
		CloseableHttpClient httpclient = HttpClients.createDefault();
		
		try {
			String url = SUKEBEI_LIST_URL + opus;
			CloseableHttpResponse response = httpclient.execute(new HttpGet(url));
			log.info("Searching... {} - {}", url, response.getStatusLine());
			
			String selectedName = null;
			String selectedUrl = null;
			Long selectedSize = new Long(0);
			Document document = Jsoup.parse(readResponse(response));

			Elements list = document.select("tr.trusted.tlistrow");
			log.info("found list {}", list.size());
			// 1개라서 view페이지가 보이거나, 못찾은 경우
			if (list.isEmpty()) {
				Elements viewdownloadbutton = document.select(".viewdownloadbutton");
				if (viewdownloadbutton.isEmpty()) {
					log.warn("Not found : {}", opus);
					throw new CrazyException("Not found list : " + opus);
				}
				selectedUrl = viewdownloadbutton.select("a").attr("href");
				selectedSize = megaBytes(document.select("table.viewtable td.vtop").last().text());
				
			}
			// 목록으로 찾은 경우
			else {
				// 찾은것중, .tlistname에 opus가 있고, .tlistsize가 가장 큰것 하나만 선택
				for (Element tlistrow : list) {
					String tlistname = tlistrow.select(".tlistname").text();
					if (!StringUtils.containsIgnoreCase(tlistname, opus)) {
						continue;
					}
					long tlistsize = megaBytes(tlistrow.select(".tlistsize").text());
					if (selectedSize < tlistsize) {
						selectedName = tlistname;
						selectedSize = tlistsize;
						selectedUrl = tlistrow.select(".tlistdownload a").attr("href");
					}
				}
			}
			log.info("selected : {} - {} - {}MB", selectedName, selectedUrl, selectedSize);
			if (selectedUrl == null) {
				throw new CrazyException("no selected download url : " + opus);
			}
			
			// 선택된 row에서 torrent 다운로드
			String downloadUrl = "http:" + selectedUrl;
			HttpGet downloadHttpGet = new HttpGet(downloadUrl);
			response = httpclient.execute(downloadHttpGet);
	        log.info("Get torrent... {} - {}", downloadUrl, response.getStatusLine());
	        if (response.getStatusLine().getStatusCode() != 200) {
	        	log.warn("Fail to save torrent, {}", response.getStatusLine().getStatusCode());
	        	throw new CrazyException("Fail to save torrent file : " + opus + " HTTP " + response.getStatusLine().getStatusCode());
	        }

	        Path target = Paths.get(saveLocation, String.format("%s_%s.torrent", title, selectedSize));
			Files.copy(response.getEntity().getContent(), target, StandardCopyOption.REPLACE_EXISTING);
			log.info("Save torrent, {}", saveLocation);
			
			try {
				Torrent torrent = SharedTorrent.load(target.toFile());
				log.info("Torrent : {}, {}, {}", torrent.getName(), torrent.getFilenames(), FileUtils.byteCountToDisplaySize(torrent.getSize()));
			} catch (NoSuchAlgorithmException e) {
				e.printStackTrace();
			}
			
			return CompletableFuture.completedFuture(target.toFile());
		} catch (IOException e) {
			log.error("Fail to look up torrent", e);
			return CompletableFuture.completedFuture(null);
		} catch (CrazyException e) {
			log.warn(e.getMessage());
			return CompletableFuture.completedFuture(null);
		} finally {
		    try {
				httpclient.close();
			} catch (IOException _ignore) {}
		}
	}

	/**
	 * 파일크기를 MB단위로 반환
	 * @param text
	 * @return
	 */
	private long megaBytes(String text) {
		if (StringUtils.contains(text, GiB)) {
			return (long) (Double.valueOf(text.replace(GiB, "").trim()) * 1000l);
		}
		else if (StringUtils.contains(text, MiB)) {
			return (long) (Double.valueOf(text.replace(MiB, "").trim()) * 1l);
		}
		return 0;
	}

	/**
	 * httpResponse convert to string
	 * JAVA 8 over
	 * @param response
	 * @return
	 * @throws UnsupportedOperationException
	 * @throws IOException
	 */
	private String readResponse(CloseableHttpResponse response) throws UnsupportedOperationException, IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));
		return reader.lines().collect(Collectors.joining("\n"));
	}

}
