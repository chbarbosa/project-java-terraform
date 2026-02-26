package com.pjtf.payments;

import java.net.URI;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sqs.SqsClient;

@Configuration
public class SqsConfig {

    @Value("${aws.sqs.endpoint}")
    private String sqsEndpoint;

    @Value("${AWS_ACCESS_KEY_ID:test}")
    private String accessKey;

    @Value("${AWS_SECRET_ACCESS_KEY:test}")
    private String secretKey;

    @Bean
    @Primary
    public SqsClient sqsClient() 
    {System.out.println(">>> Starting SQS Endpoint: " + sqsEndpoint);
        return SqsClient.builder()
                .endpointOverride(URI.create(sqsEndpoint)) 
                .region(Region.US_EAST_1)
                .credentialsProvider(StaticCredentialsProvider.create(
                    AwsBasicCredentials.create(accessKey, secretKey)))
                .build();
    }
}
