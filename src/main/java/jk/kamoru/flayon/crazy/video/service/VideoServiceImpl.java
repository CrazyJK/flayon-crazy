package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.nio.file.Path;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.VideoException;
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
import jk.kamoru.flayon.crazy.video.domain.TitlePart;
import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.domain.VideoSearch;
import jk.kamoru.flayon.crazy.video.service.queue.NotiQueue;
import jk.kamoru.flayon.crazy.video.service.webfile.WebFileLookupService;
import jk.kamoru.flayon.crazy.video.util.TistoryRSSReader;
import jk.kamoru.flayon.crazy.video.util.VideoUtils;
import lombok.extern.slf4j.Slf4j;

/**
 * video service implement class
 * @author kamoru
 */
@Service
@Slf4j
public class VideoServiceImpl extends CrazyProperties implements VideoService {


	/** minimum free space of disk */
	private final long MIN_FREE_SPAC = 10 * FileUtils.ONE_GB;
	/** sleep time of moving video */
	private final long SLEEP_TIME = 5 * 1000;
	
	/** video dao */
	@Autowired VideoDao videoDao;
	@Autowired HistoryService historyService;
	@Autowired TagDao tagDao;
	@Autowired WebFileLookupService arzonLookupService;
	@Autowired WebFileLookupService sukebeiNyaaLookupService;

	// --- private
	
	private List<Video> getVideoList(List<Video> list, Sort sort, boolean reverse) {
		if (sort == null)
			return list;
		else {
			for (Video video : list) 
				video.setSortMethod(sort);
			return list.stream()
					.sorted(reverse ? Comparator.reverseOrder() : Comparator.naturalOrder())
					.collect(Collectors.toList());
		}
	}

	private List<Studio> getStudioList(List<Studio> list, StudioSort sort, boolean reverse) {
		if (sort == null)
			return list;
		else {
			for (Studio studio : list)
				studio.setSort(sort);
			return list.stream()
					.sorted(reverse ? Comparator.reverseOrder() : Comparator.naturalOrder())
					.collect(Collectors.toList());
		}
	}

	private List<Actress> getActressList(List<Actress> list, ActressSort sort, boolean reverse) {
		if (sort == null)
			return list;
		else {
			for (Actress actress : list)
				actress.setSort(sort);
			return list.stream()
					.sorted(reverse ? Comparator.reverseOrder() : Comparator.naturalOrder())
					.collect(Collectors.toList());
		}
	}

	// --- public
	
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

	/**call executive command by action. asynchronous
	 * @param video
	 * @param action PLAY, SUBTITLES in {@link Action}
	 */
	@Async
	private void callExecutiveCommand(Video video, Action action) {
		log.debug("{} : {}", video.getOpus(), action);
		String command = null;
		String[] argumentsArray = null;
		switch(action) {
			case PLAY:
				command = PLAYER;
				argumentsArray = video.getVideoFileListPathArray();
				break;
			case SUBTITLES:
				command = EDITOR;
				argumentsArray = video.getSubtitlesFileListPathArray();
				break;
			default:
				throw new VideoException(video, "Unknown Action");
		}
		if(argumentsArray == null)
			throw new VideoException(video, "No arguments for " + action);
		
		Utils.exec(ArrayUtils.addAll(new String[]{command}, argumentsArray));
		
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
					return Utils.compareTo(o2.get("date"), o1.get("date"));
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
				foundMapList.add(map);
			} 
		}
		log.debug("q={} foundLength={}", query, foundMapList.size());
		Collections.sort(foundMapList, new Comparator<Map<String, String>>() {

			@Override
			public int compare(Map<String, String> o1, Map<String, String> o2) {
				return Utils.compareTo(o2.get("date"), o1.get("date"));
//				String thisStr = o1.get("opus");
//				String compStr = o2.get("opus");
//
//				String[] s = {thisStr, compStr};
//				Arrays.sort(s);
//				return s[0].equals(thisStr) ? 1 : -1;
			}});
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
		Collections.sort(list);

		if (log.isDebugEnabled())
			log.debug("getActressListInVideoList found studio size {}", list.size());
		return list;
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
		Collections.sort(list);
		
		if (log.isDebugEnabled())
			log.debug("found studio list size {}", list.size());
		return list;
	}

	@Override
	public Video getVideo(String opus) {
		return videoDao.getVideo(opus);
	}

	@Override
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
				.sorted(search.isSortReverse() ? Comparator.reverseOrder() : Comparator.naturalOrder())
				.collect(Collectors.toList());
/*		
		return videoDao.getVideoList().stream()
			.filter(v -> containsQuery(v, search.getSearchText()))
			.filter(v -> addCond(v, search.isAddCond(), search.isExistVideo(), search.isExistSubtitles()))
			.filter(v -> search.getSelectedStudio() == null ? true : search.getSelectedStudio().contains(v.getStudio().getName()))
			.filter(v -> search.getSelectedActress() == null ? true : VideoUtils.containsActress(v, search.getSelectedActress()))
			.filter(v -> rankMatch(v.getRank(), search.getRankRange()))
			.filter(v -> playCountMatch(v.getPlayCount(), search.getPlayCount()))
			.filter(v -> tagMatch(v, search.getSelectedTag()))
			.map(v -> v.setSortMethod(search.getSortMethod()))
			.sorted(search.isSortReverse() ? Comparator.reverseOrder() : Comparator.naturalOrder())
			.collect(Collectors.toList());
			
*/
/*		
		return videoDao.getVideoList().parallelStream()
				.filter(new Predicate<Video>(){

					@Override
					public boolean test(Video video) {
						if ((VideoUtils.equals(video.getStudio().getName(), search.getSearchText()) 
								|| VideoUtils.equals(video.getOpus(), search.getSearchText()) 
								|| VideoUtils.containsName(video.getTitle(), search.getSearchText()) 
								|| VideoUtils.containsActress(video, search.getSearchText())
								|| VideoUtils.containsName(video.getReleaseDate(), search.getSearchText())) 
							&& (search.isAddCond()   
									? ((search.isExistVideo() ? video.isExistVideoFileList() : !video.isExistVideoFileList())
										&& (search.isExistSubtitles() ? video.isExistSubtitlesFileList() : !video.isExistSubtitlesFileList())) 
									: true)
							&& (search.getSelectedStudio() == null ? true : search.getSelectedStudio().contains(video.getStudio().getName()))
							&& (search.getSelectedActress() == null ? true : VideoUtils.containsActress(video, search.getSelectedActress()))
							&& (rankMatch(video.getRank(), search.getRankRange()))
							&& (playCountMatch(video.getPlayCount(), search.getPlayCount()))
							&& tagMatch(video, search.getSelectedTag())
							) 
						{
							video.setSortMethod(search.getSortMethod());
							return true;
						}
						return false;
					}
					
				})
				.sorted(search.isSortReverse() ? Comparator.reverseOrder() : Comparator.naturalOrder())
				.collect(Collectors.toList());
*/		
/*		
		List<Video> foundList = new ArrayList<Video>();
		for (Video video : videoDao.getVideoList()) {
			if ((VideoUtils.equals(video.getStudio().getName(), search.getSearchText()) 
					|| VideoUtils.equals(video.getOpus(), search.getSearchText()) 
					|| VideoUtils.containsName(video.getTitle(), search.getSearchText()) 
					|| VideoUtils.containsActress(video, search.getSearchText())
					|| VideoUtils.containsName(video.getReleaseDate(), search.getSearchText())) 
				&& (search.isAddCond()   
						? ((search.isExistVideo() ? video.isExistVideoFileList() : !video.isExistVideoFileList())
							&& (search.isExistSubtitles() ? video.isExistSubtitlesFileList() : !video.isExistSubtitlesFileList())) 
						: true)
				&& (search.getSelectedStudio() == null ? true : search.getSelectedStudio().contains(video.getStudio().getName()))
				&& (search.getSelectedActress() == null ? true : VideoUtils.containsActress(video, search.getSelectedActress()))
				&& (rankMatch(video.getRank(), search.getRankRange()))
				&& (playCountMatch(video.getPlayCount(), search.getPlayCount()))
				&& tagMatch(video, search.getSelectedTag())
				) 
			{
				video.setSortMethod(search.getSortMethod());
				foundList.add(video);
			}
		}
		log.debug("found video list size {}", foundList.size());
		if (search.isSortReverse()) {
//			Collections.sort(foundList, Collections.reverseOrder());
			return foundList.stream().sorted(Comparator.reverseOrder()).collect(Collectors.toList());
		}
		else {
//			Collections.sort(foundList);
			return foundList.stream().sorted().collect(Collectors.toList());
		}
*/		
	}
/*	
	private boolean addCond(Video video, boolean addCond, boolean existVideo, boolean existSubtitles) {
		return addCond   
				? ((existVideo ? video.isExistVideoFileList() : !video.isExistVideoFileList())
						&& (existSubtitles ? video.isExistSubtitlesFileList() : !video.isExistSubtitlesFileList())) 
				: true;
	}
*/
/*
	private boolean containsQuery(Video video, String searchText) {
		return VideoUtils.equals(video.getStudio().getName(), searchText) 
				|| VideoUtils.equals(video.getOpus(), searchText) 
				|| VideoUtils.containsName(video.getTitle(), searchText) 
				|| VideoUtils.containsActress(video, searchText)
				|| VideoUtils.containsName(video.getReleaseDate(), searchText);
	}
*/
/*
	private boolean tagMatch(Video video, List<String> selectedTag) {
		if (selectedTag == null)
			return true;
		if (video.getTags() == null)
			return false;
		for (VTag tag : video.getTags()) {
			if (selectedTag.contains(tag.getId().toString()))
				return true;
		}
		return false;
	}
*/
	/**compare play count. {@code true} if playCount2 is {@code null} or {@code -1}
	 * @param playCount
	 * @param playCount2
	 * @return {@code true} if same of both or playCount2 {@code null}, {@code -1}
	private boolean playCountMatch(Integer playCount, Integer playCount2) {
		if (playCount2 == null || playCount2 == -1)
			return true;
		else 
			return playCount == playCount2;
	}
	 */

	/**Returns {@code true} if rankRange list contains the specified rank
	 * @param rank
	 * @param rankRange rank range list
	 * @return {@code true} if rankRange list contains the specified rank
	private boolean rankMatch(int rank, List<Integer> rankRange) {
		return rankRange.contains(rank);
	}
	 */

	@Override
	public Map<String, Long[]> groupByPath() {
		log.debug("groupByPath");
		Map<String, Long[]> pathMap = new TreeMap<>();
		Long[] total = new Long[]{0l, 0l};
		for (Video video : videoDao.getVideoList(true, false)) {
			String path = video.getDelegatePath();
			if (path.contains(STORAGE_PATH))
				path = STORAGE_PATH;
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
	public void saveActressInfo(Map<String, String> params) {
		videoDao.renameActress(params);
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
	public void reload(StopWatch stopWatch) {
		log.debug("reload");
		videoDao.reload(stopWatch, true, false);
	}

//	@Override
//	public void reload() {
//		log.debug("reload");
//		videoDao.reload(true, false);
//	}

	@Override
	public void saveStudioInfo(Map<String, String> params) {
		videoDao.renameStudio(params);
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
	public Integer minRank() {
		return MIN_RANK;
	}

	@Override
	public Integer maxRank() {
		return MAX_RANK;
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
/*
		List<Video> list = videoDao.getVideoList();
		Collections.sort(list, new Comparator<Video>(){
			@Override
			public int compare(Video o1, Video o2) {
				return o2.getScore() == o1.getScore() 
						? Utils.compareTo(o2.getReleaseDate(), o1.getReleaseDate()) 
								: o2.getScore() - o1.getScore();
			}});
		return list;
*/
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
			
			// 플레이 한적이 없는 비디오는 pass
			if (video.getPlayCount() < 1)
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
			log.info("    {} move from [{}] to [{}]", video.getFullname(), video.getDelegatePathFile().getParent(), destDir.getPath());
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
	public List<Video> torrent(Boolean getAllTorrents) {
		log.info("Torrent, getAllTorrents = {}", getAllTorrents);
		
		List<Video> allInstanceList = videoDao.getVideoList(true, false);
		List<Video> nonExistVideoList = allInstanceList.stream().filter(v -> !v.isExistVideoFileList()).collect(Collectors.toList());
		log.debug("  need torrent videos - {}", nonExistVideoList.size());
		
		// CANDIDATE_PATHS에서 찾은 파일들
		List<File> foundFiles = new ArrayList<>();
		for (String candidatePath : CANDIDATE_PATHS) {
		
			// get downloaded torrent file
			File candidateDirectory = new File(candidatePath);
			if (!candidateDirectory.exists() || !candidateDirectory.isDirectory()) {
				log.warn("{} is not valid", candidatePath);
				continue;
			}
		
			String[] extensions = String.format("%s,%s", CRAZY.SUFFIX_VIDEO.toUpperCase(), CRAZY.SUFFIX_VIDEO.toLowerCase()).split(",");
			Collection<File> found = FileUtils.listFiles(candidateDirectory, extensions, true);
			log.info("Scan video file {}, found {}", candidateDirectory, found.size());
			
			foundFiles.addAll(found);
		}
		
		// find torrent
		Collection<File> foundTorrent = FileUtils.listFiles(new File(TORRENT_PATH), new String[]{CRAZY.SUFFIX_TORRENT.toUpperCase(), CRAZY.SUFFIX_TORRENT.toLowerCase()}, true);
		log.info("Scan torrents file {}, found {}", TORRENT_PATH, foundTorrent.size());
		
		for (Video video : allInstanceList) {
			// candidates
			video.resetVideoCandidates();
			String opus = video.getOpus().toLowerCase();
			log.debug("  OPUS : {}", opus);
			for (String key : Arrays.asList(opus, StringUtils.remove(opus, "-"))) {
				for (File file : foundFiles) {
					String fileName = file.getName().toLowerCase();
					log.trace("    compare : {} = {}", fileName, key);
					if (fileName.contains(key)) {
						video.addVideoCandidates(file);
						log.debug("    add video candidate {} : {}", opus, file.getAbsolutePath());
					}
				}
			}
		}
		
		// matching video file
		for (Video video : nonExistVideoList) {
			// torrents
			video.resetTorrents();
			String opus = video.getOpus().toLowerCase();
			for (File file : foundTorrent) {
				if (StringUtils.contains(file.getName(), video.getOpus())) {
					video.addTorrents(file);
					log.debug("    add Torrent {} : {}", opus, file.getName());
				}
			}
			// find & save torrent
			if (getAllTorrents) {
				if (video.getTorrents().isEmpty()) {
					CompletableFuture<File> completableFuture = sukebeiNyaaLookupService.get(video.getOpus(), video.getTitle(), TORRENT_PATH);
					try {
						File file = completableFuture.get();
						if (file != null)
							video.addTorrents(file);
					} catch (InterruptedException | ExecutionException e) {
						log.error("sukebeiNyaaLookupService : completableFuture.get()", e);
					}
				}
			}
		}
		log.debug("Matching candidates and torrent file complete");

		Comparator<Video> byCandidates = (v2, v1) -> Integer.compare(v1.getVideoCandidates().size(), v2.getVideoCandidates().size());
		Comparator<Video> byTorrents = (v2, v1) -> Integer.compare(v1.getTorrents().size(), v2.getTorrents().size());
		Comparator<Video> byOpus = (v1, v2) -> v1.getOpus().compareTo(v2.getOpus());
		return nonExistVideoList.stream().sorted(byCandidates.thenComparing(byTorrents).thenComparing(byOpus)).collect(Collectors.toList());

	}

	@Override
	public void confirmCandidate(String opus, String path) {
		log.debug("confirmCandidate : {} - {}", opus, path);
		
		File destinationPath = null;
		for (String extraPath : STAGE_PATHS) {
			if (Utils.equalsRoot(path, extraPath)) {
				destinationPath = new File(extraPath);
				break;
			}
		}
		if (destinationPath == null)
			throw new VideoException("Not found proper destination path for candidate file");
		
		Video video = videoDao.getVideo(opus);
		int videoFileSize = video.getVideoFileList().size();
		File candidatedVideofile = new File(path);
		File videoFile = new File(destinationPath, 
				String.format("%s%s.%s", 
						video.getFullname(), 
						videoFileSize > 0 ? String.valueOf(++videoFileSize) : "", 
						Utils.getExtension(candidatedVideofile)));
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
	public List<TitlePart> parseToTitleData(String titleData, Boolean saveCoverAll) {
		List<TitlePart> titlePartList = new ArrayList<>();
		
		if (!StringUtils.isEmpty(titleData)) {
			titleData += System.getProperty("line.separator") + System.getProperty("line.separator") + "eof";
			String[] titles = titleData.split(System.getProperty("line.separator"));

			String text = null;
			try {
				for (int i = 0; i < titles.length; i++) {
					if (titles[i].trim().length() > 0) {
						// make TitlePart
						TitlePart titlePart = new TitlePart();
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
						else if (StringUtils.contains(Utils.toStringComma(REPLACE_OPUS_INFO), opusPrefix)) {
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
				List<TitlePart> _titlePartList = new ArrayList<>();
				int count = 0;
				int total = titlePartList.size();
				for (TitlePart titlePart : titlePartList) {
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
				.sorted(Comparator.comparing(TitlePart::toFullLowerName))
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
				.sorted(search.isSortReverse() ? Comparator.reverseOrder() : Comparator.naturalOrder())
				.collect(Collectors.toList());

/*		
		return videoDao.getArchiveVideoList().parallelStream()
				.filter(new Predicate<Video>() {

					@Override
					public boolean test(Video video) {
						if ((VideoUtils.equals(video.getStudio().getName(), search.getSearchText()) 
								|| VideoUtils.equals(video.getOpus(), search.getSearchText()) 
								|| VideoUtils.containsName(video.getTitle(), search.getSearchText()) 
								|| VideoUtils.containsActress(video, search.getSearchText())
								|| VideoUtils.containsName(video.getReleaseDate(), search.getSearchText())) 
							&& (search.isAddCond()   
									? ((search.isExistVideo() ? video.isExistVideoFileList() : !video.isExistVideoFileList())
										&& (search.isExistSubtitles() ? video.isExistSubtitlesFileList() : !video.isExistSubtitlesFileList())) 
									: true)
							) 
						{
							video.setSortMethod(search.getSortMethod());
							return true;
						}
						return false;
					}})
				.sorted(search.isSortReverse() ? Comparator.reverseOrder() : Comparator.naturalOrder())
				.collect(Collectors.toList());
*/
/*		
		List<Video> foundList = new ArrayList<Video>();
		for (Video video : videoDao.getArchiveVideoList()) {
			if ((VideoUtils.equals(video.getStudio().getName(), search.getSearchText()) 
					|| VideoUtils.equals(video.getOpus(), search.getSearchText()) 
					|| VideoUtils.containsName(video.getTitle(), search.getSearchText()) 
					|| VideoUtils.containsActress(video, search.getSearchText())
					|| VideoUtils.containsName(video.getReleaseDate(), search.getSearchText())) 
				&& (search.isAddCond()   
						? ((search.isExistVideo() ? video.isExistVideoFileList() : !video.isExistVideoFileList())
							&& (search.isExistSubtitles() ? video.isExistSubtitlesFileList() : !video.isExistSubtitlesFileList())) 
						: true)
//				&& (search.getSelectedStudio() == null ? true : search.getSelectedStudio().contains(video.getStudio().getName()))
//				&& (search.getSelectedActress() == null ? true : VideoUtils.containsActress(video, search.getSelectedActress()))
//				&& (rankMatch(video.getRank(), search.getRankRange()))
//				&& (playCountMatch(video.getPlayCount(), search.getPlayCount()))
				) 
			{
				video.setSortMethod(search.getSortMethod());
				foundList.add(video);
			}
		}
		if (search.isSortReverse())
			Collections.sort(foundList, Collections.reverseOrder());
		else
			Collections.sort(foundList);

		log.debug("found video list size {}", foundList.size());
		return foundList;
*/		
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
				if (Utils.isEmptyDirectory(dir)) {
					dir.delete();
					log.info("deletEmptyFolder : delete {}", dir);
				}
			}
		}
		log.debug("deletEmptyFolder END");
	}

	@Override
	public void setFavoriteOfActress(String actressName, Boolean favorite) {
		videoDao.getActress(actressName).setFavorite(favorite);
	}

	@Override
	public List<VTag> getTagList() {
		return tagDao.findAll();
	}

	@Override
	public void updateTag(VTag tag) {
		tagDao.merge(tag);
		for (Video video : videoDao.getVideoList(true, false)) {
			if (video.getInfo().getTags() == null)
				continue;
			if (video.getInfo().getTags().contains(tag)) {
				video.updateTag(tag);
			}
		}
	}

	@Override
	public void deleteTag(VTag tag) {
		tagDao.remove(tag);
		for (Video video : videoDao.getVideoList(true, false)) {
			if (video.getInfo().getTags() == null)
				continue;
			if (video.getInfo().getTags().contains(tag)) {
				video.toggleTag(tag);
			}
		}
	}

	@Override
	public void createTag(VTag tag) {
		tagDao.persist(tag);
	}

	@Override
	public List<TistoryGraviaItem> getTistoryItem() {
		return TistoryRSSReader.get(rssUrl, studioMapByOpus(), opusList());
	}

	private List<String> opusList() {
		List<String> opusList = new ArrayList<>();
		for (Video video : videoDao.getVideoList(true, false)) {
			opusList.add(video.getOpus());
		}
		return opusList;
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
	public void toggleTag(String opus, VTag tag) {
		VTag _tag = tagDao.findById(tag.getId());
		videoDao.getVideo(opus).toggleTag(_tag);
	}

	@Override
	public List<VTag> getTagListWithVideo() {
		List<VTag> allTags = tagDao.findAll();
		List<Video> videoList = videoDao.getVideoList(true, false);
		for (VTag vTag : allTags) {
			vTag.getVideoList().clear();
			for (Video video : videoList) {
				if (video.getTags() == null)
					continue;
				if (video.getTags().contains(vTag)) {
					vTag.addVideo(video);
				}
			}
		}
		return allTags;
	}

	@Override
	public VTag getTag(Integer id) {
		VTag vTag = tagDao.findById(id);
		vTag.getVideoList().clear();
		for (Video video : videoDao.getVideoList(true, false)) {
			if (video.getTags() == null)
				continue;
			if (video.getTags().contains(vTag)) {
				vTag.addVideo(video);
			}
		}
		return vTag;
	}

	@Override
	public List<Actress> getActressList(ActressSort sort, Boolean reverse, Boolean instance, Boolean archive) {
		List<Actress> list = new ArrayList<>();
		if (instance)
			list.addAll(getActressList(videoDao.getActressList(instance, false), sort, reverse));
		if (archive)
			list.addAll(getActressList(videoDao.getActressList(false, archive), sort, reverse)
					.stream().filter(a -> !list.contains(a))
					.collect(Collectors.toList()));
		return list;
	}

	@Override
	public List<Studio> getStudioList(StudioSort sort, Boolean reverse, Boolean instance, Boolean archive) {
		List<Studio> list = new ArrayList<>();
		if (instance)
			list.addAll(getStudioList(videoDao.getStudioList(instance, false), sort, reverse));
		if (archive)
			list.addAll(getStudioList(videoDao.getStudioList(false, archive), sort, reverse)
					.stream().filter(s -> !list.contains(s))
					.collect(Collectors.toList()));
		return list;
	}

	@Override
	public List<Video> getVideoList(Sort sort, Boolean reverse, Boolean instance, Boolean archive) {
		List<Video> list = new ArrayList<>();
		if (instance)
			list.addAll(getVideoList(videoDao.getVideoList(instance, false), sort, reverse));
		if (archive)
			list.addAll(getVideoList(videoDao.getVideoList(false, archive), sort, reverse)
					.stream().filter(v -> !list.contains(v))
					.collect(Collectors.toList()));
		return list;
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
				TitlePart titlePart = new TitlePart(title);
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
				FileUtils.moveFileToDirectory(file, new File(SEED_PATH), false);
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

		Map<String, CompletableFuture<File>> resultMap = new ConcurrentHashMap<String, CompletableFuture<File>>();
		for (String title : titles) {
			String opus = VideoUtils.getOpusInTitle(title);
			
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
			TitlePart titlePart = new TitlePart(title);
			if (titlePart.isCheck()) {
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
					String title = Utils.getNameExceptExtension(file);
					TitlePart savedTitlePart = new TitlePart(title);
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
	public List<Video> getVideoList(Sort sort, Boolean reverse, Boolean instance, Boolean archive, Boolean withTorrent) {
		if (withTorrent)
			torrent(false);
		return getVideoList(sort, reverse, instance, archive);
	}

}
