package jk.kamoru.flayon.crazy.video.source;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import javax.inject.Provider;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.ActressNotFoundException;
import jk.kamoru.flayon.crazy.video.StudioNotFoundException;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.VideoNotFoundException;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.util.VideoUtils;
	

public class FileBaseVideoSource implements VideoSource {
	
	protected static final Logger logger = LoggerFactory.getLogger(FileBaseVideoSource.class);

	public static final String unclassifiedActress = "Amateur";

	private final String UNKNOWN 			 = "_Unknown";
	private final String unclassifiedStudio  = UNKNOWN;
//	private final String unclassifiedOpus 	 = UNKNOWN;

	// data source
	private Map<String, Video>     videoMap	= new HashMap<>();
	private Map<String, Studio>   studioMap	= new HashMap<>();
	private Map<String, Actress> actressMap = new HashMap<>();
	
	// Domain provider
	@Inject Provider<Video>     videoProvider;
	@Inject Provider<Studio>   studioProvider;
	@Inject Provider<Actress> actressProvider;

	// logic variables
	private static boolean firstLoad = false;
	private static boolean loading = false;
	
	// property
	private String[] paths;
	private boolean isArchive;

	// property setter
	public void setPaths(String...paths) {
		logger.info(ArrayUtils.toString(paths, "IS NULL"));
		this.paths = paths;
	}
	public void setArchive(boolean isArchive) {
		this.isArchive = isArchive;
	}
	/**
	 * 기존에 만든적이 없으면, video source를 로드를 호출한다.
	 */
	private final void videoSource() {
//		logger.info("videoSource START firstLoad = {}", firstLoad);
		if (firstLoad) {
//			logger.info("loading = {}", loading);
			if (loading) {
				do {
					try {
						logger.info("loading...");
						Thread.sleep(500);
					} catch (InterruptedException e) {
						logger.error("sleep error", e);
						break;
					}
				} while(loading);
			}
		}
		else {
			load();
		}
//		logger.info("videoSource END");			
	}
	
	/**
	 * video데이터를 로드한다.
	 */
	private synchronized void load() {
		logger.debug("load START");
		firstLoad = true;
		loading = true;
		
		// find files
		Collection<File> files = Utils.listFiles(paths, null, true);
		logger.debug("    total found file {}", files.size());

		videoMap.clear();
		studioMap.clear();
		actressMap.clear();

		// 3. domain create & data source   
		for (File file : files) {
			try {
				String filename = file.getName();
				String     name = Utils.getNameExceptExtension(file);
				String      ext = Utils.getExtension(file).toLowerCase();
				
				// 연속 스페이스 제거
				name = StringUtils.normalizeSpace(name);
				
				// Unnecessary file exclusion
				if (filename.equals(VIDEO.HISTORY_LOG) 
						|| filename.equals(VIDEO.MAC_NETWORKSTORES)
						|| filename.equals(VIDEO.WINDOW_DESKTOPINI)
						|| ext.equals(VIDEO.EXT_ACTRESS) 
						|| ext.equals(VIDEO.EXT_STUDIO) 
						|| filename.equals(VIDEO.TAG_DATA_FILENAME)) {
					continue;
				}
				
				// 1       2     3      4        5     6
				// [studio][opus][title][actress][date]etc...
				String[] names 		= StringUtils.split(name, "]", 6);
				if (names == null || names.length < 5) {
					logger.warn("Unclassified file {}", file.getAbsolutePath());
					continue;
				}

				String studioName  	= VideoUtils.removeUnnecessaryCharacter(names[0], unclassifiedStudio);
				String opus    		= VideoUtils.removeUnnecessaryCharacter(names[1]);
				String title   		= VideoUtils.removeUnnecessaryCharacter(names[2], UNKNOWN);
				String actressNames = VideoUtils.removeUnnecessaryCharacter(names[3], unclassifiedActress);
				String releaseDate  = VideoUtils.removeUnnecessaryCharacter(names[4]);
				String etcInfo 		= "";
				if (names.length > 5)
					etcInfo 	    = VideoUtils.removeUnnecessaryCharacter(names[5]);
				
				Video video = videoMap.get(opus.toLowerCase());
				if (video == null) {
					video = videoProvider.get();
					video.setOpus(opus.toUpperCase());
					video.setTitle(title);
					video.setReleaseDate(releaseDate);
					video.setEtcInfo(etcInfo);
					video.setArchive(isArchive);
					videoMap.put(opus.toLowerCase(), video);
				}
				// set video File
				if (VIDEO.SUFFIX_VIDEO.contains(ext))
					video.addVideoFile(file);
				else if (VIDEO.SUFFIX_IMAGE.contains(ext))
					video.setCoverFile(file);
				else if (VIDEO.SUFFIX_SUBTITLES.contains(ext))
					video.addSubtitlesFile(file);
				else if (VIDEO.EXT_INFO.equalsIgnoreCase(ext))
					video.setInfoFile(file);
				else
					video.addEtcFile(file);
				
				Studio studio = studioMap.get(studioName.toLowerCase());
				if (studio == null) {
					studio = studioProvider.get();
					studio.setName(studioName);
					studioMap.put(studioName.toLowerCase(), studio);
				}
				// inject reference
				studio.addVideo(video);
				video.setStudio(studio);
				
				for (String actressName : StringUtils.split(actressNames, ",")) { 
					String forwardActressName = VideoUtils.sortForwardName(actressName);
					Actress actress = actressMap.get(forwardActressName);
					if (actress == null) {
						actress = actressProvider.get();
						actress.setName(actressName.trim());
						actressMap.put(forwardActressName, actress);
						
						if (actressName.trim().length() == 0) {
							logger.error("Check file {}", file);
						}
					}
					// inject reference
					actress.addVideo(video);
					actress.addStudio(studio);

					studio.addActress(actress);
					video.addActress(actress);
				}
			}
			catch (Exception e) {
				logger.error("File loading error", e);
			}
		}
		logger.debug("    total loaded video {}", videoMap.size());
		loading = false;
		logger.debug("load END");
	}

	@Override
	@PostConstruct
	public void reload() {
		load();
		logger.info("reload completed");
	}
	
	@Override
	public Map<String, Video> getVideoMap() {
		videoSource();
		return videoMap;
	}
	@Override
	public Map<String, Studio> getStudioMap() {
		videoSource();
		return studioMap;
	}
	@Override
	public Map<String, Actress> getActressMap() {
		videoSource();
		return actressMap;
	}
	@Override
	public Video getVideo(String opus) {
		videoSource();
		if (videoMap.containsKey(opus.toLowerCase()))
			return videoMap.get(opus.toLowerCase());
		else
			if (isArchive)
				return null;
			else
				throw new VideoNotFoundException(opus);
	}
	@Override
	public Studio getStudio(String name) {
		videoSource();
		if (studioMap.containsKey(name.toLowerCase()))
			return studioMap.get(name.toLowerCase());
		else
			if (isArchive)
				return new Studio();
			else
				throw new StudioNotFoundException(name);
	}
	@Override
	public Actress getActress(String name) {
		videoSource();
		if (actressMap.containsKey(VideoUtils.sortForwardName(name)))
			return actressMap.get(VideoUtils.sortForwardName(name));
		else
			if (isArchive)
				return new Actress();
			else
				throw new ActressNotFoundException(name);
	}
	@Override
	public List<Video> getVideoList() {
		videoSource();
		return new ArrayList<Video>(videoMap.values());
	}
	@Override
	public List<Studio> getStudioList() {
		videoSource();
		return new ArrayList<Studio>(studioMap.values());
	}
	@Override
	public List<Actress> getActressList() {
		videoSource();
		return new ArrayList<Actress>(actressMap.values());
	}
	@Override
	public void moveVideo(String opus, String destPath) {
		videoSource();
		videoMap.get(opus.toLowerCase()).move(destPath);
	}
	@Override
	public void arrangeVideo(String opus) {
		videoSource();
		videoMap.get(opus.toLowerCase()).arrange();
	}
	@Override
	public void removeVideo(String opus) {
		videoSource();
		videoMap.get(opus.toLowerCase()).removeVideo();
		videoMap.remove(opus.toLowerCase());
	}
	@Override
	public void deleteVideo(String opus) {
		videoSource();
		videoMap.get(opus.toLowerCase()).deleteVideo();
		videoMap.remove(opus.toLowerCase());
	}

}
