package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Path;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.error.VideoException;
import jk.kamoru.flayon.crazy.error.VideoNotFoundException;
import jk.kamoru.flayon.crazy.util.ActressUtils;
import jk.kamoru.flayon.crazy.util.CommandExecutor;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import jk.kamoru.flayon.crazy.util.StudioUtils;
import jk.kamoru.flayon.crazy.util.VideoUtils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.dao.TagDao;
import jk.kamoru.flayon.crazy.video.dao.VideoDao;
import jk.kamoru.flayon.crazy.video.domain.Action;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.ActressSort;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.Sort;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.StudioSort;
import jk.kamoru.flayon.crazy.video.domain.TistoryGraviaItem;
import jk.kamoru.flayon.crazy.video.domain.TitleValidator;
import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.domain.VideoSearch;
import jk.kamoru.flayon.crazy.video.service.noti.NotiQueue;
import jk.kamoru.flayon.crazy.video.service.webfile.WebFileLookupService;
import lombok.extern.slf4j.Slf4j;

/**
 * video service implement class
 * @author kamoru
 */
@Service
@Slf4j
public class VideoServiceImpl implements VideoService {

	/** minimum free space of disk */
	private static final long MIN_FREE_SPAC = 10 * FileUtils.ONE_GB;
	/** sleep time of moving video */
	private static final long SLEEP_TIME = 1 * 1000;
	
	@Autowired CrazyConfig config;
	@Autowired VideoDao videoDao;
	@Autowired TagDao tagDao;
	@Autowired HistoryService historyService;
	@Autowired WebFileLookupService arzonLookupService;
	@Autowired WebFileLookupService sukebeiNyaaLookupService;
	@Autowired CommandExecutor commandExecutor;

	private String[] CANDIDATE_PATHS;
	private String TORRENT_QUEUE_PATH;
	private String PLAYER;
	private String EDITOR;
	private String STORAGE_PATH;
	private String ARCHIVE_PATH;
	private int MIN_RANK;
	private int MAX_RANK;
	private int BASE_RANK;
	private long MAX_ENTIRE_VIDEO;
	private String[] STAGE_PATHS;
	private String COVER_PATH;
	private String[] REPLACE_OPUS_INFO;
	private String NO_PARSE_OPUS_PREFIX;
	private String urlRSS;
	private String TORRENT_SEED_PATH;
	
	@PostConstruct
	public void postConstruct() {
		CANDIDATE_PATHS 	= config.getCandidatePaths();
		PLAYER 				= config.getPlayer();
		EDITOR 				= config.getEditor();
		STORAGE_PATH 		= config.getStoragePath();
		ARCHIVE_PATH 		= config.getArchivePath();
		MIN_RANK 			= config.getMinRank();
		MAX_RANK 			= config.getMaxRank();
		MAX_ENTIRE_VIDEO 	= config.getMaxEntireVideo();
		BASE_RANK 			= config.getBaseRank();
		STAGE_PATHS 		= config.getStagePaths();
		COVER_PATH 			= config.getCoverPath();
		REPLACE_OPUS_INFO 	= config.getReplaceOpusInfo();
		NO_PARSE_OPUS_PREFIX = config.getNoParseOpusPrefix();
		urlRSS 				= config.getUrlRSS();
		TORRENT_QUEUE_PATH  = config.getTorrentQueuePath();
		TORRENT_SEED_PATH 	= config.getTorrentSeedPath();
	}
	
	private void fillTorrentInfo(List<Video> list) {
		List<Video> allInstanceList = list.stream().filter(v -> !v.isArchive()).collect(Collectors.toList());
		List<Video> nonExistVideoList = allInstanceList.stream().filter(v -> !v.isExistVideoFileList()).collect(Collectors.toList());
		log.info("fillTorrentInfo - non exist video file = {}", nonExistVideoList.size());
		
		// CANDIDATE_PATHS에서 mp4, avi 등 찾기
		List<File> foundFiles = new ArrayList<>();
		for (String candidatePath : CANDIDATE_PATHS) {
			File candidateDirectory = new File(candidatePath);
			if (!candidateDirectory.exists() || !candidateDirectory.isDirectory()) {
				log.warn("fillTorrentInfo - candidate path {} is not valid", candidatePath);
				continue;
			}
			String[] extensions = String.format("%s,%s", CRAZY.SUFFIX_VIDEO.toUpperCase(), CRAZY.SUFFIX_VIDEO.toLowerCase()).split(",");
			Collection<File> found = FileUtils.listFiles(candidateDirectory, extensions, true);
			log.info("fillTorrentInfo - Scan candidate : {}, {} found", candidateDirectory, found.size());
			foundFiles.addAll(found);
		}
		
		// match candidates file
		for (Video video : allInstanceList) {
			video.resetVideoCandidates();
			String opus = video.getOpus().toLowerCase();
			for (String key : Arrays.asList(opus, StringUtils.remove(opus, "-"))) {
				for (File file : foundFiles) {
					if (StringUtils.containsIgnoreCase(file.getName(), key)) {
						if (!video.getVideoCandidates().contains(file)) {
							video.addVideoCandidates(file);
							log.info("fillTorrentInfo - Add candidate [{}] : {}", opus, file);
						}
					}
				}
			}
		}
		
		// find torrent
		Collection<File> foundTorrent = FileUtils.listFiles(new File(TORRENT_QUEUE_PATH), new String[]{CRAZY.SUFFIX_TORRENT.toUpperCase(), CRAZY.SUFFIX_TORRENT.toLowerCase()}, true);
		log.info("fillTorrentInfo - Scan torrents : {}, {} found", TORRENT_QUEUE_PATH, foundTorrent.size());
		
		// matching torrent file
		for (Video video : nonExistVideoList) {
			// torrents
			video.resetTorrents();
			String opus = video.getOpus().toLowerCase();
			for (File file : foundTorrent) {
				if (StringUtils.containsIgnoreCase(file.getName(), opus)) {
					video.addTorrents(file);
					log.info("fillTorrentInfo - Add torrent [{}] : {}", opus, file);
				}
			}
		}
	}

	@Override
	public List<Video> getVideoList() {
		return getVideoList(true, false, null, false, false);
	}
	
	@Override
	public List<Video> getVideoList(boolean instance, boolean archive) {
		return getVideoList(instance, archive, null, false, false);
	}

	@Override
	public List<Video> getVideoList(boolean instance, boolean archive, Sort sort, boolean reverse) {
		return getVideoList(instance, archive, sort, reverse, false);
	}

	@Override
	public List<Video> getVideoList(boolean instance, boolean archive, Sort sort, boolean reverse, boolean withTorrent) {
		List<Video> list = new ArrayList<>();
		if (instance)
			list.addAll(videoDao.getVideoList(instance, false));
		if (archive)
			list.addAll(videoDao.getVideoList(false, archive).stream().filter(v -> !list.contains(v)).collect(Collectors.toList()));
		if (withTorrent)
			fillTorrentInfo(list);
		return sortVideo(list, sort, reverse);
	}
	
	private List<Video> sortVideo(List<Video> list, Sort sort, boolean reverse) {
		if (sort == null)
			return list;
		return list.stream().sorted((v1, v2) -> VideoUtils.compareVideo(v1, v2, sort, reverse)).collect(Collectors.toList());
	}

	@Override
	public List<Actress> getActressList() {
		return getActressList(true, false, null, false);
	}
	
	@Override
	public List<Actress> getActressList(boolean instance, boolean archive) {
		return getActressList(instance, archive, null, false);
	}
	
	@Override
	public List<Actress> getActressList(boolean instance, boolean archive, ActressSort sort, boolean reverse) {
		List<Actress> list = new ArrayList<>();
		if (instance)
			list.addAll(videoDao.getActressList(instance, false));
		if (archive)
			list.addAll(videoDao.getActressList(false, archive).stream().filter(a -> !list.contains(a)).collect(Collectors.toList()));
		return sortActress(list, sort, reverse);
	}

	private List<Actress> sortActress(List<Actress> list, ActressSort sort, boolean reverse) {
		if (sort == null)
			return list;
		return list.stream().sorted((a1, a2) -> ActressUtils.compareActress(a1, a2, sort, reverse)).collect(Collectors.toList());
	}
	
	@Override
	public List<Studio> getStudioList() {
		return getStudioList(true, false, null, false);
	}

	@Override
	public List<Studio> getStudioList(boolean instance, boolean archive) {
		return getStudioList(instance, archive, null, false);
	}
	
	@Override
	public List<Studio> getStudioList(boolean instance, boolean archive, StudioSort sort, boolean reverse) {
		List<Studio> list = new ArrayList<>();
		if (instance)
			list.addAll(videoDao.getStudioList(instance, false));
		if (archive)
			list.addAll(videoDao.getStudioList(false, archive).stream().filter(s -> !list.contains(s)).collect(Collectors.toList()));
		return sortStudio(list, sort, reverse);
	}

	private List<Studio> sortStudio(List<Studio> list, StudioSort sort, boolean reverse) {
		if (sort == null)
			return list;
		return list.stream().sorted((s1, s2) -> StudioUtils.compareStudio(s1, s2, sort, reverse)).collect(Collectors.toList());
	}
	
	@Override
	public void removeVideo(String opus) {
		log.debug(opus);
		videoDao.removeVideo(opus);
		saveHistory(getVideo(opus), Action.REMOVE);
	}

	@Override
	public void editVideoSubtitles(String opus) {
		log.debug(opus);
		callExecutiveCommand(getVideo(opus), Action.SUBTITLES);
	}

	/**
	 * call executive command by action. asynchronous
	 * @param video
	 * @param action {@link Action#PLAY PLAY}, {@link Action#SUBTITLES SUBTITLES}
	 * @see {@link Action}
	 */
	private void callExecutiveCommand(Video video, Action action) {
		log.info("{} : {}", video.getOpus(), action);
		String command = null;
		String[] arguments = null;
		switch(action) {
		case PLAY:
			command = PLAYER;
			arguments = video.getVideoFileListPathArray();
			break;
		case SUBTITLES:
			command = EDITOR;
			arguments = video.getSubtitlesFileListPathArray();
			break;
		default:
			throw new VideoException(video, "Unknown Action");
		}
		if (arguments == null)
			throw new VideoException(video, "No arguments for " + action);
		
		commandExecutor.exec(command, arguments);
		
		NotiQueue.pushNoti(action.toString() + " " + video.getOpus());
	}

	/* (non-Javadoc)
	 * search용 히스토리 검색 
	 * @see jk.kamoru.flayon.crazy.video.service.VideoService#findHistory(java.lang.String)
	 */
	@Override
	public List<Map<String, String>> findHistory(String query) {
		log.debug(query);
		
		List<Map<String, String>> foundMapList = new ArrayList<>();
		List<History> list = null;
		if (StringUtils.equals("ALL", query)) 
			list = historyService.getDeduplicatedList();
		else 
			list = historyService.findByQuery(query);
		
		for (History history : list) {
			Map<String, String> map = new HashMap<>();
			map.put("date", new SimpleDateFormat(VIDEO.DATE_TIME_PATTERN).format(history.getDate()));
			map.put("opus", history.getOpus());
			map.put("act",  history.getAction().toString());
			map.put("desc", history.getVideo() == null ? history.getDesc() : history.getVideo().getFullname());
			foundMapList.add(map);
		}
		log.debug("q={} foundLength={}", query, foundMapList.size());
		if (foundMapList.size() > 1) {
			Collections.sort(foundMapList, new Comparator<Map<String, String>>(){
	
				@Override
				public int compare(Map<String, String> o1, Map<String, String> o2) {
					return CrazyUtils.compareTo(o2.get("date"), o1.get("date"));
//					String thisStr = o1.get("date");
//					String compStr = o2.get("date");
//	
//					String[] s = {thisStr, compStr};
//					Arrays.sort(s);
//					return s[0].equals(thisStr) ? 1 : -1;
				}
				
			});
		}
		return foundMapList;
	}

	/* (non-Javadoc)
	 * search용 비디오 검색
	 * @see jk.kamoru.flayon.crazy.video.service.VideoService#findVideoList(java.lang.String)
	 */
	@Override
	public List<Map<String, String>> findVideoList(String query) {
		log.debug(query);
		List<Map<String, String>> foundMapList = new ArrayList<>();
		if(query == null || query.trim().length() == 0)
			return foundMapList;

		query = query.toLowerCase();
		for(Video video : videoDao.getVideoList(true, false)) {
			if(StringUtils.containsIgnoreCase(video.getOpus(), query)
					|| StringUtils.containsIgnoreCase(video.getStudio().getName(), query)
					|| StringUtils.containsIgnoreCase(video.getTitle(), query)
					|| StringUtils.containsIgnoreCase(video.getActressName(), query)) {
				Map<String, String> map = new HashMap<>();
				map.put("opus", video.getOpus());
				map.put("title", video.getTitle());
				map.put("studio", video.getStudio().getName());
				map.put("actress", video.getActressName());
				map.put("existVideo", String.valueOf(video.isExistVideoFileList()));
				map.put("existCover", String.valueOf(video.isExistCoverFile()));
				map.put("existSubtitles", String.valueOf(video.isExistSubtitlesFileList()));
				map.put("releaseDate", video.getReleaseDate());
				foundMapList.add(map);
			} 
		}
		log.debug("q={} foundLength={}", query, foundMapList.size());
		Collections.sort(foundMapList, new Comparator<Map<String, String>>() {
			@Override
			public int compare(Map<String, String> o1, Map<String, String> o2) {
				return CrazyUtils.compareTo(o2.get("releaseDate"), o1.get("releaseDate"));
			}
		});
		return foundMapList;
	}

	@Override
	public Actress getActress(String actressName) {
		return videoDao.getActress(actressName);
	}

	/* 
	 * videoList 안에 있는 배우만 추린다.
	 */
	@Override
	public List<Actress> getActressListInVideoList(List<Video> videoList) {
		if (log.isDebugEnabled())
			log.debug("getActressListInVideoList video size {}", videoList.size());
		
		List<Actress> list = new ArrayList<>();

		for(Video video : videoList) {
			for (Actress actress : video.getActressList()) {
				if (!list.contains(actress))
					list.add(actress);
			}
		}

		if (log.isDebugEnabled())
			log.debug("getActressListInVideoList found studio size {}", list.size());
		return sortActress(list, ActressSort.NAME, false);
	}

	@Override
	public Studio getStudio(String studioName) {
		return videoDao.getStudio(studioName);
	}

	@Override
	public List<Studio> getStudioListInVideoList(List<Video> videoList) {
		if (log.isDebugEnabled())
			log.trace("size : {}", videoList.size());
		
		List<Studio> list = new ArrayList<>();

		for(Video video : videoList) {
			Studio studio = video.getStudio();
			if (!list.contains(studio))
				list.add(studio);
		}
		
		if (log.isDebugEnabled())
			log.debug("found studio list size {}", list.size());
		return sortStudio(list, StudioSort.NAME, false);
	}

	@Override
	public Video getVideo(String opus) {
		Video video = videoDao.getVideo(opus);
		if (video == null) {
			List<History> findByOpus = historyService.findByOpus(opus);
			if (findByOpus.size() > 0) {
				TitleValidator titlePart = new TitleValidator(findByOpus.get(0).getDesc());
				video = new Video();
				video.setTitlePart(titlePart);
				video.setStudio(new Studio(titlePart.getStudio()));
				video.setArchive(true);
			}
			else
				throw new VideoNotFoundException(opus);
		}
		return video;
	}

	@Override
	@Cacheable(value="flayon-cover-cache", key="#opus")
	public byte[] getVideoCoverByteArray(String opus) {
		return videoDao.getVideo(opus).getCoverByteArray();
	}

	@Override
	public File getVideoCoverFile(String opus) {
		return videoDao.getVideo(opus).getCoverFile();
	}

	@Override
	public void playVideo(String opus) {
		log.debug(opus);
		Video video = videoDao.getVideo(opus);
		if (!video.isExistVideoFileList())
			throw new VideoException(video, "No video file");
		callExecutiveCommand(video, Action.PLAY);
		video.increasePlayCount();
		saveHistory(video, Action.PLAY);
	}

	@Override
	public void rankVideo(String opus, int rank) {
		log.debug("opus={} : rank={}", opus, rank);
		videoDao.getVideo(opus).setRank(rank);
	}

	/**save history by action
	 * @param video
	 * @param action PLAY, OVERVIEW, COVER, SUBTITLES, DELETE in {@link Action}
	 */
	private void saveHistory(Video video, Action action) {
		log.debug("opus={} : action={}", video.getOpus(), action);

		History history = new History(video, action);
		log.debug("save history - {}", history);
		historyService.persist(history);
	}

	@Override
	public void saveVideoOverview(String opus, String overViewText) {
		log.debug("opus={} : text={}", opus, overViewText);
		videoDao.getVideo(opus).saveOverView(overViewText);
	}

	@Override
	public List<Video> searchVideo(VideoSearch search) {
		log.info("searchVideo START : {}", search);
		if (search.getRankRange() == null)
			search.setRankRange(getRankRange());
		
		return videoDao.getVideoList(true, false).stream()
				.filter(v -> v.match(search))
				.sorted((v1, v2) -> VideoUtils.compareVideo(v1, v2, search.getSortMethod(), search.isSortReverse()))
				.collect(Collectors.toList());
	}

	@Override
	public Map<String, Long[]> groupByPath() {
		log.debug("groupByPath");
		Map<String, Long[]> pathMap = new TreeMap<>();
		Long[] total = new Long[]{0l, 0l};
		for (Video video : videoDao.getVideoList(true, true)) {
			String path = video.getDelegatePath();
			if (path.contains(STORAGE_PATH))
				path = STORAGE_PATH;
			else if (path.contains(ARCHIVE_PATH))
				path = ARCHIVE_PATH;
			long length = video.getLength();
			Long[] data = pathMap.get(path);
			if (data == null) {
				data = new Long[]{0l, 0l};
			}
			total[0] += 1;
			total[1] += length;
			data[0] += 1;
			data[1] += length; 
			pathMap.put(path, data);
		}
		pathMap.put("Total", total);
		return pathMap;
	}

	@Override
	public Actress saveActressInfo(Map<String, String> params) {
		return videoDao.renameActress(params);
	}

	@Override
	public Map<String, List<Video>> groupByDate() {
		log.debug("groupByDate");
		Map<String, List<Video>> map = new TreeMap<>();
		for (Video video : videoDao.getVideoList(true, false)) {
			String yyyyMM = StringUtils.substringBeforeLast(video.getReleaseDate(), ".").replace(".", "-");
			if (map.containsKey(yyyyMM)) {
				map.get(yyyyMM).add(video);
			}
			else {
				List<Video> videoList = new ArrayList<>();
				videoList.add(video);
				map.put(yyyyMM, videoList);
			}
		}
		return map;
	}

	@Override
	public Map<Integer, List<Video>> groupByRank() {
		log.debug("groupByRank");
		Map<Integer, List<Video>> map = new TreeMap<>(Collections.reverseOrder());
		for (Video video : videoDao.getVideoList(true, false)) {
			Integer rank = video.getRank();
			if (map.containsKey(rank)) {
				map.get(rank).add(video);
			}
			else {
				List<Video> videoList = new ArrayList<>();
				videoList.add(video);
				map.put(rank, videoList);
			}
		}
		return map;
	}

	@Override
	public Map<Integer, List<Video>> groupByPlay() {
		log.debug("groupByPlay");
		Map<Integer, List<Video>> map = new TreeMap<>(Collections.reverseOrder());
		for (Video video : videoDao.getVideoList(true, false)) {
			Integer play = video.getPlayCount();
			if (map.containsKey(play)) {
				map.get(play).add(video);
			}
			else {
				List<Video> videoList = new ArrayList<>();
				videoList.add(video);
				map.put(play, videoList);
			}
		}
		return map;
	}

	@Override
	public void moveVideo(String opus, String path) {
		log.info("{} move to {}", opus, path);
		videoDao.moveVideo(opus, path);
	}

	@Override
	@CacheEvict(value = "flayon-cover-cache", allEntries=true)
	public void reload(StopWatch stopWatch) {
		log.debug("reload");
		videoDao.reload(stopWatch, true, false);
	}

	@Override
	public Studio saveStudioInfo(Map<String, String> params) {
		return videoDao.renameStudio(params);
	}
	
	@Override
	public List<Integer> getPlayRange() {
		int maxPlayCount = 0;
		for (Video video : videoDao.getVideoList(true, false))
			maxPlayCount = maxPlayCount - video.getPlayCount() > 0 ? maxPlayCount : video.getPlayCount();

		List<Integer> playList = new ArrayList<>();
		for (int i=-1; i<=maxPlayCount; i++)
			playList.add(i);
		return playList;
	}

	@Override
	public List<Integer> getRankRange() {
		List<Integer> rankList = new ArrayList<>();
		for (Integer i=MIN_RANK; i<=MAX_RANK; i++)
			rankList.add(i);
		return rankList;
	}

	@Override
	public void removeLowerRankVideo() {
		for (Video video : videoDao.getVideoList(true, false)) {
			if (video.getRank() < BASE_RANK) {
				log.info("remove lower rank video {} : {} : {}", video.getOpus(), video.getRank(), video.getTitle());
				saveHistory(video, Action.REMOVE);
				videoDao.removeVideo(video.getOpus());
			}
		}
	}
	
	/* (non-Javadoc)
	 * 종합 순위<br>
	 * 점수 배정<br>
	 * 	- rank 			: rankRatio<br>
	 * 	- play count	: playRatio<br>
	 * 	- actress video	: actressRatio	<br>	
	 *  - subtitles     : subtitlesRatio
	 * @see jk.kamoru.app.video.service.VideoService#removeLowerScoreVideo()
	 */
	@Override
	public void removeLowerScoreVideo() {
		long maximumSizeOfEntireVideo = MAX_ENTIRE_VIDEO * FileUtils.ONE_GB;
		long sumSizeOfTotalVideo  = 0l;
		long sumSizeOfDeleteVideo = 0l;
		int  countOfTotalVideo    = 0;
		int  countOfDeleteVideo   = 0;
		int  minAliveScore 		  = 0;
		
		List<Video> list = getVideoListSortByScore();
		
		for (Video video : list) {
			if (video.getPlayCount() == 0 || video.getRank() == 0)
				continue;
			
			int score = video.getScore();
			sumSizeOfTotalVideo += video.getLength();
			countOfTotalVideo++;
			
			if (sumSizeOfTotalVideo > maximumSizeOfEntireVideo) {
				sumSizeOfDeleteVideo += video.getLength();
				countOfDeleteVideo++;
				
				log.info("    {}/{}. Score[{}] - {} {}",
						countOfDeleteVideo,
						countOfTotalVideo,
						score, 
						video.getFullname(),
						video.getScoreDesc());
				videoDao.removeVideo(video.getOpus());
				saveHistory(video, Action.REMOVE);
			}
			else {
				minAliveScore = score;
			}
		}
		if (countOfDeleteVideo > 0)
			log.info("    Total deleted {} video, {} GB", countOfDeleteVideo, sumSizeOfDeleteVideo / FileUtils.ONE_GB);
		log.info("    Current minimum score is {} ", minAliveScore);
	}
	
	/**
	 * Score로 정렬된 비디오 목록<br>
	 * 가장 높은 score가 앞, 같으면 release날자가 과거인거 
	 * @return
	 */
	private List<Video> getVideoListSortByScore() {
		return videoDao.getVideoList(true, false).stream()
				.sorted(Comparator.comparing(Video::getScore)
						.reversed()
						.thenComparing(Comparator.comparing(Video::getReleaseDate)))
				.collect(Collectors.toList());
	}
	
	@Override
	public void deleteGarbageFile() {
		for (Video video : videoDao.getVideoList(true, true)) {
			if (!video.isExistVideoFileList() 
					&& !video.isExistCoverFile()
					&& !video.isExistSubtitlesFileList()) {
				log.info("    delete garbage file - {}", video);
				videoDao.deleteVideo(video.getOpus());
			}
		}
	}
	
	@Override
	public void moveWatchedVideo() {
		/// 폴더의 최대 크기
		long maximumSizeOfEntireVideo = MAX_ENTIRE_VIDEO * FileUtils.ONE_GB;
		// 한번에 옮길 비디오 개수
		int maximumCountOfMoveVideo = 15;
		// 옮긴 비디오 개수
		int countOfMoveVideo = 0;
		// Watched 폴더
		File mainBaseFile = new File(STORAGE_PATH);
		// Watched Root
		Path mainBaseRoot = mainBaseFile.toPath().getRoot();
		// Watched 폴더 크기
		long usedSpace = FileUtils.sizeOfDirectory(mainBaseFile);
		// 여유 공간
		long freeSpace = mainBaseFile.getFreeSpace();
		
		log.info("    MOVE WATCHED VIDEO START :: Watched {} GB, free {} GB, watched root={}", usedSpace / FileUtils.ONE_GB, freeSpace / FileUtils.ONE_GB, mainBaseRoot);

		// 전체 비디오중에서
		for (Video video : getVideoListSortByScore()) {
			
			Path videoRoot = video.getDelegatePathFile().toPath().getRoot();
			// 다른 드라이브에 있는 파일이면, 가능한 공간 체크
			if (!mainBaseRoot.equals(videoRoot)) {
				log.debug("video root {}", videoRoot);
				// 드라이드에 남은 공간이 최소 공간보다 작으면 break
				if (freeSpace < MIN_FREE_SPAC) {
					log.debug("      Not enough space, {} < {}. opus={}", freeSpace / FileUtils.ONE_GB, MIN_FREE_SPAC / FileUtils.ONE_GB, video.getOpus());
					continue;
				}
				// Watched 폴더 크기가 최대 크기보다 커졌으면 break
				if (usedSpace > maximumSizeOfEntireVideo) {
					log.debug("      Exceed the maximum size, {}  > {}. opus={}", usedSpace / FileUtils.ONE_GB, maximumSizeOfEntireVideo / FileUtils.ONE_GB, video.getOpus());
					continue;
				}
			}
			
			// 플레이 한적이 없거나 rank 설정안한 비디오는 pass
			if (video.getPlayCount() < 1 || video.getRank() < 1)
				continue;
			// Watched 폴더에 있는 파일도 pass
			if (video.getDelegatePath().contains(mainBaseFile.getAbsolutePath()))
				continue;
			
			// 스튜디오 이름으로 폴더를 준비
			File destDir = new File(mainBaseFile, video.getStudio().getName());
			if (!destDir.exists())
				destDir.mkdir();

			// 비디오를 옮긴다
			countOfMoveVideo++;
			log.info("    move from [{}] to [{}] - {}", video.getDelegatePathFile().getParent(), destDir.getPath(), video.getFullname());
			videoDao.moveVideo(video.getOpus(), destDir.getAbsolutePath());
			
			// 다 옮겼으면 break
			if (countOfMoveVideo == maximumCountOfMoveVideo) {
				log.info("      Completed {} videos.", maximumCountOfMoveVideo);
				break;
			}
			else {
				// 잠시 쉰다.
				try {
					Thread.sleep(SLEEP_TIME);
				} catch (InterruptedException e) {
					log.error("sleep error", e);
				}
			}

			// 공간을 다시 젠다
			usedSpace = FileUtils.sizeOfDirectory(mainBaseFile);
			freeSpace = mainBaseFile.getFreeSpace();
		}
		usedSpace = FileUtils.sizeOfDirectory(mainBaseFile);
		freeSpace = mainBaseFile.getFreeSpace();
		log.info("    MOVE WATCHED VIDEO END :: Watched {} GB, free {} GB", usedSpace / FileUtils.ONE_GB, freeSpace / FileUtils.ONE_GB);
	}

	@Override
	public void arrangeVideo() {
		for (Video video : videoDao.getVideoList(true, false)) {
			String opus = video.getOpus();
			videoDao.arrangeVideo(opus);
		}
	}

	@Override
	public void confirmCandidate(String opus, String path) {
		log.debug("confirmCandidate : {} - {}", opus, path);
		
		File destinationPath = null;
		for (String extraPath : STAGE_PATHS) {
			if (CrazyUtils.equalsRoot(path, extraPath)) {
				destinationPath = new File(extraPath);
				break;
			}
		}
		if (destinationPath == null)
			throw new VideoException("Not found proper destination path for candidate file");
		
		Video video = videoDao.getVideo(opus);
		int videoFileSize = video.getVideoFileList().size();
		File candidatedVideofile = new File(path);
		File videoFile = new File(destinationPath, String.format("%s%s.%s", video.getFullname(), videoFileSize > 0 ? String.valueOf(++videoFileSize) : "", CrazyUtils.getExtension(candidatedVideofile)));
		try {
			FileUtils.moveFile(candidatedVideofile, videoFile);
			log.info("move to {}", videoFile.getAbsoluteFile());
		}
		catch (IOException e) {
			throw new VideoException(video, "candidate file moving error", e);
		}
		video.addVideoFile(videoFile);
	}

	@Override
	public Map<Integer, List<Video>> groupByScore() {
		log.debug("groupByScore");
		Map<Integer, List<Video>> map = new TreeMap<>(Collections.reverseOrder());
		for (Video video : videoDao.getVideoList(true, false)) {
			Integer score = video.getScore();
			if (map.containsKey(score)) {
				map.get(score).add(video);
			}
			else {
				List<Video> videoList = new ArrayList<>();
				videoList.add(video);
				map.put(score, videoList);
			}
		}
		return map;
	}

	@Override
	public void rename(String opus, String newName) {
		videoDao.renameVideo(opus, newName);
	}

	@Override
	public List<TitleValidator> parseToTitleData(String titleData, Boolean saveCoverAll) {
		List<TitleValidator> titlePartList = new ArrayList<>();
		
		if (!StringUtils.isEmpty(titleData)) {
			titleData += System.getProperty("line.separator") + System.getProperty("line.separator") + "eof";
			String[] titles = titleData.split(System.getProperty("line.separator"));

			String text = null;
			try {
				for (int i = 0; i < titles.length; i++) {
					if (titles[i].trim().length() > 0) {
						// make TitlePart
						TitleValidator titlePart = new TitleValidator();
						// opus
						text = titles[i++].trim().toUpperCase();
						titlePart.setOpus(text);
						// actress
						text = titles[i++].trim();
						if (!Pattern.matches("^[a-zA-Z\\s,]+", text)) { // 배우이름이 없어서 날자가 온거면
							text = "";
							i--;
						}
						titlePart.setActress(text);
						// release date
						text = titles[i++].trim();
						if (!Pattern.matches("\\d{4}.\\d{2}.\\d{2}", text)) { // 날자가 없어서 제목이 온거면
							text = "";
							i--;
						}
						titlePart.setReleaseDate(text);
						// title
						String title = "";
						while (true) {
							text = titles[i++].trim();
							if (StringUtils.isEmpty(text)) {
								i--;
								break;
							}
							title += text + " ";
						}
						titlePart.setTitle(title.trim());
						// check already contains
						if (videoDao.contains(titlePart.getOpus(), true, false)) {
							log.info("{} exist", titlePart.getOpus());
							continue;
						}
						// history check
						if (historyService.contains(titlePart.getOpus())) {
							titlePart.setSeen();
						}
						// find Studio
						String opusPrefix = StringUtils.substringBefore(titlePart.getOpus(), "-");
						if (NO_PARSE_OPUS_PREFIX.contains(opusPrefix)) {
							titlePart.setStudio("");
						}
						else if (StringUtils.contains(CrazyUtils.toStringComma(REPLACE_OPUS_INFO), opusPrefix)) {
							for (String reOpus : REPLACE_OPUS_INFO) {
								String[] opus = StringUtils.split(reOpus, "-");
								if (StringUtils.equals(opus[0], opusPrefix)) {
									titlePart.setStudio(opus[1]);
									break;
								}
							}
						}
						else {
							List<Map<String, String>> histories = findHistory(opusPrefix + "-");
							if (histories.size() > 0) {
								Map<String, String> data = histories.get(0);
								String desc = data.get("desc");
								
								titlePart.setStudio(StringUtils.substringBefore(StringUtils.substringAfter(desc, "["), "]"));
							}
							else {
								titlePart.setStudio("");
							}
						}
						// add TitlePart
						titlePartList.add(titlePart);
					}
				}
			} catch(ArrayIndexOutOfBoundsException e) {
				log.error("End");
			}

			if (saveCoverAll) {
				List<TitleValidator> _titlePartList = new ArrayList<>();
				int count = 0;
				int total = titlePartList.size();
				for (TitleValidator titlePart : titlePartList) {
					log.info("Save Cover {}/{}", ++count, total);
					CompletableFuture<File> result = arzonLookupService.get(titlePart.getOpus(), titlePart.toString(), COVER_PATH);
					try {
						File file = result.get(); 
						if (file == null) { // not found
							_titlePartList.add(titlePart);
						}
						else { // found
							titlePart.setFiles(file);
							videoDao.buildVideo(titlePart);
						}
					} catch (InterruptedException | ExecutionException e) {
						log.error("", e);
					}
				}
				titlePartList = _titlePartList;
			}
		}
		return titlePartList.stream()
//				.sorted(Comparator.comparing(TitlePart::getCheckDesc).reversed().thenComparing(Comparator.comparing(TitlePart::toString)))
				.sorted(Comparator.comparing(TitleValidator::toFullLowerName))
				.collect(Collectors.toList());
	}
	
	@Override
	public Map<Integer, List<Video>> groupByLength() {
		log.debug("groupByLength");
		Map<Integer, List<Video>> map = new TreeMap<>(Collections.reverseOrder());
		for (Video video : videoDao.getVideoList(true, false)) {
			Integer length = (int)Math.ceil(video.getLength() / (double)FileUtils.ONE_GB);

			if (map.containsKey(length)) {
				map.get(length).add(video);
			}
			else {
				List<Video> videoList = new ArrayList<>();
				videoList.add(video);
				map.put(length, videoList);
			}
		}
		return map;
	}

	@Override
	public Map<String, List<Video>> groupByExtension() {
		log.debug("groupByExtension");
		Map<String, List<Video>> map = new TreeMap<>(Collections.reverseOrder());
		for (Video video : videoDao.getVideoList(true, false)) {
			String ext = video.getExt().toLowerCase();

			if (map.containsKey(ext)) {
				map.get(ext).add(video);
			}
			else {
				List<Video> videoList = new ArrayList<>();
				videoList.add(video);
				map.put(ext, videoList);
			}
		}
		return map;
	}

	@Override
	public void resetVideoScore(String opus) {
		log.debug("resetVideoScore - {}", opus);
		videoDao.getVideo(opus).resetScore();
	}

	@Override
	public void resetWrongVideo(String opus) {
		log.debug("resetWrongVideo - {}", opus);
		videoDao.getVideo(opus).moveOutside();
	}

	@Override
	public void arrangeArchiveVideo() {
		log.debug("arrangeArchiveVideo");
		for (Video video : videoDao.getVideoList(false, true)) {
			video.arrange();
		}
	}

	@Override
	public List<Video> searchVideoInArchive(VideoSearch search) {
		log.debug("{}", search);
		if (search.getRankRange() == null)
			search.setRankRange(getRankRange());
		
		return videoDao.getVideoList(false, true).stream()
				.filter(v -> v.matchArchive(search))
				.sorted((v1, v2) -> VideoUtils.compareVideo(v1, v2, search.getSortMethod(), search.isSortReverse()))
				.collect(Collectors.toList());
	}

	@Override
	public void deletEmptyFolder() {
		log.debug("deletEmptyFolder START");
		
		List<File> folders = new ArrayList<>();
		folders.add(new File(ARCHIVE_PATH));
		folders.add(new File(COVER_PATH));
//		folders.add(new File(STORAGE_PATH));
		for (String stage : STAGE_PATHS)
			folders.add(new File(stage));
			
		for (File path : folders) {
			if (path == null || !path.exists()) {
				log.warn("deletEmptyFolder : wrong path [{}]", path);
				continue;
			}
			File[] dirs = path.listFiles(new FileFilter() {
				@Override
				public boolean accept(File file) {
					return file.isDirectory();
				}
			});
			log.debug("deletEmptyFolder : {} scan - {}", path, dirs);

			for (File dir : dirs) {
				if (CrazyUtils.isEmptyDirectory(dir)) {
					dir.delete();
					log.info("deletEmptyFolder : delete {}", dir);
				}
			}
		}
		log.debug("deletEmptyFolder END");
	}

	@Override
	public boolean setFavoriteOfActress(String actressName, Boolean favorite) {
		return videoDao.getActress(actressName).setFavorite(favorite);
	}

	@Override
	public List<TistoryGraviaItem> getTistoryItem() {
		URL url;
		try {
			url = new URL(urlRSS + "?t=" + System.currentTimeMillis());
		} catch (MalformedURLException e) {
			throw new CrazyException("rss url error", e);
		}
		return TistoryRSSReader.get(url, studioMapByOpus(), opusList());
	}

	private List<String> opusList() {
		List<String> opusList = new ArrayList<>();
		for (Video video : videoDao.getVideoList(true, true)) {
			opusList.add(video.getOpus());
		}
		for (History history : historyService.getDeduplicatedList()) {
			opusList.add(history.getOpus());
		}
		return new ArrayList<String>(new HashSet<String>(opusList));
	}
	
	/**
	 * opus앞과 스튜디오 맵
	 * @return
	 */
	private Map<String, String> studioMapByOpus() {
		Map<String, String> map = new HashMap<>();
		List<Video> videoList = videoDao.getVideoList(true, false).stream().sorted(
					Comparator.comparing(Video::getReleaseDate).reversed()
					.thenComparing(Comparator.comparing(Video::getReleaseDate).reversed())
				).collect(Collectors.toList());
		for (Video video : videoList) {
			String opus = video.getOpus();
			String studio = video.getStudio().getName();
			String key = StringUtils.substringBefore(opus, "-");
			if (!map.containsKey(key)) {
				map.put(key, studio);
			}
		}
		List<History> deduplicatedList = historyService.getDeduplicatedList().stream().sorted(
					Comparator.comparing(History::getDate).reversed()
				).collect(Collectors.toList());
		for (History history : deduplicatedList) {
			String opus = history.getOpus();
			String key = StringUtils.substringBefore(opus, "-");
			String desc = history.getVideo() == null ? history.getDesc() : history.getVideo().getFullname();
			String studio = StringUtils.substringBefore(StringUtils.substringAfter(desc, "["), "]");
			if (!map.containsKey(key)) {
				map.put(key, studio);
			}
		}
		log.debug("studioMapByOpus {}", map);
		return map;
	}
	
	@Override
	public void saveCover(String opus, String title) {
		log.info("saveCover {}, {}, {}", opus, title, COVER_PATH);
		CompletableFuture<File> result = arzonLookupService.get(opus, title, COVER_PATH);
		try {
			File file = result.get(); 
			if (file == null) {
				throw new CrazyException("not found cover : " + opus);
			}
			else { // found
				TitleValidator titlePart = new TitleValidator(title);
				titlePart.setFiles(file);
				videoDao.buildVideo(titlePart);
			}
		} catch (InterruptedException | ExecutionException e) {
			throw new CrazyException("fail to saveCover : " + opus, e);
		}
	}

	@Override
	public void moveTorrentToSeed(String opus) {
		for (File file : videoDao.getVideo(opus).getTorrents()) {
			try {
				FileUtils.moveFileToDirectory(file, new File(TORRENT_SEED_PATH), false);
			} catch (IOException e) {
				log.error("Fail to move torrent to seed dir" + opus, e);
			}
		}
	}

	@Override
	public void moveToInstance(String opus) {
		videoDao.moveToInstance(opus);
	}

	@Override
	@Async
	public void saveCover(List<String> titles) {
		log.info("saveCover at {} size={}", COVER_PATH, titles.size());

		Map<String, CompletableFuture<File>> resultMap = new ConcurrentHashMap<>();
		for (String title : titles) {
			TitleValidator part = new TitleValidator(title);
			String opus = part.getOpus();
			
			// check opus text
			if (StringUtils.isBlank(opus)) {
				log.warn("saveCover opus is blank");
				continue;
			}
			// check exists video
			if (videoDao.contains(opus, true, false)) {
				log.warn("saveCover {} is contains", opus);
				continue;
			}
			// check title valid
			TitleValidator titlePart = new TitleValidator(title);
			if (titlePart.isInvalid()) {
				log.warn("saveCover titlePart is invalid. [{}] - {}", titlePart.getCheckDescShort(), title);
				continue;
			}
			// start async lookup
			CompletableFuture<File> result = arzonLookupService.get(opus, title, COVER_PATH);
			resultMap.put(opus, result);
		}

		int foundCount = 0;
		for (Entry<String, CompletableFuture<File>> result : resultMap.entrySet()) {
			try {
				String opus = result.getKey();
				File file = result.getValue().get();

				if (file == null) {
					log.warn("saveCover {} file is null", opus);
				}
				else { // found
					foundCount++;
					String title = CrazyUtils.getNameExceptExtension(file);
					TitleValidator savedTitlePart = new TitleValidator(title);
					savedTitlePart.setFiles(file);
					videoDao.buildVideo(savedTitlePart);
				}
			} catch (InterruptedException | ExecutionException e) {
				log.error("fail to saveCover", e);
			}
		}
		log.info("saveCover {} completed", foundCount);
		
		NotiQueue.pushNoti("saveCover " + foundCount);
	}

	@Override
	public void reloadArchive() {
		videoDao.reload(null, false, true);
	}

	@Override
	public List<String> getOpusList() {
		return getVideoList().stream().map(v -> v.getOpus()).collect(Collectors.toList());
	}

	@Override
	public int downloadTorrents(String[] opusArr) {
		int found = 0;
		for (String opus : opusArr) {
			Video video = videoDao.getVideo(opus);
			video.getTorrents().clear();
			sukebeiNyaaLookupService.get(video.getOpus(), video.getTitle(), TORRENT_QUEUE_PATH);
			/*			
 			CompletableFuture<File> completableFuture = sukebeiNyaaLookupService.get(video.getOpus(), video.getTitle(), TORRENT_PATH);
			try {
				File file = completableFuture.get();
				if (file != null) {
					video.addTorrents(file);
					found++;
				}
			} catch (InterruptedException | ExecutionException e) {
				log.error("sukebeiNyaaLookupService : completableFuture.get()", e);
			}
 			*/
		}
		return found;
	}

	@Override
	public void toggleTag(VTag tag, String opus) {
		VTag _tag = tagDao.findById(tag.getId());
		videoDao.getVideo(opus).toggleTag(_tag);
	}

}
