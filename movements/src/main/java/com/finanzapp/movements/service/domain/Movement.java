package com.finanzapp.movements.service.domain;


import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Movement {

    private Long id;

    private String userEmail;

    private MovementType movementType;

    private Double amount;

    private LocalDate date;

    private Long tagId;

    private String description;
}
