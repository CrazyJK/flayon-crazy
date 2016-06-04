package jk.kamoru.flayon.crazy.video.dao;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import jk.kamoru.flayon.crazy.video.ActressNotFoundException;
import jk.kamoru.flayon.crazy.video.StudioNotFoundException;
import jk.kamoru.flayon.crazy.video.VideoException;
import jk.kamoru.flayon.crazy.video.VideoNotFoundException;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.source.VideoSource;

//@SuppressWarnings("unused")
@Repository
public class VideoDaoFile implements VideoDao {
	
	protected static final Logger logger = LoggerFactory.getLogger(VideoDaoFile.class);

	@Autowired private VideoSource instanceVideoSource;
	@Autowired private VideoSource archiveVideoSource;

	@Override
//	@Cacheable(value="videoCache")
	public List<Video> getVideoList() {
		return instanceVideoSource.getVideoList();
	}
	
	@Override
//	@Cacheable("studioCache")
	public List<Studio> getStudioList() {
		logger.trace("getStudioList");
		return instanceVideoSource.getStudioList();
	}

	@Override
//	@Cacheable("actressCache")
	public List<Actress> getActressList() {
		logger.trace("getActressList");
		return instanceVideoSource.getActressList();
	}

	@Override
//	@Cacheable(value="videoCache")
	public Video getVideo(String opus) {
		logger.trace(opus);
		try {
			return instanceVideoSource.getVideo(opus);
		} catch (VideoNotFoundException e) {
			return archiveVideoSource.getVideo(opus);
		}
	}

	@Override
	public Video getArchiveVideo(String opus) {
		logger.trace(opus);
		return archiveVideoSource.getVideo(opus);
	}
	
	@Override
//	@Cacheable("studioCache")
	public Studio getStudio(String name) {
		logger.trace(name);
		try {
			return instanceVideoSource.getStudio(name);
		} catch (StudioNotFoundException e) {
			return archiveVideoSource.getStudio(name);
		}
	}

	@Override
//	@Cacheable("actressCache")
	public Actress getActress(String name) {
		logger.trace(name);
		try {
			return instanceVideoSource.getActress(name);
		} catch (ActressNotFoundException e) {
			return archiveVideoSource.getActress(name);
		}
	}

	@Override
//	@CacheEvict(value = { "videoCache" }, allEntries=true)
	public void removeVideo(String opus) {
		logger.trace(opus);
		instanceVideoSource.removeVideo(opus);
	}

	@Override
	public void deleteVideo(String opus) {
		logger.trace(opus);
		instanceVideoSource.deleteVideo(opus);
	}

	@Override
//	@CacheEvict(value = { "videoCache" }, allEntries=true)
	public void moveVideo(String opus, String destPath) {
		logger.trace(opus);
		long elapsedTime = System.currentTimeMillis();
		instanceVideoSource.moveVideo(opus, destPath);
		logger.info("{} moved. elapsed time {} ms", opus, System.currentTimeMillis() - elapsedTime);
	}
	@Override
//	@CacheEvict(value = { "videoCache", "studioCache", "actressCache" }, allEntries=true)
	public void reload() {
		logger.trace("reload");
		instanceVideoSource.reload();
	}

	@Override
	public void arrangeVideo(String opus) {
		logger.trace(opus);
		instanceVideoSource.arrangeVideo(opus);
	}

	@Override
	public boolean contains(String opus) {
		try {
			instanceVideoSource.getVideo(opus);
			return true;
		} catch (VideoException e) {
			return false;
		}
	}

	@Override
	public List<Video> getArchiveVideoList() {
		return archiveVideoSource.getVideoList();
	}


}

