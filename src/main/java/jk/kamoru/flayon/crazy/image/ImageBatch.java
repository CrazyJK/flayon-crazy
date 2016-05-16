package jk.kamoru.flayon.crazy.image;

import java.io.File;
import java.util.Collection;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.Utils;

@Slf4j
@Component
public class ImageBatch extends CrazyProperties {

	private final String[] extensions = new String[]{"gif", "jpg", "jpeg", "png"};
	
	@Scheduled(cron="*/10 * * * * *")
	public synchronized void renameSoraPicture() {
		log.debug("Rename Sora picture Start");

		if (PATH_SORA_PICTURES == null) {
			log.warn("PATH_SORA_PICTURES is not set");
			return;
		}
		
		for (String soraPath : PATH_SORA_PICTURES) {
			
			File directory = new File(soraPath);
			if (!directory.isDirectory()) {
				log.warn("not directory : {}", soraPath);
				continue;
			}
			
			Collection<File> found = FileUtils.listFiles(directory, extensions, false);
			log.debug("{} found : {}", soraPath, found.size());
			
			String folderName = directory.getName();
			for (File file : found) {
				if (StringUtils.startsWith(file.getName(), folderName)) {
					continue;
				}
				else {
					String suffix = Utils.getExtension(file);
					File dest = new File(directory, folderName + "_" + file.lastModified() + "." + suffix);

					file.renameTo(dest);
					log.info("rename {} to {}", file.getName(), dest.getName());
				}
			}
		}
		log.debug("Rename Sora picture End");
	}
	
}
