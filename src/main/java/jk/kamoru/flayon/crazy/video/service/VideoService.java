package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.util.List;
import java.util.Map;

import jk.kamoru.flayon.base.util.StopWatch;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.ActressSort;
import jk.kamoru.flayon.crazy.video.domain.Sort;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.StudioSort;
import jk.kamoru.flayon.crazy.video.domain.TistoryGraviaItem;
import jk.kamoru.flayon.crazy.video.domain.TitleValidator;
import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.domain.VideoSearch;

/**
 * Video Service Interface
 * @author kamoru
 */
/**
 * @author kamoru
 *
 */
public interface VideoService {

	/**
	 * Call subtitles editor
	 * @param opus
	 */
	void editVideoSubtitles(String opus);

	/**
	 * find history by query 
	 * @param query
	 * @return history result
	 */
	List<Map<String, String>> findHistory(String query);

	/**
	 * find video by query
	 * @param query
	 * @return video list
	 */
	List<Map<String, String>> findVideoList(String query);

	/**
	 * get actress by name
	 * @param actressName
	 * @return actress
	 */
	Actress getActress(String actressName);

	/**
	 * actress list in video
	 * @param videoList
	 * @return actress list
	 */
	List<Actress> getActressListInVideoList(List<Video> videoList);

	/**
	 * get studio by name
	 * @param studioName
	 * @return studio
	 */
	Studio getStudio(String studioName);

	/** 
	 * get stuio ilst in video
	 * @param videoList
	 * @return studio list
	 */
	List<Studio> getStudioListInVideoList(List<Video> videoList);
	
	/** 
	 * get video by opus
	 * @param opus
	 * @return video
	 */
	Video getVideo(String opus);

	/**
	 * get video by search bean
	 * @param videoSearch
	 * @return video list
	 */
	List<Video> searchVideo(VideoSearch videoSearch);

	/**
	 * @param videoSearch
	 * @return
	 */
	List<Video> searchVideoInArchive(VideoSearch videoSearch);

	/**get info group by path
	 * @return map of path, length array
	 */
	Map<String, Long[]> groupByPath();

	/**get info group by date
	 * @return map of date, video list
	 */
	Map<String, List<Video>> groupByDate();
	
	/**get info group by rank
	 * @return map of rank, video list
	 */
	Map<Integer, List<Video>> groupByRank();
	
	/**get info group by play count
	 * @return map of play count, video list
	 */
	Map<Integer, List<Video>> groupByPlay();

	/**
	 * reload video source
	 * @param stopWatch 
	 */
	void reload(StopWatch stopWatch);

	/**
	 * reload archive source
	 */
	void reloadArchive();
	
	List<Actress> getActressList();
	
	List<Actress> getActressList(boolean instance, boolean archive);
	
	List<Actress> getActressList(boolean instance, boolean archive, ActressSort sort, boolean reverse);

	List<Studio> getStudioList();

	List<Studio> getStudioList(boolean instance, boolean archive);
	
	List<Studio> getStudioList(boolean instance, boolean archive, StudioSort sort, boolean reverse);

	List<Video> getVideoList();
	
	List<Video> getVideoList(boolean instance, boolean archive);
	
	List<Video> getVideoList(boolean instance, boolean archive, Sort sort, boolean reverse);

	List<Video> getVideoList(boolean instance, boolean archive, Sort sort, boolean reverse, boolean withTorrent);

	List<Video> getVideoList(boolean instance, boolean archive, Sort sort, boolean reverse, boolean withCandidate, boolean existVideo);

	/**
	 * get rank range
	 * @return rank list
	 */
	List<Integer> getRankRange();

	/**
	 * get info group by score
	 * @return map of score, video list
	 */
	Map<Integer, List<Video>> groupByScore();

	/**
	 * get groups by length
	 * @return map of length, video list
	 */
	Map<Integer, List<Video>> groupByLength();

	/**
	 * group by extension
	 * @return
	 */
	Map<String, List<Video>> groupByExtension();

	List<TistoryGraviaItem> getTistoryItem();

	void moveTorrentToSeed(String opus);

	void moveTorrentToSeed(File file);

	// --- action method of video --------------------------------------

	/**play video
	 * @param opus
	 */
	void playVideo(String opus);

	/**set video rank
	 * @param opus
	 * @param rank
	 */
	void rankVideo(String opus, int rank);

	/**save video overvire
	 * @param opus
	 * @param overViewTxt
	 */
	void saveVideoOverview(String opus, String overViewTxt);

	/**
	 * move watched video
	 */
	int moveWatchedVideo();

	/**
	 * arrange video. move files of video to same directory  
	 */
	void arrangeVideo();

	/**move video file. rename to fullname
	 * @param opus
	 * @param path current video file
	 */
	void confirmCandidate(String opus, String path, char type);

	/**
	 * reset rank and playcount
	 * @param opus
	 */
	void resetVideoScore(String opus);

	/**
	 * reset wrong video. move video file to outside. reset rank & playcount
	 * @param opus
	 */
	void resetWrongVideo(String opus);

	/**
	 * arrange archive video by yyyy-MM
	 */
	void arrangeArchiveVideo();

	/**
	 * save video cover
	 * @param opus
	 * @param title
	 */
	void saveCover(String opus, String title);
	
	// --- action method of actress --------------------------------------

	/**save actress info
	 * @param params map of actress info
	 * @return 
	 */
	Actress saveActressInfo(Map<String, String> params);

	/**
	 * set favorite
	 * @param actressName
	 * @param favorite
	 * @return 
	 */
	boolean setFavoriteOfActress(String actressName, Boolean favorite);

	// --- action method of actress --------------------------------------

	/**
	 * save studio info
	 * @param params map of studio info
	 * @return 
	 */
	Studio saveStudioInfo(Map<String, String> params);
	
	// --- action method of source --------------------------------------
	
	/**Remove video
	 * @param opus
	 */
	void removeVideo(String opus);

	/**move video files
	 * @param opus
	 * @param path destination path
	 */
	void moveVideo(String opus, String path);

	/**
	 * remove lower rank video
	 */
	int removeLowerRankVideo();

	/**
	 * remove lower socore video
	 */
	int removeLowerScoreVideo();

	/**
	 * delete garbage file
	 */
	int deleteGarbageFile();

	/**
	 * rename studio/opus/title/actress/released...
	 * @param opus
	 * @param newName
	 */
	void rename(String opus, String newName);

	/**
	 * @param titleData
	 * @param saveCoverAll
	 * @return
	 */
	List<TitleValidator> parseToTitleData(String titleData, Boolean saveCoverAll);

	/**
	 * move to instance source
	 * @param opus
	 */
	void moveToInstance(String opus);

	/**
	 * save cover and insert to source
	 * @param titles
	 * @return
	 */
	void saveCover(List<String> titles);

	
	// --- for batch ----------------------------------------------------

	List<String> getOpusList();

	int downloadTorrents(String[] opusArr);

	void toggleTag(VTag tag, String opus);

	List<Map<String, String>> findTorrent(String query);

	List<Map<String, String>> findStudio(String query);

}
