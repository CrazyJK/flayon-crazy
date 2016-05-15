package jk.kamoru.crazy;

import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.lang.StringUtils;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.WebAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@Slf4j
@RequestMapping("/auth") 
public class AuthController extends AbstractController {
	
	private static final Object LOCAL_PASS = "crazyjk";
	private static final String LOCAL = "127.0.0.1 localhost 0:0:0:0:0:0:0:1 ";
	
	@RequestMapping("/login") 
	public String loginForm(Model model, Locale locale, HttpSession session, HttpServletRequest request,
			@RequestParam(value="error", required=false, defaultValue="false") boolean error) {
		
		if (error) {
			AuthenticationException exception = (AuthenticationException)session.getAttribute(WebAttributes.AUTHENTICATION_EXCEPTION);
			if (exception != null)
				model.addAttribute("exception", exception);
		}
		String servername = LOCAL + request.getServerName();
		String remoteAddr = request.getRemoteAddr();
		boolean local = StringUtils.contains(servername, remoteAddr);
		if (local)
			model.addAttribute("passwd", LOCAL_PASS);
		model.addAttribute("error", error);
		model.addAttribute(locale);

		log.info("show login form. servername={} remoreAddr={} isLocal={}", servername, remoteAddr, local);

		return "auth/loginForm";
	}

	@RequestMapping("/accessDenied")
	public String accessDenied() {
		log.warn("show access denied page");
		return "auth/accessDenied";
	}
	
	@RequestMapping("/expiredSession")
	public String expiredSession() {
		log.warn("show expired session page");
		return "auth/expiredSession";
	}

	@RequestMapping("/invalidSession")
	public String invalidSession() {
		log.warn("show invalid session page");
		return "auth/invalidSession";
	}
}
