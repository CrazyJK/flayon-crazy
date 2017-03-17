package jk.kamoru.flayon.crazy.image;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.Utils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class ImageBatch extends CrazyProperties {

	private boolean isSet = true;
	
	@Scheduled(fixedDelay = 1000 * 60)
	public synchronized void renameSoraPicture() {
		log.debug("Rename Sora picture Start");

		if (isSet && (SORA_PICTURES_PATHS == null || SORA_PICTURES_PATHS.length < 1)) {
			isSet = false;
			log.warn("PATH_SORA_PICTURES is not set");
			return;
		}
		
		for (String soraPath : SORA_PICTURES_PATHS) {
			File directory = new File(soraPath);
			if (!directory.isDirectory()) {
				log.warn("not directory : {}", soraPath);
				continue;
			}
			
			for (File file : FileUtils.listFiles(directory, IMAGE.SUFFIX_IMAGE_ARRAY, false)) {
				if (StringUtils.startsWith(file.getName(), directory.getName()))
					continue;

				File dest = new File(directory, directory.getName() + "_" + file.lastModified() + "." + Utils.getExtension(file));
				file.renameTo(dest);
				log.info("rename {} to {}", file.getName(), dest.getName());
			}
		}
		log.debug("Rename Sora picture End");
	}
	
}
