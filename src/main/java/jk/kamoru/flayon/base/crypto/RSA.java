/**
 * ref) http://swlock.blogspot.kr/2016/01/rsa-java-2-3.html
 */
package jk.kamoru.flayon.base.crypto;

import java.security.Key;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;

import javax.crypto.Cipher;

import org.apache.commons.codec.binary.Base64;

import jk.kamoru.flayon.FlayOnException;

public class RSA implements Crypto {

	private PublicKey publicKey;
	private PrivateKey privateKey;
	private String charset;

	public RSA(KeyPair keyPair) {
		this(keyPair.getPublic(), keyPair.getPrivate(), ENCODING);
	}

	public RSA(KeyPair keyPair, String charset) {
		this(keyPair.getPublic(), keyPair.getPrivate(), charset);
	}

	public RSA(PublicKey publicKey, PrivateKey privateKey) {
		this(publicKey, privateKey, ENCODING);
	}

	public RSA(PublicKey publicKey, PrivateKey privateKey, String charset) {
		this.publicKey = publicKey;
		this.privateKey = privateKey;
		this.charset = charset;
	}

	@Override
	public String encrypt(String str) {
		try {
			Cipher cipher = Cipher.getInstance(RSA_TRANSFORMATION, RSA_PROVIDER);
			cipher.init(Cipher.ENCRYPT_MODE, publicKey);
			byte[] bytes = str.getBytes(charset);
			byte[] doFinal = cipher.doFinal(bytes);
			byte[] encodeBase64 = Base64.encodeBase64(doFinal);
			return new String(encodeBase64);
		} catch (Exception e) {
			throw new FlayOnException("RSA encryption error", e);
		}
	}

	@Override
	public String decrypt(String str) {
		try {
			Cipher cipher = Cipher.getInstance(RSA_TRANSFORMATION, RSA_PROVIDER);
			cipher.init(Cipher.DECRYPT_MODE, privateKey);
			byte[] bytes = str.getBytes();
			byte[] decodeBase64 = Base64.decodeBase64(bytes);
			byte[] doFinal = cipher.doFinal(decodeBase64);
			return new String(doFinal, charset);
		} catch (Exception e) {
			throw new FlayOnException("RSA decryption error", e);
		}
	}

	public static KeyPair generateKey() {
		try {
			SecureRandom random = new SecureRandom();
			KeyPairGenerator generator = KeyPairGenerator.getInstance(RSA_ALGORITHM);

			generator.initialize(2048, random);
			return generator.generateKeyPair();
		} catch (Exception e) {
			throw new FlayOnException("fail to generate key", e);
		}
	}

	public static String getKeyString(Key key) {
		return byteArrayToHex(key.getEncoded());
	}

	public static PublicKey getPublicKey(String publicKeyString) {
		try {
			X509EncodedKeySpec keySpec = new X509EncodedKeySpec(hexToByteArray(publicKeyString));
			KeyFactory keyFactory = KeyFactory.getInstance(RSA_ALGORITHM);
			return keyFactory.generatePublic(keySpec);
		} catch (Exception e) {
			throw new FlayOnException("fail to generate key", e);
		}
	}
	
	public static PrivateKey getPrivateKey(String privateKeyString) {
		try {
			PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(hexToByteArray(privateKeyString));
			KeyFactory keyFactory = KeyFactory.getInstance(RSA_ALGORITHM);
			return keyFactory.generatePrivate(keySpec);
		} catch (Exception e) {
			throw new FlayOnException("fail to generate key", e);
		}
	}
	
	// byte[] to hex sting
	private static String byteArrayToHex(byte[] ba) {
		if (ba == null || ba.length == 0) {
			return null;
		}
		StringBuffer sb = new StringBuffer(ba.length * 2);
		String hexNumber;
		for (int x = 0; x < ba.length; x++) {
			hexNumber = "0" + Integer.toHexString(0xff & ba[x]);
			sb.append(hexNumber.substring(hexNumber.length() - 2));
		}
		return sb.toString();
	}

	// hex string to byte[]
	private static byte[] hexToByteArray(String hex) {
		if (hex == null || hex.length() == 0) {
			return null;
		}
		byte[] ba = new byte[hex.length() / 2];
		for (int i = 0; i < ba.length; i++) {
			ba[i] = (byte) Integer.parseInt(hex.substring(2 * i, 2 * i + 2), 16);
		}
		return ba;
	}
	 
}
