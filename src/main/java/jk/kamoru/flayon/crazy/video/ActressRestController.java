package jk.kamoru.flayon.crazy.video;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jk.kamoru.flayon.crazy.util.NameDistanceChecker;
import jk.kamoru.flayon.crazy.util.NameDistanceChecker.CheckResult;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.TitleValidator;
import jk.kamoru.flayon.crazy.video.service.ActressPictureService;
import jk.kamoru.flayon.crazy.video.service.VideoService;

@RestController
@RequestMapping("/rest/actress")
public class ActressRestController {

	@Autowired VideoService videoService;
	@Autowired ActressPictureService actressPictureService;

	@RequestMapping(method=RequestMethod.GET)
	public List<Actress> list(
			@RequestParam(value="i", required=false, defaultValue="true") boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") boolean archive) {
		return videoService.getActressList(instance, archive);
	}

	@RequestMapping(value="/{name}", method=RequestMethod.GET)
	public Actress actress(@PathVariable String name) {
		return videoService.getActress(name);
	}

	@RequestMapping(method=RequestMethod.PUT)
	public Actress saveActressInfo(@RequestParam Map<String, String> params) {
		return videoService.saveActressInfo(params);
	}

	@RequestMapping(value="/{name}/favorite/{onOff}", method=RequestMethod.PUT)
	public Boolean putActressFavorite(@PathVariable String name, @PathVariable Boolean onOff) {
		return videoService.setFavoriteOfActress(name, onOff);
	}

	@RequestMapping("/namecheck")
	public List<CheckResult> nameCheck(
			@RequestParam(value="l", required=false, defaultValue="0.9") double limit,
			@RequestParam(value="i", required=false, defaultValue="true") boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") boolean archive) {
		return NameDistanceChecker.check(videoService.getActressList(instance, archive).stream()
				.filter(a -> !a.getName().equals(TitleValidator.AMATEUR)).collect(Collectors.toList()), limit);
	}
	
	@PostMapping("{name}/picture")
	public void handleFileUpload(@PathVariable String name, @RequestParam("image") MultipartFile multipartFile) {
		actressPictureService.store(multipartFile, name);
    }
	
}
