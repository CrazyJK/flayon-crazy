package jk.kamoru.flayon.crazy.video.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.Socket;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import javax.net.ssl.SSLContext;
import javax.xml.ws.spi.http.HttpContext;

import org.apache.http.client.ClientProtocolException;
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
import org.apache.http.impl.conn.BasicHttpClientConnectionManager;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.ssl.SSLContexts;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ArzonReader {

	static String arzonURL = "https://www.arzon.jp/index.php?action=adult_customer_agecheck&agecheck=1&redirect=https%3A%2F%2Fwww.arzon.jp%2Fitemlist.html%3Ft%3D%26m%3Dall%26s%3D%26q%3D";

	// static String arzonURL = "http://daum.net?123";

	public static void main(String[] args) throws ClientProtocolException, IOException {
		ArzonReader.get3("CND-170", "제목");

	}

	public static void get(String opus, String title) {
		log.info("find cover {}", title);

		Proxy proxy = new Proxy(Proxy.Type.SOCKS, new InetSocketAddress("127.0.0.1", 9150));
		
		try {
			HttpURLConnection connection = (HttpURLConnection) new URL(arzonURL + opus).openConnection(proxy);

			connection.setConnectTimeout(1000 * 60); // Timeout 설정
			connection.setReadTimeout(1000 * 60); // Read Timeout 설정

			InputStream is = connection.getInputStream();
			log.info("usingProxy {}", connection.usingProxy());

			BufferedReader bin = new BufferedReader(new InputStreamReader(is));

			StringBuilder sb = new StringBuilder();
			String line;
			while ((line = bin.readLine()) != null) {
				sb.append(line);
			}
			bin.close();

			log.info("html {}", sb.toString());

			Document document = Jsoup.parse(sb.toString());
			Elements trs = document.select(".yes");

			log.info("anker {}", trs.html());

			
		} catch (Exception e) {
			log.error("Fail to arzon read", e);
		}
	}


	public static void get3(String opus, String title) {
	    InetSocketAddress socksaddr = new InetSocketAddress("127.0.0.1", 9150);
	    HttpClientContext context = HttpClientContext.create();
	    context.setAttribute("socks.address", socksaddr);

	    Registry<ConnectionSocketFactory> registry = RegistryBuilder.<ConnectionSocketFactory>create()
		        .register("http", PlainConnectionSocketFactory.INSTANCE)
		        .register("https", new MyConnectionSocketFactory(SSLContexts.createSystemDefault()))
		        .build();
		PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager(registry);
		CloseableHttpClient httpclient = HttpClients.custom().setConnectionManager(cm).build();

		try {
		    // search
			String url = arzonURL + opus;
		    CloseableHttpResponse response = httpclient.execute(new HttpGet(url));
	        log.info("search : {} - {}", url, response.getStatusLine());
			Document document = Jsoup.parse(read(response));
			Elements yes = document.select(".yes");
			log.info("  found .yes : {}", yes.html());

			Elements item = document.select("#item");
			Elements anker = item.select("div.pictlist dl.hentry dt a");
			String itemlist = anker.get(0).attr("href");
			log.info("  found anker : {}", itemlist);
			
			// find itemlist
			url = "https://www.arzon.jp" + itemlist;
			response = httpclient.execute(new HttpGet(url));
	        log.info("find itemlist : {} - {}", url, response.getStatusLine());
			document = Jsoup.parse(read(response));
			Elements img = document.select("img.item_img");
			String imgSrc = img.attr("src");
			log.info("  img src : {}", imgSrc);
			
			// image save
			url = "https:" + imgSrc;
			response = httpclient.execute(new HttpGet(url));
	        log.info("image : {} - {}", url, response.getStatusLine());
			Path target = Paths.get("C:\\Users\\kamoru\\Desktop", title + ".jpg");
			Files.copy(response.getEntity().getContent(), target, StandardCopyOption.REPLACE_EXISTING);
	        
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
		    try {
				httpclient.close();
			} catch (IOException e) {
			}
		}
	}
	
	private static String read(CloseableHttpResponse response) throws UnsupportedOperationException, IOException {
		BufferedReader bin = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));

		StringBuilder sb = new StringBuilder();
		String line;
		while ((line = bin.readLine()) != null) {
			sb.append(line);
		}
		return sb.toString();
	}
	
	static class MyConnectionSocketFactory extends SSLConnectionSocketFactory {

	    public MyConnectionSocketFactory(final SSLContext sslContext) {
	        super(sslContext);
	    }

	    public Socket createSocket(final HttpContext context) throws IOException {
	        InetSocketAddress socksaddr = (InetSocketAddress) context.getAttribute("socks.address");
	        Proxy proxy = new Proxy(Proxy.Type.SOCKS, socksaddr);
	        return new Socket(proxy);
	    }

	}
}
