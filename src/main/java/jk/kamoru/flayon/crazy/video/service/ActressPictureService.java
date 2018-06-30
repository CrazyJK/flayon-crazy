package jk.kamoru.flayon.crazy.video.service;

import org.springframework.web.multipart.MultipartFile;

public interface ActressPictureService {

	void store(MultipartFile multipartFile, String name);
	
}
