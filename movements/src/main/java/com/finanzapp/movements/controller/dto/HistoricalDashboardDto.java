package com.finanzapp.movements.controller.dto;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class HistoricalDashboardDto {

    Integer year;

    Double idealAmount;

    Double realAmount;
}
