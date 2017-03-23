package jk.kamoru.flayon.crazy;

import static org.junit.Assert.assertTrue;

import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.PublicKey;

import org.junit.Test;

import jk.kamoru.flayon.base.crypto.AES256;
import jk.kamoru.flayon.base.crypto.Crypto;
import jk.kamoru.flayon.base.crypto.RSA;
import jk.kamoru.flayon.base.crypto.SHA;

public class CryptoTest {

	String plain = "가나다1234567890123456 가나다라마바사아자차카타파하";

	@Test
	public void aes256ecb() {
		String key = "crazyjk-kamoru-58818";
		// ECB
		Crypto aes256 = new AES256(AES256.AlgorithmMode.ECB, key, null);
		String encrypt = aes256.encrypt(plain);
		System.out.println("aes256 ecb encrypt : " + encrypt);
		String decrypt = aes256.decrypt(encrypt);
		System.out.println("aes256 ecb decrypt : " + decrypt);

		assertTrue(plain.equals(new String(decrypt)));
	}
	
	@Test
	public void aes256cbcNoIV() {
		String key = "crazyjk-kamoru-58818-6969";
		// CBC
		Crypto aes256 = new AES256(AES256.AlgorithmMode.CBC, key, null);
		String encrypt = aes256.encrypt(plain);
		System.out.println("aes256 cbc no iv encrypt : " + encrypt);
		String decrypt = aes256.decrypt(encrypt);
		System.out.println("aes256 cbc no iv decrypt : " + decrypt);

		assertTrue(plain.equals(new String(decrypt)));
	}

	@Test
	public void aes256cbcWithIV() {
		String key = "crazyjk-kamoru-58818";
		String iv = "jk.kamoru.flayon";
		// CBC
		Crypto aes256 = new AES256(AES256.AlgorithmMode.CBC, key, iv);
		String encrypt = aes256.encrypt(plain);
		System.out.println("aes256 cbc with iv encrypt : " + encrypt);
		String decrypt = aes256.decrypt(encrypt);
		System.out.println("aes256 cbc with iv decrypt : " + decrypt);

		assertTrue(plain.equals(new String(decrypt)));
	}

	@Test
	public void rsa() {
		KeyPair keyPair = RSA.generateKey();
		
		String publicKeyString = RSA.getKeyString(keyPair.getPublic());
		PublicKey publicKey = RSA.getPublicKey(publicKeyString);

		String privateKeyString = RSA.getKeyString(keyPair.getPrivate());
		PrivateKey privateKey = RSA.getPrivateKey(privateKeyString);
		
		System.out.println("rsa public  key : " + publicKeyString);
		System.out.println("rsa pirvate key : " + privateKeyString);
		
		Crypto rsa = new RSA(publicKey, privateKey);
		
		String encrypt = rsa.encrypt(plain);
		System.out.println("rsa encrypt : " + encrypt);
		
		String decrypt = rsa.decrypt(encrypt);
		System.out.println("rsa decrypt : " + decrypt);

		assertTrue(plain.equals(new String(decrypt)));
	}

	@Test
	public void sha1() {
		Crypto sha1 = new SHA(SHA.AlgorithmType.SHA1);
		System.out.println("sha1   encrypt : " + sha1.encrypt(plain));
	}
	@Test
	public void sha256() {
		Crypto sha256 = new SHA(SHA.AlgorithmType.SHA256);
		System.out.println("sha256 encrypt : " + sha256.encrypt(plain));
	}
	@Test
	public void sha384() {
		Crypto sha384 = new SHA(SHA.AlgorithmType.SHA384);
		System.out.println("sha384 encrypt : " + sha384.encrypt(plain));
	}
	@Test
	public void sha512() {
		Crypto sha512 = new SHA(SHA.AlgorithmType.SHA512);
		System.out.println("sha512 encrypt : " + sha512.encrypt(plain));		
	}
	
}
