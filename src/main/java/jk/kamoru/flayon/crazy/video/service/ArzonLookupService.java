package jk.kamoru.flayon.crazy.video.service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import javax.net.ssl.SSLContext;
import javax.xml.ws.spi.http.HttpContext;

import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.config.Registry;
import org.apache.http.config.RegistryBuilder;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.ssl.SSLContexts;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;

/**
 * arzon에서 품번 검색하여 첫번째 아이템의 cover 이미지를 다운로드 한다
 * @author kamoru
 *
 */
@Slf4j
@Service
public class ArzonLookupService {

	private static String ARZON_HOST = "https://www.arzon.jp";
	private static String ARZON_SEARCH = ARZON_HOST + "/index.php?action=adult_customer_agecheck&agecheck=1&redirect=https%3A%2F%2Fwww.arzon.jp%2Fitemlist.html%3Ft%3D%26m%3Dall%26s%3D%26q%3D";

	public static void main(String[] args) throws ClientProtocolException, IOException {
		new ArzonLookupService().get("CND-161", "제목1", "/home/kamoru/workspace");
	}

	public static void testFlayon() {

		CloseableHttpClient httpclient = HttpClients.createDefault();
		
		try {
			// login
			String url = "http://127.0.0.1:58818/login";
			HttpPost post = new HttpPost(url);
		    List<NameValuePair> paramList = new ArrayList<NameValuePair>();
		    paramList.add(new BasicNameValuePair("username", "kamoru"));
		    paramList.add(new BasicNameValuePair("password", "1"));
		    post.setEntity(new UrlEncodedFormEntity(paramList));
		    CloseableHttpResponse response = httpclient.execute(post);
			
			// req video main
			url = "http://127.0.0.1:58818/video";
			response = httpclient.execute(new HttpGet(url));
	        log.info("video main : {} - {}", url, response.getStatusLine());
			
			// req actress list
			url = "http://127.0.0.1:58818/video/actress";
			response = httpclient.execute(new HttpGet(url));
	        log.info("actress list : {} - {}", url, response.getStatusLine());
	        
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
		    try {
				httpclient.close();
			} catch (IOException e) {
			}
		}
	}
	
	private static String readResponse(CloseableHttpResponse response) throws UnsupportedOperationException, IOException {
		BufferedReader bin = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));

		StringBuilder sb = new StringBuilder();
		String line;
		while ((line = bin.readLine()) != null) {
			sb.append(line);
		}
		return sb.toString();
	}

	@Async
	public CompletableFuture<Boolean> get(String opus, String title, String imageLocation) {
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
	        log.info("Searching... {} - {}", url, response.getStatusLine());
			Document document = Jsoup.parse(readResponse(response));
			Elements item = document.select("#item");
			Elements ankers = item.select("div.pictlist dl.hentry dt a");
			if (ankers == null || ankers.isEmpty()) {
				log.info("  not found : {}", opus);
				return CompletableFuture.completedFuture(new Boolean(false));
			}
			String firstItemUri = ankers.get(0).attr("href");
			log.info("  found firstItemUri : {}", firstItemUri);
			
			// find itemlist
			String itemlistUrl = ARZON_HOST + firstItemUri;
			response = httpclient.execute(new HttpGet(itemlistUrl));
	        log.info("Finding itemlist... {} - {}", url, response.getStatusLine());
			document = Jsoup.parse(readResponse(response));
			Elements img = document.select("img.item_img");
			String imgSrc = img.attr("src");
			log.info("  found img src : {}", imgSrc);
			
			// image save
			String imgUrl = "https:" + imgSrc;
			HttpGet httpGetImage = new HttpGet(imgUrl);
//			httpGetImage.addHeader("Accept", "image/png,image/*;q=0.8,*/*;q=0.5");
			httpGetImage.addHeader("Referer", itemlistUrl);
			response = httpclient.execute(httpGetImage);
	        log.info("Get image... {} - {}", imgUrl, response.getStatusLine());
	        if (response.getStatusLine().getStatusCode() != 200) {
	        	log.info("fail to save image, {}", response.getStatusLine().getStatusCode());
				return CompletableFuture.completedFuture(new Boolean(false));
	        }
			Path target = Paths.get(imageLocation, title + ".jpg");
			Files.copy(response.getEntity().getContent(), target, StandardCopyOption.REPLACE_EXISTING);
			log.info("  save image at {}", imageLocation);
			return CompletableFuture.completedFuture(new Boolean(true));
		} catch (IOException e) {
			e.printStackTrace();
			return CompletableFuture.completedFuture(new Boolean(false));
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
	        log.info("init");
	    }

	    public Socket createSocket(final HttpContext context) throws IOException {
	        InetSocketAddress socksaddr = (InetSocketAddress) context.getAttribute("socks.address");
	        Proxy proxy = new Proxy(Proxy.Type.SOCKS, socksaddr);
	        log.info("createSocket : {}", proxy);
	        return new Socket(proxy);
	    }

	}
}
