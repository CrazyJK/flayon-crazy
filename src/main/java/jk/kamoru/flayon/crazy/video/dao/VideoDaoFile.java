package jk.kamoru.flayon.crazy.video.dao;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.TitleValidator;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.error.ActressNotFoundException;
import jk.kamoru.flayon.crazy.video.error.StudioNotFoundException;
import jk.kamoru.flayon.crazy.video.error.VideoException;
import jk.kamoru.flayon.crazy.video.error.VideoNotFoundException;
import jk.kamoru.flayon.crazy.video.source.VideoSource;
import lombok.extern.slf4j.Slf4j;

@Repository
@Slf4j
public class VideoDaoFile implements VideoDao {

	@Autowired VideoSource instanceVideoSource;
	@Autowired VideoSource archiveVideoSource;
	@Autowired CrazyConfig config;

	@Override
	public List<Video> getVideoList(Boolean instance, Boolean archive) {
		List<Video> list = new ArrayList<>();
		if (instance)
			list.addAll(instanceVideoSource.getVideoList());
		if (archive)
			list.addAll(archiveVideoSource.getVideoList());
		return list;
	}
	
	@Override
	public List<Studio> getStudioList(Boolean instance, Boolean archive) {
		List<Studio> list = new ArrayList<>();
		if (instance)
			list.addAll(instanceVideoSource.getStudioList());
		if (archive)
			list.addAll(archiveVideoSource.getStudioList());
		return list;
	}

	@Override
	public List<Actress> getActressList(Boolean instance, Boolean archive) {
		List<Actress> list = new ArrayList<>();
		if (instance)
			list.addAll(instanceVideoSource.getActressList());
		if (archive)
			list.addAll(archiveVideoSource.getActressList());
		return list;
	}

	@Override
	public Video getVideo(String opus) {
		try {
			return instanceVideoSource.getVideo(opus);
		} catch (VideoNotFoundException e) {
			return archiveVideoSource.getVideo(opus);
		}
	}
	
	@Override
	public Studio getStudio(String name) {
		try {
			return instanceVideoSource.getStudio(name);
		} catch (StudioNotFoundException e) {
			return archiveVideoSource.getStudio(name);
		}
	}

	@Override
	public Actress getActress(String name) {
		try {
			return instanceVideoSource.getActress(name);
		} catch (ActressNotFoundException e) {
			return  archiveVideoSource.getActress(name);
		}
	}

	@Override
	public void removeVideo(String opus) {
		instanceVideoSource.removeVideo(opus);
	}

	@Override
	public void deleteVideo(String opus) {
		if (contains(opus, true, false))
			instanceVideoSource.deleteVideo(opus);
		else if (contains(opus, false, true))
			archiveVideoSource.deleteVideo(opus);
		else
			throw new VideoNotFoundException(opus);
	}

	@Override
	public void moveVideo(String opus, String destPath) {
		instanceVideoSource.moveVideo(opus, destPath);
	}

	@Override
	public void reload(StopWatch stopWatch, Boolean instance, Boolean archive) {
		if (instance)
			instanceVideoSource.reload(stopWatch);
		if (archive)
			archiveVideoSource.reload(stopWatch);
	}

	@Override
	public boolean contains(String opus, Boolean instance, Boolean archive) {
		boolean found = false;
		if (instance)
			try {
				found = instanceVideoSource.getVideo(opus) != null;
			} catch (VideoException ignore) {
				found = false;
			}
		if (archive)
			found = archiveVideoSource.getVideo(opus) != null;
		return found;
	}

	@Override
	public void arrangeVideo(String opus) {
		Video video = instanceVideoSource.getVideo(opus);
		boolean foundArchive = false;
		// if no cover, find archive
		if (video.isExistVideoFileList()) {
			// cover
			if (!video.isExistCoverFile()) {
				Video archiveVideo = archiveVideoSource.getVideo(opus);
				if (archiveVideo != null) {
					if (archiveVideo.isExistCoverFile()) {
						video.setCoverFile(archiveVideo.getCoverFile());
						foundArchive = true;
					}
				}			
			}
			// subtitles
			if (!video.isExistSubtitlesFileList()) {
				Video archiveVideo = archiveVideoSource.getVideo(opus);
				if (archiveVideo != null) {
					if (archiveVideo.isExistSubtitlesFileList()) {
						video.setSubtitlesFileList(archiveVideo.getSubtitlesFileList());
						foundArchive = true;
					}
				}
			}
		}
		if (foundArchive)
			archiveVideoSource.deleteVideo(opus);
		
		instanceVideoSource.arrangeVideo(opus);
	}

	/* 
	 * (non-Javadoc)
	 * @see jk.kamoru.flayon.crazy.video.dao.VideoDao#moveToInstance(java.lang.String)
	 */
	@Override
	public void moveToInstance(String opus) {
		Video archiveVideo = archiveVideoSource.getVideo(opus);
		if (archiveVideo == null)
			throw new VideoNotFoundException(opus);

		try {
			Video video = instanceVideoSource.getVideo(opus);
			throw new VideoException(video, "this video exist both instance and archive");
		} 
		catch(VideoNotFoundException e) {
			archiveVideo.setArchive(false);
			archiveVideo.move(config.getStagePaths()[0]);
			archiveVideo.resetScore();
			instanceVideoSource.addVideo(archiveVideo);
			archiveVideoSource.removeElement(archiveVideo.getOpus());
		}
	}

	@Override
	public void renameVideo(String opus, String newName) {
		Video video = instanceVideoSource.getVideo(opus);
		video.renameFile(newName);
		List<File> fileAll = video.getFileAll();
		instanceVideoSource.removeElement(opus);
		
		TitleValidator titlePart = new TitleValidator(newName);
		log.info("renameVideo : titlePart = {}", titlePart.getStyleString());
		titlePart.setFiles(fileAll.toArray(new File[fileAll.size()]));
		buildVideo(titlePart);
	}

	@Override
	public void buildVideo(TitleValidator titlePart) {
		instanceVideoSource.addTitlePart(titlePart);
	}

	@Override
	public Studio renameStudio(Map<String, String> data) {
		String name = data.get(Studio.NAME);
		String newName = data.get(Studio.NEWNAME);
		log.info("renameActress name={}, newname={}", name, newName);

		if (!name.equals(newName)) {
			Studio studio = getStudio(name);
			
			Map<String, String> renameData = new HashMap<>();
			for (Video video : studio.getVideoList()) {
				String newFullname = String.format("[%s][%s][%s][%s][%s]", newName, video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate());
				renameData.put(video.getOpus(), newFullname);
			}
			
			for (Map.Entry<String, String> entry : renameData.entrySet()) {
				renameVideo(entry.getKey(), entry.getValue());
			}
		}
		Studio studio = getStudio(newName);
		studio.saveInfo(data);
		return studio;
	}

	@Override
	public Actress renameActress(Map<String, String> data) {
		String name = data.get(Actress.NAME);
		String newName = data.get(Actress.NEWNAME);
		log.info("renameActress name={}, newname={}", name, newName);
		
		if (!name.equals(newName)) {
			Actress actress = getActress(name);
			log.info("renameActress video size = {}", actress.getVideoList().size());
			
			Map<String, String> renameData = new HashMap<>();
			for (Video video : actress.getVideoList()) {
				String actressNames = video.getActressName();
 				String newActressNames = StringUtils.replace(actressNames, name, newName);
				String newFullname = String.format("[%s][%s][%s][%s][%s]", video.getStudio().getName(), video.getOpus(), video.getTitle(), newActressNames, video.getReleaseDate());
				renameData.put(video.getOpus(), newFullname);
			}
			
			for (Map.Entry<String, String> entry : renameData.entrySet()) {
				renameVideo(entry.getKey(), entry.getValue());
			}
		}
		Actress actress = getActress(newName);
		actress.saveInfo(data);
		return actress;
	}
}

