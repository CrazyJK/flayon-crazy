package jk.kamoru.flayon.crazy.video.source;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import javax.inject.Provider;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.error.ActressNotFoundException;
import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.error.StudioNotFoundException;
import jk.kamoru.flayon.crazy.error.VideoNotFoundException;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import jk.kamoru.flayon.crazy.util.VideoUtils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.TitlePart;
import jk.kamoru.flayon.crazy.video.domain.Video;
	

/**
 * implementations VideoSource
 * 
 * @author kamoru
 */
public class FileBaseVideoSource implements VideoSource {
	
	protected static final Logger logger = LoggerFactory.getLogger(FileBaseVideoSource.class);

	// domain map
	private Map<String, Video>     videoMap	= new HashMap<>();
	private Map<String, Studio>   studioMap	= new HashMap<>();
	private Map<String, Actress> actressMap = new HashMap<>();

	// Domain provider
	@Inject Provider<Video>     videoProvider;
	@Inject Provider<Studio>   studioProvider;
	@Inject Provider<Actress> actressProvider;

	// logic variables
	private boolean firstCall = true;
	private boolean startLoad = false;
	
	// property
	private boolean isArchive;
	private String torrentPath;
	private String[] paths;

	/**
	 * @param isArchive
	 * @param torrentPath
	 * @param paths
	 */
	public FileBaseVideoSource(boolean isArchive, String torrentPath, String...paths) {
		this.isArchive = isArchive;
		this.torrentPath = torrentPath;
		this.paths = paths;
		logger.info("{} set {}, {}", toTypeString(), torrentPath, ArrayUtils.toString(paths, "IS NULL"));
	}
	
	private String toTypeString() {
		return isArchive ? "Archive" : "Instance";
	}
	
	/**
	 * 첫 call이면 load()
	 */
	private final void videoSource() {
		if (firstCall) {
			if (startLoad) {
				while(startLoad) {
					try {
						logger.warn("loading... {}", toTypeString());
						Thread.sleep(500);
					} catch (InterruptedException e) {
						logger.error("sleep error", e);
						break;
					}
				}
			}
			else {
				load(null);
			}
		}
	}
	
	private synchronized void load(StopWatch stopWatch) {
		firstCall = false;
		startLoad = true;
		logger.debug("Start {} video source load", toTypeString());
		boolean standalone = false;
		if (stopWatch == null) {
			standalone = true;
			stopWatch = new StopWatch(toTypeString() + " VideoSource load");
		}
		

		List<String> wrongFileNames = new ArrayList<>();
		
		// find files
		stopWatch.start("load : listFiles");
		Collection<File> files = CrazyUtils.listFiles(paths, null, true);
		stopWatch.stop();

//		videoMap.clear();
//		studioMap.clear();
//		actressMap.clear();

		Map<String, Video>     _videoMap = new HashMap<>();
		Map<String, Studio>   _studioMap = new HashMap<>();
		Map<String, Actress> _actressMap = new HashMap<>();

		// domain create & data source
		stopWatch.start("load : make Video object in " + files.size() + " files");
		for (File file : files) {
			String filename = file.getName();
			String     name = CrazyUtils.getNameExceptExtension(file);
			String      ext = CrazyUtils.getExtension(file).toLowerCase();
			try {
				// Unnecessary file exclusion
				if (VIDEO.OS_SYSTEM_FILENAMES.contains(filename) 
						|| (VIDEO.SUFFIX_IMAGE.contains(ext) && file.getParentFile().getName().equals("_info"))
						|| VIDEO.EXT_ACTRESS.equals(ext) 
						|| VIDEO.EXT_STUDIO.equals(ext) 
						|| VIDEO.HISTORY_LOG_FILENAME.equals(filename)
						|| VIDEO.TAG_DATA_FILENAME.equals(filename)
						|| VIDEO.WRONG_FILENAME.equals(filename)
						) {
					continue;
				}
				
				/*  1       2     3      4        5       6
				   [studio][opus][title][actress][release]etc...*/
				TitlePart titlePart = new TitlePart(name);
				titlePart.setFiles(file);
				if (titlePart.isCheck()) {
					logger.warn("wrong file : {}, {}, {}", file.getCanonicalPath(), titlePart.getCheckDescShort(), titlePart.getStyleString());
					wrongFileNames.add(String.format("[%s] : %s, %s, %s", file.getPath(), file.getName(), titlePart.getCheckDescShort(), titlePart.getStyleString()));
					continue;
				}
				addTitlePart(titlePart, _videoMap, _studioMap, _actressMap);
			}
			catch (CrazyException e) {
				logger.warn("{}\n{}", e.getMessage(), filename);
			}			
			catch (Exception e) {
				logger.error("File loading error : " + filename, e);
			}
		}
		stopWatch.stop();

		stopWatch.start("load : save wrong filename");
		try {
			if (wrongFileNames.size() > 0)
				FileUtils.writeLines(new File(paths[0], VIDEO.WRONG_FILENAME), VIDEO.ENCODING, wrongFileNames.stream().sorted().collect(Collectors.toList()), false);
		} catch (IOException e) {
			logger.error("write wrong file name fail", e);
		}
		stopWatch.stop();

		  videoMap =   _videoMap;
		 studioMap =  _studioMap;
		actressMap = _actressMap;
		
		startLoad = false;
		if (standalone)
			logger.info("{} video source load. {} videos\n\n{}", toTypeString(), videoMap.size(), stopWatch.prettyPrint());
		else
			logger.info("{} video source load. {} videos", toTypeString(), videoMap.size());
	}

	@Override
	public void reload(StopWatch stopWatch) {
		load(stopWatch);
		if (!isArchive)
			matchTorrent();
	}

	@Override
	@PostConstruct
	public void reload() {
		reload(null);
	}

	private synchronized void matchTorrent() {
		// find torrents
		if (torrentPath != null) {
			Collection<File> foundTorrent = FileUtils.listFiles(new File(torrentPath), 
					String.format("%s,%s", CRAZY.SUFFIX_TORRENT.toUpperCase(), CRAZY.SUFFIX_TORRENT.toLowerCase()).split(","), true);
			logger.debug("Scan torrents file {}, found {}", torrentPath, foundTorrent.size());
			
			for (Video video : getVideoList()) {
				video.resetTorrents();
				for (File file : foundTorrent) {
					if (StringUtils.contains(file.getName(), video.getOpus())) {
						video.addTorrents(file);
					}
				}
			}
		}
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
	/**
	 * if instance, 못찾으면 VideoNotFoundException
	 * if archive, 못찾으면 null;
	 * @see jk.kamoru.flayon.crazy.video.source.VideoSource#getVideo(java.lang.String)
	 */
	@Override
	public Video getVideo(String opus) {
		videoSource();
		if (videoMap.containsKey(opus.toUpperCase()))
			return videoMap.get(opus.toUpperCase());
		else
			if (isArchive)
				return null;
			else
				throw new VideoNotFoundException(opus);
	}
	@Override
	public Studio getStudio(String name) {
		videoSource();
		if (studioMap.containsKey(name.toUpperCase()))
			return studioMap.get(name.toUpperCase());
		else
			if (isArchive)
				return new Studio(name + " not exist");
			else
				throw new StudioNotFoundException(name);
	}
	@Override
	public Actress getActress(String name) {
		videoSource();
		if (actressMap.containsKey(name))
			return actressMap.get(name);
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
		videoMap.get(opus.toUpperCase()).move(destPath);
	}
	@Override
	public void arrangeVideo(String opus) {
		videoSource();
		videoMap.get(opus.toUpperCase()).arrange();
	}
	@Override
	public void removeElement(String opus) {
		videoSource();
		Video video = videoMap.get(opus);
		videoMap.remove(opus.toUpperCase());

		Studio studio = video.getStudio();
		studio.removeVideo(video);
		if (studio.getVideoList().size() == 0)
			studioMap.remove(studio.getName().toUpperCase());
		
		List<Actress> actressList = video.getActressList();
		for (Actress actress : actressList) {
			actress.removeVideo(video);
			if (actress.getVideoList().size() == 0)
				actressMap.remove(actress.getName());
		}
	}
	
	@Override
	public void removeVideo(String opus) {
		videoMap.get(opus.toUpperCase()).removeVideo();
		removeElement(opus);
	}
	@Override
	public void deleteVideo(String opus) {
		videoMap.get(opus.toUpperCase()).deleteFileAll();
		removeElement(opus);
	}

	@Override
	public void addVideo(Video video) {
		videoSource();
		videoMap.put(video.getOpus(), video);
	}

	@Override
	public void addFile(File file) {
		TitlePart part = new TitlePart(file.getName());
		part.setFiles(file);
		addTitlePart(part);
	}

	@Override
	public void addTitlePart(TitlePart titlePart) {
		addTitlePart(titlePart, videoMap, studioMap, actressMap);
	}

	private void addTitlePart(TitlePart titlePart, Map<String, Video> videoMap, Map<String, Studio> studioMap, Map<String, Actress> actressMap) {
		Video video = videoMap.get(titlePart.getOpus());
		if (video == null) {
			video = videoProvider.get();
			video.setTitlePart(titlePart);
			video.setArchive(isArchive);
			videoMap.put(video.getOpus(), video);
		}
		for (File file : titlePart.getFiles()) {
			String ext = CrazyUtils.getExtension(file).toLowerCase();
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
		}
		
		Studio studio = studioMap.get(titlePart.getStudio().toUpperCase());
		if (studio == null) {
			studio = studioProvider.get();
			studio.setName(titlePart.getStudio());
			studio.loadAdditionalInfo();
			studioMap.put(titlePart.getStudio().toUpperCase(), studio);
		}
		studio.addVideo(video);
		video.setStudio(studio);

		for (String actressName : StringUtils.split(titlePart.getActress(), ",")) {
			actressName = VideoUtils.trimBlank(actressName);
			Actress actress = actressMap.get(actressName);
			if (actress == null) {
				actress = actressProvider.get();
				actress.setName(actressName);
				actress.loadAdditionalInfo();
				actress.setArchive(isArchive);
				actressMap.put(actressName, actress);
			}		
			actress.addVideo(video);
			actress.addStudio(studio);
			studio.addActress(actress);
			video.addActress(actress);
		}
	}
	
}
