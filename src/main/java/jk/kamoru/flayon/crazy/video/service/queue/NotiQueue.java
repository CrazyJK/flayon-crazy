package jk.kamoru.flayon.crazy.video.service.queue;

import java.util.ArrayList;
import java.util.List;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class NotiQueue {

	private static List<String> notiList = new ArrayList<>();
	
	public static void pushNoti(String message) {
		notiList.add(message);
		log.info("push noti : {}. queue size {}", message, notiList.size());
	}
	
	public static String getNoti() {
		String msg = "";
		if (notiList.size() > 0) {
			msg = notiList.get(0);
			notiList.remove(0);
			
			log.info("get Noti {}. remaining noti {}", msg, notiList.size());
		}
		return msg;
	}
}
