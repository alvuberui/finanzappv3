package com.finanzapp.tags.service.impl;

import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class MovementsClientImpl {

    private final RestClient movementsRestClient;

    public MovementsClientImpl(RestClient movementsRestClient) {
        this.movementsRestClient = movementsRestClient;
    }

    public void updateMovementsWhenTagIsDeleted(String bearerToken, Long tagId) {
        movementsRestClient
                .put()
                .uri("/movement/movements/updateMovementTags/{tagId}", tagId)
                .header("Authorization", "Bearer " + bearerToken)
                .retrieve()
                .onStatus(HttpStatusCode::isError, (req, res) -> {
                    throw new IllegalStateException(
                            "Error llamando a updateMovementTags. Status: " + res.getStatusCode()
                    );
                })
                .toBodilessEntity();
    }
}
