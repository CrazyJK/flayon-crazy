package jk.kamoru.flayon.crazy.video.service.noti;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class NotiQueue {

	private static final long TIME_OFFSET = 5000l;
	
	private static List<Noti> notiList = new ArrayList<>();
	private static Map<Long, Integer> lastNotiIndexByUseridMap = new HashMap<>();
	
	public static void pushNoti(String message) {
		Noti noti = new Noti(System.currentTimeMillis(), message);
		notiList.add(noti);
		log.info("push Noti : {}th {}", notiList.size(), noti);
	}
	
	public static String getMessage(Long userid) {
		return getNoti(userid).getMessage();
	}	
	
	public static Noti getNoti(Long userid) {
		if (!lastNotiIndexByUseridMap.containsKey(userid)) {
			lastNotiIndexByUseridMap.put(userid, -1); // init
		}
		String msg = "";
		int nextNotiIndex = lastNotiIndexByUseridMap.get(userid) + 1;
		if (notiList.size() > nextNotiIndex) {
			Noti noti = notiList.get(nextNotiIndex);
			lastNotiIndexByUseridMap.put(userid, nextNotiIndex);
			
			// past 5s      > 53000                      - 51000 = 2000
			if (TIME_OFFSET > System.currentTimeMillis() - noti.getTimeMillis()) {
				msg = noti.getMessage();
				log.info("get Noti : userid {}, {}th [{}]", userid, nextNotiIndex+1, msg);
				return noti;
			}
			else {
				return getNoti(userid);
			}
		}
		return new Noti();
	}

}

