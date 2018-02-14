package jk.kamoru.flayon.crazy.video.service.lookup;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.Socket;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import javax.net.ssl.SSLContext;
import javax.xml.ws.spi.http.HttpContext;

import org.apache.http.client.methods.CloseableHttpResponse;
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

import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.extern.slf4j.Slf4j;

public abstract class WebfileLookupAdapter implements FileLookupService {

	private static final String SOCKET_ADDRESS = "socks.address";
	private static final InetSocketAddress TOR_SOCKET_ADDR = new InetSocketAddress("127.0.0.1", 9150);

	@Slf4j
	static class TorConnectionSocketFactory extends SSLConnectionSocketFactory {

	    public TorConnectionSocketFactory(final SSLContext sslContext) {
	        super(sslContext);
	        log.debug("init");
	    }

	    public Socket createSocket(final HttpContext context) throws IOException {
	        InetSocketAddress socketAddr = (InetSocketAddress) context.getAttribute(SOCKET_ADDRESS);
	        Proxy proxy = new Proxy(Proxy.Type.SOCKS, socketAddr);
	        log.debug("createSocket. Proxy : {}", proxy);
	        return new Socket(proxy);
	    }
	}

	public abstract CompletableFuture<File> get(String keyword, String saveFilename, String saveLocation);

	protected CloseableHttpClient getTorHttpClient() {
		HttpClientContext context = HttpClientContext.create();
	    context.setAttribute(SOCKET_ADDRESS, TOR_SOCKET_ADDR);

	    Registry<ConnectionSocketFactory> registry = RegistryBuilder.<ConnectionSocketFactory>create()
		        .register("http", PlainConnectionSocketFactory.INSTANCE)
		        .register("https", new TorConnectionSocketFactory(SSLContexts.createSystemDefault()))
		        .build();
	    
		PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager(registry);
		return HttpClients.custom().setConnectionManager(cm).build();
	}
	
	protected String readResponse(CloseableHttpResponse response) throws UnsupportedOperationException, IOException {
		return new BufferedReader(
				new InputStreamReader(
						response.getEntity().getContent())).lines().collect(Collectors.joining(VIDEO.LINE));
	}

}
