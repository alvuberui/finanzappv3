package com.finanzapp.movements.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

@Configuration
public class TagsClientConfig {

    @Bean
    RestClient tagsRestClient(@Value("${services.tags.base-url}") String baseUrl) {
        var rf = new SimpleClientHttpRequestFactory();
        rf.setConnectTimeout(2000);
        rf.setReadTimeout(3000);

        return RestClient.builder()
                .baseUrl(baseUrl)
                .requestFactory(rf)
                .build();
    }
}

