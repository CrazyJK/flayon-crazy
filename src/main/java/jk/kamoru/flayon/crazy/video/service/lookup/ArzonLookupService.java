package jk.kamoru.flayon.crazy.video.service.lookup;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.concurrent.CompletableFuture;

import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jk.kamoru.flayon.crazy.video.error.VideoException;
import lombok.extern.slf4j.Slf4j;

/**
 * arzon에서 품번 검색하여 첫번째 아이템의 cover 이미지를 다운로드 한다
 * @author kamoru
 *
 */
@Slf4j
@Service("arzonLookupService")
public class ArzonLookupService extends WebfileLookupAdapter {

	private static final String ARZON_HOST = "https://www.arzon.jp";
	private static final String ARZON_SEARCH = ARZON_HOST + "/index.php?action=adult_customer_agecheck&agecheck=1&redirect=https%3A%2F%2Fwww.arzon.jp%2Fitemlist.html%3Ft%3D%26m%3Dall%26s%3D%26q%3D";

	@Async
	@Override
	public CompletableFuture<File> get(String opus, String title, String imageLocation) {
		log.info("Look up {} cover at {}", opus, ARZON_HOST);
		
		try (CloseableHttpClient httpclient = getTorHttpClient()) {
			
		    // search
			String url = ARZON_SEARCH + opus;
		    CloseableHttpResponse response = httpclient.execute(new HttpGet(url));
	        log.debug("Searching... {} - {}", url, response.getStatusLine());
			Document document = Jsoup.parse(readResponse(response));
			Elements item = document.select("#item");
			Elements ankers = item.select("div.pictlist dl.hentry dt a");
			if (ankers == null || ankers.isEmpty()) {
				throw new VideoException("Not found list : " + opus);
			}
			
			String firstItemUri = ankers.get(0).attr("href");
			log.debug("  found firstItemUri : {}", firstItemUri);
			
			// find itemlist
			String itemlistUrl = ARZON_HOST + firstItemUri;
			response = httpclient.execute(new HttpGet(itemlistUrl));
	        log.debug("Finding itemlist... {} - {}", url, response.getStatusLine());
			document = Jsoup.parse(readResponse(response));
			Elements img = document.select("img.item_img");
			String imgSrc = img.attr("src");
			log.debug("  found img src : {}", imgSrc);
			
			// image save
			String imgUrl = "https:" + imgSrc;
			HttpGet httpGetImage = new HttpGet(imgUrl);
//			httpGetImage.addHeader("Accept", "image/png,image/*;q=0.8,*/*;q=0.5");
			httpGetImage.addHeader("Referer", itemlistUrl);
			response = httpclient.execute(httpGetImage);
	        log.debug("Get image... {} - {}", imgUrl, response.getStatusLine());
	        if (response.getStatusLine().getStatusCode() != 200) {
				throw new VideoException("Fail to save cover : " + opus + " HTTP " + response.getStatusLine().getStatusCode());
	        }
	        
			Path target = Paths.get(imageLocation, title + ".jpg");
			Files.copy(response.getEntity().getContent(), target, StandardCopyOption.REPLACE_EXISTING);
			log.info("Save cover, {}", target);
			return CompletableFuture.completedFuture(target.toFile());
		} catch (IOException e) {
			log.error("Fail to look up cover " + title, e);
			return CompletableFuture.completedFuture(null);
		} catch (VideoException e) {
			log.warn(e.getMessage());
			return CompletableFuture.completedFuture(null);
		}
	}

}
