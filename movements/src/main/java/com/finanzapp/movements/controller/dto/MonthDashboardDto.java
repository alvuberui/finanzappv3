package com.finanzapp.movements.controller.dto;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class MonthDashboardDto {

    Integer month;

    String monthName;

    Double idealAmount;

    Double realAmount;
}
