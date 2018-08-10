package jk.kamoru.flayon.crazy.video;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.CrazyController;
import jk.kamoru.flayon.crazy.util.VideoUtils;
import jk.kamoru.flayon.crazy.video.daemon.VideoBatch;
import jk.kamoru.flayon.crazy.video.domain.ActressSort;
import jk.kamoru.flayon.crazy.video.domain.Sort;
import jk.kamoru.flayon.crazy.video.domain.StudioSort;
import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.domain.VideoSearch;
import jk.kamoru.flayon.crazy.video.domain.View;
import jk.kamoru.flayon.crazy.video.service.HistoryService;
import jk.kamoru.flayon.crazy.video.service.TagService;
import jk.kamoru.flayon.crazy.video.service.VideoService;

/**
 * Video controller
 * @author kamoru
 */
@Controller
@RequestMapping("/video")
public class VideoController extends CrazyController {

	static final Logger logger = LoggerFactory.getLogger(VideoController.class);
	
	@Autowired VideoService videoService;
	@Autowired VideoBatch videoBatch;
	@Autowired TagService tagService;
	@Autowired HistoryService historyService;
	@Autowired CrazyConfig config;

	@ModelAttribute("minRank") 			public int minRank()             { return config.getMinRank(); }
	@ModelAttribute("maxRank") 			public int maxRank()             { return config.getMaxRank(); }
	@ModelAttribute("playRatio")		public int playRatio()           { return config.getPlayRatio(); }
	@ModelAttribute("rankRatio")		public int rankRatio()           { return config.getRankRatio(); }
	@ModelAttribute("actressRatio")		public int actressRatio()        { return config.getActressRatio(); }
	@ModelAttribute("subtitlesRatio")	public int subtitlesRatio()      { return config.getSubtitlesRatio(); }
	@ModelAttribute("maxEntireVideo")	public int maxEntireVideo()      { return config.getMaxEntireVideo(); }
	@ModelAttribute("urlSearchVideo")	public String urlSearchVideo()   { return config.getUrlSearchVideo(); }
	@ModelAttribute("urlSearchActress")	public String urlSearchActress() { return config.getUrlSearchActress(); }
	@ModelAttribute("urlSearchTorrent")	public String urlSearchTorrent() { return config.getUrlSearchTorrent(); }
	
	@RequestMapping
	public String front() {
		return "video/front";
	}
	
	@GetMapping("/vertical")
	public String verticalView() {
		return "video/videoVertical";
	}
	
	/**
	 * display video main view
	 * @param model
	 * @param videoSearch
	 * @return view name
	 */
	@RequestMapping("/main")
	public String videoMain(Model model, @ModelAttribute VideoSearch videoSearch) {
		List<Video> videoList =  videoService.searchVideo(videoSearch);
		
		model.addAttribute("views", 	View.values());
		model.addAttribute("sorts", 	Sort.values());
		model.addAttribute("rankRange", videoService.getRankRange());
		model.addAttribute("playRange", VideoUtils.getPlayRange(videoList));
		model.addAttribute("videoList", videoList);
		model.addAttribute("opusArray", VideoUtils.getOpusArrayStyleStringIfVideofile(videoList));
		model.addAttribute("tagList", 	tagService.getTagListWithVideo());

		return "video/videoMain";
	}

	@RequestMapping(value="/actress", method=RequestMethod.GET)
	public String actressList() {
		return "video/actressList";
	}

	/**
	 * display actress list view
	 * @param model
	 * @param sort default NAME if {@code null}
	 * @return view name
	 */
	@RequestMapping(value="/actress2", method=RequestMethod.GET)
	public String actressList2(Model model, 
			@RequestParam(value="sort", required=false, defaultValue="NAME") ActressSort sort,
			@RequestParam(value="r", required=false, defaultValue="false") Boolean reverse,
			@RequestParam(value="i", required=false, defaultValue="true") Boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") Boolean archive) {
		model.addAttribute(videoService.getActressList(instance, archive, sort, reverse));
		model.addAttribute("sorts", ActressSort.values());
		model.addAttribute("sort", sort);
		model.addAttribute("reverse", reverse);
		model.addAttribute("instance", instance);
		model.addAttribute("archive", archive);
		return "video/actressList2";
	}

	/**
	 * display a actress detail view
	 * @param model
	 * @param actressName actress name
	 * @return view name
	 */
	@RequestMapping(value="/actress/{actressName}", method=RequestMethod.GET)
	public String actressDetail(Model model, @PathVariable String actressName) {
		model.addAttribute(videoService.getActress(actressName));
		return "video/actressDetail";
	}
	
	/**
	 * display status briefing view
	 * @param model
	 * @return view name
	 */
	@RequestMapping(value="/briefing", method=RequestMethod.GET)
	public String briefing(Model model) {

		model.addAttribute("pathMap", 		videoService.groupByPath());
		model.addAttribute("dateMap", 		videoService.groupByDate());
		model.addAttribute("rankMap", 		videoService.groupByRank());
		model.addAttribute("playMap", 		videoService.groupByPlay());
		model.addAttribute("scoreMap", 		videoService.groupByScore());
		model.addAttribute("lengthMap", 	videoService.groupByLength());
		model.addAttribute("extensionMap", 	videoService.groupByExtension());
		
		model.addAttribute(videoService.getVideoList());
		model.addAttribute(videoService.getStudioList());
		model.addAttribute(videoService.getActressList());

		model.addAttribute("tagList", tagService.getTagListWithVideo());

		return "video/briefing";
	}

	/**
	 * for single page application
	 * @return
	 */
	@RequestMapping(value="/list_spa", method=RequestMethod.GET)
	public String videoListBySpa() {
		return "video/videoListBySpa";
	}

	/**
	 * video search query
	 * @param query
	 * @return
	 */
	@RequestMapping("/search")
	public String searchView(Model model) {
		model.addAttribute("deleteLowerRankVideo",  videoBatch.getBatchOption(VideoBatch.Option.R));
		model.addAttribute("deleteLowerScoreVideo", videoBatch.getBatchOption(VideoBatch.Option.S));
		model.addAttribute("moveWatchedVideo", 		videoBatch.getBatchOption(VideoBatch.Option.W));
        return "video/search";		
	}

	/**
	 * display studio list view
	 * @param model
	 * @param sort default NAME
	 * @return view name
	 */
	@RequestMapping(value="/studio", method=RequestMethod.GET)
	public String studioList(Model model, 
			@RequestParam(value="i", required=false, defaultValue="true") Boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") Boolean archive) {
		model.addAttribute(videoService.getStudioList(instance, archive));
		model.addAttribute("sorts", StudioSort.values());
		model.addAttribute("instance", instance);
		model.addAttribute("archive", archive);
		return "video/studioList";
	}

	/**
	 * display studio detail view
	 * @param model
	 * @param studio
	 * @return view name
	 */
	@RequestMapping(value="/studio/{studio}", method=RequestMethod.GET)
	public String studioDetail(Model model, @PathVariable String studio) {
		model.addAttribute(videoService.getStudio(studio));
		return "video/studioDetail";
	}

	/**
	 * display video overview view
	 * @param model
	 * @param opus
	 * @return view name
	 */
	@RequestMapping(value="/{opus}/overview", method=RequestMethod.GET)
	public String videoOverview(Model model, @PathVariable("opus") String opus) {
		model.addAttribute("video", videoService.getVideo(opus));
		return "video/videoOverview";
	}

	/**
	 * display video detail view
	 * @param model
	 * @param opus
	 * @return view name
	 */
	@RequestMapping(value="/{opus}", method=RequestMethod.GET)
	public String videoDetail(Model model, @PathVariable String opus) {
		Video video = videoService.getVideo(opus);
		model.addAttribute(video);
		model.addAttribute("tagList", tagService.getTagList());
		if (video.isArchive())
			return "video/videoDetailArchive";
		else
			return "video/videoDetail";
	}
	
	@RequestMapping("/archive")
	public String videoArchive(Model model, @ModelAttribute VideoSearch videoSearch) {
		if (StringUtils.isBlank(videoSearch.getSearchText())) {
			videoSearch.setSearchText("Need to query");
		}
		List<Video> videoList =  videoService.searchVideoInArchive(videoSearch);

		model.addAttribute("views", 	View.values());
		model.addAttribute("sorts", 	Sort.values());
		model.addAttribute("videoList", videoList);
		model.addAttribute("tagList", 	tagService.getTagListWithVideo());
		
		return "video/videoArchive";
	}

	/**
	 * parsing title
	 * @param model
	 * @param titleData
	 * @return
	 */
	@RequestMapping("/parseToTitle")
	public String parseToTitle(Model model, 
			@RequestParam(value="titleData", required=false, defaultValue="") String titleData,
			@RequestParam(value="saveCoverAll", required=false, defaultValue="false") Boolean saveCoverAll,
			@RequestParam Map<String, String> params) {
		model.addAttribute("titleList", videoService.parseToTitleData(titleData, saveCoverAll));
		model.addAttribute("titleData", titleData);
		return "video/parseToTitle";
	}

	@RequestMapping("/history")
	public String historyGraph() {
		return "video/historyGraph";
	}
	
	@RequestMapping("/historyOnDB")
	public String historyOnDB() {
		return "video/historyOnDB";
	}
	
	@RequestMapping("/gravia")
	public String graviainterview() {
		return "video/graviainterview";
	}

	@RequestMapping("/tag")
	public String tagList() {
		return "video/tagList";
	}

	@RequestMapping("/tag/{tagId}")
	public String tagDetail(Model model, @PathVariable Integer tagId) {
		VTag tag = tagService.getTag(tagId);
		model.addAttribute("tag", tag);
		List<Video> likeVideoList = tagService.likeVideo(tag);
		model.addAttribute("likeVideoList", likeVideoList);
		return "video/tagDetail";
	}

}
