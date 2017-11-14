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

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.error.ActressNotFoundException;
import jk.kamoru.flayon.crazy.error.StudioNotFoundException;
import jk.kamoru.flayon.crazy.error.VideoException;
import jk.kamoru.flayon.crazy.error.VideoNotFoundException;
import jk.kamoru.flayon.crazy.util.VideoUtils;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.TitlePart;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.source.VideoSource;
import lombok.extern.slf4j.Slf4j;

@Repository
@Slf4j
public class VideoDaoFile implements VideoDao {

	@Autowired CrazyProperties crazyProperties;
	@Autowired private VideoSource instanceVideoSource;
	@Autowired private VideoSource archiveVideoSource;

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
			return archiveVideoSource.getActress(name);
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
			archiveVideo.move(crazyProperties.getSTAGE_PATHS()[0]);
			archiveVideo.resetScore();
			instanceVideoSource.addVideo(archiveVideo);
			archiveVideoSource.removeElement(archiveVideo.getOpus());
		}
	}

	@Override
	public void renameVideo(String opus, String newName) {
		Video video = instanceVideoSource.getVideo(opus);
		video.rename(newName);
		List<File> fileAll = video.getFileAll();
		instanceVideoSource.removeElement(opus);
		
		log.info("renameVideo : opus={}, newName={}", opus, newName);
		TitlePart titlePart = new TitlePart(newName);
		log.info("renameVideo : titlePart = {}", titlePart.getStyleString());
		titlePart.setFiles(fileAll.toArray(new File[fileAll.size()]));
		buildVideo(titlePart);
	}

	@Override
	public void buildVideo(TitlePart titlePart) {
		instanceVideoSource.addTitlePart(titlePart);
	}

	@Override
	public Studio renameStudio(Map<String, String> data) {
		String studioName = data.get("name");
		String studioNewName = data.get("newname");
		if (!StringUtils.equals(studioName, studioNewName)) {
			Studio studio = instanceVideoSource.getStudio(studioName.toUpperCase());	
			Map<String, String> renameData = new HashMap<>();
			for (Video video : studio.getVideoList()) {
				String newFullname = String.format("[%s][%s][%s][%s][%s]", studioNewName, video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate());
				renameData.put(video.getOpus(), newFullname);
			}
			for (Map.Entry<String, String> entry : renameData.entrySet()) {
				renameVideo(entry.getKey(), entry.getValue());
			}
		}
		Studio studio = instanceVideoSource.getStudio(studioNewName.toUpperCase());
		studio.saveInfo(data);
		return studio;
	}

	@Override
	public Actress renameActress(Map<String, String> data) {
		String actressName = data.get("name");
		String actressNewName = data.get("newname");
		log.info("renameActress name={}, newname={}", actressName, actressNewName);
		
		if (!actressName.equals(actressNewName)) {
			Actress actress = instanceVideoSource.getActress(VideoUtils.sortForwardName(actressName));
			log.info("renameActress video size = {}", actress.getVideoList());
			
			Map<String, String> renameData = new HashMap<>();
			for (Video video : actress.getVideoList()) {
				String actressNames = video.getActressName();
 				String newActressNames = StringUtils.replace(actressNames, actressName, actressNewName);
				String newFullname = String.format("[%s][%s][%s][%s][%s]", video.getStudio().getName(), video.getOpus(), video.getTitle(), newActressNames, video.getReleaseDate());
				renameData.put(video.getOpus(), newFullname);
			}
			
			for (Map.Entry<String, String> entry : renameData.entrySet()) {
				renameVideo(entry.getKey(), entry.getValue());
			}
		}
		Actress actress = instanceVideoSource.getActress(VideoUtils.sortForwardName(actressNewName));
		actress.saveInfo(data);
		return actress;
	}
}

