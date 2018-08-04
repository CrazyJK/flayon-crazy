package jk.kamoru.flayon.crazy.video;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Random;

import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jk.kamoru.flayon.base.util.IOUtils;
import jk.kamoru.flayon.base.util.ImageUtils;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.VideoService;

@RestController
@RequestMapping("/cover")
public class CoverController {

	@Autowired VideoService videoService;

	@GetMapping("/video/{opus}")
	public HttpEntity<byte[]> videoCover(HttpServletResponse response, @PathVariable String opus) throws IOException {
		File imageFile = videoService.getVideoCoverFile(opus);
		if(imageFile == null)
			return null;
		return httpEntity(response, imageFile);
	}

	@GetMapping("/video/{opus}/title")
	public HttpEntity<byte[]> videoCoverWithTitle(HttpServletResponse response, @PathVariable String opus) throws IOException {
		Video video = videoService.getVideo(opus);
		File imageFile = video.getCoverFile();
		if(imageFile == null)
			return null;
		return httpEntity(response, imageFile, ImageUtils.mergeTextToImage(video.getTitle(), imageFile));
	}

	@GetMapping("/video/random")
	public HttpEntity<byte[]> randomVideoCover(HttpServletResponse response) throws IOException {
		List<Video> videoList = videoService.getVideoList();
		Random random = new Random();
		int index = random.nextInt(videoList.size());
		String opus = videoList.get(index).getOpus();
		File imageFile = videoService.getVideoCoverFile(opus);
		if(imageFile == null)
			return null;
		return httpEntity(response, imageFile);
	}

	@GetMapping("/actress/{actressName}")
	public HttpEntity<byte[]> actressImage(HttpServletResponse response, @PathVariable String actressName) throws IOException {
		Actress actress = videoService.getActress(actressName);
		File imageFile = actress.getImage();
		if(imageFile == null)
			return null;
		return httpEntity(response, imageFile);
	}
	
	private HttpEntity<byte[]> httpEntity(HttpServletResponse response, File imageFile) throws IOException {
		return httpEntity(response, imageFile, FileUtils.readFileToByteArray(imageFile));
	}

	private HttpEntity<byte[]> httpEntity(HttpServletResponse response, File imageFile, byte[] imageBytes) throws IOException {
		MediaType mediaType = MediaType.parseMediaType("image/" + IOUtils.getSuffix(imageFile));
		
		response.setHeader("Cache-Control", "public, max-age=" + VIDEO.WEBCACHETIME_SEC);
		response.setHeader("Pragma", "public");
		response.setDateHeader("Expires", new Date().getTime() + VIDEO.WEBCACHETIME_MILI);
		response.setDateHeader("Last-Modified", imageFile.lastModified());
		response.setContentType(mediaType.getType());

		HttpHeaders headers = new HttpHeaders();
		headers.setContentLength(imageBytes.length);
		headers.setContentType(mediaType);
		
		return new HttpEntity<byte[]>(imageBytes, headers);
	}

}
