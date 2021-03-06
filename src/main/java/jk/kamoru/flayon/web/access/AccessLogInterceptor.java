package jk.kamoru.flayon.web.access;

import java.util.Arrays;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.MDC;
import org.springframework.security.core.context.SecurityContextImpl;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.util.StringUtils;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import jk.kamoru.flayon.web.security.User;
import lombok.extern.slf4j.Slf4j;

/**
 * handler 완료 시점에 accesslog형식으로 로그에 기록한다.
 * <pre>
 *  <code>@</code>Override
 *  public void addInterceptors(InterceptorRegistry registry) {
 *  	registry.addInterceptor(new HandlerAccessLogger().setRepository(AccessLogRepository accessLogRepository, boolean useAccesslogRepository));
 *  }
 * </pre>
 * @author kamoru
 *
 */
@Slf4j
public class AccessLogInterceptor implements HandlerInterceptor {

	private static final String MDC_STARTTIME = "StartTime";
	private static final String MDC_USERNAME  = "Username";
	
	private AccessLogRepository accessLogRepository;
	private boolean useAccesslogRepository;

	/**
	 * 엑세스 로그 repository 설정
	 * @param accessLogRepository repository
	 * @param useAccesslogRepository 사용여부
	 * @return
	 */
	public HandlerInterceptor setRepository(AccessLogRepository accessLogRepository, boolean useAccesslogRepository) {
		this.accessLogRepository = accessLogRepository;
		this.useAccesslogRepository = useAccesslogRepository;
		log.debug("use Accesslog Repository = {}, {}", useAccesslogRepository, accessLogRepository);
		return this;
	}
	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		MDC.put(MDC_STARTTIME, Long.toString(System.currentTimeMillis()));
		User user = getUser(request);
		if (user != null) {
			MDC.put(MDC_USERNAME, user.getName());
		}
		return true;
	}

	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
	}

	@Override
	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
		getAccesslog(request, response, handler, null, ex);
		MDC.clear();
	}

	private void getAccesslog(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView, Exception ex) {
		final long startTime = Long.parseLong(MDC.get(MDC_STARTTIME));

		Date   logDate     = new Date();
		String remoteAddr  = request.getRemoteAddr();
		String reqMethod   = request.getMethod();
		String requestUri  = request.getRequestURI();
		String contentType = trim(response.getContentType());
		long   elapsedtime = System.currentTimeMillis() - startTime;
		String handlerInfo = "";
		String exceptionInfo = ex == null ? "" : ex.getMessage();
		String modelAndViewInfo = "";
		User   user        = getUser(request);
		int    status      = response.getStatus();

		// for handlerInfo
		if (handler instanceof org.springframework.web.method.HandlerMethod) { // for Controller
			HandlerMethod method = (HandlerMethod) handler;
			handlerInfo = String.format("%s.%s", method.getBean().getClass().getSimpleName(), method.getMethod().getName());
		} 
		else if (handler instanceof org.springframework.web.servlet.resource.ResourceHttpRequestHandler) { // for static resources. No additional information
			// do nothing
		}
		else { // another handler
			handlerInfo = String.format("%s", handler);
		}

		if (contentType.startsWith("image")
				|| handlerInfo.startsWith("ImageController.image")
				|| handlerInfo.startsWith("RestImageController.getImageInfoByPath")
				|| requestUri.contains("ping")
				|| requestUri.startsWith("/js")
				|| requestUri.startsWith("/css")
				|| requestUri.startsWith("/webjars")) {
			return;
		}
		
		// for modelAndView
		if (modelAndView != null) {
			String viewName = modelAndView.getViewName();
			String modelNames = Arrays.toString(modelAndView.getModel().keySet().toArray(new String[0]));
			modelAndViewInfo = String.format("view=%s model=%s", viewName, modelNames);
		}
		
		AccessLog accessLog = new AccessLog(
				logDate,
				remoteAddr,
				reqMethod, 
				requestUri,
				contentType,
				elapsedtime,
				handlerInfo,
				exceptionInfo,
				modelAndViewInfo,
				user,
				status);
		
		if (useAccesslogRepository)
			accessLogRepository.save(accessLog);
		
		log.info(accessLog.toLogString());
	}

	private User getUser(HttpServletRequest request) {
		SecurityContextImpl securityContext = (SecurityContextImpl) request.getSession().getAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY);
		if (securityContext != null)
			return (User) securityContext.getAuthentication().getPrincipal();
		return null;
	}
	
	private String trim(String str) {
		return str == null ? "" : StringUtils.trimWhitespace(str);
	}
}
