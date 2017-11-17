package jk.kamoru.flayon.crazy;

import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.IOException;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FileUtils;
import org.junit.Test;

public class Base64Test {

	@Test
	public void test() throws IOException {
		String text  = "Base64 인코딩 디코딩";

		/* base64 encoding */
		byte[] encoded = Base64.encodeBase64(text.getBytes("EUC-KR"));

		/* base64 decoding */
		byte[] decoded = Base64.decodeBase64(encoded);
		
		System.out.println("인코딩 전 : " + text);
		System.out.println("인코딩 text : " + new String(encoded));
		System.out.println("디코딩 text : " + new String(decoded, "EUC-KR"));
	
		
		System.out.println("16진수 " + Long.toString(58818, 16));
		System.out.println("32진수 " + Long.toString(58818, 32));
				
		assertTrue(text.equals(new String(decoded)));
	}

//	@Test
	public void test2() throws IOException {
		
		StringBuilder sb = new StringBuilder();
		for (String line : FileUtils.readLines(new File("/home/kamoru/Downloads/base64.txt"))) {
			sb.append(line);
		}
		byte[] decoded = Base64.decodeBase64(sb.toString());
		System.out.println("디코딩 text : " + new String(decoded, "EUC-KR"));

	}
}
