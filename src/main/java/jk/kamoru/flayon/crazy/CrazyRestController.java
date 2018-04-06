package jk.kamoru.flayon.crazy;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
