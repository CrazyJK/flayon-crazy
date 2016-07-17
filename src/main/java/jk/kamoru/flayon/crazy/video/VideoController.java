package jk.kamoru.flayon.crazy.video;

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import jk.kamoru.flayon.crazy.AbstractController;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.domain.Action;
import jk.kamoru.flayon.crazy.video.domain.ActressSort;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.HistoryData;
import jk.kamoru.flayon.crazy.video.domain.Sort;
import jk.kamoru.flayon.crazy.video.domain.StudioSort;
import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.domain.VideoSearch;
import jk.kamoru.flayon.crazy.video.domain.View;
import jk.kamoru.flayon.crazy.video.service.HistoryService;
import jk.kamoru.flayon.crazy.video.service.VideoService;
import jk.kamoru.flayon.crazy.video.util.CoverUtils;
import jk.kamoru.flayon.crazy.video.util.VideoUtils;

/**
 * Video controller<br>
 * @author kamoru
 */
@Controller
@RequestMapping("/video")
public class VideoController extends AbstractController {

	protected static final Logger logger = LoggerFactory.getLogger(VideoController.class);
	
	@Autowired private VideoService videoService;
	@Autowired private HistoryService historyService;
	@Autowired private VideoBatch videoBatch;

	long today = new Date().getTime();
	
	/**minimum rank model attrubute by named 'minRank'
	 * @return model attribute
	 */
	@ModelAttribute("minRank")
	public Integer minRank() {
		return videoService.minRank();
	}

	/**maximum rank model attrubute by named 'maxRank'
	 * @return model attribute
	 */
	@ModelAttribute("maxRank")
	public Integer maxRank() {
		return videoService.maxRank();
	}

	@ModelAttribute("playRatio")		public int playRatio() { return PLAY_RATIO; }
	@ModelAttribute("rankRatio")		public int rankRatio() { return RANK_RATIO; }
	@ModelAttribute("actressRatio")		public int actressRatio() { return ACTRESS_RATIO; }
	@ModelAttribute("subtitlesRatio")	public int subtitlesRatio() { return SUBTITLES_RATIO; }

	@ModelAttribute("urlSearchVideo")	public String urlSearchVideo() { return urlSearchVideo; }
	@ModelAttribute("urlSearchActress")	public String urlSearchActress() { return urlSearchActress; }
	@ModelAttribute("urlSearchTorrent")	public String urlSearchTorrent() { return urlSearchTorrent; }
	
	@ModelAttribute("maxEntireVideo")	public int maxEntireVideo() { return MAX_ENTIRE_VIDEO; }
	
	
	/**display actress list view
	 * @param model
	 * @param sort default NAME if {@code null}
	 * @return view name
	 */
	@RequestMapping(value="/actress", method=RequestMethod.GET)
	public String actressList(Model model, @RequestParam(value="sort", required=false, defaultValue="NAME") ActressSort sort,
			@RequestParam(value="r", required=false, defaultValue="false") Boolean reverse,
			@RequestParam(value="i", required=false, defaultValue="true") Boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") Boolean archive) {
		logger.trace("actressList sort={} reverse={}, instance={}, archive={}", sort, reverse, instance, archive);
		model.addAttribute(videoService.getActressList(sort, reverse, instance, archive));
		model.addAttribute("sorts", ActressSort.values());
		model.addAttribute("sort", sort);
		model.addAttribute("reverse", reverse);
		model.addAttribute("instance", instance);
		model.addAttribute("archive", archive);
		return "video/actressList";
	}

	/**display a actress detail view
	 * @param model
	 * @param actressName actress name
	 * @return view name
	 */
	@RequestMapping(value="/actress/{actressName}", method=RequestMethod.GET)
	public String actressDetail(Model model, @PathVariable String actressName) {
		logger.trace(actressName);
		model.addAttribute(videoService.getActress(actressName));
		return "video/actressDetail";
	}

	/**save actres info
	 * @param actressName
	 * @param params map of info
	 */
	@RequestMapping(value="/actress/{actressName}", method=RequestMethod.POST)
	public String saveActressInfo(@PathVariable String actressName, @RequestParam Map<String, String> params) {
		logger.trace("{}", params);
		String currentActressName = videoService.saveActressInfo(actressName, params);
		return "redirect:/video/actress/" + currentActressName;
	}

	@RequestMapping(value="/actress/{actressName}/favorite/{favorite}", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void putActressFavorite(@PathVariable String actressName, @PathVariable Boolean favorite) {
		logger.debug("{}, {}", actressName, favorite);
		videoService.setFavoriteOfActress(actressName, favorite);
	}
	
	/**display status briefing view
	 * @param model
	 * @return view name
	 */
	@RequestMapping(value="/briefing", method=RequestMethod.GET)
	public String briefing(Model model) {
		logger.info("briefing START");

		videoService.reload();
		logger.info("briefing reload");
		model.addAttribute("pathMap", 		videoService.groupByPath());
		logger.info("briefing path");
		model.addAttribute("dateMap", 		videoService.groupByDate());
		logger.info("briefing date");
		model.addAttribute("rankMap", 		videoService.groupByRank());
		logger.info("briefing rank");
		model.addAttribute("playMap", 		videoService.groupByPlay());
		logger.info("briefing play");
		model.addAttribute("scoreMap", 		videoService.groupByScore());
		logger.info("briefing score");
		model.addAttribute("lengthMap", 	videoService.groupByLength());
		logger.info("briefing length");
		model.addAttribute("extensionMap", 	videoService.groupByExtension());
		logger.info("briefing ext");
		
		model.addAttribute(videoService.getStudioList());
		logger.info("briefing studiolist");
		model.addAttribute(videoService.getActressList());
		logger.info("briefing actresslist");
		model.addAttribute(videoService.getVideoList());
		logger.info("briefing videolist");

		model.addAttribute("tagList", videoService.getTagListWithVideo());
		logger.info("briefing taglist");

		model.addAttribute("MOVE_WATCHED_VIDEO", 		videoBatch.isMOVE_WATCHED_VIDEO());
		model.addAttribute("DELETE_LOWER_RANK_VIDEO", 	videoBatch.isDELETE_LOWER_RANK_VIDEO());
		model.addAttribute("DELETE_LOWER_SCORE_VIDEO", 	videoBatch.isDELETE_LOWER_SCORE_VIDEO());
		
		logger.info("briefing rndering view...");
		return "video/briefing";
	}

	/**send history list by query
	 * @param model
	 * @param query search keyword
	 * @return view name
	 */
	@RequestMapping(value="/history", method=RequestMethod.GET)
	public String history(Model model, @RequestParam(value="q", required=false, defaultValue="") String query) {
		logger.trace("query={}", query);
		model.addAttribute("historyList", videoService.findHistory(query));
		return "video/history";
	}

	/**display video list view
	 * @param model
	 * @param sort default Opus if {@code null}
	 * @return view name
	 */
	@RequestMapping(value="/list", method=RequestMethod.GET)
	public String videoList(Model model, @RequestParam(value="sort", required=false, defaultValue="O") Sort sort,
			@RequestParam(value="r", required=false, defaultValue="false") Boolean reverse,
			@RequestParam(value="i", required=false, defaultValue="true") Boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") Boolean archive) {
		logger.trace("videoList sort={} reverse={}, instance={}, archive={}", sort, reverse, instance, archive);
		model.addAttribute("videoList", videoService.getVideoList(sort, reverse, instance, archive));
		model.addAttribute("sorts", Sort.values());
		model.addAttribute("sort", sort);
		model.addAttribute("reverse", reverse);
		model.addAttribute("instance", instance);
		model.addAttribute("archive", archive);
		return "video/videoList";
	}

	/**display video torrent info view
	 * @param model
	 * @return view name
	 */
	@RequestMapping(value="/torrent", method=RequestMethod.GET)
	public String torrent(Model model) {
		logger.trace("torrent");
		model.addAttribute("videoList", videoService.torrent());
		return "video/torrent";
	}

	/**
	 * video search query
	 * @param query
	 * @return
	 */
	@RequestMapping("/search")
	public String searchJson(Model model, @RequestParam(value="q", required=false, defaultValue="") String query) {
		logger.trace("query={}", query);
		model.addAttribute("videoList", videoService.findVideoList(query));
		model.addAttribute("historyList", videoService.findHistory(query));
        return "video/search";		
	}

	/**display studio detail view
	 * @param model
	 * @param studio
	 * @return view name
	 */
	@RequestMapping(value="/studio/{studio}", method=RequestMethod.GET)
	public String studioDetail(Model model, @PathVariable String studio) {
		logger.trace(studio);
		model.addAttribute(videoService.getStudio(studio));
		return "video/studioDetail";
	}

	/**put studio info
	 * @param studio
	 * @param params map of info
	 */
	@RequestMapping(value="/studio/{studio}", method=RequestMethod.PUT)
	public String putStudioInfo(@PathVariable String studio, @RequestParam Map<String, String> params) {
		logger.debug("{}", params);
		String studioName = videoService.saveStudioInfo(studio, params);

		return "redirect:/video/studio/" + studioName;
	}

	/**display studio list view
	 * @param model
	 * @param sort default NAME
	 * @return view name
	 */
	@RequestMapping(value="/studio", method=RequestMethod.GET)
	public String studioList(Model model, @RequestParam(value="sort", required=false, defaultValue="NAME") StudioSort sort,
			@RequestParam(value="r", required=false, defaultValue="false") Boolean reverse,
			@RequestParam(value="i", required=false, defaultValue="true") Boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") Boolean archive) {
		logger.trace("studioList sort={} reverse={}, instance={}, archive={}", sort, reverse, instance, archive);
		model.addAttribute(videoService.getStudioList(sort, reverse, instance, archive));
		model.addAttribute("sorts", StudioSort.values());
		model.addAttribute("sort", sort);
		model.addAttribute("reverse", reverse);
		model.addAttribute("instance", instance);
		model.addAttribute("archive", archive);
		return "video/studioList";
	}

	/**send video cover image<br>
	 * send redirect '/no/cover' if image not found
	 * @param opus
	 * @return image entity
	 * @throws IOException
	 */
	@RequestMapping(value="/{opus}/cover", method=RequestMethod.GET)
	public HttpEntity<byte[]> videoCover(@PathVariable String opus, HttpServletResponse response) throws IOException {
		logger.trace("{}", opus);
		File imageFile = videoService.getVideoCoverFile(opus);
		if(imageFile == null)
			return null;
		return httpEntity(videoService.getVideoCoverByteArray(opus), Utils.getExtension(imageFile), response, imageFile);
	}
	
	@RequestMapping(value="/{opus}/cover/title", method=RequestMethod.GET)
	public HttpEntity<byte[]> videoCoverWithTitle(@PathVariable String opus, HttpServletResponse response) throws IOException {
		logger.trace("{}", opus);
		Video video = videoService.getVideo(opus);
		File imageFile = video.getCoverFile();
		if(imageFile == null)
			return null;
		return httpEntity(CoverUtils.getCoverWithTitle(imageFile, video.getTitle()), Utils.getExtension(imageFile), response, imageFile);
	}

	/**
	 * returns image entity<br>
	 * cache time {@link VIDEO#WEBCACHETIME_SEC}, {@link VIDEO#WEBCACHETIME_MILI}
	 * @param imageBytes
	 * @param suffix
	 * @param response
	 * @param imageFile
	 * @return image entity
	 */
	private HttpEntity<byte[]> httpEntity(byte[] imageBytes, String suffix, HttpServletResponse response, File imageFile) {
		if (imageBytes == null)
			return null;

		response.setHeader("Cache-Control", "public, max-age=" + VIDEO.WEBCACHETIME_SEC);
		response.setHeader("Pragma", "public");
		response.setDateHeader("Expires", today + VIDEO.WEBCACHETIME_MILI);
		response.setDateHeader("Last-Modified", imageFile.lastModified());

		HttpHeaders headers = new HttpHeaders();
		headers.setContentLength(imageBytes.length);
		headers.setContentType(MediaType.parseMediaType("image/" + suffix));
//		headers.setCacheControl("max-age=" + VIDEO.WEBCACHETIME_SEC);
//		headers.setDate(		today + VIDEO.WEBCACHETIME_MILI);
//		headers.setExpires(		today + VIDEO.WEBCACHETIME_MILI);
//		headers.setLastModified(today - VIDEO.WEBCACHETIME_MILI);
		
		return new HttpEntity<byte[]>(imageBytes, headers);
	}

	/**display video overview view
	 * @param model
	 * @param opus
	 * @return view name
	 */
	@RequestMapping(value="/{opus}/overview", method=RequestMethod.GET)
	public String videoOverview(Model model, @PathVariable("opus") String opus) {
		logger.trace(opus);
		model.addAttribute("video", videoService.getVideo(opus));
		return "video/videoOverview";
	}

	/**save video overview
	 * @param model
	 * @param opus
	 * @param overview
	 */
	@RequestMapping(value="/{opus}/overview", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void opusOverviewPost(Model model, @PathVariable("opus") String opus, @RequestParam("overViewTxt") String overview) {
		logger.trace("{} - {}", opus, overview);
		videoService.saveVideoOverview(opus, overview);
	}

	/**call video player
	 * @param model
	 * @param opus
	 */
	@RequestMapping(value="/{opus}/play", method=RequestMethod.GET)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void callVideoPlayer(@PathVariable String opus) {
		logger.trace(opus);
		videoService.playVideo(opus);
	}

	/**save video rank info
	 * @param model
	 * @param opus
	 * @param rank
	 */
	@RequestMapping(value="/{opus}/rank/{rank}", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void putVideoRank(Model model, @PathVariable String opus, @PathVariable int rank) {
		logger.trace("{} : {}", opus, rank);
		videoService.rankVideo(opus, rank);
	}

	/**call Subtitles editor
	 * @param model
	 * @param opus
	 */
	@RequestMapping(value="/{opus}/subtitles", method=RequestMethod.GET)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void opusSubtitles(Model model, @PathVariable String opus) {
		logger.trace(opus);
		videoService.editVideoSubtitles(opus);
	}

	/**remove video
	 * @param model
	 * @param opus
	 */
	@RequestMapping(value="/{opus}", method=RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void removeVideo(Model model, @PathVariable("opus") String opus) {
		logger.trace(opus);
		videoService.removeVideo(opus);
	}

	/**display video detail view
	 * @param model
	 * @param opus
	 * @return view name
	 */
	@RequestMapping(value="/{opus}", method=RequestMethod.GET)
	public String videoDetail(Model model, @PathVariable String opus) {
		logger.info(opus);
		Video video = videoService.getVideo(opus);
		if (video == null)
			throw new VideoNotFoundException(opus);
		model.addAttribute(video);
		model.addAttribute("tagList", videoService.getTagList());
		if (video.isArchive())
			return "video/videoDetailArchive";
		else
			return "video/videoDetail";
	}
	
	/**rank, play 초기화
	 * @param model
	 * @param opus
	 * @return
	 */
	@RequestMapping(value="/{opus}/reset", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void videoReset(@PathVariable String opus) {
		logger.trace(opus);
		videoService.resetVideoScore(opus);
	}

	/**잘못 매칭된 비디오. 밖으로 옮기고, info초기화
	 * @param model
	 * @param opus
	 * @return
	 */
	@RequestMapping(value="/{opus}/wrong", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void videoWrong(@PathVariable String opus) {
		logger.trace(opus);
		videoService.resetWrongVideo(opus);
	}

	/**
	 * Test code. 
	 */
	@RequestMapping(value="/{opus}", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void opusPost() {
		logger.warn("POST do not something yet");
		throw new CrazyException(new IllegalStateException("POST do not something yet"));
	}
	
	/**display video main view
	 * @param model
	 * @param videoSearch
	 * @return view name
	 */
	@RequestMapping
	public String videoMain(Model model, @ModelAttribute VideoSearch videoSearch) {
		if (logger.isDebugEnabled())
			logger.debug("videoMain START : {}", videoSearch);
		List<Video> videoList =  videoService.searchVideo(videoSearch);
		if (logger.isDebugEnabled())
			logger.debug("videoMain search {}", videoList.size());
		
		model.addAttribute("views", 		View.values());
		model.addAttribute("sorts", 		Sort.values());
		model.addAttribute("rankRange", 	videoService.getRankRange());
		model.addAttribute("playRange", 	videoService.getPlayRange());
		model.addAttribute("videoList", 	videoList);
		model.addAttribute("opusArray", 	VideoUtils.getOpusArrayStyleStringWithVideofile(videoList));
		if (videoSearch.isWholeActressStudioView()) {
			model.addAttribute("actressList", 	videoService.getActressList());
			model.addAttribute("studioList", 	videoService.getStudioList());
		}
		else {
			model.addAttribute("actressList", 	videoService.getActressListInVideoList(videoList));
			model.addAttribute("studioList", 	videoService.getStudioListInVideoList(videoList));
		}
		model.addAttribute("tagList", videoService.getTagListWithVideo());

		if (logger.isDebugEnabled())
			logger.debug("videoMain END");
		return "video/videoMain";
	}

	@RequestMapping("/archive")
	public String videoArchive(Model model, @ModelAttribute VideoSearch videoSearch) {
		if (logger.isDebugEnabled())
			logger.debug("videoArchive START : {}", videoSearch);
		List<Video> videoList =  videoService.searchVideoInArchive(videoSearch);
		if (logger.isDebugEnabled())
			logger.debug("videoArchive search {}", videoList.size());

		model.addAttribute("views", 		View.values());
		model.addAttribute("sorts", 		Sort.values());
		model.addAttribute("videoList", 	videoList);
		if (videoSearch.isWholeActressStudioView()) {
			model.addAttribute("actressList", 	videoService.getActressListInArchive());
			model.addAttribute("studioList", 	videoService.getStudioListInArchive());
		}
		else {
			model.addAttribute("actressList", 	videoService.getActressListInVideoList(videoList));
			model.addAttribute("studioList", 	videoService.getStudioListInVideoList(videoList));
		}
		model.addAttribute("tagList", videoService.getTagListWithVideo());
		
		if (logger.isDebugEnabled())
			logger.debug("videoArchive END");
		return "video/videoArchive";
	}
	
	/**reload video source
	 * @param model
	 */
	@RequestMapping("/reload")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void reload(Model model) {
		logger.trace("reload");
		videoService.reload();
	}

	/**display video manager view
	 * @return view name
	 */
	@RequestMapping("/manager")
	public String manager() {
		logger.trace("video manager");
		return "video/manager";
	}

	/**move watched video
	 * @param model
	 */
	@RequestMapping(value="/manager/moveWatchedVideo", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void moveWatchedVideo(Model model) {
		synchronized (java.lang.Object.class) {
			logger.trace("move watched video");
			videoService.moveWatchedVideo();
			videoService.reload();
		}
	}
	
	/**remove lower rank video
	 * @param model
	 */
	@RequestMapping(value="/manager/removeLowerRankVideo", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void removeLowerRankVideo(Model model) {
		logger.trace("delete lower rank video");
		videoService.removeLowerRankVideo();
	}
	
	/**remove lower score video
	 * @param model
	 */
	@RequestMapping(value="/manager/removeLowerScoreVideo", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void removeLowerScoreVideo(Model model) {
		logger.trace("delete lower score video");
		videoService.removeLowerScoreVideo();
	}
	
	/**confirm video candidate
	 * @param model
	 * @param opus
	 * @param path
	 */
	@RequestMapping(value="/{opus}/confirmCandidate", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void confirmCandidate(Model model, @PathVariable("opus") String opus, @RequestParam("path") String path) {
		logger.info("confirm candidate video file. {} {}", opus, path);
		videoService.confirmCandidate(opus, path);
	}
	
	/**rename video title
	 * @param opus
	 * @param newName
	 */
	@RequestMapping(value="/{opus}/rename", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void rename(@PathVariable("opus") String opus, @RequestParam("newname") String newName) {
		logger.info("rename {} -> {}", opus, newName);
		videoService.rename(opus, newName);
	}
	
	/**
	 * play count reset in history
	 */
	@RequestMapping("/transferPlayCountInfo")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void transferPlayCountInfo() {
		for (Video video : videoService.getVideoList()) {
			int playCount = 0;
			List<History> histories = historyService.findByVideo(video);
			for (History history : histories) {
				if (history.getAction() == Action.PLAY)
					playCount++;
			}
			video.setPlayCount(playCount);
		}
	}

	/**parsing title
	 * @param model
	 * @param titleData
	 * @return
	 */
	@RequestMapping("/parseToTitle")
	public String parseToTitle(Model model, @RequestParam(value="titleData", required=false, defaultValue="") String titleData) {
		logger.trace("parse to title");
		model.addAttribute("titleList", videoService.parseToTitleData(titleData));
		model.addAttribute("titleData", titleData);
		return "video/parseToTitle";
	}
	
	/**parsing title
	 * @param model
	 * @param titleData
	 * @return
	 */
	@RequestMapping("/parseToTitle2")
	public String parseToTitle2(Model model, @RequestParam(value="titleData", required=false, defaultValue="") String titleData) {
		logger.trace("parse to title");
		model.addAttribute("titleList", videoService.parseToTitleData2(titleData));
		model.addAttribute("titleData", titleData);
		return "video/parseToTitle2";
	}
	
	/**search torrent
	 * @param model
	 * @param opus
	 * @return
	 */
	@RequestMapping("/torrent/search/{opus}")
	public String torrentSearch(Model model, @PathVariable("opus") String opus) {
		logger.trace("torrentSearch");
		model.addAttribute(videoService.getVideo(opus));
		return "video/torrentSearch";
	}

	@RequestMapping(value="/set/MOVE_WATCHED_VIDEO/{setValue}", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void setMOVE_WATCHED_VIDEO(@PathVariable("setValue") boolean setValue) {
		videoBatch.setMOVE_WATCHED_VIDEO(setValue);
	}
	@RequestMapping(value="/set/DELETE_LOWER_RANK_VIDEO/{setValue}", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void setDELETE_LOWER_RANK_VIDEO(@PathVariable("setValue") boolean setValue) {
		videoBatch.setDELETE_LOWER_RANK_VIDEO(setValue);
	}
	@RequestMapping(value="/set/DELETE_LOWER_SCORE_VIDEO/{setValue}", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void setDELETE_LOWER_SCORE_VIDEO(@PathVariable("setValue") boolean setValue) {
		videoBatch.setDELETE_LOWER_SCORE_VIDEO(setValue);
	}

	@RequestMapping("/list2")
	public String list2() {
		return "video/videoList2";
	}

	@RequestMapping("/history/{pattern}")
	public String historyMonthly(Model model, @PathVariable String pattern) {
		model.addAttribute("data", historyService.getGraphData(pattern));
		return "video/historyGraph";
	}

	@RequestMapping("/history/forGoogleChart")
	public @ResponseBody String historyForGoogleChart() {
		StringBuilder sb = new StringBuilder("{");
		sb.append("\"cols\":[{\"label\":\"Date\", \"type\":\"date\"},{\"label\":\"Play\", \"type\":\"number\"}],");
		sb.append("\"rows\":[");
		String pattern = "yyyy-MM-dd";
		Collection<HistoryData> graphData = historyService.getGraphData(pattern);
		for (HistoryData data : graphData) {
			String[] datePart = data.getDate().split("-");
			int year  = Integer.parseInt(datePart[0]);
			int month = Integer.parseInt(datePart[1]) -1;
			int day   = Integer.parseInt(datePart[2]);
			sb.append(String.format("{\"c\":[{\"v\": \"Date(%s, %s, %s)\"},{\"v\":%s}]},", 
					year, month, day, data.getPlay()));
		}
		
		sb.append("]}");
		return sb.toString();
	}

	@RequestMapping(value="/tag/{tagId}", method=RequestMethod.GET)
	public String viewTag(Model model, @PathVariable Integer tagId) {
		VTag tag = videoService.getTag(tagId);
		model.addAttribute("tag", tag);
		return "video/tagDetail";
	}

	@RequestMapping(value="/tag/{tagId}", method=RequestMethod.POST)
	public String updateTag(Model model, @ModelAttribute VTag tag, @PathVariable Integer tagId) {
		videoService.updateTag(tag);
		return "redirect:/video/tag/" + tagId;
	}
	
	@RequestMapping(value="/tag", method=RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deleteTag(@ModelAttribute VTag tag) {
		logger.info("deleteTag {}", tag);
		videoService.deleteTag(tag);
	}
	
	@RequestMapping(value="/tag", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void saveTag(@ModelAttribute VTag tag, @RequestParam(value="opus", required=false, defaultValue="") String opus) {
		videoService.createTag(tag);
		if (opus.length() > 0)
			videoService.toggleTag(opus, tag);
	}
	
	@RequestMapping("/gravia")
	public String graviainterview(Model model) {
		model.addAttribute(videoService.getTistoryItem());
		return "video/graviainterview";
	}
	
	@RequestMapping(value="/{opus}/tag", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void toggleTag(@ModelAttribute VTag tag, @PathVariable String opus) {
		videoService.toggleTag(opus, tag);
	}
	
}
