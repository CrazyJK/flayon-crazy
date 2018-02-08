package jk.kamoru.flayon.web.security;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;

import jk.kamoru.flayon.web.BaseException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/user")
public class UserController {
	
	private static final String ListView      = "user/list";
	private static final String DetailView    = "user/user";
	private static final String ProfileView   = "user/profile";
	
	@Autowired UserRepository userRepository;

	@ModelAttribute("allRoles")
	public Role[] allRoles() {
		 return Role.values();
	}
	
	@RequestMapping({"", "/list"})
    public String list(Model model) {
		model.addAttribute(userRepository.findAll());
		return ListView;
    }

	@RequestMapping("/new")
	public String newUser(Model model) {
		log.debug("new user form");
		model.addAttribute(new User());
		return DetailView;
	}

	@RequestMapping("/profile")
	public String profile(Model model, @AuthenticationPrincipal User user) {
		log.debug("profile {}", user);
		model.addAttribute("user", userRepository.getOne(user.getId()));
		return ProfileView;
	}

	@RequestMapping(value="/profile", method=RequestMethod.POST)
	public String profileSave(@Valid User user, BindingResult bindingResult) {
		log.debug("profile save {}", user);
		
		if (bindingResult.hasErrors()) {
			log.warn("valid error {}", bindingResult);
			return "/user/profile";
		}
		
		userRepository.save(user);
		return "redirect:/user/profile";
	}

	@RequestMapping(value="/{id}", method=RequestMethod.GET)
	public String view(Model model, @PathVariable Long id) {
		log.debug("view {}", id);
		User findOne = userRepository.getOne(id);
		if (findOne == null) {
			throw new BaseException("User not found");
		}
		model.addAttribute(findOne);
		return DetailView;
	}

	@RequestMapping(value="/{id}", method=RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deleteById(@PathVariable Long id) {
		log.info("deleteById {}", id);
		userRepository.delete(id);
	}

	@RequestMapping(method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void save(@Valid User user) {
		log.info("save {}", user);
		userRepository.save(user);
	}

}
