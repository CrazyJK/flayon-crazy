package jk.kamoru.flayon.base.access;

import java.util.Arrays;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.core.context.SecurityContextImpl;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.util.StringUtils;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.resource.ResourceHttpRequestHandler;

import jk.kamoru.flayon.base.security.FlayOnUser;
import jk.kamoru.flayon.base.security.User;
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
public class HandlerAccessLogger implements HandlerInterceptor {

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
		request.setAttribute("startTime", new Long(System.currentTimeMillis()));
		return true;
	}

	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
	}

	@Override
	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
		getAccesslog(request, response, handler, null, ex);
	}

	private void getAccesslog(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView, Exception ex) {
		long startTime = (Long)request.getAttribute("startTime");
		long elapsedtime = System.currentTimeMillis() - startTime;

		String handlerlInfo = "";
		// for Controller
		if (handler instanceof org.springframework.web.method.HandlerMethod) {
			HandlerMethod method = (HandlerMethod) handler;
			handlerlInfo = String.format("%s.%s", method.getBean().getClass().getSimpleName(), method.getMethod().getName());
		} 
		// for static resources. No additional information
		else if (handler instanceof ResourceHttpRequestHandler) {
			// do nothing
		}
		// another handler 
		else {
			handlerlInfo = String.format("%s", handler);
		}

		// for modelAndView
		String modelAndViewInfo = "";
		if (modelAndView != null) {
			String viewName = modelAndView.getViewName();
			String modelNames = Arrays.toString(modelAndView.getModel().keySet().toArray(new String[0]));
			modelAndViewInfo = String.format("view=%s model=%s", viewName, modelNames);
		}
		
		String exceptionInfo = "";
		if (ex != null) {
			exceptionInfo = "Error : " + ex.getMessage();
		}
		
		// user
		User user = null;
		SecurityContextImpl securityContext = (SecurityContextImpl) request.getSession().getAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY);
		if (securityContext != null) {
			FlayOnUser flayOnUser = (FlayOnUser)securityContext.getAuthentication().getPrincipal();
			user = flayOnUser.getUser();
		}
		String contentType = trim(response.getContentType());
		String requestUri = request.getRequestURI();
		int status = response.getStatus();
		AccessLog accessLog = new AccessLog(
				new Date(),
				request.getRemoteAddr(),
				request.getMethod(), 
				requestUri,
				contentType,
				elapsedtime,
				handlerlInfo,
				exceptionInfo,
				modelAndViewInfo,
				user,
				status);

		if (useAccesslogRepository)
			accessLogRepository.save(accessLog);
		
		if (!(contentType.startsWith("image") || requestUri.contains("ping.json") || handlerlInfo.startsWith("ImageController.image")))
			log.info(accessLog.toLogString());
	}

	private String trim(String str) {
		return str == null ? "" : StringUtils.trimWhitespace(str);
	}
}
