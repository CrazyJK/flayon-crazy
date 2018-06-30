package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.dao.VideoDao;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class ActressPictureServiceImpl implements ActressPictureService {

	@Autowired CrazyConfig config;
	@Autowired VideoDao videoDao;

	@Override
	public void store(MultipartFile multipartFile, String name) {
		String sourceFileNameExtension = FilenameUtils.getExtension(multipartFile.getOriginalFilename()).toLowerCase(); 
		try {
			String pictureName = name + "." + sourceFileNameExtension;
			File destinationFile = new File(config.getStoragePath() + CRAZY.PATH + "_info", pictureName);
			multipartFile.transferTo(destinationFile);
			log.info("save uploaded file : {}", destinationFile);
			
			Actress actress = videoDao.getActress(name);
			actress.setImage(destinationFile);
			
		} catch (IllegalStateException | IOException e) {
			throw new CrazyException("Fail to store uploaded file:" + e.getMessage(), e);
		}
	}

}
