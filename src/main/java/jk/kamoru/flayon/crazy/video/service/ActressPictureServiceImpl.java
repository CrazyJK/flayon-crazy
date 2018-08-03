package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.dao.VideoDao;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ActressPictureServiceImpl implements ActressPictureService {

	@Autowired
	CrazyConfig config;
	@Autowired
	VideoDao videoDao;

	@Override
	public void store(MultipartFile multipartFile, String name) {
		String multipartFileExtension = FilenameUtils.getExtension(multipartFile.getOriginalFilename()).toLowerCase();
		String suffix = StringUtils.isBlank(multipartFileExtension) ? "" : "." + multipartFileExtension;

		try {
			File destinationFile = new File(config.getStoragePath() + CRAZY.PATH + "_info", name + suffix);
			multipartFile.transferTo(destinationFile);
			log.info("save uploaded file : {}", destinationFile);

			Actress actress = videoDao.getActress(name);
			actress.setImage(destinationFile);

		} catch (IllegalStateException | IOException e) {
			throw new CrazyException("Fail to store uploaded file:" + e.getMessage(), e);
		}
	}

}
