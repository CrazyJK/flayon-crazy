package jk.kamoru.flayon.crazy;

import static org.junit.Assert.assertFalse;

import java.rmi.server.UID;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.UUID;

import org.apache.commons.codec.digest.DigestUtils;
import org.junit.Test;

import lombok.extern.slf4j.Slf4j;

/**
 * ref. http://www.javapractices.com/topic/TopicAction.do?Id=56
 * @author kamoru
 */
@Slf4j
public class GeneratingUniqueID {

	@Test
	public void javaUtilUUID() {
		UUID idOne = UUID.randomUUID();
		UUID idTwo = UUID.randomUUID();
		log.info("javaUtilUUID : uuid2          = {}", idTwo);
		log.info("javaUtilUUID : uuid1          = {}", idOne);
		log.info("javaUtilUUID : uuid1.hashCode = {}", idOne.hashCode());
		log.info("javaUtilUUID : uuid1.version  = {}", idOne.version());
		log.info("javaUtilUUID : uuid1.variant  = {}", idOne.variant());
		log.info("javaUtilUUID : uuid1.rHyphen  = {}", idOne.toString().replaceAll("-", ""));
		
		assertFalse(idOne.equals(idTwo));
	}

	@Test
	public void secureRandomAndMessageDigest() throws NoSuchAlgorithmException {
		// Initialize SecureRandom
		// This is a lengthy operation, to be done only upon
		// initialization of the application
		SecureRandom prng = SecureRandom.getInstance("SHA1PRNG");

		// generate a random number
		String randomNum = new Integer(prng.nextInt()).toString();

		// get its digest
		MessageDigest sha = MessageDigest.getInstance("SHA-1");
		byte[] result = sha.digest(randomNum.getBytes());
		String hexEncode = hexEncode(result);

		String randomNum2 = new Integer(prng.nextInt()).toString();
		byte[] result2 = sha.digest(randomNum2.getBytes());
		String hexEncode2 = hexEncode(result2);

		String sha1Hex = DigestUtils.sha1Hex(randomNum2);
		
		log.info("secureRandomAndMessageDigest : Random number       = {}", randomNum);
		log.info("secureRandomAndMessageDigest : Message digest      = {}", hexEncode);
		log.info("secureRandomAndMessageDigest : Random number       = {}", randomNum2);
		log.info("secureRandomAndMessageDigest : Message digest      = {}", hexEncode2);
		log.info("secureRandomAndMessageDigest : DigestUtils.sha1Hex = {}", sha1Hex);
		
		assertFalse(randomNum.equals(randomNum2) || hexEncode.equals(hexEncode2));
	}

	@Test
	public void javaRmiServerUid() {
		UID user1 = new UID();
		UID user2 = new UID();
		log.info("javaRmiServerUid : UID1 = {}", user1);
		log.info("javaRmiServerUid : UID2 = {}", user2);
		
		assertFalse(user1.equals(user2));
	}
	
	/**
	 * The byte[] returned by MessageDigest does not have a nice textual
	 * representation, so some form of encoding is usually performed.
	 *
	 * This implementation follows the example of David Flanagan's book "Java In
	 * A Nutshell", and converts a byte array into a String of hex characters.
	 *
	 * Another popular alternative is to use a "Base64" encoding.
	 */
	static private String hexEncode(byte[] aInput) {
		StringBuilder result = new StringBuilder();
		char[] digits = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		for (int idx = 0; idx < aInput.length; ++idx) {
			byte b = aInput[idx];
			result.append(digits[(b & 0xf0) >> 4]);
			result.append(digits[b & 0x0f]);
		}
		return result.toString();
	}

}
