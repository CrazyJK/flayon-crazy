package jk.kamoru.flayon.crazy.video.dao;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.video.ActressNotFoundException;
import jk.kamoru.flayon.crazy.video.StudioNotFoundException;
import jk.kamoru.flayon.crazy.video.VideoException;
import jk.kamoru.flayon.crazy.video.VideoNotFoundException;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.TitlePart;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.source.VideoSource;

@Repository
public class VideoDaoFile extends CrazyProperties implements VideoDao {
	
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
		instanceVideoSource.deleteVideo(opus);
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

//	@Override
//	public void reload(Boolean instance, Boolean archive) {
//		if (instance)
//			instanceVideoSource.reload();
//		if (archive)
//			archiveVideoSource.reload();
//	}

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
			archiveVideo.resetScore();
			archiveVideo.setArchive(false);
			archiveVideo.move(STAGE_PATHS[0]);
			instanceVideoSource.addVideo(archiveVideo);
			archiveVideoSource.removeVideo(archiveVideo.getOpus());
		}
	}

	@Override
	public void renameVideo(String opus, String newName) {
		Video video = instanceVideoSource.getVideo(opus);
		video.rename(newName);
		List<File> fileAll = video.getFileAll();
		instanceVideoSource.removeElement(opus);
		
		TitlePart titlePart = new TitlePart(newName);
		titlePart.setFiles(fileAll.toArray(new File[fileAll.size()]));
		buildVideo(titlePart);
	}

	@Override
	public void buildVideo(TitlePart titlePart) {
		instanceVideoSource.addTitlePart(titlePart);
	}
}

