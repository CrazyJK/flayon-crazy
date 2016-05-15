package jk.kamoru.crazy.image.source;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import jk.kamoru.crazy.CrazyProperties;
import jk.kamoru.crazy.image.IMAGE;
import jk.kamoru.crazy.image.ImageNotFoundException;
import jk.kamoru.crazy.image.domain.Image;
import jk.kamoru.util.FileUtils;
import lombok.extern.slf4j.Slf4j;

import org.apache.commons.lang.math.NumberUtils;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Repository;

/**
 * Implementation of {@link ImageSource}
 * @author kamoru
 *
 */
@Repository
@Slf4j
public class LocalImageSource extends CrazyProperties implements ImageSource {

	private List<Image> imageList;
	
	private boolean loading = false;

	private synchronized void load() {
		loading = true;
		
		int idx = 0;

		if (imageList == null)
			imageList = new ArrayList<Image>();
		imageList.clear();

		for (String path : this.IMAGE_PATHS) {
			File dir = new File(path);
			if (dir.isDirectory()) {
				log.info("image scanning : {}", dir);
				for (File file : FileUtils.listFiles(dir, IMAGE.imageSuffix, true))
					imageList.add(new Image(file, idx++));
			}
		}
		log.info("Total found image size : {}", imageList.size());
		
		Collections.sort(imageList, new Comparator<Image>() {
			@Override
			public int compare(Image o1, Image o2) {
				return NumberUtils.compare(o1.getLastModified(), o2.getLastModified());
			}
		});
		loading = false;
	}

	private List<Image> imageSource() {
		if (imageList == null)
			load();
		else 
			if (loading)
				do {
					try {
						Thread.sleep(500);
					} catch (InterruptedException e) {
						log.error("sleep error", e);
						break;
					}
				} while (loading);
		return imageList;
	}

	@Override
	public Image getImage(int idx) {
		try {
			return imageSource().get(idx);
		}
		catch(IndexOutOfBoundsException  e) {
			throw new ImageNotFoundException(idx, e);
		}
	}

	@Override
	public List<Image> getImageList() {
		return imageSource();
	}

	@Override
	public int getImageSourceSize() {
		return imageSource().size();
	}

	@Override
	public void delete(int idx) {
		imageSource().get(idx).delete();
		imageSource().remove(idx);
	}

	@Override
	@Scheduled(cron = "0 */17 * * * *")
	public void reload() {
		load();
	}

}
