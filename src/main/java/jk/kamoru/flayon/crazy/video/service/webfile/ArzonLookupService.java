package jk.kamoru.flayon.crazy.video.service.webfile;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import javax.net.ssl.SSLContext;
import javax.xml.ws.spi.http.HttpContext;

import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.config.Registry;
import org.apache.http.config.RegistryBuilder;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.ssl.SSLContexts;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jk.kamoru.flayon.crazy.error.VideoException;
import lombok.extern.slf4j.Slf4j;

/**
 * arzon에서 품번 검색하여 첫번째 아이템의 cover 이미지를 다운로드 한다
 * @author kamoru
 *
 */
@Slf4j
@Service("arzonLookupService")
public class ArzonLookupService implements WebFileLookupService {

	private static String ARZON_HOST = "https://www.arzon.jp";
	private static String ARZON_SEARCH = ARZON_HOST + "/index.php?action=adult_customer_agecheck&agecheck=1&redirect=https%3A%2F%2Fwww.arzon.jp%2Fitemlist.html%3Ft%3D%26m%3Dall%26s%3D%26q%3D";

//	public static void main(String[] args) throws IOException {
//		new ArzonLookupService().get("CND-161", "제목1", "/home/kamoru/workspace");
//	}
	
	/**
	 * httpResponse convert to Stirng
	 * traditional method
	 * @param response
	 * @return
	 * @throws UnsupportedOperationException
	 * @throws IOException
	 */
	@SuppressWarnings("unused")
	private static String readResponse2(CloseableHttpResponse response) throws UnsupportedOperationException, IOException {
		BufferedReader bin = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));

		StringBuilder sb = new StringBuilder();
		String line;
		while ((line = bin.readLine()) != null) {
			sb.append(line);
		}
		return sb.toString();
	}

	/**
	 * httpResponse convert to string
	 * JAVA 8 over
	 * @param response
	 * @return
	 * @throws UnsupportedOperationException
	 * @throws IOException
	 */
	private static String readResponse(CloseableHttpResponse response) throws UnsupportedOperationException, IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));
		return reader.lines().collect(Collectors.joining("\n"));
	}

	@Override
	@Async
	public CompletableFuture<File> get(String opus, String title, String imageLocation) {
		log.info("Look up {} cover at arzon.jp", opus);
		
		HttpClientContext context = HttpClientContext.create();
	    InetSocketAddress torSocksAddr = new InetSocketAddress("127.0.0.1", 9150);
	    context.setAttribute("socks.address", torSocksAddr);

	    Registry<ConnectionSocketFactory> registry = RegistryBuilder.<ConnectionSocketFactory>create()
		        .register("http", PlainConnectionSocketFactory.INSTANCE)
		        .register("https", new TorConnectionSocketFactory(SSLContexts.createSystemDefault()))
		        .build();
		PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager(registry);
		CloseableHttpClient httpclient = HttpClients.custom().setConnectionManager(cm).build();

		try {
			
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
		} finally {
		    try {
				httpclient.close();
			} catch (IOException _ignore) {}
		}
	}

	@Slf4j
	static class TorConnectionSocketFactory extends SSLConnectionSocketFactory {

	    public TorConnectionSocketFactory(final SSLContext sslContext) {
	        super(sslContext);
	        log.debug("init");
	    }

	    public Socket createSocket(final HttpContext context) throws IOException {
	        InetSocketAddress socksaddr = (InetSocketAddress) context.getAttribute("socks.address");
	        Proxy proxy = new Proxy(Proxy.Type.SOCKS, socksaddr);
	        log.debug("createSocket : {}", proxy);
	        return new Socket(proxy);
	    }

	}
}
