package com.finanzapp.user.controller;

import com.finanzapp.user.controller.dto.BooleanRespondeDto;
import com.finanzapp.user.controller.dto.CreateUserRequestDto;
import com.finanzapp.user.controller.mapper.CommonObjectMapper;
import com.finanzapp.user.service.UserService;
import jakarta.validation.Valid;
import lombok.Builder;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@Builder
public class UserController {

    private final UserService userService;

    private final CommonObjectMapper commonObjectMapper;

    @GetMapping("/isOnboarded")
    public ResponseEntity<BooleanRespondeDto> isUserOnboarded(@RequestParam("email") String email) {
        BooleanRespondeDto response = commonObjectMapper.toBooleanRespondeDto(userService.hasOnBoarded(email));
        return ResponseEntity.ok(response);
    }

    @PostMapping("/")
    public ResponseEntity<Void> createUser(@Valid @RequestBody CreateUserRequestDto requestDto) {
        userService.createUser(
                commonObjectMapper.toCreateUserRequest(requestDto)
        );
        return ResponseEntity.ok().build();
    }
}
