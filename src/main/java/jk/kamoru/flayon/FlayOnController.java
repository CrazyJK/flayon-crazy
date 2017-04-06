package jk.kamoru.flayon;

import java.io.IOException;
import java.lang.Thread.State;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.lang.management.ThreadInfo;
import java.lang.management.ThreadMXBean;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.security.KeyPair;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.mvc.method.RequestMappingInfo;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;

import jk.kamoru.flayon.base.access.AccessLog;
import jk.kamoru.flayon.base.access.AccessLogRepository;
import jk.kamoru.flayon.base.crypto.AES256;
import jk.kamoru.flayon.base.crypto.RSA;
import jk.kamoru.flayon.base.crypto.SHA;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequestMapping("/flayon")
public class FlayOnController {

	@Value("${use.repository.accesslog}") boolean useAccesslogRepository;

	@Autowired ApplicationContext context;
	@Autowired AccessLogRepository accessLogRepository;
	@Autowired Environment environment;

	@RequestMapping("/requestMappingList")
	public String requestMapping(Model model, @RequestParam(value="sort", required=false, defaultValue="P") final String sort) {

		RequestMappingHandlerMapping rmhm = context.getBean(RequestMappingHandlerMapping.class);

		List<Map<String, String>> mappingList = new ArrayList<Map<String, String>>();
		
		for (Map.Entry<RequestMappingInfo, HandlerMethod> entry : rmhm.getHandlerMethods().entrySet()) {
			Map<String, String> mappingData = new HashMap<String, String>();
			mappingData.put("reqPattern", StringUtils.substringBetween(entry.getKey().getPatternsCondition().toString(), "[", "]"));
			mappingData.put("reqMethod",  StringUtils.substringBetween(entry.getKey().getMethodsCondition().toString(), "[", "]"));
			mappingData.put("beanType",   StringUtils.substringAfterLast(entry.getValue().getBeanType().getName(), "."));
			mappingData.put("beanMethod", entry.getValue().getMethod().getName());

			mappingList.add(mappingData);
		}
		
		Collections.sort(mappingList, new Comparator<Map<String, String>>() {
			
			@Override
			public int compare(Map<String, String> o1, Map<String, String> o2) {
				if (sort.equals("P")) {
					return o1.get("reqPattern").compareTo(o2.get("reqPattern"));
				}
				else if (sort.equals("M")) {
					return o1.get("reqMethod").compareTo(o2.get("reqMethod"));
				}
				else if (sort.equals("C")) {
					int firstCompare = o1.get("beanType").compareTo(o2.get("beanType"));
					int secondCompare = o1.get("beanMethod").compareTo(o2.get("beanMethod"));
					return firstCompare == 0 ? secondCompare : firstCompare;
				}
				else {
					return o1.get("reqPattern").compareTo(o2.get("reqPattern"));
				}
			}
		});
		model.addAttribute("mappingList", mappingList);
		return "flayon/requestMappingList";
	}
	
	@RequestMapping("/error")
	public String error(Model model, @RequestParam(value="k", required=false, defaultValue="") String kind) {
		if (kind.equals("default"))
			throw new RuntimeException("default error");
		else if (kind.equals("falyon"))
			throw new FlayOnException("falyon error", new Exception("flayon error"));
		
		return "flayon/occurError";
	}

	@RequestMapping("/memory")
	public String memoryInfo(Model model) {
		MemoryMXBean memoryMXBean = ManagementFactory.getMemoryMXBean();
		MemoryUsage heapMemoryUsage = memoryMXBean.getHeapMemoryUsage();
		MemoryUsage nonHeapMemoryUsage = memoryMXBean.getNonHeapMemoryUsage();
		double heapUsedPercent = ((double)heapMemoryUsage.getUsed()/(double)heapMemoryUsage.getMax()) * 100.0D;
		double nonHeapUsedPercent = nonHeapMemoryUsage.getMax() == -1 ? 0 :
				((double)nonHeapMemoryUsage.getUsed()/(double)nonHeapMemoryUsage.getMax()) * 100.0D;

		model.addAttribute("heap", heapMemoryUsage);
		model.addAttribute("nonHeap", nonHeapMemoryUsage);
		model.addAttribute("heapUsedPercent", heapUsedPercent);
		model.addAttribute("nonHeapUsedPercent", nonHeapUsedPercent);
		
		return "flayon/memory";
	}
	
	@RequestMapping("/colors")
	public String colors() {
		return "flayon/colors";
	}
	
	@RequestMapping("/portscan")
	public String portscan(HttpServletRequest request, Model model) {
		
		String ip = request.getParameter("ip");
		if (StringUtils.isEmpty(ip))
			ip = "127.0.0.1";
		int port_s = 0;
		try {
			port_s = Integer.parseInt(request.getParameter("ports"));
		} catch (Exception e) {}
		int port_e = 0;
		try {
			port_e = Integer.parseInt(request.getParameter("porte"));
		} catch (Exception e) {}
		String[] portArr = null;
		try {
			portArr = request.getParameter("portArr").split(",");
		} catch (Exception e) {}

		List<Integer> ports = new ArrayList<>(); 
		if (port_s > 0 && port_s < port_e)
			for(int port=port_s; port<= port_e; port++)
				ports.add(port);
		else if (portArr != null)
			for(String port : portArr)
				if (port.trim().length() > 0)
					try {
						int _port = Integer.parseInt(port.trim());
						if (_port > 0)
							ports.add(_port);
					} catch (Exception e) {}

		List<Object[]> results = new ArrayList<>();
		if (ports.size() > 0) {
			final int timeout = 200;
			for(int port : ports) {
				try {
					Socket socket = new Socket();
		          	socket.connect(new InetSocketAddress(ip, port), timeout);
		          	socket.close();
		          	results.add(new Object[] {ip, port, true});
		        } catch (Exception ex) {
					results.add(new Object[] {ip, port, false});
		        }
			}
		}
		model.addAttribute("results", results);
		model.addAttribute("ip", ip);
		model.addAttribute("ports", port_s);
		model.addAttribute("porte", port_e);
		model.addAttribute("portArr", StringUtils.join(portArr, ","));
		
		return "flayon/portscan";
	}
	
	@RequestMapping("/webcontext")
	public String webContext(Model model) {
		model.addAttribute("profiles", environment.getActiveProfiles());
		return "flayon/webContext";
	}
	
	@RequestMapping("/threaddump")
	public String threadDump(ThreadParamInfo info, Model model) {
				
		ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
		ThreadInfo[] threadInfoArray = threadMXBean.getThreadInfo(threadMXBean.getAllThreadIds(), Integer.MAX_VALUE);
		List<ThreadInfo> threadInfos = new ArrayList<>();
		for (ThreadInfo threadInfo : threadInfoArray) {
		
			// filter the current thread
			if (threadInfo.getThreadId() == Thread.currentThread().getId()) continue;
			
			// filter name
			if (!StringUtils.isEmpty(info.getName())) {
				if (!threadInfo.getThreadName().startsWith(info.getName())) continue;
			}
			
			// filter state
			if (!StringUtils.isEmpty(info.getState())) {
				if (!threadInfo.getThreadState().toString().equals(info.getState())) continue;
			}
			
			// show only specific thread id
			if (info.getThreadId() > 0) {
				if (threadInfo.getThreadId() != info.getThreadId()) continue;
			}
			
			threadInfos.add(threadInfo);
		}
		log.info("========== threadInfos size {}", threadInfos.size());
		Collections.sort(threadInfos, new Comparator<ThreadInfo>() {

			@Override
				public int compare(ThreadInfo o1, ThreadInfo o2) {
					if (o1 == null || o2 == null) return 0;
					return o1.getThreadName().compareTo(o2.getThreadName());
				}
				
			}
		);
		List<String> states = new ArrayList<>();
		for (State _state : Thread.State.values()) {
			states.add(_state.toString());
		}
		
		model.addAttribute("threadInfos", threadInfos);
		model.addAttribute("threadStates", Thread.State.values());
		model.addAttribute("paramInfo", info);
		
		return "flayon/threadDump";
	}

	@RequestMapping("/logviewt")
	public String logView(HttpServletRequest request, Model model) {
		
		String logpath    = request.getParameter("logpath");
		String delimeter  = request.getParameter("delimeter");
		String search     = request.getParameter("search");
		String searchOper = request.getParameter("searchOper");
		String deliMax    = request.getParameter("deliMax");

		logpath   = logpath   == null ? "" : logpath.trim();
		delimeter = delimeter == null ? "" : delimeter;
		search    = search    == null ? "" : search.trim();
		searchOper= searchOper== null ? "or" : searchOper;
		int max = StringUtils.isEmpty(deliMax) ? -1 : Integer.parseInt(deliMax);

		List<String[]> lines = new ArrayList<String[]>();
		int tdCount = 0;
		String msg = "";
		try {
			lines = Utils.readLines(logpath, delimeter, max, search, searchOper);
			for (String[] line : lines) {
				tdCount = line.length > tdCount ? line.length : tdCount;
			}
		}
		catch (Exception e) {
			msg = e.getMessage();
		}
		
		model.addAttribute("lines", lines);
		model.addAttribute("tdCount", tdCount);
		model.addAttribute("msg", msg);
		model.addAttribute("logpath", logpath);
		model.addAttribute("delimeter", delimeter);
		model.addAttribute("deliMax", deliMax);
		model.addAttribute("search", search);
		model.addAttribute("searchOper", searchOper);

		return "flayon/logView";
	}

	@RequestMapping("/accesslog")
	public String accesslog(Model model, 
			@PageableDefault(sort = { "id" }, direction = Direction.DESC, size = 15) Pageable pageable,
			@RequestParam(value="remoteAddr", required=false, defaultValue="") String remoteAddr, 
			@RequestParam(value="requestURI", required=false, defaultValue="") String requestURI) {
		log.info("remoteAddr [{}], requestURI [{}], {}", remoteAddr, requestURI, pageable);

		Page<AccessLog> page = null;
		if (useAccesslogRepository) {
			if (!StringUtils.isEmpty(requestURI) || !StringUtils.isEmpty(remoteAddr)) {
				page = accessLogRepository.findByRequestURILikeAndRemoteAddrLike(requestURI, remoteAddr, pageable);
				log.info("findByCondition {}", page.getContent().size());
			}
			else {
				page = accessLogRepository.findAll(pageable);
				log.info("findAll {}", page.getContent().size());
			}
		}
		else {
			page = new PageImpl<AccessLog>(new ArrayList<AccessLog>());
		}
		model.addAttribute(page);
		model.addAttribute("useAccesslogRepository", useAccesslogRepository);

		return "flayon/accesslog";
	}
	
	@RequestMapping("/exec")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void execCommand(@RequestParam(value="cmd") String cmd, 
			@RequestParam(value="args", required=false, defaultValue="") final String args) {
		log.info("cmd={}, args={}", cmd, args);
		exec(new String[]{cmd, args});
	}
	
	@RequestMapping("/openFolder")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void openFolder(@RequestParam(value="folder") String folder) {
		folder = StringUtils.replace(folder, "/", System.getProperty("file.separator"));
		log.info("open folder={}", folder);
		exec(new String[]{"explorer", folder});
	}

	private void exec(String[] command) {
		try {
			Runtime.getRuntime().exec(command);
		} catch (IOException e) {
			throw new FlayOnException("execute error", e);
		}
	}
	
	static Map<String, Map<String, String>> cryptoMethods = new HashMap<>();
	static {
		
		Map<String, String> shaMethod = new TreeMap<>();
		shaMethod.put("SHA1", "encrypt");
		shaMethod.put("SHA256", "encrypt");
		shaMethod.put("SHA384", "encrypt");
		shaMethod.put("SHA512", "encrypt");
		cryptoMethods.put("SHA", shaMethod);
		
		Map<String, String> aesMethod = new TreeMap<>();
		aesMethod.put("AES256 ecb encrypt", "encrypt");
		aesMethod.put("AES256 ecb decrypt", "decrypt");
		aesMethod.put("AES256 cbc noIv encrypt", "encrypt");
		aesMethod.put("AES256 cbc noIv decrypt", "decrypt");
		aesMethod.put("AES256 cbc Iv encrypt", "encrypt");
		aesMethod.put("AES256 cbc Iv decrypt", "decrypt");
		cryptoMethods.put("AES", aesMethod);
		
		Map<String, String> rsaMethod = new TreeMap<>();
		rsaMethod.put("RSA encrypt", "encrypt");
		rsaMethod.put("RSA decrypt", "decrypt");
		cryptoMethods.put("RSA", rsaMethod);
	}
	
	@RequestMapping("/crypto")
	public String crypto(Model model) {
		model.addAttribute("cryptoMethods", cryptoMethods);
		return "flayon/crypto";
	}

	String key = "crazyjk-kamoru-58818-6969";
	String iv  = "flayon-crazy";
	KeyPair keyPair = RSA.generateKey();
	
	@RequestMapping(value="/crypto", method=RequestMethod.POST)
	public @ResponseBody String doCrypt(@RequestParam String method, @RequestParam String value) {
		log.info("doCrypt : {}, {}", method, value);		
		switch (method) {
		case "SHA1":
			return new SHA(SHA.AlgorithmType.SHA1).encrypt(value);
		case "SHA256":
			return new SHA(SHA.AlgorithmType.SHA256).encrypt(value);
		case "SHA384":
			return new SHA(SHA.AlgorithmType.SHA384).encrypt(value);
		case "SHA512":
			return new SHA(SHA.AlgorithmType.SHA512).encrypt(value);
		case "AES256 ecb encrypt":
			return new AES256(AES256.AlgorithmMode.ECB, key, null).encrypt(value);
		case "AES256 ecb decrypt":
			return new AES256(AES256.AlgorithmMode.ECB, key, null).decrypt(value);
		case "AES256 cbc noIv encrypt":
			return new AES256(AES256.AlgorithmMode.CBC, key, null).encrypt(value);
		case "AES256 cbc noIv decrypt":
			return new AES256(AES256.AlgorithmMode.CBC, key, null).decrypt(value);
		case "AES256 cbc Iv encrypt":
			return new AES256(AES256.AlgorithmMode.CBC, key, iv).encrypt(value);
		case "AES256 cbc Iv decrypt":
			return new AES256(AES256.AlgorithmMode.CBC, key, iv).decrypt(value);
		case "RSA encrypt":
			return new RSA(keyPair).encrypt(value);
		case "RSA decrypt":
			return new RSA(keyPair).decrypt(value);
		default:
			return "not available method";
		}
	}

}

@Data
class ThreadParamInfo {
	
	private String name;
	private String state;
	private long threadId;

	public boolean hasAnyValue() {
		return StringUtils.length(name) > 0 || StringUtils.length(state) > 0 || threadId > 0;
	}
}

