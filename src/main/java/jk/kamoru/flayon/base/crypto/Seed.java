package jk.kamoru.flayon.base.crypto;

import java.io.UnsupportedEncodingException;

import org.apache.commons.codec.binary.Base64;

import jk.kamoru.flayon.base.BaseException;
import jk.kamoru.flayon.base.crypto.seed.KISA_SEED_CBC;
import jk.kamoru.flayon.base.crypto.seed.KISA_SEED_CTR;
import jk.kamoru.flayon.base.crypto.seed.KISA_SEED_ECB;

public class Seed implements Crypto {

	public static enum AlgorithmMode {
		ECB, CBC, CTR;
	}

	private static final int LIMIT = 100;
	
	private AlgorithmMode mode;
	private byte[] key = new byte[16];
	private byte[] iv  = new byte[16];
	private byte[] ctr = {(byte)0x000, (byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000,(byte)0x000, (byte)0x0CE};
	private String charset;
	
	public Seed(AlgorithmMode mode, String key, String iv) {
		this(mode, key, iv, ENCODING);
	}

	public Seed(AlgorithmMode mode, String key, String iv, String charset) {
		this.mode = mode;
		this.charset = charset;
		init(key, iv);
	}
	
	private void init(String key, String iv) {
		try {
			byte[] keyBytes = key.getBytes(charset);
			if (keyBytes.length < 16) {
				throw new BaseException("key size must be 16 bytes");
			} else if (keyBytes.length > 16) {
				System.arraycopy(keyBytes, 0, this.key, 0, 16);
			} else {
				this.key = keyBytes;
			}
			
			if (iv == null) {
				if (this.mode == AlgorithmMode.CBC) {
					throw new BaseException("CBC mode need to iv");
				}
			}
			else {
				byte[] ivBytes = iv.getBytes(charset);
				if (ivBytes.length < 16) {
					throw new BaseException("iv size must be 16 bytes");
				} else if (ivBytes.length > 16) {
					System.arraycopy(ivBytes, 0, this.iv, 0, 16);
				} else {
					this.iv = ivBytes;
				}
			}
		} catch (UnsupportedEncodingException e) {
			throw new BaseException("Seed initiating error", e);
		}
	}

	@Override
	public String encrypt(String str) {
		if (str == null)
			throw new BaseException("SEED encryption error : input string null");
		switch (mode) {
		case ECB:
			return encryptECB(str);
		case CBC:
			return encryptCBC(str);
		case CTR:
			return encryptCTR(str);
		default:
			throw new BaseException("Unknown seed algorithmMode");
		}
	}

	@Override
	public String decrypt(String str) {
		if (str == null)
			throw new BaseException("SEED decryption error : input string null");
		switch (mode) {
		case ECB:
			return decryptECB(str);
		case CBC:
			return decryptCBC(str);
		case CTR:
			return decryptCTR(str);
		default:
			throw new BaseException("Unknown seed algorithmMode");
		}
	}

	private String encryptCBC(String str) {
		try {
			byte[] message = str.getBytes(charset);
			byte[] seed_CBC_Encrypt;
			if (str.length() < LIMIT) {
				seed_CBC_Encrypt = KISA_SEED_CBC.SEED_CBC_Encrypt(key, iv, message, 0, message.length);
			}
			else {
				seed_CBC_Encrypt = KISA_SEED_CBC.encrypt(key, iv, message);
			}
			return new String(Base64.encodeBase64(seed_CBC_Encrypt));
		} catch (Exception e) {
			throw new BaseException("SEED CBC encryption error", e);
		}
	}

	private String decryptCBC(String str) {
		try {
			byte[] message = Base64.decodeBase64(str.getBytes());
			byte[] seed_CBC_Decrypt;
			if (str.length() < LIMIT) {
				seed_CBC_Decrypt = KISA_SEED_CBC.SEED_CBC_Decrypt(key, iv, message, 0, message.length);
			}
			else {
				seed_CBC_Decrypt = KISA_SEED_CBC.decrypt(key, iv, message);
			}
			return new String(seed_CBC_Decrypt, charset);
		} catch (Exception e) {
			throw new BaseException("SEED CBC decryption error", e);
		}
	}

	private String encryptECB(String str) {
		try {
			byte[] message = str.getBytes(charset);
			byte[] seed_ECB_Encrypt;
			if (str.length() < LIMIT) {
				seed_ECB_Encrypt = KISA_SEED_ECB.SEED_ECB_Encrypt(key, message, 0, message.length);
			}
			else {
				seed_ECB_Encrypt = KISA_SEED_ECB.encrypt(key, message);
			}
			return new String(Base64.encodeBase64(seed_ECB_Encrypt));
		} catch (Exception e) {
			throw new BaseException("SEED ECB encryption error", e);
		}
	}
	
	private String decryptECB(String str) {
		try {
			byte[] pbCipher = Base64.decodeBase64(str.getBytes());
			byte[] seed_ECB_Decrypt;
			if (str.length() < LIMIT) {
				seed_ECB_Decrypt = KISA_SEED_ECB.SEED_ECB_Decrypt(key, pbCipher, 0, pbCipher.length);
			}
			else {
				seed_ECB_Decrypt = KISA_SEED_ECB.decrypt(key, pbCipher);
			}
			return new String(seed_ECB_Decrypt, charset);
		} catch (Exception e) {
			throw new BaseException("SEED ECB decryption error", e);
		}
	}

	private String encryptCTR(String str) {
		try {
			byte[] message = str.getBytes(charset);
			byte[] seed_CTR_Encrypt;
			if (str.length() < LIMIT) {
				seed_CTR_Encrypt = KISA_SEED_CTR.SEED_CTR_Encrypt(key, ctr, message, 0, message.length);
			}
			else {
				seed_CTR_Encrypt = KISA_SEED_CTR.encrypt(key, ctr, message);
			}
			return new String(Base64.encodeBase64(seed_CTR_Encrypt));
		} catch (Exception e) {
			throw new BaseException("SEED CTR encryption error", e);
		}
	}

	private String decryptCTR(String str) {
		try {
			byte[] pbCipher = Base64.decodeBase64(str.getBytes());
			byte[] seed_CTR_Decrypt;
			if (str.length() < LIMIT) {
				seed_CTR_Decrypt = KISA_SEED_CTR.SEED_CTR_Decrypt(key, ctr, pbCipher, 0, pbCipher.length);
			}
			else {
				seed_CTR_Decrypt = KISA_SEED_CTR.decrypt(key, ctr, pbCipher);
			}
			return new String(seed_CTR_Decrypt, charset);
		} catch (Exception e) {
			throw new BaseException("SEED CTR decryption error", e);
		}
	}

}
