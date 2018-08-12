package jk.kamoru.flayon.crazy.video.service;

import java.io.Serializable;

import javax.servlet.http.HttpServletResponse;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;

import jk.kamoru.flayon.crazy.video.VIDEO;

public interface CoverService {

	CoverHttpEntity<byte[]> getVideoCover(HttpServletResponse response, String opus);
	
	CoverHttpEntity<byte[]> getVideoCoverRandom(HttpServletResponse response);
	
	CoverHttpEntity<byte[]> getVideoCoverWithTitle(HttpServletResponse response, String opus);
	
	CoverHttpEntity<byte[]> getVideoCoverRandomWithTitle(HttpServletResponse response);
	
	CoverHttpEntity<byte[]> getActressCover(HttpServletResponse response, String name);

	CoverHttpEntity<byte[]> getActressCoverWithName(HttpServletResponse response, String name);

}

class CoverHttpEntity<T> extends HttpEntity<byte[]> implements Serializable {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	public CoverHttpEntity(byte[] imageBytes, HttpHeaders headers) {
		super(imageBytes, headers);
	}
}
