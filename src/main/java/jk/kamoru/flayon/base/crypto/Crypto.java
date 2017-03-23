package jk.kamoru.flayon.base.crypto;

import jk.kamoru.flayon.FLAYON;

public interface Crypto {

	public static final String AES_ECB_TRANSFORMATION = "AES/ECB/PKCS5Padding";

	public static final String AES_CBC_TRANSFORMATION = "AES/CBC/PKCS5Padding";

	public static final String AES_ALGORITHM = "AES";

	public static final String RSA_TRANSFORMATION = "RSA/ECB/PKCS1PADDING";
	
	public static final String RSA_ALGORITHM = "RSA";

	public static final String RSA_PROVIDER = "SunJCE";

	public static final String ENCODING = FLAYON.ENCODING;

	public String encrypt(String str);
	
	public String decrypt(String str);
	
}
