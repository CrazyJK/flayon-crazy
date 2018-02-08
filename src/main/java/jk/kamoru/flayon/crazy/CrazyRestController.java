package jk.kamoru.flayon.crazy;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jk.kamoru.flayon.crazy.video.service.noti.Noti;
import jk.kamoru.flayon.crazy.video.service.noti.NotiQueue;
import jk.kamoru.flayon.web.security.User;

@RestController
@RequestMapping("/rest")
public class CrazyRestController {

	@RequestMapping("/ping")
	public Noti ping(@AuthenticationPrincipal User flayUser) {
		return NotiQueue.getNoti(flayUser.getId());
	}
	
}
