package com.finanzapp.movements.controller;


import com.finanzapp.movements.controller.dto.*;
import com.finanzapp.movements.controller.mapper.MovementMapper;
import com.finanzapp.movements.service.MovementService;
import com.finanzapp.movements.service.impl.MovementTagsEnricher;
import lombok.Builder;
import org.apache.coyote.Response;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/movements")
@Builder
public class MovementController {

    private final MovementService movementService;

    private final MovementMapper movementMapper;

    private final MovementTagsEnricher movementTagsEnricher;


    @GetMapping("/allYears")
    public ResponseEntity<List<Integer>> getAllYears(
            @AuthenticationPrincipal Jwt jwt) {

        String email = jwt.getClaimAsString("email");

        List<Integer> response = movementService.getYearsFromMovements(email);

        return ResponseEntity.ok(response);
    }

    @GetMapping()
    public ResponseEntity<List<MovementResponseDto>> getMovementsByUserEmailAndDateBetweenOrderByDate(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("from") LocalDate from,
            @RequestParam("to") LocalDate to) {

        String email = jwt.getClaimAsString("email");
        String bearerToken = jwt.getTokenValue();

        List<MovementResponseDto> response = movementMapper.toMovementDtoList(
                movementService.getMovementsByUserEmailAndDateBetweenOrderByDate(email, from, to)
        );

        response = movementTagsEnricher.enrich(response, bearerToken);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/tag/{tagId}")
    public ResponseEntity<List<MovementResponseDto>> getMovementsByUserEmailAndDateBetweenOrderByDateFilterByTag(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("from") LocalDate from,
            @RequestParam("to") LocalDate to,
            @PathVariable Long tagId) {

        String email = jwt.getClaimAsString("email");

        String bearerToken = jwt.getTokenValue();

        List<MovementResponseDto> response = movementMapper.toMovementDtoList(
                movementService.getMovementsByUserEmailAndDateBetweenOrderByDateFilterByTagId(email, from, to, tagId)
        );

        response = movementTagsEnricher.enrich(response, bearerToken);

        return ResponseEntity.ok(response);
    }



    @GetMapping("/anual")
    public ResponseEntity<AnualMovementResponseDto> getMovementsByUserEmailMovementTypeAndDateBetweenOrderByDate(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("from") LocalDate from,
            @RequestParam("to") LocalDate to,
            @RequestParam("metric") String metric
    ) {
        String tokenValue = jwt.getTokenValue();
        String email = jwt.getClaimAsString("email");

        AnualMovementResponseDto response = movementMapper.toAnualMovementResponseDto(
                movementService.getAnualMovementDashboard(
                        email,
                        metric,
                        from,
                        to,
                        tokenValue
                )
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/anual/{tagId}")
    public ResponseEntity<AnualMovementResponseDto> getMovementsByUserEmailMovementTypeAndDateBetweenOrderByDateFilterByTagId(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("from") LocalDate from,
            @RequestParam("to") LocalDate to,
            @RequestParam("metric") String metric,
            @PathVariable Long tagId
    ) {
        String tokenValue = jwt.getTokenValue();
        String email = jwt.getClaimAsString("email");

        AnualMovementResponseDto response = movementMapper.toAnualMovementResponseDto(
                movementService.getAnualMovementDashboardFilterByTagId(
                        email,
                        metric,
                        from,
                        to,
                        tokenValue,
                        tagId
                )
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/historical")
    public ResponseEntity<HistoricalMovementResponseDto> getAnualDashboardMovement(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("metric") String metric
    ) {
        String tokenValue = jwt.getTokenValue();
        String email = jwt.getClaimAsString("email");

        HistoricalMovementResponseDto response = movementMapper.toHistoricalMovementResponseDto(
                movementService.getHistoricalMovements(
                        email,
                        metric,
                        tokenValue
                )
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/historical/{tagId}")
    public ResponseEntity<HistoricalMovementResponseDto> getAnualDashboardMovement(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("metric") String metric,
            @PathVariable Long tagId
    ) {
        String tokenValue = jwt.getTokenValue();
        String email = jwt.getClaimAsString("email");

        HistoricalMovementResponseDto response = movementMapper.toHistoricalMovementResponseDto(
                movementService.getHistoricalMovementsFilterByTagId(
                        email,
                        metric,
                        tokenValue,
                        tagId
                )
        );
        return ResponseEntity.ok(response);
    }

    @PostMapping()
    public ResponseEntity<MovementResponseDto> createMovement(@RequestBody CreateMovementDto createMovementDto, @AuthenticationPrincipal Jwt jwt) {
        String email = jwt.getClaimAsString("email");

        MovementResponseDto response = movementMapper.toMovementDto(
                movementService.createMovement(
                        movementMapper.toCreateMovementRequest(createMovementDto),email, jwt.getTokenValue() )
        );

        return ResponseEntity.ok(response);
        
    }

    @PutMapping("/{id}")
    public ResponseEntity<MovementResponseDto> updateMovement(
            @PathVariable Long id,
            @RequestBody UpdateMovementDto updateMovementDto,
            @AuthenticationPrincipal Jwt jwt
    ) {
        String email = jwt.getClaimAsString("email");

        MovementResponseDto response = movementMapper.toMovementDto(
                movementService.updateMovement(
                        id,
                        movementMapper.toUpdateMovementRequest(updateMovementDto),
                        email, jwt.getTokenValue()
                )
        );

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<MovementResponseDto> getMovementById(
            @PathVariable Long id,
            @AuthenticationPrincipal Jwt jwt
    ) {
        String email = jwt.getClaimAsString("email");

        MovementResponseDto response = movementMapper.toMovementDto(
                movementService.getMovementById(id, email)
        );

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity deleteMovementById(
            @PathVariable Long id,
            @AuthenticationPrincipal Jwt jwt
    ) {
        String email = jwt.getClaimAsString("email");

        movementService.deleteMovementById(id, email);

        return ResponseEntity.ok().build();
    }

    @PutMapping("/updateMovementTags/{tagId}")
    public ResponseEntity<Void> updateMovementTagsOnTagDeletion(
            @PathVariable Long tagId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        String email = jwt.getClaimAsString("email");
        movementService.updateMovementsWhenTagIsDeleted(email, tagId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/savings")
    public ResponseEntity<Double> getActualTotalSavings(
            @AuthenticationPrincipal Jwt jwt
    ) {
        String email = jwt.getClaimAsString("email");
        String tokenValue = jwt.getTokenValue();

        Double response = movementService.getActualTotalSavings(email, tokenValue);

        return ResponseEntity.ok(response);
    }
}
