package jk.kamoru.flayon.crazy;

import static org.junit.Assert.assertTrue;

import org.apache.commons.codec.binary.Base64;
import org.junit.Test;

public class Base64Test {

	@Test
	public void test() {
		String text  = "Base64 인코딩 디코딩";

		/* base64 encoding */
		byte[] encoded = Base64.encodeBase64(text.getBytes());

		/* base64 decoding */
		byte[] decoded = Base64.decodeBase64(encoded);

		System.out.println("인코딩 전 : " + text);
		System.out.println("인코딩 text : " + new String(encoded));
		System.out.println("디코딩 text : " + new String(decoded));
	
		
		System.out.println("16진수 " + Long.toString(58818, 16));
		System.out.println("32진수 " + Long.toString(58818, 32));
				
		assertTrue(text.equals(new String(decoded)));
	}

}
