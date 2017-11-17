package jk.kamoru.flayon.test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;

import lombok.Cleanup;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ServerBenchmark {

	private static final String SERVER = "http://127.0.0.1:58818";
	
	public static void testFlayon() throws IOException {

		@Cleanup CloseableHttpClient httpclient = HttpClients.createDefault();
		
		// login
		String url = SERVER + "/login";
		HttpPost post = new HttpPost(url);
	    List<NameValuePair> paramList = new ArrayList<NameValuePair>();
	    paramList.add(new BasicNameValuePair("username", "kamoru"));
	    paramList.add(new BasicNameValuePair("password", "crazyjk"));
	    post.setEntity(new UrlEncodedFormEntity(paramList));
	    CloseableHttpResponse response = httpclient.execute(post);
        log.info("login : {} - {}", url, response.getStatusLine());
        showContent(response);

		// req video main
		url = SERVER + "/video";
		response = httpclient.execute(new HttpGet(url));
        log.info("video main : {} - {}", url, response.getStatusLine());
        showContent(response);
		
		// req actress list
		url = SERVER + "/video/actress";
		response = httpclient.execute(new HttpGet(url));
        log.info("actress list : {} - {}", url, response.getStatusLine());
        showContent(response);
	    
	}

	private static void showContent(CloseableHttpResponse response) throws UnsupportedOperationException, IOException {
		
		try (BufferedReader br = new BufferedReader(new InputStreamReader(response.getEntity().getContent()))) {
	        String line = null;
	        while ((line = br.readLine()) != null) {
	        	log.debug("{}", line);
	        }
		}
		/*
        @Cleanup BufferedReader br = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));
        String line = null;
        while ((line = br.readLine()) != null) {
        	log.info("{}", line);
        }
        */
	}
}
