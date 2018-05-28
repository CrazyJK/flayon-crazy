package jk.kamoru.flayon.crazy;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jk.kamoru.flayon.base.util.IOUtils;
import jk.kamoru.flayon.crazy.video.service.noti.Noti;
import jk.kamoru.flayon.crazy.video.service.noti.NotiQueue;
import jk.kamoru.flayon.web.security.User;

@RestController
@RequestMapping("/rest")
public class CrazyRestController {

	@Autowired NotiQueue notiQueue;

	@RequestMapping("/ping")
	public Noti ping(@AuthenticationPrincipal User flayUser) {
		return notiQueue.pull(flayUser.getId());
	}
	
	@RequestMapping("/noti/list")
	public List<Noti> notiList() {
		return notiQueue.getNotiList();
	}
	
	@RequestMapping(value="/file/out", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void outFile(@RequestParam("file") File file) {
		try {
			FileUtils.moveFileToDirectory(file, IOUtils.getRoot(file), false);
		} catch (IOException e) {
			throw new CrazyException("Fail to move", e);
		}
	}

}
