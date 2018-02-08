package jk.kamoru.flayon.base.security;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import jk.kamoru.flayon.base.error.BaseException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/user")
public class UserController {
	
	private static final String ListView      = "user/list";
	private static final String DetailView    = "user/user";
	private static final String ProfileView   = "user/profile";
	private static final String Redirect_List = "redirect:/user";
	
	@Autowired UserRepository userRepository;

	@RequestMapping
    public String list(Model model) {
		model.addAttribute(userRepository.findAll());
		return ListView;
    }

	@RequestMapping(method=RequestMethod.POST)
	public String postUser(@Valid User user, BindingResult result) {
		log.debug("save user {}", user);
		if (result.hasErrors()) {
			log.warn("save user : valid error. {}", result);
			return ListView;
		}
		userRepository.save(user);
		return Redirect_List;
	}

	@RequestMapping(method=RequestMethod.PUT)
	public User putUser(@Valid User user, BindingResult result) {
		log.debug("save user {}", user);
		if (result.hasErrors()) {
			log.warn("save user : valid error. {}", result);
			return null;
		}
		return userRepository.save(user);
	}

	@RequestMapping(method=RequestMethod.DELETE)
	public String deleteUser(@ModelAttribute User user) {
		log.debug("delete user {}", user);
		userRepository.delete(user);
		return Redirect_List;
	}


	@RequestMapping(value="/{id}", method=RequestMethod.GET)
	public String getUserList(Model model, @PathVariable Long id) {
		log.debug("getUserList {}", id);
		if (id == 0) {
			User user = new User();
			user.setId(new Long(0));
			model.addAttribute(user);
		}
		else {
			User findOne = userRepository.findOne(id);
			if (findOne == null) {
				throw new BaseException("User not found");
			}
			model.addAttribute(findOne);
		}
		model.addAttribute("allRoles", User.Role.values());
		return DetailView;
	}
	
	@RequestMapping(value="/{id}", method=RequestMethod.POST)
	public String editUser(@Valid User user, BindingResult result, @PathVariable Long id, Model model) {
		log.info("edit user {}", user);
		if (result.hasErrors()) {
			log.warn("edit user : valid error. {}", result);
			model.addAttribute("allRoles", User.Role.values());
			return DetailView;
		}
		userRepository.save(user);
		return Redirect_List;
	}
	
	@RequestMapping(value="/{id}", method=RequestMethod.DELETE)
	public String deleteUser(@PathVariable Long id) {
		log.debug("delete user id = {}", id);
		userRepository.delete(id);
		return Redirect_List;
	}

	@RequestMapping("/profile")
	public String profile(Model model, @AuthenticationPrincipal FlayOnUser flayonUser) {
		if (log.isDebugEnabled())
			log.debug("profile userdetails {}", flayonUser);
		model.addAttribute(userRepository.getOne(flayonUser.getUser().getId()));
		return ProfileView;
	}
	
	@RequestMapping(value="/profile", method=RequestMethod.POST)
	public String editProfile(@Valid User user, BindingResult result) {
		log.debug("edit profile {}", user);
		if (result.hasErrors()) {
			log.warn("edit profile : valid error. {}", result);
			return ProfileView;
		}
		userRepository.save(user);
		return ProfileView;
	}
	
}
