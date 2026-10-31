package com.finanzapp.movements.service.domain;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class MonthDashboard {

    Integer month;

    String monthName;

    Double idealAmount;

    Double realAmount;
}
