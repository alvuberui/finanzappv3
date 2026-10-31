package com.finanzapp.movements.controller.dto;

import com.finanzapp.movements.service.domain.MovementType;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UpdateMovementDto {

    private String userEmail;

    private MovementType movementType;

    private Double amount;

    private LocalDate date;

    private Long tagId;

    private String description;
}
