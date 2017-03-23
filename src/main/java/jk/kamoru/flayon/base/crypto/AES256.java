/**
 * ref) http://aramk.tistory.com/32, http://www.enjoydev.com/memo/405
 */
package jk.kamoru.flayon.base.crypto;

import java.security.Key;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;

import jk.kamoru.flayon.FlayOnException;

public class AES256 implements Crypto {

	private final int AES_KEY_SIZE_128 = 128;
	
	private String charset;
	private String transformation;
	private Key keySpec;
	private IvParameterSpec ivParameterSpec;
	private AlgorithmMode algorithmMode;
	
	public AES256(AlgorithmMode algorithmMode, String key, String iv) {
		this(algorithmMode, key, iv, ENCODING);
	}
	
	public AES256(AlgorithmMode algorithmMode, String key, String iv, String charset) {
		this.algorithmMode = algorithmMode;
		this.charset = charset;
		init(key, iv);
	}
	
	private void init(String key, String iv) {
		try {
			if (key == null || key.length() < 16)
				throw new IllegalStateException("key length must be 16 over");
			
			byte[] keyBytes = key.getBytes(charset);
			keyBytes = Arrays.copyOf(keyBytes, AES_KEY_SIZE_128 / 8);
			keySpec = new SecretKeySpec(keyBytes, AES_ALGORITHM);

			if (algorithmMode == AlgorithmMode.ECB) {
				transformation = AES_ECB_TRANSFORMATION;
			}
			else if (algorithmMode == AlgorithmMode.CBC) {
				transformation = AES_CBC_TRANSFORMATION;
				byte[] ivBytes = null;
				if (iv != null) {
					ivBytes = iv.getBytes(charset);
					ivBytes = Arrays.copyOf(ivBytes, AES_KEY_SIZE_128 / 8);
				}
				else {
					ivBytes = new byte[]{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
				}
				ivParameterSpec = new IvParameterSpec(ivBytes);
			}
			else {
				throw new FlayOnException("Unknown algorithm mode");
			}
		} catch (Exception e) {
			throw new FlayOnException("AES256 initiating error", e);
		}
	}

	// 암호화
	@Override
	public String encrypt(String str) {
		try {
			Cipher cipher = Cipher.getInstance(transformation);
			if (ivParameterSpec == null)
				cipher.init(Cipher.ENCRYPT_MODE, keySpec);
			else
				cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivParameterSpec);
			byte[] bytes = str.getBytes(charset);
			byte[] doFinal = cipher.doFinal(bytes);
			byte[] encodeBase64 = Base64.encodeBase64(doFinal);
			return new String(encodeBase64);
		} catch (Exception e) {
			throw new FlayOnException("AES256 encryption error", e);
		}
	}

	// 복호화
	@Override
	public String decrypt(String str) {
		try {
			Cipher cipher = Cipher.getInstance(transformation);
			if (ivParameterSpec == null)
				cipher.init(Cipher.DECRYPT_MODE, keySpec);
			else
				cipher.init(Cipher.DECRYPT_MODE, keySpec, ivParameterSpec);
			byte[] bytes = str.getBytes();
			byte[] decodeBase64 = Base64.decodeBase64(bytes);
			byte[] doFinal = cipher.doFinal(decodeBase64);
			return new String(doFinal, charset);
		} catch (Exception e) {
			throw new FlayOnException("AES256 decryption error", e);
		}
	}

	public static enum AlgorithmMode {
		ECB, CBC;
	}
}
