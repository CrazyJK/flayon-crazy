package jk.kamoru.flayon.base.crypto;

import org.apache.commons.codec.digest.DigestUtils;

import jk.kamoru.flayon.web.BaseException;

public class SHA implements Crypto {

	private AlgorithmType algorithmType;
	
	public SHA(AlgorithmType algorithmType) {
		this.algorithmType = algorithmType;
	}
	
	@Override
	public String encrypt(String str) {
		switch (algorithmType) {
		case SHA1:
			return DigestUtils.sha1Hex(str);
		case SHA256:
			return DigestUtils.sha256Hex(str);
		case SHA384:
			return DigestUtils.sha384Hex(str);
		case SHA512:
			return DigestUtils.sha512Hex(str);
		default:
			throw new BaseException("Unknown sha type");
		}
	}

	@Override
	public String decrypt(String str) {
		throw new BaseException("Not support");
	}

	public static enum AlgorithmType {
		SHA1, SHA256, SHA384, SHA512;
	}
}
