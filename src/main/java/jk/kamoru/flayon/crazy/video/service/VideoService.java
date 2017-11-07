package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.util.List;
import java.util.Map;

import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.ActressSort;
import jk.kamoru.flayon.crazy.video.domain.Sort;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.StudioSort;
import jk.kamoru.flayon.crazy.video.domain.TistoryGraviaItem;
import jk.kamoru.flayon.crazy.video.domain.TitlePart;
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
	 * all actress list
	 * @return actress list
	 */
//	List<Actress> getActressList();

//	List<Actress> getActressListInArchive();

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
	 * get all studio list
	 * @return studio list
	 */
//	List<Studio> getStudioList();

//	List<Studio> getStudioListInArchive();

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
	 * get video cover byte array
	 * @param opus
	 * @return cover byte array
	 */
	byte[] getVideoCoverByteArray(String opus);

	/**
	 * get video cover file
	 * @param opus
	 * @return cover file
	 */
	File getVideoCoverFile(String opus);

	/**
	 * get all video list
	 * @return video list
	 */
//	List<Video> getVideoList();
	
	/**
	 * get all archive video list
	 * @return
	 */
//	List<Video> getArchiveVideoList();


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
	 * reload video source
	 */
//	void reload();

	/**
	 * reload archive source
	 */
	void reloadArchive();
	
	/**get all sorted actress list
	 * @param sort
	 * @param reverse 
	 * @return actress list
	 */
//	@Deprecated
//	List<Actress> getActressList(ActressSort sort, boolean reverse);

	/**
	 * actress list in instance and/or archive
	 * @param sort
	 * @param reverse
	 * @param instance
	 * @param archive
	 * @return
	 */
	List<Actress> getActressList(ActressSort sort, Boolean reverse, Boolean instance, Boolean archive);

	/**get all sorted studio list
	 * @param sort
	 * @param reverse 
	 * @return studio list
	 */
//	@Deprecated
//	List<Studio> getStudioList(StudioSort sort, boolean reverse);

	/**
	 * studio list in instance and/or archive
	 * @param sort
	 * @param reverse
	 * @param instance
	 * @param archive
	 * @return
	 */
	List<Studio> getStudioList(StudioSort sort, Boolean reverse, Boolean instance, Boolean archive);

	/**get all sorted video list
	 * @param sort
	 * @param reverse 
	 * @return video list
	 */
//	@Deprecated
//	List<Video> getVideoList(Sort sort, boolean reverse);
	
	/**
	 * video list in instance and/or archive
	 * @param sort
	 * @param reverse
	 * @param instance
	 * @param archive
	 * @return
	 */
	List<Video> getVideoList(Sort sort, Boolean reverse, Boolean instance, Boolean archive);

	List<Video> getVideoList(Sort sort, Boolean reverse, Boolean instance, Boolean archive, Boolean withTorrent);

	/**
	 * get play count range
	 * @return play count list
	 */
	List<Integer> getPlayRange();

	/**
	 * get minimum rank in properties
	 * @return rank
	 */
	Integer minRank();

	/**
	 * get maximum rank in properties
	 * @return rank
	 */
	Integer maxRank();

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
	void moveWatchedVideo();

	/**
	 * arrange video. move files of video to same directory  
	 */
	void arrangeVideo();

	/**get video list with torrent info
	 * @param getAllTorrents 
	 */
	List<Video> torrent(Boolean getAllTorrents);

	/**move video file. rename to fullname
	 * @param opus
	 * @param path current video file
	 */
	void confirmCandidate(String opus, String path);

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
	 * @param name actress name
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
	void removeLowerRankVideo();

	/**
	 * remove lower socore video
	 */
	void removeLowerScoreVideo();

	/**
	 * delete garbage file
	 */
	void deleteGarbageFile();

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
	List<TitlePart> parseToTitleData(String titleData, Boolean saveCoverAll);

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
	
	/**
	 * 하위에 속이 빈 폴더를 지운다
	 */
	void deletEmptyFolder();

	List<String> getOpusList();

	int getTorrents(String[] opusArr);

	void toggleTag(VTag tag, String opus);

}
